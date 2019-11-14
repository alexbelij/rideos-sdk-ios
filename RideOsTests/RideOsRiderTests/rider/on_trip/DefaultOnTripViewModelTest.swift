import CoreLocation
import Cuckoo
import Foundation
import RideOsCommon
import RideOsTestHelpers
import RideOsRider
import RxSwift
import RxTest
import XCTest

class DefaultOnTripViewModelTest: ReactiveTestCase {
    static let currentTaskId = "current_trip_id"
    static let newTaskId = "new_trip_id"
    static let newPickupLocation = DesiredAndAssignedLocation(
        desiredLocation: NamedTripLocation(
            tripLocation: TripLocation(location: CLLocationCoordinate2D(latitude: 1, longitude: 1)),
            displayName: "new pickup"
        )
    )
    static let newDropoffLocation = DesiredAndAssignedLocation(
        desiredLocation: NamedTripLocation(
            tripLocation: TripLocation(location: CLLocationCoordinate2D(latitude: 4, longitude: 4)),
            displayName: "new dropoff"
        )
    )
    static let existingPickupLocation = DesiredAndAssignedLocation(
        desiredLocation: NamedTripLocation(
            tripLocation: TripLocation(location: CLLocationCoordinate2D(latitude: 2, longitude: 2)),
            displayName: "existing pickup"
        )
    )
    static let existingDropoffLocation = DesiredAndAssignedLocation(
        desiredLocation: NamedTripLocation(
            tripLocation: TripLocation(location: CLLocationCoordinate2D(latitude: 3, longitude: 3)),
            displayName: "existing dropoff"
        )
    )

    var viewModelUnderTest: DefaultOnTripViewModel!
    var tripInteractor: MockTripInteractor!
    var displayStateRecorder: TestableObserver<OnTripDisplayState>!
    var tripFinishedListener: RecordingTripFinishedListener!

    func setUp(editPickupResponse: Observable<String>, editDropoffResponse: Observable<String>) {
        super.setUp()

        tripInteractor = MockTripInteractor()
        
        stub(tripInteractor) { stub in
            when(stub.editPickup(tripId: any(), newPickupLocation: any())).thenReturn(editPickupResponse)
            when(stub.editDropoff(tripId: any(), newDropoffLocation: any())).thenReturn(editDropoffResponse)
        }
        
        tripFinishedListener = RecordingTripFinishedListener()
        viewModelUnderTest = DefaultOnTripViewModel(
            tripId: DefaultOnTripViewModelTest.currentTaskId,
            tripFinishedListener: tripFinishedListener,
            tripInteractor: tripInteractor,
            schedulerProvider: TestSchedulerProvider(scheduler: scheduler),
            logger: ConsoleLogger()
        )

        displayStateRecorder = scheduler.record(viewModelUnderTest.displayState)

        assertNil(viewModelUnderTest, after: { self.viewModelUnderTest = nil })
    }

    func testInitialDisplayStateIsCurrentTrip() {
        setUp(editPickupResponse: Observable.empty(),
              editDropoffResponse: Observable.error(TripInteractorError.invalidResponse))
        scheduler.start()

        XCTAssertEqual(displayStateRecorder.events, [.next(0, .currentTrip)])
    }

    func testEditPickupTransitionsDisplayStateToEditingPickup() {
        setUp(editPickupResponse: Observable.empty(),
              editDropoffResponse: Observable.error(TripInteractorError.invalidResponse))
        scheduler.scheduleAt(1) {
            self.viewModelUnderTest.editPickup(
                existingPickupLocation: DefaultOnTripViewModelTest.existingPickupLocation,
                existingDropoffLocation: DefaultOnTripViewModelTest.existingDropoffLocation
            )
        }
        scheduler.start()

        XCTAssertEqual(displayStateRecorder.events, [
            .next(0, .currentTrip),
            .next(2, .editingPickup(existingPickupLocation: DefaultOnTripViewModelTest.existingPickupLocation,
                                    existingDropoffLocation: DefaultOnTripViewModelTest.existingDropoffLocation))
        ])
    }
    
