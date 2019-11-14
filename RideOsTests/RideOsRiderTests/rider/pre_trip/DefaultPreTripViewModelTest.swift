import CoreLocation
import Cuckoo
import RideOsCommon
import RideOsTestHelpers
import RideOsRider
import RxSwift
import RxTest
import XCTest

class DefaultPreTripViewModelTest: ReactiveTestCase {
    private static let tripId = "trip_id"

    private static let initialPreTripState: PreTripState = .selectingPickupDropoff(initialPickupLocation: nil,
                                                                                   initialDropoffLocation: nil,
                                                                                   initialFocus: .dropoff)

    private static let pickupLocation = PreTripLocation(
        desiredAndAssignedLocation: DesiredAndAssignedLocation(
            desiredLocation: NamedTripLocation(
                tripLocation: TripLocation(location: CLLocationCoordinate2D(latitude: 0, longitude: 0)),
                displayName: "pickup"
            )
        ),
        wasConfirmed: false
    )
    
    private static let dropoffLocation = PreTripLocation(
        desiredAndAssignedLocation: DesiredAndAssignedLocation(
            desiredLocation: NamedTripLocation(
                tripLocation: TripLocation(location: CLLocationCoordinate2D(latitude: 1, longitude: 1)),
                displayName: "dropoff"
            )
        ),
        wasConfirmed: false
    )
    
    var viewModelUnderTest: DefaultPreTripViewModel!
    var stateRecorder: TestableObserver<PreTripState>!
    var listener: MockPreTripListener!

    func setUp(enableSeatCountSelection: Bool,
               createTripObservable: Observable<String> = Observable.just(DefaultPreTripViewModelTest.tripId)) {
        super.setUp()

        ResolvedFleet.instance.set(resolvedFleet: FleetInfo.defaultFleetInfo)

        listener = MockPreTripListener()
        stub(listener) { stub in
            when(stub.onTripCreated(tripId: any())).thenDoNothing()
            when(stub.cancelPreTrip()).thenDoNothing()
        }

        let tripInteractor = MockTripInteractor()
        stub(tripInteractor) { stub in
            when(
                stub.createTripForPassenger(passengerId: any(),
                                            contactInfo: any(),
                                            fleetId: any(),
                                            numPassengers: any(),
                                            pickupLocation: any(),
                                            dropoffLocation: any(),
                                            vehicleId: any())
            ).thenReturn(createTripObservable)
            when(stub.cancelTrip(passengerId: any(), tripId: any())).thenReturn(Completable.never())
        }

        viewModelUnderTest = DefaultPreTripViewModel(
            userStorageReader: UserDefaultsUserStorageReader(
                userDefaults: TemporaryUserDefaults(stringValues: [CommonUserStorageKeys.userId: "user id"])
            ),
            tripInteractor: tripInteractor,
            listener: listener,
            enableSeatCountSelection: enableSeatCountSelection,
            schedulerProvider: TestSchedulerProvider(scheduler: scheduler),
            passengerName: Observable.just(""),
            logger: ConsoleLogger()
        )

        stateRecorder = scheduler.createObserver(PreTripState.self)
        viewModelUnderTest.getPreTripState()
            .asDriver(onErrorJustReturn: .selectingPickupDropoff(initialPickupLocation: nil,
                                                                 initialDropoffLocation: nil,
                                                                 initialFocus: .pickup))
            .drive(stateRecorder)
            .disposed(by: disposeBag)

        assertNil(viewModelUnderTest, after: { self.viewModelUnderTest = nil })
    }

    func testInitialStateIsSelectingPickupDropoff() {
        setUp(enableSeatCountSelection: false)
        XCTAssertRecordedElements(stateRecorder.events, [DefaultPreTripViewModelTest.initialPreTripState])
    }

