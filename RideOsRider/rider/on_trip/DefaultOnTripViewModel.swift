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
import RxSwiftExt

public class DefaultOnTripViewModel: OnTripViewModel {
    private static let tripInteractorRepeatBehavior = RepeatBehavior.immediate(maxCount: 5)
    private let disposeBag = DisposeBag()

    private let displayStateMachine: StateMachine<OnTripDisplayState>

    private let tripId: String
    private weak var tripFinishedListener: TripFinishedListener?
    private let tripInteractor: TripInteractor

    public init(tripId: String,
                tripFinishedListener: TripFinishedListener,
                tripInteractor: TripInteractor = DefaultTripInteractor(),
                schedulerProvider: SchedulerProvider = DefaultSchedulerProvider(),
                logger: Logger = LoggerDependencyRegistry.instance.logger) {
        displayStateMachine = StateMachine<OnTripDisplayState>(schedulerProvider: schedulerProvider,
                                                               initialState: .currentTrip,
                                                               logger: logger)
        self.tripId = tripId
        self.tripFinishedListener = tripFinishedListener
        self.tripInteractor = tripInteractor

        displayStateMachine.observeCurrentState()
            .distinctUntilChanged()
            .map(DefaultOnTripViewModel.getUpdatedPickupLocation)
            .filterNil()
            .observeOn(schedulerProvider.io())
            .flatMap { [tripId, tripInteractor] newPickupLocation in
                tripInteractor
                    .editPickup(tripId: tripId, newPickupLocation: newPickupLocation.namedTripLocation.tripLocation)
                    .logErrors(logger: logger)
                    .retry(DefaultOnTripViewModel.tripInteractorRepeatBehavior)
            }
            .subscribe(onError: { [displayStateMachine] _ in
                displayStateMachine.transition { _ in .currentTrip }
            })
            .disposed(by: disposeBag)

        displayStateMachine.observeCurrentState()
            .distinctUntilChanged()
            .map(DefaultOnTripViewModel.getUpdatedDropoffLocation)
            .filterNil()
            .observeOn(schedulerProvider.io())
            .flatMap { [tripId, tripInteractor] newDropoffLocation in
                tripInteractor
                    .editDropoff(tripId: tripId, newDropoffLocation: newDropoffLocation.namedTripLocation.tripLocation)
                    .logErrors(logger: logger)
                    .retry(DefaultOnTripViewModel.tripInteractorRepeatBehavior)
            }
            .subscribe(onError: { [displayStateMachine] _ in
                displayStateMachine.transition { _ in .currentTrip }
            })
            .disposed(by: disposeBag)
    }

    public var displayState: Observable<OnTripDisplayState> {
        return displayStateMachine.observeCurrentState()
    }

    public func editPickup(existingPickupLocation: DesiredAndAssignedLocation,
                           existingDropoffLocation: DesiredAndAssignedLocation) {
        displayStateMachine.transition {
            guard $0 == .currentTrip else {
                throw InvalidStateTransitionError
                    .invalidStateTransition("\(#function) called during invalid state: \($0)")
            }
            return .editingPickup(existingPickupLocation: existingPickupLocation,
                                  existingDropoffLocation: existingDropoffLocation)
        }
    }

    public func editDropoff(existingPickupLocation: DesiredAndAssignedLocation,
                            existingDropoffLocation: DesiredAndAssignedLocation) {
        displayStateMachine.transition {
            guard $0 == .currentTrip else {
                throw InvalidStateTransitionError
                    .invalidStateTransition("\(#function) called during invalid state: \($0)")
            }
            return .editingDropoff(existingPickupLocation: existingPickupLocation,
                                   existingDropoffLocation: existingDropoffLocation)
        }
    }

    public func set(pickup: PreTripLocation, dropoff: PreTripLocation) {
        displayStateMachine.transition {
            switch $0 {
            case .editingPickup:
                return .updatingPickup(newPickupLocation: pickup.desiredAndAssignedLocation)
            case .editingDropoff:
                return .updatingDropoff(newDropoffLocation: dropoff.desiredAndAssignedLocation)
            default:
                throw InvalidStateTransitionError
                    .invalidStateTransition("\(#function) called during invalid state: \($0)")
            }
        }
    }

    public func cancelSetPickupDropoff() {
        displayStateMachine.transition {
            switch $0 {
            case .editingPickup, .editingDropoff:
                return .currentTrip
            default:
                throw InvalidStateTransitionError
                    .invalidStateTransition("\(#function) called during invalid state: \($0)")
            }
        }
    }

    public func tripFinished() {
        tripFinishedListener?.tripFinished()
    }

    private static func getUpdatedPickupLocation(
        fromDisplayState state: OnTripDisplayState
    ) -> DesiredAndAssignedLocation? {
        switch state {
        case let .updatingPickup(newPickupLocation):
            return newPickupLocation
        default:
            return nil
        }
    }

    private static func getUpdatedDropoffLocation(
        fromDisplayState state: OnTripDisplayState
    ) -> DesiredAndAssignedLocation? {
        switch state {
        case let .updatingDropoff(newDropoffLocation):
            return newDropoffLocation
        default:
            return nil
        }
    }
}
