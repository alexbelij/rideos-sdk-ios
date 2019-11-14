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

public class DefaultVehicleSettingsViewModel: VehicleSettingsViewModel {
    public var licensePlate: BehaviorSubject<String> { return savedLicensePlateSubject }

    private let savedLicensePlateSubject = BehaviorSubject<String>(value: "")
    private let driverVehicleInteractor: DriverVehicleInteractor
    private let userStorageReader: UserStorageReader
    private let logger: Logger
    private let disposeBag = DisposeBag()

    public init(driverVehicleInteractor: DriverVehicleInteractor = DefaultDriverVehicleInteractor(),
                userStorageReader: UserStorageReader = UserDefaultsUserStorageReader(),
                logger: Logger = LoggerDependencyRegistry.instance.logger) {
        self.driverVehicleInteractor = driverVehicleInteractor
        self.userStorageReader = userStorageReader
        self.logger = logger

        self.driverVehicleInteractor.getVehicleInfo(vehicleId: userStorageReader.userId)
            .asObservable()
            .logErrorsAndRetry(logger: logger)
            .asSingle()
            .subscribe(
                onSuccess: { [unowned self] vehicleInfo in
                    self.savedLicensePlateSubject.onNext(vehicleInfo.licensePlate)
                },
                onError: { [unowned self] error in
                    self.logger.logError("Error getting vehicle info: \(error)")
                }
            )
            .disposed(by: disposeBag)
    }

    public func update(licensePlate: String) -> Completable {
        return driverVehicleInteractor
            .updateLicensePlate(vehicleId: userStorageReader.userId, licensePlate: licensePlate)
            .do(
                onError: { error in
                    self.logger.logError("Error saving license plate \(licensePlate): \(error)")
                },
                onCompleted: {
                    self.savedLicensePlateSubject.onNext(licensePlate)
                }
            )
    }
}
