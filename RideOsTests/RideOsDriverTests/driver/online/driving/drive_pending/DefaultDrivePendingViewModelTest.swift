import CoreLocation
import RideOsCommon
import RideOsDriver
import RideOsTestHelpers
import RxTest
import XCTest

class DefaultDrivePendingViewModelTest: ReactiveTestCase {
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
    private static let style = DefaultDrivePendingViewModel.Style(passengerTextProvider: passengerTextProvider,
                                                                  drawablePathWidth: 2.0,
                                                                  drawablePathColor: .green,
                                                                  destinationIcon: DrawableMarkerIcons.pickupPin())
    private static let deviceLocation = CLLocation(latitude: 1, longitude: 1)
    
    private var viewModelUnderTest: DefaultDrivePendingViewModel!
    private var addressTextRecorder: TestableObserver<String>!
    private var mapStateProviderRecorder: MapStateProviderRecorder!

    override func setUp() {
        super.setUp()

        let destinationWaypoint = DefaultDrivePendingViewModelTest.destinationWaypoint
        let deviceLocator = FixedDeviceLocator(deviceLocation: DefaultDrivePendingViewModelTest.deviceLocation)
        let style = DefaultDrivePendingViewModelTest.style
        let routeInteractor = PointToPointRouteInteractor(scheduler: scheduler)
        let geocodeInteractor = EchoGeocodeInteractor(scheduler: scheduler)
        let schedulerProvider = TestSchedulerProvider(scheduler: scheduler)

        viewModelUnderTest = DefaultDrivePendingViewModel(destinationWaypoint: destinationWaypoint,
                                                          style: style,
                                                          deviceLocator: deviceLocator,
                                                          routeInteractor: routeInteractor,
                                                          geocodeInteractor: geocodeInteractor,
                                                          schedulerProvider: schedulerProvider,
                                                          logger: ConsoleLogger())

        addressTextRecorder = scheduler.record(viewModelUnderTest.addressText)

        mapStateProviderRecorder = MapStateProviderRecorder(mapStateProvider: viewModelUnderTest, scheduler: scheduler)

        assertNil(viewModelUnderTest, after: { self.viewModelUnderTest = nil })
    }
    
    func testViewModelReflectsExpectedPassengerText() {
        let expectedPassengerText = DefaultDrivePendingViewModelTest.passengerTextProvider(
            DefaultDrivePendingViewModelTest.tripResourceInfo
        )
        
        XCTAssertEqual(viewModelUnderTest.passengersText, expectedPassengerText)
    }

    func testViewModelReflectsExpectedAddressText() {
        let expectedRouteDetailText = EchoGeocodeInteractor.displayName

        scheduler.start()

        XCTAssertEqual(addressTextRecorder.events, [
            next(1, expectedRouteDetailText),
            completed(2),
        ])
    }

    func testViewModelDoesNotShowUserLocationOnMap() {
        XCTAssertEqual(mapStateProviderRecorder.mapSettingsRecorder.events, [
            next(0, MapSettings(shouldShowUserLocation: false)),
            completed(0),
        ])
    }

    func testViewModelShowsRouteFromDeviceLocationToDestinationBoundsOnMap() {
        let expectedRoute = [
            DefaultDrivePendingViewModelTest.deviceLocation.coordinate,
            DefaultDrivePendingViewModelTest.destination,
        ]

        scheduler.start()

        XCTAssertEqual(mapStateProviderRecorder.cameraUpdateRecorder.events, [
            next(2, CameraUpdate.fitLatLngBounds(LatLngBounds(containingCoordinates: expectedRoute))),
            completed(3),
        ])
    }

    func testViewModelShowsPathForRouteFromDeviceLocationToDestinationOnMap() {
        let expectedRoute = [
            DefaultDrivePendingViewModelTest.deviceLocation.coordinate,
            DefaultDrivePendingViewModelTest.destination,
        ]

        scheduler.start()

        XCTAssertEqual(mapStateProviderRecorder.pathRecorder.events, [
            .next(2, [DrawablePath(coordinates: expectedRoute,
                                   width: DefaultDrivePendingViewModelTest.style.drawablePathWidth,
                                   color: DefaultDrivePendingViewModelTest.style.drawablePathColor)]),
            .completed(3),
        ])
    }

    func testViewModelShowsDestinationMarkerOnMap() {
        scheduler.start()

        XCTAssertEqual(mapStateProviderRecorder.markerRecorder.events, [
            .next(2, [
                "vehicle": DrawableMarker(coordinate: DefaultDrivePendingViewModelTest.deviceLocation.coordinate,
                                          heading: DefaultDrivePendingViewModelTest.deviceLocation.course,
                                          icon: DefaultDrivePendingViewModelTest.style.vehicleIcon),
                "destination": DrawableMarker(coordinate: DefaultDrivePendingViewModelTest.destination,
                                              icon: DefaultDrivePendingViewModelTest.style.destinationIcon),
            ]),
            .completed(3),
        ])
    }
}
