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
import RxCocoa
import RxOptional
import RxSwift

public class DefaultVehicleRegistrationViewModel: VehicleRegistrationViewModel {
    private let disposeBag = DisposeBag()

    private let vehicleRegistrationInfoRelay =
        BehaviorRelay(value: VehicleRegistration(name: "", phoneNumber: "",
                                                 licensePlate: "", riderCapacity: 0))

    private let resolvedFleet: ResolvedFleet
    private let userStorageReader: UserStorageReader
    private let driverVehicleInteractor: DriverVehicleInteractor
    private let schedulerProvider: SchedulerProvider

    public init(schedulerProvider: SchedulerProvider = DefaultSchedulerProvider(),
                driverVehicleInteractor: DriverVehicleInteractor = DefaultDriverVehicleInteractor(),
                resolvedFleet: ResolvedFleet = ResolvedFleet.instance,
                userStorageReader: UserStorageReader = UserDefaultsUserStorageReader()) {
        self.schedulerProvider = schedulerProvider
        self.driverVehicleInteractor = driverVehicleInteractor
        self.resolvedFleet = resolvedFleet
        self.userStorageReader = userStorageReader
    }

    public func setPreferredNameText(_ text: String) {
        let oldVehicleInfo = vehicleRegistrationInfoRelay.value
        let newVehicleInfo = VehicleRegistration(name: text,
                                                 phoneNumber: oldVehicleInfo.phoneNumber,
                                                 licensePlate: oldVehicleInfo.licensePlate,
                                                 riderCapacity: oldVehicleInfo.riderCapacity)
        vehicleRegistrationInfoRelay.accept(newVehicleInfo)
    }

    public func setPhoneNumberText(_ text: String) {
        let oldVehicleInfo = vehicleRegistrationInfoRelay.value
        let newVehicleInfo = VehicleRegistration(name: oldVehicleInfo.name,
                                                 phoneNumber: text,
                                                 licensePlate: oldVehicleInfo.licensePlate,
                                                 riderCapacity: oldVehicleInfo.riderCapacity)
        vehicleRegistrationInfoRelay.accept(newVehicleInfo)
    }

    public func setLicensePlateText(_ text: String) {
        let oldVehicleInfo = vehicleRegistrationInfoRelay.value
        let newVehicleInfo = VehicleRegistration(name: oldVehicleInfo.name,
                                                 phoneNumber: oldVehicleInfo.phoneNumber,
                                                 licensePlate: text,
                                                 riderCapacity: oldVehicleInfo.riderCapacity)
        vehicleRegistrationInfoRelay.accept(newVehicleInfo)
    }

    public func setRiderCapacityText(_ text: String) {
        let oldVehicleInfo = vehicleRegistrationInfoRelay.value
        let newVehicleInfo = VehicleRegistration(name: oldVehicleInfo.name,
                                                 phoneNumber: oldVehicleInfo.phoneNumber,
                                                 licensePlate: oldVehicleInfo.licensePlate,
                                                 riderCapacity: Int32(text) ?? 0)
        vehicleRegistrationInfoRelay.accept(newVehicleInfo)
    }

    public func submit() -> Completable {
        return resolvedFleet.resolvedFleet.first()
            .flatMapCompletable { [unowned self] fleetInfo -> Completable in
                guard let fleetInfo = fleetInfo else {
                    return Completable.error(
                        InvalidVehicleRegistrationInfoError.invalidInfo("No resolved fleet info")
                    )
                }

                let registrationInfo = self.vehicleRegistrationInfoRelay.value

                guard DefaultVehicleRegistrationViewModel.isVehicleRegistrationInfoValid(registrationInfo) else {
                    return Completable.error(
                        InvalidVehicleRegistrationInfoError.invalidInfo("Invalid registration info")
                    )
                }

                return self.driverVehicleInteractor.createVehicle(
                    vehicleId: self.userStorageReader.userId,
                    fleetId: fleetInfo.fleetId,
                    vehicleInfo: registrationInfo
                )
            }
    }

    public func isSubmitActionEnabled() -> Observable<Bool> {
        return vehicleRegistrationInfoRelay.asObservable()
            .map { info in DefaultVehicleRegistrationViewModel.isVehicleRegistrationInfoValid(info) }
    }

    private static func isVehicleRegistrationInfoValid(_ vehicleInfo: VehicleRegistration) -> Bool {
        return vehicleInfo.name.isNotEmpty && vehicleInfo.phoneNumber.isNotEmpty
            && vehicleInfo.licensePlate.isNotEmpty && vehicleInfo.riderCapacity > 0
    }
}
