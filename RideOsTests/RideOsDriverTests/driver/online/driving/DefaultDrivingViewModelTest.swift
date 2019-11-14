import CoreLocation
import RideOsCommon
import RideOsDriver
import RideOsTestHelpers
import RxTest
import XCTest

class DefaultDrivingModelTest: ReactiveTestCase {
    private static let destination = CLLocationCoordinate2D(latitude: 42, longitude: 42)

    private var viewModelUnderTest: DrivingViewModel!
    private var stateRecorder: TestableObserver<DrivingViewState>!

    func setUp(withInitialStep step: DrivingViewState.Step) {
        super.setUp()

        viewModelUnderTest = DefaultDrivingViewModel(destination: DefaultDrivingModelTest.destination,
                                                     initialStep: step,
                                                     schedulerProvider: TestSchedulerProvider(scheduler: scheduler),
                                                     logger: ConsoleLogger())
        stateRecorder = scheduler.record(viewModelUnderTest.drivingViewState)

        assertNil(viewModelUnderTest, after: { self.viewModelUnderTest = nil })
    }

    func testViewModelReflectsExpectedInitialState() {
        let expectedInitialStep: DrivingViewState.Step = .drivePending
        setUp(withInitialStep: expectedInitialStep)

        scheduler.start()

        XCTAssertEqual(stateRecorder.events, [
            next(0, DrivingViewState(drivingStep: expectedInitialStep,
                                     destination: DefaultDrivingModelTest.destination)),
        ])
    }

    func testViewModelWithDrivePendingTransitionsToNavigatingOnStartNavigation() {
        setUp(withInitialStep: .drivePending)

        scheduler.scheduleAt(0) { self.viewModelUnderTest.startNavigation() }

        scheduler.start()

        XCTAssertEqual(stateRecorder.events, [
            next(0, DrivingViewState(drivingStep: .drivePending,
                                     destination: DefaultDrivingModelTest.destination)),
            next(1, DrivingViewState(drivingStep: .navigating,
                                     destination: DefaultDrivingModelTest.destination)),
        ])
    }

    func testViewModelThatIsNavigatingTransitionsToConfirmingArrivalOnFinishNavigation() {
        setUp(withInitialStep: .navigating)

        scheduler.scheduleAt(0) { self.viewModelUnderTest.finishedNavigation(didCancelNavigation: false) }

        scheduler.start()

        XCTAssertEqual(stateRecorder.events, [
            next(0, DrivingViewState(drivingStep: .navigating,
                                     destination: DefaultDrivingModelTest.destination)),
            next(1, DrivingViewState(drivingStep: .confirmingArrival(showBackToNavigation: false),
                                     destination: DefaultDrivingModelTest.destination)),
        ])
    }
    
    func testViewModelThatIsNavigatingTransitionsToConfirmingArrivalWithBackToNavigationEnabledOnCancellation() {
        setUp(withInitialStep: .navigating)

        scheduler.scheduleAt(0) { self.viewModelUnderTest.finishedNavigation(didCancelNavigation: true) }

        scheduler.start()

        XCTAssertEqual(stateRecorder.events, [
            next(0, DrivingViewState(drivingStep: .navigating,
                                     destination: DefaultDrivingModelTest.destination)),
            next(1, DrivingViewState(drivingStep: .confirmingArrival(showBackToNavigation: true),
                                     destination: DefaultDrivingModelTest.destination)),
        ])
    }

    func testViewModelWaitingToConfirmArrivalMaintainsSameStateAfterConfirmingArrival() {
        setUp(withInitialStep: .confirmingArrival(showBackToNavigation: false))

        scheduler.scheduleAt(0) { self.viewModelUnderTest.arrivalConfirmed() }

        scheduler.start()

        XCTAssertEqual(stateRecorder.events, [
            next(0, DrivingViewState(drivingStep: .confirmingArrival(showBackToNavigation: false),
                                     destination: DefaultDrivingModelTest.destination)),
        ])
    }
}
