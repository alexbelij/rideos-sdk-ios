// Copyright 2019 rideOS, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import CoreLocation
import Foundation
import RideOsCommon
import RxSwift

public class DefaultSetPickupDropoffViewModel: SetPickupDropoffViewModel {
    private let disposeBag = DisposeBag()
    private let searchingForPickupDropoffStep: SetPickupDropOffDisplayState.Step
    private let stepSubject: BehaviorSubject<SetPickupDropOffDisplayState.Step>
    private let locationStateStateMachine: StateMachine<LocationState>

    private weak var listener: SetPickupDropoffListener?

    public init(listener: SetPickupDropoffListener,
                initialPickup: PreTripLocation?,
                initialDropoff: PreTripLocation?,
                initialFocus: LocationSearchFocusType,
                enablePickupSearch: Bool,
                enableDropoffSearch: Bool,
                schedulerProvider: SchedulerProvider = DefaultSchedulerProvider(),
                logger: Logger = LoggerDependencyRegistry.instance.logger) {
        self.listener = listener
        searchingForPickupDropoffStep = .searchingForPickupDropoff(enablePickupSearch: enablePickupSearch,
                                                                   enableDropoffSearch: enableDropoffSearch)
        stepSubject = BehaviorSubject<SetPickupDropOffDisplayState.Step>(value: searchingForPickupDropoffStep)
        locationStateStateMachine = StateMachine(
            schedulerProvider: schedulerProvider,
            initialState: LocationState(pickup: initialPickup,
                                        dropoff: initialDropoff,
                                        changedByUser: false,
                                        focus: initialFocus),
            logger: logger
        )

        locationStateStateMachine.observeCurrentState()
            .observeOn(schedulerProvider.mainThread())
            .subscribe(onNext: { [unowned self] locationState in
                if let (pickup, dropoff) = locationState.completedPickupDropoff() {
                    if !dropoff.wasConfirmed {
                        self.stepSubject.onNext(.confirmingDropoff)
                    } else if !pickup.wasConfirmed {
                        self.stepSubject.onNext(.confirmingPickup)
                    } else {
                        self.listener?.set(pickup: pickup, dropoff: dropoff)
                    }
                } else {
                    self.stepSubject.onNext(self.searchingForPickupDropoffStep)
                }
            })
            .disposed(by: disposeBag)
    }

    public func getDisplayState() -> Observable<SetPickupDropOffDisplayState> {
        return Observable
            .combineLatest(stepSubject, locationStateStateMachine.observeCurrentState())
            .distinctUntilChanged { $0 == $1 }
            .map { step, locationState in
                SetPickupDropOffDisplayState(step: step,
                                             pickup: locationState.pickup,
                                             dropoff: locationState.dropoff,
                                             focus: locationState.focus)
            }
    }

    private func getCurrentStep() -> SetPickupDropOffDisplayState.Step {
        do {
            return try stepSubject.value()
        } catch {
            fatalError("Unable to fetch current step")
        }
    }

    public func setPickup(_ pickup: PreTripLocation) {
        locationStateStateMachine.transition { currentState in
            LocationState(pickup: pickup,
                          dropoff: currentState.dropoff,
                          changedByUser: true)
        }
    }

    public func setDropoff(_ dropoff: PreTripLocation) {
        locationStateStateMachine.transition { currentState in
            LocationState(pickup: currentState.pickup,
                          dropoff: dropoff,
                          changedByUser: true)
        }
    }

    private struct LocationState: Equatable {
        let pickup: PreTripLocation?
        let dropoff: PreTripLocation?
        let changedByUser: Bool
        let focus: LocationSearchFocusType

        init(pickup: PreTripLocation?, dropoff: PreTripLocation?, changedByUser: Bool, focus: LocationSearchFocusType) {
            self.pickup = pickup
            self.dropoff = dropoff
            self.changedByUser = changedByUser
            self.focus = focus
        }

        init(pickup: PreTripLocation?,
             dropoff: PreTripLocation?,
             changedByUser: Bool) {
            self.init(pickup: pickup,
                      dropoff: dropoff,
                      changedByUser: changedByUser,
                      focus: pickup == nil && dropoff != nil ? .pickup : .dropoff)
        }

        func completedPickupDropoff() -> (PreTripLocation, PreTripLocation)? {
            if changedByUser, let pickup = pickup, let dropoff = dropoff {
                return (pickup, dropoff)
            }
            return nil
        }
    }
}

// MARK: LocationSearchListener

extension DefaultSetPickupDropoffViewModel: LocationSearchListener {
    public func selectPickup(_ pickup: GeocodedLocationModel) {
        setPickup(
            PreTripLocation(
                desiredAndAssignedLocation: DesiredAndAssignedLocation(
                    desiredLocation: NamedTripLocation(geocodedLocation: pickup)
                ),
                wasConfirmed: false
            )
        )
    }

    public func selectDropoff(_ dropoff: GeocodedLocationModel) {
        setDropoff(
            PreTripLocation(
                desiredAndAssignedLocation: DesiredAndAssignedLocation(
                    desiredLocation: NamedTripLocation(geocodedLocation: dropoff)
                ),
                wasConfirmed: false
            )
        )
    }

    public func setPickupOnMap() {
        stepSubject.onNext(.settingPickupOnMap)
    }

    public func setDropoffOnMap() {
        stepSubject.onNext(.settingDropoffOnMap)
    }

    public func cancelLocationSearch() {
        listener?.cancelSetPickupDropoff()
    }

    public func doneSearching() {
        locationStateStateMachine.transition { currentState in
            LocationState(pickup: currentState.pickup,
                          dropoff: currentState.dropoff,
                          changedByUser: true,
                          focus: currentState.focus)
        }
    }
}

// MARK: ConfirmLocationListener

extension DefaultSetPickupDropoffViewModel: ConfirmLocationListener {
    public func confirmLocation(_ location: DesiredAndAssignedLocation) {
        switch getCurrentStep() {
        case .settingPickupOnMap, .confirmingPickup:
            setPickup(PreTripLocation(desiredAndAssignedLocation: location, wasConfirmed: true))
        case .settingDropoffOnMap, .confirmingDropoff:
            setDropoff(PreTripLocation(desiredAndAssignedLocation: location, wasConfirmed: true))
        default:
            fatalError("\(#function) called on an invalid step")
        }
    }

    public func cancelConfirmLocation() {
        stepSubject.onNext(searchingForPickupDropoffStep)
    }
}
