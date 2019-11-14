import CoreLocation
import Cuckoo
import Foundation
import RideOsCommon
import RideOsTestHelpers
import RideOsRider
import RxTest
import XCTest

class DefaultSetPickupDropoffViewModelTest: ReactiveTestCase {
    private static let pickup = PreTripLocation(
        desiredAndAssignedLocation: DesiredAndAssignedLocation(
            desiredLocation: NamedTripLocation(
                tripLocation: TripLocation(location: CLLocationCoordinate2D(latitude: 1, longitude: 2)),
                displayName: "pickup"
            )
        ),
        wasConfirmed: false
    )
    
    private static let confirmedPickup = PreTripLocation(
        desiredAndAssignedLocation: DefaultSetPickupDropoffViewModelTest.pickup.desiredAndAssignedLocation,
        wasConfirmed: true
    )

    private static let dropoff = PreTripLocation(
        desiredAndAssignedLocation: DesiredAndAssignedLocation(
            desiredLocation: NamedTripLocation(
                tripLocation: TripLocation(location: CLLocationCoordinate2D(latitude: 3, longitude: 4)),
                displayName: "dropoff"
            )
        ),
        wasConfirmed: false
    )
    
    private static let confirmedDropoff = PreTripLocation(
        desiredAndAssignedLocation: DefaultSetPickupDropoffViewModelTest.dropoff.desiredAndAssignedLocation,
        wasConfirmed: true
    )

    private static let enablePickupSearch = true
    private static let enableDropoffSearch = true
    private static let expectedSearchingForPickupDropoffState =
        SetPickupDropOffDisplayState.Step.searchingForPickupDropoff(
            enablePickupSearch: DefaultSetPickupDropoffViewModelTest.enablePickupSearch,
            enableDropoffSearch: DefaultSetPickupDropoffViewModelTest.enableDropoffSearch
    )

    var viewModelUnderTest: DefaultSetPickupDropoffViewModel!
    var listener: MockSetPickupDropoffListener!
    var recorder: TestableObserver<SetPickupDropOffDisplayState>!

    func setUp(initialPickup: PreTripLocation?,
               initialDropoff: PreTripLocation?,
               initialFocus: LocationSearchFocusType) {
        super.setUp()
        
        listener = MockSetPickupDropoffListener()
        stub(listener) { stub in
            when(stub.cancelSetPickupDropoff()).thenDoNothing()
            when(stub.set(pickup: any(), dropoff: any())).thenDoNothing()
        }
        
        viewModelUnderTest = DefaultSetPickupDropoffViewModel(
            listener: listener,
            initialPickup: initialPickup,
            initialDropoff: initialDropoff,
            initialFocus: initialFocus,
            enablePickupSearch: DefaultSetPickupDropoffViewModelTest.enablePickupSearch,
            enableDropoffSearch: DefaultSetPickupDropoffViewModelTest.enableDropoffSearch,
            schedulerProvider: TestSchedulerProvider(scheduler: scheduler),
            logger: ConsoleLogger()
        )
        recorder = scheduler.createObserver(SetPickupDropOffDisplayState.self)

        viewModelUnderTest.getDisplayState()
            .asDriver(onErrorJustReturn: SetPickupDropOffDisplayState(
                step: DefaultSetPickupDropoffViewModelTest.expectedSearchingForPickupDropoffState,
                pickup: nil,
                dropoff: nil,
                focus: .none
            ))
            .drive(recorder)
            .disposed(by: disposeBag)

        assertNil(viewModelUnderTest, after: { self.viewModelUnderTest = nil })
    }

    func testInitialSetPickupDropOffDisplayStateWithNoInitialPickupOrDropoffMatchesExpectedState() {
        setUp(initialPickup: nil, initialDropoff: nil, initialFocus: .dropoff)

        scheduler.start()

        XCTAssertEqual(recorder.events, [
            next(0, SetPickupDropOffDisplayState(
                step: DefaultSetPickupDropoffViewModelTest.expectedSearchingForPickupDropoffState,
                pickup: nil,
                dropoff: nil,
                focus: .dropoff
            ))
        ])

        verifyNoMoreInteractions(listener)
    }

