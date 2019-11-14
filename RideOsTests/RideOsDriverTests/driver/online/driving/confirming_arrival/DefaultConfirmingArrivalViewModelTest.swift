import CoreLocation
import RideOsCommon
import RideOsDriver
import RideOsTestHelpers
import RxTest
import XCTest

class DefaultConfirmingArrivalViewModelTest: ReactiveTestCase {
    private static let destination = CLLocationCoordinate2D(latitude: 42, longitude: 42)
    private static let contactInfo = ContactInfo(name: "test_name")
    private static let tripResourceInfo = TripResourceInfo(numberOfPassengers: 1, contactInfo: contactInfo)
    private static let action = VehiclePlanAction(destination: destination,
                                                  actionType: .driveToDropoff,
                                                  tripResourceInfo: tripResourceInfo)
    private static let destinationWaypoint = VehiclePlan.Waypoint(taskId: "test_task_id",
                                                                  stepIds: [""],
                                                                  action: action)
    private static let passengerTextProvider: TripResourceInfo.PassengerTextProvider = {
        "requester_name: \($0.contactInfo.name!), number_of_passengers: \($0.numberOfPassengers)"
    }
    private static let style = DefaultConfirmingArrivalViewModel.Style(
        passengerTextProvider: passengerTextProvider,
        destinationIcon:  DrawableMarkerIcons.pickupPin(),
        vehicleIcon: DrawableMarkerIcons.car()
    )
    private static let deviceLocation = CLLocation(latitude: 1, longitude: 1)


    private var echoGeocodeInteractor: EchoGeocodeInteractor!
    private var recordingDriverVehicleInteractor: FixedDriverVehicleInteractor!
    private var viewModelUnderTest: DefaultConfirmingArrivalViewModel!
    private var addressTextRecorder: TestableObserver<String>!
    private var mapStateProviderRecorder: MapStateProviderRecorder!
    private var stateRecorder: TestableObserver<ConfirmingArrivalViewState>!
    
    func setUp(finishStepsError: Error?) {
        super.setUp()

        recordingDriverVehicleInteractor = FixedDriverVehicleInteractor(finishStepsError: finishStepsError)
        echoGeocodeInteractor = EchoGeocodeInteractor(scheduler: scheduler)
        
        viewModelUnderTest =
            DefaultConfirmingArrivalViewModel(
                destinationWaypoint: DefaultConfirmingArrivalViewModelTest.destinationWaypoint,
                deviceLocator: FixedDeviceLocator(deviceLocation: DefaultConfirmingArrivalViewModelTest.deviceLocation),
                driverVehicleInteractor: recordingDriverVehicleInteractor,
                geocodeInteractor: echoGeocodeInteractor, userStorageReader: UserDefaultsUserStorageReader(
                    userDefaults:TemporaryUserDefaults(stringValues: [CommonUserStorageKeys.userId: "user id"])
                ),
                style: DefaultConfirmingArrivalViewModelTest.style,
                schedulerProvider: TestSchedulerProvider(scheduler: scheduler),
                logger: ConsoleLogger()
        )

        addressTextRecorder = scheduler.record(viewModelUnderTest.addressText)

        mapStateProviderRecorder = MapStateProviderRecorder(mapStateProvider: viewModelUnderTest, scheduler: scheduler)
        stateRecorder = scheduler.record(viewModelUnderTest.confirmingArrivalState)
        
        assertNil(viewModelUnderTest, after: { self.viewModelUnderTest = nil })
    }

    func testViewModelReflectsExpectedPassengerText() {
        setUp(finishStepsError: nil)
        
        let expectedPassengerText = DefaultConfirmingArrivalViewModelTest.passengerTextProvider(
            DefaultConfirmingArrivalViewModelTest.tripResourceInfo
        )

        XCTAssertEqual(viewModelUnderTest.passengersText, expectedPassengerText)
    }
    
    func testViewModelReflectsExpectedAddressText() {
        setUp(finishStepsError: nil)
        
        scheduler.start()
        
        XCTAssertEqual(addressTextRecorder.events, [
            next(1, EchoGeocodeInteractor.displayName),
            completed(2),
            ])
    }
    