    func testSelectingPickupDropoffTransitionsToConfirmingTrip() {
        setUp(enableSeatCountSelection: false)
        viewModelUnderTest.set(pickup: DefaultPreTripViewModelTest.pickupLocation,
                               dropoff: DefaultPreTripViewModelTest.dropoffLocation)
        scheduler.start()

        XCTAssertRecordedElements(
            stateRecorder.events,
            [
                DefaultPreTripViewModelTest.initialPreTripState,
                .confirmingTrip(
                    confirmedPickupLocation: DefaultPreTripViewModelTest.pickupLocation.desiredAndAssignedLocation,
                    confirmedDropoffLocation: DefaultPreTripViewModelTest.dropoffLocation.desiredAndAssignedLocation
                )
            ]
        )
        verifyNoMoreInteractions(listener)
    }
    func testConfirmingTripTransitionsToConfirmedAndCallsListenerOnTripCreated() {
        setUp(enableSeatCountSelection: false)
        scheduler.scheduleAt(0) {
            self.viewModelUnderTest.set(pickup: DefaultPreTripViewModelTest.pickupLocation,
                                        dropoff: DefaultPreTripViewModelTest.dropoffLocation)
            self.viewModelUnderTest.confirmTrip(selectedVehicle: .automatic)
        }

        scheduler.start()

        XCTAssertEqual(stateRecorder.events, [
            next(0, DefaultPreTripViewModelTest.initialPreTripState),
            next(1, .confirmingTrip(
                confirmedPickupLocation: DefaultPreTripViewModelTest.pickupLocation.desiredAndAssignedLocation,
                confirmedDropoffLocation: DefaultPreTripViewModelTest.dropoffLocation.desiredAndAssignedLocation
            )),
            next(2, .confirmed(
                confirmedPickupLocation: DefaultPreTripViewModelTest.pickupLocation.desiredAndAssignedLocation,
                confirmedDropoffLocation: DefaultPreTripViewModelTest.dropoffLocation.desiredAndAssignedLocation,
                numPassengers: 1,
                selectedVehicle: .automatic
            ))
        ])
        
        verify(listener, times(1)).onTripCreated(tripId: equal(to: DefaultPreTripViewModelTest.tripId))
        verifyNoMoreInteractions(listener)
    }

    func testTripCreationFailureReturnsToConfirmingTripState() {
        setUp(enableSeatCountSelection: false,
              createTripObservable: Observable.error(TripInteractorError.invalidResponse))

        stateRecorder = scheduler.createObserver(PreTripState.self)
        viewModelUnderTest.getPreTripState()
            .asDriver(onErrorJustReturn: .selectingPickupDropoff(initialPickupLocation: nil,
                                                                 initialDropoffLocation: nil,
                                                                 initialFocus: .pickup))
            .drive(stateRecorder)
            .disposed(by: disposeBag)

        scheduler.scheduleAt(0) {
            self.viewModelUnderTest.set(pickup: DefaultPreTripViewModelTest.pickupLocation,
                                        dropoff: DefaultPreTripViewModelTest.dropoffLocation)
            self.viewModelUnderTest.confirmTrip(selectedVehicle: .automatic)
        }

        scheduler.start()

        XCTAssertEqual(stateRecorder.events, [
            next(0, DefaultPreTripViewModelTest.initialPreTripState),
            next(1, .confirmingTrip(
                confirmedPickupLocation: DefaultPreTripViewModelTest.pickupLocation.desiredAndAssignedLocation,
                confirmedDropoffLocation: DefaultPreTripViewModelTest.dropoffLocation.desiredAndAssignedLocation
            )),
            next(2, .confirmed(
                confirmedPickupLocation: DefaultPreTripViewModelTest.pickupLocation.desiredAndAssignedLocation,
                confirmedDropoffLocation: DefaultPreTripViewModelTest.dropoffLocation.desiredAndAssignedLocation,
                numPassengers: 1,
                selectedVehicle: .automatic
            )),
            next(4, .confirmingTrip(
                confirmedPickupLocation: DefaultPreTripViewModelTest.pickupLocation.desiredAndAssignedLocation,
                confirmedDropoffLocation: DefaultPreTripViewModelTest.dropoffLocation.desiredAndAssignedLocation
            ))
        ])

        verifyNoMoreInteractions(listener)
    }

    func testCancelInvokesCancelOnListener() {
        setUp(enableSeatCountSelection: false)
        viewModelUnderTest.cancelSetPickupDropoff()
        verify(listener, times(1)).cancelPreTrip()
    }

