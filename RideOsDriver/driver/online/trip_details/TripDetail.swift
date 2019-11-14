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

public struct TripDetail {
    public enum ActionToPerform {
        case rejectTrip
        case cancelTrip
        case endTrip
    }

    public let nextWaypoint: VehiclePlan.Waypoint
    public let actionToPerform: ActionToPerform
    public let passengerDisplayText: String
    public let passengerContactUrl: URL?
    public let pickupLocationDisplayName: String?
    public let dropoffLocationDisplayName: String

    public init(nextWaypoint: VehiclePlan.Waypoint,
                actionToPerform: ActionToPerform,
                passengerDisplayText: String,
                passengerContactUrl: URL?,
                pickupLocationDisplayName: String?,
                dropoffLocationDisplayName: String) {
        self.nextWaypoint = nextWaypoint
        self.actionToPerform = actionToPerform
        self.passengerDisplayText = passengerDisplayText
        self.passengerContactUrl = passengerContactUrl
        self.pickupLocationDisplayName = pickupLocationDisplayName
        self.dropoffLocationDisplayName = dropoffLocationDisplayName
    }
}
