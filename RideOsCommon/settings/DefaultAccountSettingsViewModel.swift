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
import RxSwift

public class DefaultAccountSettingsViewModel: AccountSettingsViewModel {
    public var preferredName: BehaviorSubject<String> { return savedPreferredNameSubject }
    public var phoneNumber: BehaviorSubject<String> { return savedPhoneNumberSubject }
    public var email: Single<String> { return getUserEmail }

    private let savedPreferredNameSubject = BehaviorSubject<String>(value: "")
    private let savedPhoneNumberSubject = BehaviorSubject<String>(value: "")
    private let user: User
    private let userProfileInteractor: UserProfileInteractor
    private let userStorageReader: UserStorageReader
    private let logger: Logger
    private let disposeBag = DisposeBag()

    public init(user: User = User.currentUser,
                userProfileInteractor: UserProfileInteractor =
                    CommonDependencyRegistry.instance.commonDependencyFactory.userProfileInteractor,
                userStorageReader: UserStorageReader = UserDefaultsUserStorageReader(),
                logger: Logger = LoggerDependencyRegistry.instance.logger) {
        self.user = user
        self.userProfileInteractor = userProfileInteractor
        self.userStorageReader = userStorageReader
        self.logger = logger

        userProfileInteractor.getUserProfile(userId: userStorageReader.userId)
            .asObservable()
            .logErrorsAndRetry(logger: logger)
            .asSingle()
            .subscribe(
                onSuccess: { [unowned self] userProfile in
                    self.savedPreferredNameSubject.onNext(userProfile.preferredName)
                    self.savedPhoneNumberSubject.onNext(userProfile.phoneNumber)
                },
                onError: { [unowned self] error in
                    self.logger.logError("Error getting user profile: \(error)")
                }
            )
            .disposed(by: disposeBag)
    }

    private var getUserEmail: Single<String> {
        return Single.create { [unowned self] single in
            self.user.fetchProfile { profile in
                guard let profile = profile, let email = profile.email else {
                    self.logger.logError("Could not get email for user profile.")
                    single(.success(""))
                    return
                }

                single(.success(email))
            }

            return Disposables.create()
        }
    }

    public func update(preferredName: String) -> Completable {
        let savedPhoneNumber: String
        do {
            savedPhoneNumber = try savedPhoneNumberSubject.value()
        } catch {
            logger.logError("Could not get saved phone number when updating preferred name.")
            return Completable.error(error)
        }

        let userProfile = UserProfile(preferredName: preferredName, phoneNumber: savedPhoneNumber)

        return userProfileInteractor.storeUserProfile(userId: userStorageReader.userId, userProfile: userProfile)
            .do(
                onError: { error in
                    self.logger.logError("Error saving preferred name for user profile: \(error)")
                },
                onCompleted: {
                    self.savedPreferredNameSubject.onNext(userProfile.preferredName)
                    self.savedPhoneNumberSubject.onNext(userProfile.phoneNumber)
                }
            )
    }

    public func update(phoneNumber: String) -> Completable {
        let savedPreferredName: String
        do {
            savedPreferredName = try savedPreferredNameSubject.value()
        } catch {
            logger.logError("Could not get saved preferred name when updating phone number.")
            return Completable.error(error)
        }

        let userProfile = UserProfile(preferredName: savedPreferredName, phoneNumber: phoneNumber)

        return userProfileInteractor.storeUserProfile(userId: userStorageReader.userId, userProfile: userProfile)
            .do(
                onError: { error in
                    self.logger.logError("Error saving phone number for user profile: \(error)")
                },
                onCompleted: {
                    self.savedPreferredNameSubject.onNext(userProfile.preferredName)
                    self.savedPhoneNumberSubject.onNext(userProfile.phoneNumber)
                }
            )
    }
}
