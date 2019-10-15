import CoreLocation
import RideOsCommon
import RideOsDriver
import RideOsTestHelpers
import RxSwift
import RxTest
import XCTest

class DefaultOnlineViewModelTest: ReactiveTestCase {
    private static let deviceLocation = CLLocation(latitude: 42, longitude: 42)

    private static let pickupAction = VehiclePlanAction(
        destination: CLLocationCoordinate2D(latitude: 1,longitude: 2),
        actionType: .driveToPickup,
        tripResourceInfo: TripResourceInfo(numberOfPassengers: 4, nameOfTripRequester: "test_name")
    )
    private static let pickupWaypoint = VehiclePlan.Waypoint(taskId: "task_id",
                                                             stepIds: ["pickup_step_id"],
                                                             action: DefaultOnlineViewModelTest.pickupAction)
    
    private static let loadResourceAction = VehiclePlanAction(
        destination: CLLocationCoordinate2D(latitude: 1, longitude: 2),
        actionType: .loadResource,
        tripResourceInfo: TripResourceInfo(numberOfPassengers: 4, nameOfTripRequester: "test_name")
    )
    
    private static let loadResourceWaypoint = VehiclePlan.Waypoint(
        taskId: "task_id",
        stepIds: ["load_resource_step_id"],
        action: DefaultOnlineViewModelTest.loadResourceAction
    )

    private static let dropoffAction = VehiclePlanAction(
        destination: CLLocationCoordinate2D(latitude: 3, longitude: 4),
        actionType: .driveToDropoff,
        tripResourceInfo: TripResourceInfo(numberOfPassengers: 4, nameOfTripRequester: "test_name")
    )
    private static let dropoffWaypoint = VehiclePlan.Waypoint(taskId: "task_id",
                                                              stepIds: ["dropoff_step_id"],
                                                              action: DefaultOnlineViewModelTest.dropoffAction)

    private var viewModelUnderTest: OnlineViewModel!
    private var recordingGoOfflineListener: RecordingGoOfflineListener!
    private var recordingVehicleStateSynchronizer: RecordingVehicleStateSynchronizer!
    private var stateRecorder: TestableObserver<OnlineViewState>!

    func setUp(withPlan plan: VehiclePlan, synchronizeVehicleStateCompletable: Completable = Completable.empty()) {
        super.setUp()
        recordingGoOfflineListener = RecordingGoOfflineListener()
        recordingVehicleStateSynchronizer = RecordingVehicleStateSynchronizer(
            synchronizeVehicleStateCompletable: synchronizeVehicleStateCompletable
        )

        let deviceLocation = DefaultOnlineViewModelTest.deviceLocation
        viewModelUnderTest = DefaultOnlineViewModel(
            goOfflineListener: recordingGoOfflineListener,
            driverPlanInteractor: FixedDriverPlanInteractor(vehiclePlan: plan),
            vehicleStateSynchronizer: recordingVehicleStateSynchronizer,
            userStorageReader: UserDefaultsUserStorageReader(
                userDefaults: TemporaryUserDefaults(stringValues: [CommonUserStorageKeys.userId: "user id"])
            ),
            deviceLocator: FixedDeviceLocator(deviceLocation: deviceLocation),
            schedulerProvider: TestSchedulerProvider(scheduler: scheduler),
            logger: ConsoleLogger()
        )
        stateRecorder = scheduler.record(viewModelUnderTest.getOnlineViewState())

        assertNil(viewModelUnderTest, after: { self.viewModelUnderTest = nil })
    }

    func testViewModelReflectsExpectedInitialState() {
        setUp(withPlan: VehiclePlan(waypoints: []))

        scheduler.advanceTo(1)

        XCTAssertEqual(stateRecorder.events, [
            next(1, .idle),
        ])
    }

    func testGoOfflineCallsListener() {
        setUp(withPlan: VehiclePlan(waypoints: []))

        viewModelUnderTest.didGoOffline()

        XCTAssertEqual(recordingGoOfflineListener.methodCalls, ["didGoOffline()"])
    }

    func testGettingPlanWithPickupStepTransitionsToDriveToPickup() {
        setUp(withPlan: VehiclePlan(waypoints: [DefaultOnlineViewModelTest.pickupWaypoint]))

        scheduler.advanceTo(4)

        XCTAssertEqual(stateRecorder.events, [
            next(1, .idle),
            next(4, .drivingToPickup(waypoint: DefaultOnlineViewModelTest.pickupWaypoint)),
        ])
    }

    func testGettingPlanWithLoadResourceStepTransitionsToWaitingForPassenger() {
        setUp(withPlan: VehiclePlan(waypoints: [DefaultOnlineViewModelTest.loadResourceWaypoint]))

        scheduler.advanceTo(4)

        XCTAssertEqual(stateRecorder.events, [
            next(1, .idle),
            next(4, .waitingForPassenger(waypoint: DefaultOnlineViewModelTest.loadResourceWaypoint)),
        ])
    }

    func testGettingPlanWithDropoffStepTransitionsToDriveToDropoff() {
        setUp(withPlan: VehiclePlan(waypoints: [DefaultOnlineViewModelTest.dropoffWaypoint]))

        scheduler.advanceTo(4)

        XCTAssertEqual(stateRecorder.events, [
            next(1, .idle),
            next(4, .drivingToDropoff(waypoint: DefaultOnlineViewModelTest.dropoffWaypoint)),
        ])
    }

    func testViewModelPeriodicallySynchronizesVehicleState() {
        setUp(withPlan: VehiclePlan(waypoints: []))

        scheduler.advanceTo(5)

        XCTAssertEqual(recordingVehicleStateSynchronizer.methodCalls,
                       [
                           "synchronizeVehicleState(vehicleId:vehicleCoordinate:vehicleHeading:)",
                           "synchronizeVehicleState(vehicleId:vehicleCoordinate:vehicleHeading:)",
                       ])
    }
    
    func testViewModelContinuesSynchronizingVehicleStateAfterEncounteringAnError() {
        let error = NSError(domain: "test_error_domain", code: 0, userInfo: nil)
        
        setUp(withPlan: VehiclePlan(waypoints: []), synchronizeVehicleStateCompletable: Completable.error(error))
        
        scheduler.advanceTo(5)
        
        XCTAssertEqual(recordingVehicleStateSynchronizer.methodCalls,
                       [
                        "synchronizeVehicleState(vehicleId:vehicleCoordinate:vehicleHeading:)",
                        "synchronizeVehicleState(vehicleId:vehicleCoordinate:vehicleHeading:)",
            ])
    }
}
