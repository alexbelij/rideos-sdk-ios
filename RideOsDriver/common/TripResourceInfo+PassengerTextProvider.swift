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

extension TripResourceInfo {
    public typealias PassengerTextProvider = (TripResourceInfo) -> String

    public static let defaultPassengerTextProvider: PassengerTextProvider = { tripResourceInfo in
        let passengersText: String

        if let passengerName = tripResourceInfo.contactInfo.name {
            if tripResourceInfo.numberOfPassengers > 1 {
                let numberOfRidersExcludingRequester = tripResourceInfo.numberOfPassengers - 1
                passengersText = "\(passengerName) + \(numberOfRidersExcludingRequester)"
            } else {
                passengersText = passengerName
            }
        } else {
            passengersText = ""
        }

        return passengersText
    }
}
