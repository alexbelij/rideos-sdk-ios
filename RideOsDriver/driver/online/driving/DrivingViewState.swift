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

public struct DrivingViewState: Equatable {
    public enum Step: Equatable {
        case drivePending
        case navigating
        case confirmingArrival(showBackToNavigation: Bool)

        public static func == (lhs: Step, rhs: Step) -> Bool {
            switch (lhs, rhs) {
            case (.drivePending, .drivePending):
                return true
            case (.navigating, .navigating):
                return true
            case let (.confirmingArrival(lhsShowBackToNavigation), .confirmingArrival(rhsShowBackToNavigation)):
                return lhsShowBackToNavigation == rhsShowBackToNavigation
            default:
                return false
            }
        }
    }

    let drivingStep: Step
    let destination: CLLocationCoordinate2D

    public init(drivingStep: Step, destination: CLLocationCoordinate2D) {
        self.drivingStep = drivingStep
        self.destination = destination
    }
}