    func testCancelConfirmTripTransitionsToSelectingPickupDropoffWithExpectedState() {
        setUp(enableSeatCountSelection: false)
        scheduler.scheduleAt(1, action: {
            self.viewModelUnderTest.set(pickup: DefaultPreTripViewModelTest.pickupLocation,
                                        dropoff: DefaultPreTripViewModelTest.dropoffLocation)
        })
        scheduler.scheduleAt(4, action: {
            self.viewModelUnderTest.cancelConfirmTrip()
        })
        scheduler.start()

        XCTAssertEqual(
            stateRecorder.events,
            [
                next(0, DefaultPreTripViewModelTest.initialPreTripState),
                next(2, .confirmingTrip(
                    confirmedPickupLocation: DefaultPreTripViewModelTest.pickupLocation.desiredAndAssignedLocation,
                    confirmedDropoffLocation: DefaultPreTripViewModelTest.dropoffLocation.desiredAndAssignedLocation
                )),
                next(5, .selectingPickupDropoff(
                    initialPickupLocation: PreTripLocation(
                        desiredAndAssignedLocation: DefaultPreTripViewModelTest.pickupLocation.desiredAndAssignedLocation,
                        wasConfirmed: true
                    ),
                    initialDropoffLocation: PreTripLocation(
                        desiredAndAssignedLocation: DefaultPreTripViewModelTest.dropoffLocation.desiredAndAssignedLocation,
                        wasConfirmed: true
                    ),
                    initialFocus: .dropoff
                ))
            ]
        )
        verifyNoMoreInteractions(listener)
    }

    func testCancelTripRequestCallsCancelPreTripOnListener() {
        setUp(enableSeatCountSelection: false)
        viewModelUnderTest.cancelTripRequest()
        verify(listener, times(1)).cancelPreTrip()
    }

    func testConfirmingTripWithSeatCountSelectionEnabledTransitionsToConfirmingSeatsState() {
        setUp(enableSeatCountSelection: true)
        scheduler.scheduleAt(1) {
            self.viewModelUnderTest.set(
                pickup: DefaultPreTripViewModelTest.pickupLocation,
                dropoff: DefaultPreTripViewModelTest.dropoffLocation
            )
            self.viewModelUnderTest.confirmTrip(selectedVehicle: .automatic)
        }
        scheduler.start()

        XCTAssertEqual(
            stateRecorder.events,
            [
                next(0, DefaultPreTripViewModelTest.initialPreTripState),
                next(
                    2,
                    .confirmingTrip(
                        confirmedPickupLocation: DefaultPreTripViewModelTest.pickupLocation.desiredAndAssignedLocation,
                        confirmedDropoffLocation: DefaultPreTripViewModelTest.dropoffLocation.desiredAndAssignedLocation
                    )
                ),
                next(
                    3,
                    .confirmingSeats(
                        confirmedPickupLocation: DefaultPreTripViewModelTest.pickupLocation.desiredAndAssignedLocation,
                        confirmedDropoffLocation: DefaultPreTripViewModelTest.dropoffLocation.desiredAndAssignedLocation,
                        selectedVehicle: .automatic
                    )
                )
            ]
        )
    }

    func testConfirmingSeatsTransitionsToConfirmedState() {
        let seatCount: UInt32 = 3
        setUp(enableSeatCountSelection: true)
        scheduler.scheduleAt(1) {
            self.viewModelUnderTest.set(
                pickup: DefaultPreTripViewModelTest.pickupLocation,
                dropoff: DefaultPreTripViewModelTest.dropoffLocation
            )
            self.viewModelUnderTest.confirmTrip(selectedVehicle: .automatic)
            self.viewModelUnderTest.confirm(seatCount: seatCount)
        }

        scheduler.start()

        XCTAssertEqual(
            stateRecorder.events,
            [
                next(0, DefaultPreTripViewModelTest.initialPreTripState),
                next(
                    2,
                    .confirmingTrip(
                        confirmedPickupLocation: DefaultPreTripViewModelTest.pickupLocation.desiredAndAssignedLocation,
                        confirmedDropoffLocation: DefaultPreTripViewModelTest.dropoffLocation.desiredAndAssignedLocation
                    )
                ),
                next(
                    3,
                    .confirmingSeats(
                        confirmedPickupLocation: DefaultPreTripViewModelTest.pickupLocation.desiredAndAssignedLocation,
                        confirmedDropoffLocation: DefaultPreTripViewModelTest.dropoffLocation.desiredAndAssignedLocation,
                        selectedVehicle: .automatic
                    )
                ),
                next(
                    4,
                    .confirmed(
                        confirmedPickupLocation: DefaultPreTripViewModelTest.pickupLocation.desiredAndAssignedLocation,
                        confirmedDropoffLocation: DefaultPreTripViewModelTest.dropoffLocation.desiredAndAssignedLocation,
                        numPassengers: seatCount,
                        selectedVehicle: .automatic
                    )
                )
            ]
        )
    }
}