    func testInitialSetPickupDropOffDisplayStateWithInitialPickupAndDropoffMatchesExpectedState() {
        setUp(initialPickup: DefaultSetPickupDropoffViewModelTest.pickup,
              initialDropoff: DefaultSetPickupDropoffViewModelTest.dropoff,
              initialFocus: .dropoff)

        scheduler.start()

        XCTAssertEqual(recorder.events, [
            next(0,
                 SetPickupDropOffDisplayState(
                    step: DefaultSetPickupDropoffViewModelTest.expectedSearchingForPickupDropoffState,
                    pickup: DefaultSetPickupDropoffViewModelTest.pickup,
                    dropoff: DefaultSetPickupDropoffViewModelTest.dropoff,
                    focus: .dropoff
                )
            )
        ])
        
        verifyNoMoreInteractions(listener)
    }

    func testSettingPickupTransitionsToExpectedSetPickupDropoffDisplayState() {
        setUp(initialPickup: nil, initialDropoff: nil, initialFocus: .pickup)

        scheduler.scheduleAt(1) {
            self.viewModelUnderTest.selectPickup(
                DefaultSetPickupDropoffViewModelTest
                    .pickup
                    .desiredAndAssignedLocation
                    .namedTripLocation
                    .geocodedLocation
            )
        }
        scheduler.start()

        XCTAssertEqual(recorder.events, [
            next(0, SetPickupDropOffDisplayState(
                step: DefaultSetPickupDropoffViewModelTest.expectedSearchingForPickupDropoffState,
                pickup: nil,
                dropoff: nil,
                focus: .pickup
            )),
            next(2, SetPickupDropOffDisplayState(
                step: DefaultSetPickupDropoffViewModelTest.expectedSearchingForPickupDropoffState,
                pickup: DefaultSetPickupDropoffViewModelTest.pickup,
                dropoff: nil,
                focus: .dropoff
            ))
        ])
        
        verifyNoMoreInteractions(listener)
    }

    func testSettingDropoffTransitionsToExpectedSetPickupDropoffDisplayState() {
        setUp(initialPickup: nil, initialDropoff: nil, initialFocus: .dropoff)

        scheduler.scheduleAt(1) {
            self.viewModelUnderTest.selectDropoff(
                DefaultSetPickupDropoffViewModelTest
                    .dropoff
                    .desiredAndAssignedLocation
                    .namedTripLocation
                    .geocodedLocation
            )
        }
        scheduler.start()

        XCTAssertEqual(recorder.events, [
            next(0, SetPickupDropOffDisplayState(
                step: DefaultSetPickupDropoffViewModelTest.expectedSearchingForPickupDropoffState,
                pickup: nil,
                dropoff: nil,
                focus: .dropoff
            )),
            next(2, SetPickupDropOffDisplayState(
                step: DefaultSetPickupDropoffViewModelTest.expectedSearchingForPickupDropoffState,
                pickup: nil,
                dropoff: DefaultSetPickupDropoffViewModelTest.dropoff,
                focus: .pickup
            ))
        ])

        verifyNoMoreInteractions(listener)
    }

