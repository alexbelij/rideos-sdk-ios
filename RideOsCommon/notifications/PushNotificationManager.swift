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
import RideOsApi
import RxOptional
import RxSwift
import UserNotifications

public class PushNofificationManager {
    public typealias RegisterDeviceCallback = (String, Data) -> Completable

    private static let appleRemoteNotificationRegistrationRetryCount = 5
    private static let appleRemoteNotificationRegistrationRetryDelay: RxTimeInterval = 5.0

    private let disposeBag = DisposeBag()
    private let pushNotificationAuthorizationGrantedSubject = BehaviorSubject(value: false)
    private let deviceTokenSubject = ReplaySubject<Data>.create(bufferSize: 1)
    private let appleRemoteNotificationErrorSubject = ReplaySubject<Error>.create(bufferSize: 1)

    private let notificationCenter: UNUserNotificationCenter

    public static func forDriver(logger: Logger) -> PushNofificationManager {
        let deviceRegistryInteractor = DefaultDeviceRegistryInteractor()
        return PushNofificationManager(
            registerDeviceCallback: { [deviceRegistryInteractor] in
                deviceRegistryInteractor.setDriverDeviceInfo(vehicleId: $0,
                                                             deviceId: $1)
            },
            logger: logger
        )
    }

    public static func forRider(logger: Logger) -> PushNofificationManager {
        let deviceRegistryInteractor = DefaultDeviceRegistryInteractor()
        return PushNofificationManager(
            registerDeviceCallback: { [deviceRegistryInteractor] in
                deviceRegistryInteractor.setRiderDeviceInfo(riderId: $0,
                                                            deviceId: $1)
            },
            logger: logger
        )
    }

    private init(
        registerDeviceCallback: @escaping RegisterDeviceCallback,
        logger: Logger,
        userIdObservable: Observable<String?> = UserDefaultsUserStorageReader().observe(CommonUserStorageKeys.userId),
        uiApplication: UIApplication = UIApplication.shared,
        notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current(),
        schedulerProvider: SchedulerProvider = DefaultSchedulerProvider()
    ) {
        self.notificationCenter = notificationCenter

        // When push notification authorization is granted, register for notifications with Apple
        pushNotificationAuthorizationGrantedSubject
            .observeOn(schedulerProvider.mainThread())
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [uiApplication] _ in uiApplication.registerForRemoteNotifications() })
            .disposed(by: disposeBag)

        // When we receive an Error attempting to register for notifications with Apple, retry up to
        // appleRemoteNotificationRegistrationRetryCount times
        appleRemoteNotificationErrorSubject
            .observeOn(schedulerProvider.mainThread())
            .take(PushNofificationManager.appleRemoteNotificationRegistrationRetryCount)
            .delay(PushNofificationManager.appleRemoteNotificationRegistrationRetryDelay,
                   scheduler: schedulerProvider.mainThread())
            .subscribe(onNext: { [uiApplication] _ in uiApplication.registerForRemoteNotifications() })
            .disposed(by: disposeBag)

        // Update the device registry when the device token or user ID change
        Observable
            .combineLatest(pushNotificationAuthorizationGrantedSubject.filter { $0 },
                           deviceTokenSubject,
                           userIdObservable.filterNil())
            .observeOn(schedulerProvider.io())
            .map { ($0.1, $0.2) }
            .flatMapLatest { [registerDeviceCallback] deviceId, vehicleId in
                registerDeviceCallback(vehicleId, deviceId)
            }
            .asObservable()
            .logErrorsAndRetry(logger: logger)
            .subscribe()
            .disposed(by: disposeBag)

        requestNotificationAuthorization()
    }

    public func onNotificationAuthorizationSuccess(deviceToken: Data) {
        deviceTokenSubject.onNext(deviceToken)
    }

    public func onNotificationAuthorizationError(_ error: Error) {
        appleRemoteNotificationErrorSubject.onNext(error)
    }

    private func requestNotificationAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            self.pushNotificationAuthorizationGrantedSubject.onNext(granted)
        }
    }
}