    func testViewModelReflectsExpectedInitialState() {
        setUp(finishStepsError: nil)
        
        XCTAssertEqual(stateRecorder.events, [
            next(0, .arrivalUnconfirmed),
            ])
    }
    
    func testViewModelReflectsConfirmingArrivalAfterConfirmArrivalIsCalled() {
        setUp(finishStepsError: nil)
        
        viewModelUnderTest.confirmArrival()
        
        scheduler.advanceTo(1)
        
        XCTAssertEqual(recordingDriverVehicleInteractor.methodCalls, ["finishSteps(vehicleId:taskId:stepIds:)"])
        
        XCTAssertEqual(stateRecorder.events, [
            next(0, .arrivalUnconfirmed),
            next(1, .confirmingArrival),
            ])
    }
    
    func testViewModelReflectsArrivalConfirmedAfterConfirmingArrivalSucceeds() {
        setUp(finishStepsError: nil)
        
        viewModelUnderTest.confirmArrival()
        
        scheduler.start()
        
        XCTAssertEqual(stateRecorder.events, [
            next(0, .arrivalUnconfirmed),
            next(1, .confirmingArrival),
            next(2, .confirmedArrival),
            ])
    }
    
    func testViewModelReflectsFailingToConfirmArrivalAfterConfirmArrivalWithRetryFails() {
        setUp(finishStepsError: NSError(domain: "", code: 0, userInfo: nil))
        
        viewModelUnderTest.confirmArrival()
        
        scheduler.start()
        
        XCTAssertEqual(stateRecorder.events, [
            next(0, .arrivalUnconfirmed),
            next(1, .confirmingArrival),
            next(6, .failedToConfirmArrival),
            ])
    }
    
    func testViewModelDoesNotTryToConfirmArrivalAgainIfAlreadyConfirmedArrival() {
        setUp(finishStepsError: nil)
        
        viewModelUnderTest.confirmArrival()
        
        scheduler.advanceTo(2)
        
        viewModelUnderTest.confirmArrival()
        
        scheduler.advanceTo(3)
        
        XCTAssertEqual(stateRecorder.events, [
            next(0, .arrivalUnconfirmed),
            next(1, .confirmingArrival),
            next(2, .confirmedArrival),
            ])
    }

    func testViewModelDoesNotShowUserLocationOnMap() {
        setUp(finishStepsError: nil)
        
        XCTAssertEqual(mapStateProviderRecorder.mapSettingsRecorder.events, [
            next(0, MapSettings(shouldShowUserLocation: false)),
            completed(0),
        ])
    }

    func testViewModelFitsCurrentLocationAndDestinationLocationOnMap() {
        setUp(finishStepsError: nil)
        
        let expectedLatLngBounds = LatLngBounds(containingCoordinates: [
            DefaultConfirmingArrivalViewModelTest.deviceLocation.coordinate,
            DefaultConfirmingArrivalViewModelTest.destination
            ])
        
        scheduler.start()
        
        XCTAssertEqual(mapStateProviderRecorder.cameraUpdateRecorder.events, [
            next(0, CameraUpdate.fitLatLngBounds(expectedLatLngBounds)),
            completed(0),
            ])
    }
    
    func testViewModelShowsVehicleAndDestinationMarkerOnMap() {
        setUp(finishStepsError: nil)
        
        scheduler.start()
        
        XCTAssertEqual(mapStateProviderRecorder.markerRecorder.events, [
            next(1, [
                "vehicle": DrawableMarker(coordinate: DefaultConfirmingArrivalViewModelTest.deviceLocation.coordinate,
                                          heading: DefaultConfirmingArrivalViewModelTest.deviceLocation.course,
                                          icon: DefaultConfirmingArrivalViewModelTest.style.vehicleIcon),
                "destination": DrawableMarker(coordinate: DefaultConfirmingArrivalViewModelTest.destination,
                                              icon: DefaultConfirmingArrivalViewModelTest.style.destinationIcon),
                ]),
            completed(2),
            ])
    }
}