    func testSettingPickupOnMapConfirmingAndThenSelectingDropoffTransitionsToExpectedSetPickupDropoffDisplayState() {
        setUp(initialPickup: nil, initialDropoff: nil, initialFocus: .pickup)

        scheduler.scheduleAt(1) {
            self.viewModelUnderTest.setPickupOnMap()
        }
        scheduler.scheduleAt(2) {
            self.viewModelUnderTest
                .confirmLocation(DefaultSetPickupDropoffViewModelTest.pickup.desiredAndAssignedLocation)
        }

        scheduler.scheduleAt(3) {
            self.viewModelUnderTest.selectDropoff(
                DefaultSetPickupDropoffViewModelTest
                    .dropoff
                    .desiredAndAssignedLocation
                    .namedTripLocation
                    .geocodedLocation
            )
        }

        scheduler.start()

        XCTAssertEqual(recorder.events, [
            next(0, SetPickupDropOffDisplayState(
                step: DefaultSetPickupDropoffViewModelTest.expectedSearchingForPickupDropoffState,
                pickup: nil,
                dropoff: nil,
                focus: .pickup
            )),
            next(1, SetPickupDropOffDisplayState(step: .settingPickupOnMap,
                                                 pickup: nil,
                                                 dropoff: nil,
                                                 focus: .pickup)),
            next(3, SetPickupDropOffDisplayState(step: .settingPickupOnMap,
                                                 pickup: DefaultSetPickupDropoffViewModelTest.confirmedPickup,
                                                 dropoff: nil,
                                                 focus: .dropoff)),
            next(4, SetPickupDropOffDisplayState(
                step: DefaultSetPickupDropoffViewModelTest.expectedSearchingForPickupDropoffState,
                pickup: DefaultSetPickupDropoffViewModelTest.confirmedPickup,
                dropoff: nil,
                focus: .dropoff
            )),
            next(4, SetPickupDropOffDisplayState(
                step: DefaultSetPickupDropoffViewModelTest.expectedSearchingForPickupDropoffState,
                pickup: DefaultSetPickupDropoffViewModelTest.confirmedPickup,
                dropoff: DefaultSetPickupDropoffViewModelTest.dropoff,
                focus: .dropoff
            )),
            next(5, SetPickupDropOffDisplayState(
                step: .confirmingDropoff,
                pickup: DefaultSetPickupDropoffViewModelTest.confirmedPickup,
                dropoff: DefaultSetPickupDropoffViewModelTest.dropoff,
                focus: .dropoff
            ))
        ])

        verifyNoMoreInteractions(listener)
    }

    func testSettingDropoffOnMapAndThenConfirmingTransitionsToConfirmingPickup() {
        setUp(initialPickup: DefaultSetPickupDropoffViewModelTest.pickup, initialDropoff: nil, initialFocus: .dropoff)

        scheduler.scheduleAt(1) { self.viewModelUnderTest.setDropoffOnMap() }
        scheduler.scheduleAt(2) {
            self.viewModelUnderTest
                .confirmLocation(DefaultSetPickupDropoffViewModelTest.dropoff.desiredAndAssignedLocation)
        }
        scheduler.start()

        XCTAssertEqual(recorder.events, [
            next(0, SetPickupDropOffDisplayState(
                step: DefaultSetPickupDropoffViewModelTest.expectedSearchingForPickupDropoffState,
                pickup: DefaultSetPickupDropoffViewModelTest.pickup,
                dropoff: nil,
                focus: .dropoff
            )),
            next(1, SetPickupDropOffDisplayState(
                step: .settingDropoffOnMap,
                pickup: DefaultSetPickupDropoffViewModelTest.pickup,
                dropoff: nil,
                focus: .dropoff
            )),
            next(3, SetPickupDropOffDisplayState(
                step: .settingDropoffOnMap,
                pickup: DefaultSetPickupDropoffViewModelTest.pickup,
                dropoff: DefaultSetPickupDropoffViewModelTest.confirmedDropoff,
                focus: .dropoff
            )),
            next(4, SetPickupDropOffDisplayState(
                step: .confirmingPickup,
                pickup: DefaultSetPickupDropoffViewModelTest.pickup,
                dropoff: DefaultSetPickupDropoffViewModelTest.confirmedDropoff,
                focus: .dropoff
            )),
        ])
        
        verifyNoMoreInteractions(listener)
    }

    func testCancellingLocationSearchCallsCancelSetPickupDropoffOnListener() {
        setUp(initialPickup: nil, initialDropoff: nil, initialFocus: .dropoff)
        scheduler.scheduleAt(1, action: { self.viewModelUnderTest.cancelLocationSearch() })
        scheduler.start()

        verify(listener, times(1)).cancelSetPickupDropoff()
        verifyNoMoreInteractions(listener)
    }