    func testEditDropoffTransitionsDisplayStateToEditingPickup() {
        setUp(editPickupResponse: Observable.empty(),
              editDropoffResponse: Observable.error(TripInteractorError.invalidResponse))
        scheduler.scheduleAt(1) {
            self.viewModelUnderTest.editDropoff(
                existingPickupLocation: DefaultOnTripViewModelTest.existingPickupLocation,
                existingDropoffLocation: DefaultOnTripViewModelTest.existingDropoffLocation
            )
        }
        scheduler.start()

        XCTAssertEqual(displayStateRecorder.events, [
            .next(0, .currentTrip),
            .next(2, .editingDropoff(existingPickupLocation: DefaultOnTripViewModelTest.existingPickupLocation,
                                     existingDropoffLocation: DefaultOnTripViewModelTest.existingDropoffLocation))
        ])
    }

    func testCancelSetPickupTransitionsDisplayStateBackToCurrentTrip() {
        setUp(editPickupResponse: Observable.empty(),
              editDropoffResponse: Observable.error(TripInteractorError.invalidResponse))
        scheduler.scheduleAt(1) {
            self.viewModelUnderTest.editPickup(
                existingPickupLocation: DefaultOnTripViewModelTest.existingPickupLocation,
                existingDropoffLocation: DefaultOnTripViewModelTest.existingDropoffLocation
            )
        }
        scheduler.scheduleAt(2) { self.viewModelUnderTest.cancelSetPickupDropoff() }
        scheduler.start()

        XCTAssertEqual(displayStateRecorder.events, [
            .next(0, .currentTrip),
            .next(2, .editingPickup(existingPickupLocation: DefaultOnTripViewModelTest.existingPickupLocation,
                                    existingDropoffLocation: DefaultOnTripViewModelTest.existingDropoffLocation)),
            .next(3, .currentTrip)
        ])
    }

    func testSetPickupTransitionsStateToUpdatingPickupAndCallsTaskInteractorEditPickup() {
        setUp(editPickupResponse: Observable.just(DefaultOnTripViewModelTest.newTaskId),
              editDropoffResponse: Observable.error(TripInteractorError.invalidResponse))
        scheduler.scheduleAt(1) {
            self.viewModelUnderTest.editPickup(
                existingPickupLocation: DefaultOnTripViewModelTest.existingPickupLocation,
                existingDropoffLocation: DefaultOnTripViewModelTest.existingDropoffLocation
            )
        }
        scheduler.scheduleAt(2) {
            self.viewModelUnderTest.set(
                pickup: PreTripLocation(desiredAndAssignedLocation: DefaultOnTripViewModelTest.newPickupLocation,
                                        wasConfirmed: true),
                dropoff: PreTripLocation(desiredAndAssignedLocation: DefaultOnTripViewModelTest.existingDropoffLocation,
                                         wasConfirmed: true)
            )
        }
        scheduler.start()

        XCTAssertEqual(displayStateRecorder.events, [
            .next(0, .currentTrip),
            .next(2, .editingPickup(existingPickupLocation: DefaultOnTripViewModelTest.existingPickupLocation,
                                    existingDropoffLocation: DefaultOnTripViewModelTest.existingDropoffLocation)),
            .next(3, .updatingPickup(newPickupLocation: DefaultOnTripViewModelTest.newPickupLocation))
        ])

        verify(tripInteractor, times(1)).editPickup(
            tripId: equal(to: DefaultOnTripViewModelTest.currentTaskId),
            newPickupLocation: equal(to: DefaultOnTripViewModelTest.newPickupLocation.namedTripLocation.tripLocation)
        )
    }
    
    func testSetDropoffTransitionsStateToUpdatingPickupAndCallsTaskInteractorEditPickup() {
        setUp(editPickupResponse: Observable.error(TripInteractorError.invalidResponse),
              editDropoffResponse: Observable.just(DefaultOnTripViewModelTest.newTaskId))
        scheduler.scheduleAt(1) {
            self.viewModelUnderTest.editDropoff(
                existingPickupLocation: DefaultOnTripViewModelTest.existingPickupLocation,
                existingDropoffLocation: DefaultOnTripViewModelTest.existingDropoffLocation
            )
        }
        scheduler.scheduleAt(2) {
            self.viewModelUnderTest.set(
                pickup: PreTripLocation(desiredAndAssignedLocation: DefaultOnTripViewModelTest.existingPickupLocation,
                                        wasConfirmed: true),
                dropoff: PreTripLocation(desiredAndAssignedLocation: DefaultOnTripViewModelTest.newDropoffLocation,
                                         wasConfirmed: true)
            )
        }
        scheduler.start()

        XCTAssertEqual(displayStateRecorder.events, [
            .next(0, .currentTrip),
            .next(2, .editingDropoff(existingPickupLocation: DefaultOnTripViewModelTest.existingPickupLocation,
                                     existingDropoffLocation: DefaultOnTripViewModelTest.existingDropoffLocation)),
            .next(3, .updatingDropoff(newDropoffLocation: DefaultOnTripViewModelTest.newDropoffLocation))
        ])

        verify(tripInteractor, times(1)).editDropoff(
            tripId: equal(to: DefaultOnTripViewModelTest.currentTaskId),
            newDropoffLocation: equal(to: DefaultOnTripViewModelTest.newDropoffLocation.namedTripLocation.tripLocation)
        )
    }

