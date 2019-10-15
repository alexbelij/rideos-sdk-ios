import CoreLocation
import RideOsCommon
import RideOsDriver
import RideOsTestHelpers
import RxTest
import XCTest

class DefaultWaitingForPickupViewModelTest: ReactiveTestCase {
    private static let pickupLocationCoordinate = CLLocationCoordinate2D(latitude: 42, longitude: 42)
    private static let tripResourceInfo = TripResourceInfo(numberOfPassengers: 2, nameOfTripRequester: "test_name")
    private static let action = VehiclePlanAction(destination: pickupLocationCoordinate,
                                                  actionType: .loadResource,
                                                  tripResourceInfo: tripResourceInfo)
    private static let pickupWaypoint = VehiclePlan.Waypoint(taskId: "test_task_id",
                                                                  stepIds: [""],
                                                                  action: action)
    private static let deviceLocation = CLLocation(latitude: 1, longitude: 1)
    
    private static let passengerPickupTextProvider: DefaultWaitingForPickupViewModel.PassengerPickupTextProvider = {
        "requester_name: \($0.nameOfTripRequester), number_of_passengers: \($0.numberOfPassengers)"
    }
    
    private static let style = DefaultWaitingForPickupViewModel.Style(
        passengerPickupTextProvider: passengerPickupTextProvider,
        pickupLocationIcon: DrawableMarkerIcons.pickupPin(),
        vehicleIcon: DrawableMarkerIcons.car()
    )
    
    private var viewModelUnderTest: DefaultWaitingForPickupViewModel!
    private var recordingDriverVehicleInteractor: FixedDriverVehicleInteractor!
    private var mapStateProviderRecorder: MapStateProviderRecorder!
    private var stateRecorder: TestableObserver<ConfirmingPickupViewState>!
    
    func setUp(finishStepsError: Error?) {
        super.setUp()
        
        recordingDriverVehicleInteractor = FixedDriverVehicleInteractor(finishStepsError: finishStepsError)
        
        viewModelUnderTest = DefaultWaitingForPickupViewModel(
            pickupWaypoint: DefaultWaitingForPickupViewModelTest.pickupWaypoint,
            driverVehicleInteractor: recordingDriverVehicleInteractor,
            userStorageReader: UserDefaultsUserStorageReader(
                userDefaults:TemporaryUserDefaults(stringValues: [CommonUserStorageKeys.userId: "user id"])
            ),
            deviceLocator: FixedDeviceLocator(deviceLocation: DefaultWaitingForPickupViewModelTest.deviceLocation),
            style: DefaultWaitingForPickupViewModelTest.style,
            schedulerProvider: TestSchedulerProvider(scheduler: scheduler),
            logger: ConsoleLogger()
        )
        
        mapStateProviderRecorder = MapStateProviderRecorder(mapStateProvider: viewModelUnderTest, scheduler: scheduler)
        stateRecorder = scheduler.record(viewModelUnderTest.confirmingPickupState)
        
        assertNil(viewModelUnderTest, after: { self.viewModelUnderTest = nil })
    }
    
    func testViewModelReflectsExpectedPassengerPickupText() {
        setUp(finishStepsError: nil)
        
        let expectedPassengerPickupText =
            DefaultWaitingForPickupViewModelTest.passengerPickupTextProvider(
                DefaultWaitingForPickupViewModelTest.tripResourceInfo
        )
        
        XCTAssertEqual(viewModelUnderTest.passengersToPickupText, expectedPassengerPickupText)
    }
    
    func testViewModelReflectsExpectedInitialState() {
        setUp(finishStepsError: nil)
        
        XCTAssertEqual(stateRecorder.events, [
            next(0, .pickupUnconfirmed),
            ])
    }
    
    func testViewModelReflectsConfirmingPickupAfterConfirmPickupIsCalled() {
        setUp(finishStepsError: nil)
        
        viewModelUnderTest.confirmPickup()
        
        scheduler.advanceTo(1)
        
        XCTAssertEqual(recordingDriverVehicleInteractor.methodCalls, ["finishSteps(vehicleId:taskId:stepIds:)"])
        
        XCTAssertEqual(stateRecorder.events, [
            next(0, .pickupUnconfirmed),
            next(1, .confirmingPickup),
            ])
    }
    
    func testViewModelReflectsPickupConfirmedAfterConfirmingPickupSucceeds() {
        setUp(finishStepsError: nil)
        
        viewModelUnderTest.confirmPickup()
        
        scheduler.start()
        
        XCTAssertEqual(stateRecorder.events, [
            next(0, .pickupUnconfirmed),
            next(1, .confirmingPickup),
            next(2, .confirmedPickup),
            ])
    }
    
    func testViewModelReflectsFailingToConfirmPickupAfterConfirmPickupWithRetryFails() {
        setUp(finishStepsError: NSError(domain: "", code: 0, userInfo: nil))
        
        viewModelUnderTest.confirmPickup()
        
        scheduler.start()
        
        XCTAssertEqual(stateRecorder.events, [
            next(0, .pickupUnconfirmed),
            next(1, .confirmingPickup),
            next(6, .failedToConfirmPickup),
            ])
    }
    
    func testViewModelDoesNotTryToConfirmPickupAgainIfAlreadyConfirmedPickup() {
        setUp(finishStepsError: nil)
        
        viewModelUnderTest.confirmPickup()
        
        scheduler.advanceTo(2)
        
        viewModelUnderTest.confirmPickup()
        
        scheduler.advanceTo(3)
        
        XCTAssertEqual(stateRecorder.events, [
            next(0, .pickupUnconfirmed),
            next(1, .confirmingPickup),
            next(2, .confirmedPickup),
            ])
    }
    
    func testViewModelDoesNotShowUserLocationOnMap() {
        setUp(finishStepsError: nil)
        
        XCTAssertEqual(mapStateProviderRecorder.mapSettingsRecorder.events, [
            next(0, MapSettings(shouldShowUserLocation: false)),
            completed(0),
            ])
    }
    
    func testViewModelFitsCurrentLocationAndPickupLocationOnMap() {
        setUp(finishStepsError: nil)
        
        let expectedLatLngBounds = LatLngBounds(containingCoordinates: [
            DefaultWaitingForPickupViewModelTest.deviceLocation.coordinate,
            DefaultWaitingForPickupViewModelTest.pickupLocationCoordinate
            ])
        
        scheduler.start()
        
        XCTAssertEqual(mapStateProviderRecorder.cameraUpdateRecorder.events, [
            next(0, CameraUpdate.fitLatLngBounds(expectedLatLngBounds)),
            completed(0),
            ])
    }

    func testViewModelShowsVehicleAndPickupLocationMarkersOnMap() {
        setUp(finishStepsError: nil)
        
        scheduler.start()

        XCTAssertEqual(mapStateProviderRecorder.markerRecorder.events, [
            .next(0, [
                "vehicle": DrawableMarker(coordinate: DefaultWaitingForPickupViewModelTest.deviceLocation.coordinate,
                                          heading: DefaultWaitingForPickupViewModelTest.deviceLocation.course,
                                          icon: DefaultWaitingForPickupViewModelTest.style.vehicleIcon),
                "pickup": DrawableMarker(coordinate: DefaultWaitingForPickupViewModelTest.pickupLocationCoordinate,
                                         icon: DefaultWaitingForPickupViewModelTest.style.pickupLocationIcon),
                ]),
            .completed(0),
            ])
    }
}