    func testDoneSearchingWithConfirmedLocationsCallsSetPickupDropoffOnListener() {
        setUp(initialPickup: DefaultSetPickupDropoffViewModelTest.confirmedPickup,
              initialDropoff: DefaultSetPickupDropoffViewModelTest.confirmedDropoff,
              initialFocus: .dropoff)
        scheduler.scheduleAt(1, action: { self.viewModelUnderTest.doneSearching() })
        scheduler.start()

        verify(listener, times(1)).set(pickup: equal(to: DefaultSetPickupDropoffViewModelTest.confirmedPickup),
                                       dropoff: equal(to: DefaultSetPickupDropoffViewModelTest.confirmedDropoff))
        verifyNoMoreInteractions(listener)
    }
    
    func testDoneSearchingWithUnconfirmedLocationsThenConfirmingDropoffAndPickupCallsSetPickupDropoffOnListener() {
        setUp(initialPickup: DefaultSetPickupDropoffViewModelTest.pickup,
              initialDropoff: DefaultSetPickupDropoffViewModelTest.dropoff,
              initialFocus: .dropoff)
        scheduler.scheduleAt(1, action: { self.viewModelUnderTest.doneSearching() })
        scheduler.scheduleAt(4, action: {
            self.viewModelUnderTest
                .confirmLocation(DefaultSetPickupDropoffViewModelTest.dropoff.desiredAndAssignedLocation)
        })
        scheduler.scheduleAt(7, action: {
            self.viewModelUnderTest
                .confirmLocation(DefaultSetPickupDropoffViewModelTest.pickup.desiredAndAssignedLocation)
        })
        scheduler.start()
        
        XCTAssertEqual(recorder.events, [
            next(0, SetPickupDropOffDisplayState(
                step: DefaultSetPickupDropoffViewModelTest.expectedSearchingForPickupDropoffState,
                pickup: DefaultSetPickupDropoffViewModelTest.pickup,
                dropoff: DefaultSetPickupDropoffViewModelTest.dropoff,
                focus: .dropoff
            )),
            next(2, SetPickupDropOffDisplayState(
                step: DefaultSetPickupDropoffViewModelTest.expectedSearchingForPickupDropoffState,
                pickup: DefaultSetPickupDropoffViewModelTest.pickup,
                dropoff: DefaultSetPickupDropoffViewModelTest.dropoff,
                focus: .dropoff
            )),
            next(3, SetPickupDropOffDisplayState(
                step: .confirmingDropoff,
                pickup: DefaultSetPickupDropoffViewModelTest.pickup,
                dropoff: DefaultSetPickupDropoffViewModelTest.dropoff,
                focus: .dropoff
            )),
            next(5, SetPickupDropOffDisplayState(
                step: .confirmingDropoff,
                pickup: DefaultSetPickupDropoffViewModelTest.pickup,
                dropoff: DefaultSetPickupDropoffViewModelTest.confirmedDropoff,
                focus: .dropoff
            )),
            next(6, SetPickupDropOffDisplayState(
                step: .confirmingPickup,
                pickup: DefaultSetPickupDropoffViewModelTest.pickup,
                dropoff: DefaultSetPickupDropoffViewModelTest.confirmedDropoff,
                focus: .dropoff
            )),
            next(8, SetPickupDropOffDisplayState(
                step: .confirmingPickup,
                pickup: DefaultSetPickupDropoffViewModelTest.confirmedPickup,
                dropoff: DefaultSetPickupDropoffViewModelTest.confirmedDropoff,
                focus: .dropoff
            )),
        ])

        verify(listener, times(1)).set(pickup: equal(to: DefaultSetPickupDropoffViewModelTest.confirmedPickup),
                                       dropoff: equal(to: DefaultSetPickupDropoffViewModelTest.confirmedDropoff))
        verifyNoMoreInteractions(listener)
    }
}
