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

public class RiderUserProfileInteractor: UserProfileInteractor {
    private let userStorageReader: UserStorageReader
    private let userStorageWriter: UserStorageWriter

    public init(userStorageReader: UserStorageReader = UserDefaultsUserStorageReader(),
                userStorageWriter: UserStorageWriter = UserDefaultsUserStorageWriter()) {
        self.userStorageReader = userStorageReader
        self.userStorageWriter = userStorageWriter
    }

    public func getUserProfile(userId _: String) -> Single<UserProfile> {
        return Observable.combineLatest(
            userStorageReader.observe(CommonUserStorageKeys.preferredName),
            userStorageReader.observe(CommonUserStorageKeys.phoneNumber)
        )
        .map { UserProfile(preferredName: $0 ?? "", phoneNumber: $1 ?? "") }
        .take(1)
        .asSingle()
    }

    public func storeUserProfile(userId _: String, userProfile: UserProfile) -> Completable {
        userStorageWriter.set(key: CommonUserStorageKeys.preferredName, value: userProfile.preferredName)
        userStorageWriter.set(key: CommonUserStorageKeys.phoneNumber, value: userProfile.phoneNumber)

        return Completable.empty()
    }
}
