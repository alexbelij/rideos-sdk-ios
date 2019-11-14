import Cuckoo
import RideOsCommon
import RideOsTestHelpers
import RideOsRider
import RxSwift
import RxTest
import XCTest

class DefaultMainViewModelTest: ReactiveTestCase {
    private static let tripId = "trip_id"

    var viewModelUnderTest: DefaultMainViewModel!
    var stateRecorder: TestableObserver<MainViewState>!

    func setUp(currentTripSequence: [String?]) {
        super.setUp()
        
        let tripInteractor = MockTripInteractor()
        stub(tripInteractor) { stub in
            var ongoingStub = when(stub.getCurrentTrip(forPassenger: any()))
                .thenReturn(Observable.just(currentTripSequence[0]))
            for trip in currentTripSequence[1...] {
                ongoingStub = ongoingStub.thenReturn(Observable.just(trip))
            }
        }
        
        viewModelUnderTest = DefaultMainViewModel(
            userStorageReader: UserDefaultsUserStorageReader(
                userDefaults: TemporaryUserDefaults(stringValues: [CommonUserStorageKeys.userId: "user id"])
            ),
            tripInteractor: tripInteractor,
            schedulerProvider: TestSchedulerProvider(scheduler: scheduler),
            logger: ConsoleLogger()
        )
        stateRecorder = scheduler.record(viewModelUnderTest.getMainViewState())

        assertNil(viewModelUnderTest, after: { self.viewModelUnderTest = nil })
    }

    func testStartingLocationSearchTransitionsToPreTripState() {
        setUp(currentTripSequence: [nil])
        scheduler.scheduleAt(2) {
            self.viewModelUnderTest.startLocationSearch()
        }

        scheduler.advanceTo(3)

        XCTAssertEqual(stateRecorder.events, [
            next(0, .startScreen),
            next(3, .preTrip),
        ])
    }

    func testTripCreationTransitionsToOnTripState() {
        setUp(currentTripSequence: [nil])
        scheduler.scheduleAt(2) {
            self.viewModelUnderTest.onTripCreated(tripId: DefaultMainViewModelTest.tripId)
        }

        scheduler.advanceTo(3)

        XCTAssertEqual(stateRecorder.events, [
            next(0, .startScreen),
            next(3, .onTrip(tripId: DefaultMainViewModelTest.tripId)),
        ])
    }

    func testCreatingDefaultMainViewModelWhileOnTripTransitionsToOnTripState() {
        setUp(currentTripSequence: [DefaultMainViewModelTest.tripId])

        scheduler.advanceTo(2)

        XCTAssertEqual(stateRecorder.events, [
            next(0, .startScreen),
            next(2, .onTrip(tripId: DefaultMainViewModelTest.tripId)),
        ])
    }

    func testTripEndsButOnTripContinuesUntilTripFinishedIsCalled() {
        setUp(currentTripSequence: [DefaultMainViewModelTest.tripId, nil])
        scheduler.scheduleAt(5) {
            self.viewModelUnderTest.tripFinished()
        }

        scheduler.advanceTo(6)

        XCTAssertEqual(stateRecorder.events, [
            next(0, .startScreen),
            next(2, .onTrip(tripId: DefaultMainViewModelTest.tripId)),
            next(6, .startScreen)
        ])
    }
}
