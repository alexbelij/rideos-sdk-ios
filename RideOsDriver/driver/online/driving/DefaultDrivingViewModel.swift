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

public class DefaultDrivingViewModel: DrivingViewModel {
    public var drivingViewState: Observable<DrivingViewState> {
        return stateMachine.observeCurrentState()
            .distinctUntilChanged()
            .map { [destination] in DrivingViewState(drivingStep: $0, destination: destination) }
    }

    private let destination: CLLocationCoordinate2D
    private let schedulerProvider: SchedulerProvider

    private let stateMachine: StateMachine<DrivingViewState.Step>

    public init(destination: CLLocationCoordinate2D,
                initialStep: DrivingViewState.Step = .drivePending,
                schedulerProvider: SchedulerProvider = DefaultSchedulerProvider(),
                logger: Logger = LoggerDependencyRegistry.instance.logger) {
        self.destination = destination
        self.schedulerProvider = schedulerProvider

        stateMachine = StateMachine(schedulerProvider: schedulerProvider, initialState: initialStep, logger: logger)
    }

    public func getCurrentDrivingViewState() throws -> DrivingViewState {
        return try DrivingViewState(drivingStep: stateMachine.getCurrentState(), destination: destination)
    }

    public func startNavigation() {
        stateMachine.transition { currentState in
            guard [
                DrivingViewState.Step.drivePending,
                DrivingViewState.Step.confirmingArrival(showBackToNavigation: true),
            ].contains(currentState) else {
                throw InvalidStateTransitionError.invalidStateTransition(
                    "\(#function) called during invalid state: \(currentState)")
            }

            return .navigating
        }
    }

    public func arrivalConfirmed() {
        stateMachine.transition { currentState in
            guard case .confirmingArrival = currentState else {
                throw InvalidStateTransitionError.invalidStateTransition(
                    "\(#function) called during invalid state: \(currentState)")
            }

            return currentState
        }
    }

    public func finishedNavigation(didCancelNavigation: Bool) {
        stateMachine.transition { currentState in
            guard case .navigating = currentState else {
                throw InvalidStateTransitionError.invalidStateTransition(
                    "\(#function) called during invalid state: \(currentState)")
            }

            return .confirmingArrival(showBackToNavigation: didCancelNavigation)
        }
    }
}
