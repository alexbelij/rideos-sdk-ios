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
import RxSwift

public class DriverUserProfileInteractor: UserProfileInteractor {
    private let driverVehicleInteractor: DriverVehicleInteractor

    public init(driverVehicleInteractor: DriverVehicleInteractor = DefaultDriverVehicleInteractor()) {
        self.driverVehicleInteractor = driverVehicleInteractor
    }

    public func getUserProfile(userId: String) -> Single<UserProfile> {
        return driverVehicleInteractor.getVehicleInfo(vehicleId: userId).map { vehicleInfo in
            UserProfile(
                preferredName: vehicleInfo.contactInfo.name ?? "",
                phoneNumber: vehicleInfo.contactInfo.phoneNumber ?? ""
            )
        }
    }

    public func storeUserProfile(userId: String, userProfile: UserProfile) -> Completable {
        return driverVehicleInteractor.updateContactInfo(
            vehicleId: userId,
            contactInfo: ContactInfo(name: userProfile.preferredName, phoneNumber: userProfile.phoneNumber)
        )
    }
}
