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
import RxSwift

public class DefaultDeviceRegistryInteractor: DeviceRegistryInteractor {
    private let deviceRegistryService: RideHailNotificationDeviceRegistryService
    private let bundle: Bundle

    public init(
        deviceRegistryService: RideHailNotificationDeviceRegistryService = RideHailNotificationDeviceRegistryService.serviceWithApiHost(),
        bundle: Bundle = Bundle.main
    ) {
        self.deviceRegistryService = deviceRegistryService
        self.bundle = bundle
    }

    public func setRiderDeviceInfo(riderId: String, deviceId: Data) -> Completable {
        return Completable.create { [deviceRegistryService, unowned self] observer in
            let request = RideHailNotificationSetRiderDeviceInfoRequest()
            request.riderId = riderId
            request.deviceInfo = self.deviceInfoFor(deviceId: deviceId)

            let call = deviceRegistryService.rpcToSetRiderDeviceInfo(with: request) { response, error in

                guard error == nil else {
                    observer(.error(error!))
                    return
                }

                guard response != nil else {
                    observer(.error(DeviceRegistryInteractorError.invalidResponse))
                    return
                }

                observer(.completed)
            }

            call.start()

            return Disposables.create {
                call.cancel()
            }
        }
    }

    public func setDriverDeviceInfo(vehicleId: String, deviceId: Data) -> Completable {
        return Completable.create { [deviceRegistryService, unowned self] observer in
            let request = RideHailNotificationSetDriverDeviceInfoRequest()
            request.vehicleId = vehicleId
            request.deviceInfo = self.deviceInfoFor(deviceId: deviceId)

            let call = deviceRegistryService.rpcToSetDriverDeviceInfo(with: request) { response, error in

                guard error == nil else {
                    observer(.error(error!))
                    return
                }

                guard response != nil else {
                    observer(.error(DeviceRegistryInteractorError.invalidResponse))
                    return
                }

                observer(.completed)
            }

            call.start()

            return Disposables.create {
                call.cancel()
            }
        }
    }

    private func deviceInfoFor(deviceId: Data) -> RideHailNotificationDeviceInfo {
        let deviceInfo = RideHailNotificationDeviceInfo()
        deviceInfo.iosDevice = RideHailNotificationDeviceInfo_IosDevice()
        deviceInfo.iosDevice.token = deviceId
        deviceInfo.iosDevice.bundleId = bundle.bundleIdentifier
        return deviceInfo
    }
}