    func testTaskInteractorEditPickupErrorTransitionsBackToCurrentTrip() {
        setUp(editPickupResponse: Observable.error(TripInteractorError.invalidResponse),
              editDropoffResponse: Observable.error(TripInteractorError.invalidResponse))
        scheduler.scheduleAt(1) {
            self.viewModelUnderTest.editPickup(
                existingPickupLocation: DefaultOnTripViewModelTest.existingPickupLocation,
                existingDropoffLocation: DefaultOnTripViewModelTest.existingDropoffLocation
            )
        }
        scheduler.scheduleAt(2) {
            self.viewModelUnderTest.set(
                pickup: PreTripLocation(desiredAndAssignedLocation: DefaultOnTripViewModelTest.newPickupLocation,
                                        wasConfirmed: true),
                dropoff: PreTripLocation(desiredAndAssignedLocation: DefaultOnTripViewModelTest.existingDropoffLocation,
                                         wasConfirmed: true)
            )
        }
        scheduler.start()

        XCTAssertEqual(displayStateRecorder.events, [
            .next(0, .currentTrip),
            .next(2, .editingPickup(existingPickupLocation: DefaultOnTripViewModelTest.existingPickupLocation,
                                    existingDropoffLocation: DefaultOnTripViewModelTest.existingDropoffLocation)),
            .next(3, .updatingPickup(newPickupLocation: DefaultOnTripViewModelTest.newPickupLocation)),
            .next(5, .currentTrip)
        ])
    }
    
    func testTaskInteractorEditDropoffErrorTransitionsBackToCurrentTrip() {
        setUp(editPickupResponse: Observable.error(TripInteractorError.invalidResponse),
              editDropoffResponse: Observable.error(TripInteractorError.invalidResponse))
        scheduler.scheduleAt(1) {
            self.viewModelUnderTest.editDropoff(
                existingPickupLocation: DefaultOnTripViewModelTest.existingPickupLocation,
                existingDropoffLocation: DefaultOnTripViewModelTest.existingDropoffLocation
            )
        }
        scheduler.scheduleAt(2) {
            self.viewModelUnderTest.set(
                pickup: PreTripLocation(desiredAndAssignedLocation: DefaultOnTripViewModelTest.existingPickupLocation,
                                        wasConfirmed: true),
                dropoff: PreTripLocation(desiredAndAssignedLocation: DefaultOnTripViewModelTest.newDropoffLocation,
                                         wasConfirmed: true)
            )
        }
        scheduler.start()

        XCTAssertEqual(displayStateRecorder.events, [
            .next(0, .currentTrip),
            .next(2, .editingDropoff(existingPickupLocation: DefaultOnTripViewModelTest.existingPickupLocation,
                                     existingDropoffLocation: DefaultOnTripViewModelTest.existingDropoffLocation)),
            .next(3, .updatingDropoff(newDropoffLocation: DefaultOnTripViewModelTest.newDropoffLocation)),
            .next(5, .currentTrip)
        ])
    }

    func testCallingTripFinishedCallsTripFinishedListener() {
        setUp(editPickupResponse: Observable.empty(),
              editDropoffResponse: Observable.error(TripInteractorError.invalidResponse))
        scheduler.start()

        viewModelUnderTest.tripFinished()

        XCTAssertEqual(tripFinishedListener.methodCalls, ["tripFinished()"])
    }
}

class RecordingTripFinishedListener: MethodCallRecorder, TripFinishedListener {
    func tripFinished() {
        recordMethodCall(#function)
    }
}
