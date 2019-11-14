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

import CoreLocation
import Foundation
import grpc
import RideOsApi
import RideOsCommon
import RxSwift

public class DefaultDriverVehicleInteractor: DriverVehicleInteractor {
    private let driverVehicleService: RideHailDriverRideHailDriverService

    public init(driverVehicleService: RideHailDriverRideHailDriverService =
        RideHailDriverRideHailDriverService.serviceWithApiHost()) {
        self.driverVehicleService = driverVehicleService
    }

    public func markVehicleReady(vehicleId: String) -> Completable {
        return setVehicleReadiness(vehicleId: vehicleId, readyForDispatch: true)
    }

    public func markVehicleNotReady(vehicleId: String) -> Completable {
        return setVehicleReadiness(vehicleId: vehicleId, readyForDispatch: false)
    }

    public func finishSteps(vehicleId: String, taskId: String, stepIds: [String]) -> Completable {
        return Observable.from(stepIds)
            .concatMap {
                self.finishStep(vehicleId: vehicleId, taskId: taskId, stepId: $0)
            }
            .ignoreElements()
    }

    private func finishStep(vehicleId: String, taskId: String, stepId: String) -> Completable {
        return Completable.create { [driverVehicleService] completable in
            let completeStepRequest = RideHailDriverCompleteStepRequest()
            completeStepRequest.vehicleId = vehicleId
            completeStepRequest.tripId = taskId
            completeStepRequest.stepId = stepId

            let call = driverVehicleService.rpcToCompleteStep(with: completeStepRequest) { response, error in

                guard error == nil else {
                    completable(.error(error!))
                    return
                }

                guard response != nil else {
                    completable(.error(DriverVehicleInteractorError.invalidResponse))
                    return
                }

                completable(.completed)
            }

            call.start()

            return Disposables.create {
                call.cancel()
            }
        }
    }

    public func rejectTrip(vehicleId: String, tripId: String) -> Completable {
        return Completable.create { [driverVehicleService] completable in
            let rejectTripRequest = RideHailDriverRejectTripRequest()
            rejectTripRequest.vehicleId = vehicleId
            rejectTripRequest.tripId = tripId

            let call = driverVehicleService.rpcToRejectTrip(with: rejectTripRequest) { response, error in

                guard error == nil else {
                    completable(.error(error!))
                    return
                }

                guard response != nil else {
                    completable(.error(DriverVehicleInteractorError.invalidResponse))
                    return
                }

                completable(.completed)
            }

            call.start()

            return Disposables.create {
                call.cancel()
            }
        }
    }

    public func cancelTrip(tripId: String) -> Completable {
        return Completable.create { [driverVehicleService] completable in
            let cancelTripRequest = RideHailDriverCancelTripRequest()
            cancelTripRequest.id_p = tripId

            let call = driverVehicleService.rpcToCancelTrip(with: cancelTripRequest) { response, error in
                guard error == nil else {
                    completable(.error(error!))
                    return
                }

                guard response != nil else {
                    completable(.error(DriverVehicleInteractorError.invalidResponse))
                    return
                }

                completable(.completed)
            }

            call.start()

            return Disposables.create {
                call.cancel()
            }
        }
    }

    public func createVehicle(vehicleId: String, fleetId: String, vehicleInfo: VehicleRegistration) -> Completable {
        return Completable.create { [driverVehicleService] completable in
            let request = RideHailDriverCreateVehicleRequest()
            request.id_p = vehicleId
            request.fleetId = fleetId

            request.definition = RideHailCommonsVehicleDefinition()
            request.definition.riderCapacity = UInt32(vehicleInfo.riderCapacity)

            request.info = RideHailCommonsVehicleInfo()
            request.info.licensePlate = vehicleInfo.licensePlate
            request.info.driverInfo = RideHailCommonsDriverInfo()
            request.info.driverInfo.contactInfo = RideHailCommonsContactInfo()
            request.info.driverInfo.contactInfo.name = vehicleInfo.name
            request.info.driverInfo.contactInfo.phoneNumber = vehicleInfo.phoneNumber

            let call = driverVehicleService.rpcToCreateVehicle(with: request) { response, error in
                guard error == nil else {
                    completable(.error(error!))
                    return
                }

                guard response != nil else {
                    completable(.error(DriverVehicleInteractorError.invalidResponse))
                    return
                }

                completable(.completed)
            }

            call.start()

            return Disposables.create {
                call.cancel()
            }
        }
    }

    private func setVehicleReadiness(vehicleId: String, readyForDispatch: Bool) -> Completable {
        return Completable.create { [driverVehicleService] completable in
            let request = RideHailDriverUpdateVehicleStateRequest()
            request.id_p = vehicleId
            if readyForDispatch {
                request.setToReady = RideHailDriverUpdateVehicleStateRequest_SetToReady()
            } else {
                request.setToNotReady = RideHailDriverUpdateVehicleStateRequest_SetToNotReady()
            }

            let call = driverVehicleService.rpcToUpdateVehicleState(with: request) { response, error in
                guard error == nil else {
                    completable(.error(error!))
                    return
                }

                guard response != nil else {
                    completable(.error(DriverVehicleInteractorError.invalidResponse))
                    return
                }

                completable(.completed)
            }

            call.start()

            return Disposables.create {
                call.cancel()
            }
        }
    }

