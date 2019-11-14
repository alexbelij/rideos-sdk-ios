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

import Foundation
import RideOsCommon

public struct SetPickupDropOffDisplayState: Equatable {
    public enum Step: Equatable {
        case searchingForPickupDropoff(enablePickupSearch: Bool, enableDropoffSearch: Bool)
        case settingPickupOnMap
        case settingDropoffOnMap
        case confirmingPickup
        case confirmingDropoff
    }

    public let step: Step
    public let pickup: PreTripLocation?
    public let dropoff: PreTripLocation?
    public let focus: LocationSearchFocusType

    public init(step: Step,
                pickup: PreTripLocation?,
                dropoff: PreTripLocation?,
                focus: LocationSearchFocusType) {
        self.step = step
        self.pickup = pickup
        self.dropoff = dropoff
        self.focus = focus
    }
}
