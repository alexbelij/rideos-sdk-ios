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
import RideOsCommon
import RxSwift

public class DefaultWaitingForPickupViewModel: WaitingForPickupViewModel {
    public typealias PassengerPickupTextProvider = (TripResourceInfo) -> String

    public struct Style {
        public static let defaultPassengerPickupTextProvider: PassengerPickupTextProvider = { tripResourceInfo in
            let passengersToPickupText: String

            if tripResourceInfo.numberOfPassengers > 1 {
                let numberOfRidersExcludingRequester = tripResourceInfo.numberOfPassengers - 1
                passengersToPickupText = "\(tripResourceInfo.nameOfTripRequester) + \(numberOfRidersExcludingRequester)"
            } else {
                passengersToPickupText = tripResourceInfo.nameOfTripRequester
            }

            let passengerPickupTextFormat = RideOsDriverResourceLoader.instance.getString(
                "ai.rideos.driver.online.waiting-for-pickup.title-format"
            )

            return String(format: passengerPickupTextFormat, passengersToPickupText)
        }

        public let passengerPickupTextProvider: PassengerPickupTextProvider
        public let pickupLocationIcon: DrawableMarkerIcon
        public let vehicleIcon: DrawableMarkerIcon

        public init(
            passengerPickupTextProvider: @escaping PassengerPickupTextProvider =
                Style.defaultPassengerPickupTextProvider,
            pickupLocationIcon: DrawableMarkerIcon = DrawableMarkerIcons.pickupPin(),
            vehicleIcon: DrawableMarkerIcon = DrawableMarkerIcons.car()
        ) {
            self.passengerPickupTextProvider = passengerPickupTextProvider
            self.pickupLocationIcon = pickupLocationIcon
            self.vehicleIcon = vehicleIcon
        }
    }

    public var passengersToPickupText: String {
        return style.passengerPickupTextProvider(tripResourceInfo)
    }

    public var confirmingPickupState: Observable<ConfirmingPickupViewState> {
        return stateMachine.observeCurrentState()
    }

    private let tripResourceInfo: TripResourceInfo
    private let pickupWaypoint: VehiclePlan.Waypoint
    private let driverVehicleInteractor: DriverVehicleInteractor
    private let userStorageReader: UserStorageReader
    private let deviceLocator: DeviceLocator
    private let style: Style
    private let schedulerProvider: SchedulerProvider
    private let logger: Logger
    private let stateMachine: StateMachine<ConfirmingPickupViewState>
    private let disposeBag: DisposeBag

    public init(pickupWaypoint: VehiclePlan.Waypoint,
                driverVehicleInteractor: DriverVehicleInteractor = DefaultDriverVehicleInteractor(),
                userStorageReader: UserStorageReader = UserDefaultsUserStorageReader(),
                deviceLocator: DeviceLocator = PotentiallySimulatedDeviceLocator(),
                style: Style = Style(),
                schedulerProvider: SchedulerProvider = DefaultSchedulerProvider(),
                logger: Logger = LoggerDependencyRegistry.instance.logger) {
        self.pickupWaypoint = pickupWaypoint
        self.driverVehicleInteractor = driverVehicleInteractor
        self.deviceLocator = deviceLocator
        self.userStorageReader = userStorageReader
        self.style = style
        self.logger = logger
        self.schedulerProvider = schedulerProvider

        tripResourceInfo = pickupWaypoint.action.tripResourceInfo
        stateMachine = StateMachine(schedulerProvider: schedulerProvider,
                                    initialState: .pickupUnconfirmed,
                                    logger: logger)
        disposeBag = DisposeBag()
    }

    public func confirmPickup() {
        guard let currentState = try? stateMachine.getCurrentState() else {
            return
        }

        switch currentState {
        case .pickupUnconfirmed, .failedToConfirmPickup:
            stateMachine.transition { _ in .confirmingPickup }

            driverVehicleInteractor.finishSteps(vehicleId: userStorageReader.userId,
                                                taskId: pickupWaypoint.taskId,
                                                stepIds: [String](pickupWaypoint.stepIds))
                .observeOn(schedulerProvider.io())
                .asObservable()
                .logErrorsAndRetry(logger: logger)
                .subscribe(
                    onError: { [stateMachine] _ in
                        stateMachine.transition { _ in .failedToConfirmPickup }
                    },
                    onCompleted: { [stateMachine] in
                        stateMachine.transition { _ in .confirmedPickup }
                    }
                )
                .disposed(by: disposeBag)
        default:
            return
        }
    }
}

// MARK: MapStateProvider

extension DefaultWaitingForPickupViewModel: MapStateProvider {
    public func getMapSettings() -> Observable<MapSettings> {
        return Observable.just(MapSettings(shouldShowUserLocation: false))
    }

    public func getCameraUpdates() -> Observable<CameraUpdate> {
        return Observable.combineLatest(deviceLocator.observeCurrentLocation(),
                                        Observable.just(pickupWaypoint.action.destination))
            .map { currentLocation, pickupLocationCoordinate in
                CameraUpdate.fitLatLngBounds(LatLngBounds(containingCoordinates: [currentLocation.coordinate,
                                                                                  pickupLocationCoordinate]))
            }
    }

    public func getMarkers() -> Observable<[String: DrawableMarker]> {
        return Observable.combineLatest(deviceLocator.observeCurrentLocation(),
                                        Observable.just(pickupWaypoint.action.destination))
            .map { [style] currentLocation, pickupLocationCoordinate in
                [
                    "vehicle": DrawableMarker(coordinate: currentLocation.coordinate,
                                              heading: currentLocation.course,
                                              icon: style.vehicleIcon),
                    "pickup": DrawableMarker(coordinate: pickupLocationCoordinate, icon: style.pickupLocationIcon),
                ]
            }
    }
}