    public func updateVehiclePose(
        vehicleId: String,
        vehicleCoordinate: CLLocationCoordinate2D,
        vehicleHeading: CLLocationDirection
    ) -> Completable {
        let request = RideHailDriverUpdateVehicleStateRequest()
        request.id_p = vehicleId

        let positionUpdate = RideHailDriverUpdateVehicleStateRequest_UpdatePosition()
        positionUpdate.updatedPosition = Position(coordinate: vehicleCoordinate)

        let updatedHeading = GPBFloatValue()
        updatedHeading.value = Float(vehicleHeading)
        positionUpdate.updatedHeading = updatedHeading

        request.updatePosition = positionUpdate

        return Completable.create { [driverVehicleService] completable in
            let call = driverVehicleService.rpcToUpdateVehicleState(with: request) { _, error in
                guard error == nil else {
                    completable(.error(error!))
                    return
                }

                return completable(.completed)
            }

            call.start()

            return Disposables.create {
                call.cancel()
            }
        }
    }

    public func getVehicleStatus(vehicleId: String) -> Single<VehicleStatus> {
        return getVehicleState(vehicleId: vehicleId).map {
            $0.readiness ? VehicleStatus.ready : VehicleStatus.notReady
        }.catchError {
            if ($0 as NSError).code == grpc.GRPC_STATUS_NOT_FOUND.rawValue {
                return Single.just(VehicleStatus.unregistered)
            }

            return Single.error($0)
        }
    }

    public func getVehicleState(vehicleId: String) -> Single<RideHailCommonsVehicleState> {
        let request = RideHailDriverGetVehicleStateRequest()
        request.id_p = vehicleId

        return Single.create { [driverVehicleService] single in
            let call = driverVehicleService.rpcToGetVehicleState(with: request) { response, error in
                guard error == nil else {
                    single(.error(error!))
                    return
                }

                guard let response = response else {
                    single(.error(DriverPlanInteractorError.invalidResponse))
                    return
                }

                return single(.success(response.state))
            }

            call.start()

            return Disposables.create {
                call.cancel()
            }
        }
    }

    public func updateVehicleRouteLegs(
        vehicleId: String,
        legs: [RideHailDriverUpdateVehicleStateRequest_SetRouteLegs_LegDefinition]
    ) -> Completable {
        let request = RideHailDriverUpdateVehicleStateRequest()
        request.id_p = vehicleId

        let routeLegsToSet = RideHailDriverUpdateVehicleStateRequest_SetRouteLegs()
        routeLegsToSet.legDefinitionArray = NSMutableArray(array: legs)

        request.setRouteLegs = routeLegsToSet

        return Completable.create { [driverVehicleService] completable in
            let call = driverVehicleService.rpcToUpdateVehicleState(with: request) { _, error in
                guard error == nil else {
                    completable(.error(error!))
                    return
                }

                return completable(.completed)
            }

            call.start()

            return Disposables.create {
                call.cancel()
            }
        }
    }

    public func updateContactInfo(vehicleId: String, contactInfo: ContactInfo) -> Completable {
        let request = RideHailDriverUpdateVehicleRequest()
        request.id_p = vehicleId
        request.updatedVehicleInfo = RideHailCommonsVehicleInfoUpdate()
        request.updatedVehicleInfo.driverInfo = RideHailCommonsDriverInfo()
        request.updatedVehicleInfo.driverInfo.contactInfo = RideHailCommonsContactInfo()
        request.updatedVehicleInfo.driverInfo.contactInfo.name = contactInfo.name
        request.updatedVehicleInfo.driverInfo.contactInfo.phoneNumber = contactInfo.phoneNumber
        request.updatedVehicleInfo.driverInfo.contactInfo.contactURL = contactInfo.url?.absoluteString

        return Completable.create { [driverVehicleService] completable in
            let call = driverVehicleService.rpcToUpdateVehicle(with: request) { _, error in
                guard error == nil else {
                    completable(.error(error!))
                    return
                }

                return completable(.completed)
            }

            call.start()

            return Disposables.create {
                call.cancel()
            }
        }
    }

    public func updateLicensePlate(vehicleId: String, licensePlate: String) -> Completable {
        let request = RideHailDriverUpdateVehicleRequest()
        request.id_p = vehicleId
        request.updatedVehicleInfo = RideHailCommonsVehicleInfoUpdate()
        request.updatedVehicleInfo.licensePlate = GPBStringValue()
        request.updatedVehicleInfo.licensePlate.value = licensePlate

        return Completable.create { [driverVehicleService] completable in
            let call = driverVehicleService.rpcToUpdateVehicle(with: request) { _, error in
                guard error == nil else {
                    completable(.error(error!))
                    return
                }

                return completable(.completed)
            }

            call.start()

            return Disposables.create {
                call.cancel()
            }
        }
    }

    public func getVehicleInfo(vehicleId: String) -> Single<VehicleInfo> {
        let request = RideHailDriverGetVehicleInfoRequest()
        request.id_p = vehicleId

        return Single.create { [driverVehicleService] single in
            let call = driverVehicleService.rpcToGetVehicleInfo(with: request) { response, error in
                guard error == nil else {
                    single(.error(error!))
                    return
                }

                guard let response = response,
                    let responseInfo = response.info else {
                    single(.error(DriverVehicleInteractorError.invalidResponse))
                    return
                }

                let contactInfo = ContactInfo(
                    name: responseInfo.driverInfo.contactInfo.name,
                    phoneNumber: responseInfo.driverInfo.contactInfo.phoneNumber,
                    contactURL: responseInfo.driverInfo.contactInfo.contactURL
                )

                return single(.success(VehicleInfo(licensePlate: responseInfo.licensePlate, contactInfo: contactInfo)))
            }

            call.start()

            return Disposables.create {
                call.cancel()
            }
        }
    }
}
