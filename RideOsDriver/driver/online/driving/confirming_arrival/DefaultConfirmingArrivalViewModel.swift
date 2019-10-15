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
import RxOptional
import RxSwift
import RxSwiftExt

public class DefaultConfirmingArrivalViewModel: ConfirmingArrivalViewModel {
    private static let geocodeRepeatBehavior = RepeatBehavior.immediate(maxCount: 2)

    public struct Style {
        public let destinationIcon: DrawableMarkerIcon
        public let vehicleIcon: DrawableMarkerIcon

        public init(destinationIcon: DrawableMarkerIcon = DrawableMarkerIcons.dropoffPin(),
                    vehicleIcon: DrawableMarkerIcon = DrawableMarkerIcons.car()) {
            self.destinationIcon = destinationIcon
            self.vehicleIcon = vehicleIcon
        }
    }

    public var arrivalDetailText: Observable<String> {
        return reverseGeocodeObservable().map { $0.displayName }
    }

    public var confirmingArrivalState: Observable<ConfirmingArrivalViewState> {
        return stateMachine.observeCurrentState()
    }

    private let destinationWaypoint: VehiclePlan.Waypoint
    private let driverVehicleInteractor: DriverVehicleInteractor
    private let geocodeInteractor: GeocodeInteractor
    private let userStorageReader: UserStorageReader
    private let deviceLocator: DeviceLocator
    private let style: Style
    private let schedulerProvider: SchedulerProvider
    private let logger: Logger
    private let stateMachine: StateMachine<ConfirmingArrivalViewState>
    private let disposeBag: DisposeBag

    public init(destinationWaypoint: VehiclePlan.Waypoint,
                deviceLocator: DeviceLocator = PotentiallySimulatedDeviceLocator(),
                driverVehicleInteractor: DriverVehicleInteractor = DefaultDriverVehicleInteractor(),
                geocodeInteractor: GeocodeInteractor =
                    DriverDependencyRegistry.instance.mapsDependencyFactory.geocodeInteractor,
                userStorageReader: UserStorageReader = UserDefaultsUserStorageReader(),
                style: Style = Style(),
                schedulerProvider: SchedulerProvider = DefaultSchedulerProvider(),
                logger: Logger = LoggerDependencyRegistry.instance.logger) {
        self.destinationWaypoint = destinationWaypoint
        self.driverVehicleInteractor = driverVehicleInteractor
        self.geocodeInteractor = geocodeInteractor
        self.userStorageReader = userStorageReader
        self.deviceLocator = deviceLocator
        self.style = style
        self.schedulerProvider = schedulerProvider
        self.logger = logger

        stateMachine = StateMachine(schedulerProvider: schedulerProvider,
                                    initialState: .arrivalUnconfirmed,
                                    logger: logger)
        disposeBag = DisposeBag()
    }

    public func confirmArrival() {
        guard let currentState = try? stateMachine.getCurrentState() else {
            return
        }

        switch currentState {
        case .arrivalUnconfirmed, .failedToConfirmArrival:
            stateMachine.transition { _ in .confirmingArrival }

            driverVehicleInteractor.finishSteps(vehicleId: userStorageReader.userId,
                                                taskId: destinationWaypoint.taskId,
                                                stepIds: [String](destinationWaypoint.stepIds))
                .observeOn(schedulerProvider.io())
                .asObservable()
                .logErrorsAndRetry(logger: logger)
                .subscribe(
                    onError: { [stateMachine] _ in
                        stateMachine.transition { _ in .failedToConfirmArrival }
                    },
                    onCompleted: { [stateMachine] in
                        stateMachine.transition { _ in .confirmedArrival }
                    }
                )
                .disposed(by: disposeBag)
        default:
            return
        }
    }

    private func reverseGeocodeObservable() -> Observable<GeocodedLocationModel> {
        return geocodeInteractor.reverseGeocode(location: destinationWaypoint.action.destination, maxResults: 1)
            .observeOn(schedulerProvider.computation())
            .logErrors(logger: logger)
            .retry(DefaultConfirmingArrivalViewModel.geocodeRepeatBehavior)
            .map { $0.first }
            .filterNil()
            .share(replay: 1)
    }
}

// MARK: MapStateProvider

extension DefaultConfirmingArrivalViewModel: MapStateProvider {
    public func getMapSettings() -> Observable<MapSettings> {
        return Observable.just(MapSettings(shouldShowUserLocation: false))
    }

    public func getCameraUpdates() -> Observable<CameraUpdate> {
        return Observable.combineLatest(deviceLocator.observeCurrentLocation(),
                                        Observable.just(destinationWaypoint.action.destination))
            .map { currentLocation, destinationCoordinate in
                CameraUpdate.fitLatLngBounds(LatLngBounds(containingCoordinates: [currentLocation.coordinate,
                                                                                  destinationCoordinate]))
            }
    }

    public func getMarkers() -> Observable<[String: DrawableMarker]> {
        return Observable.combineLatest(deviceLocator.observeCurrentLocation(), reverseGeocodeObservable())
            .map { [style] currentLocation, destination in
                [
                    "vehicle": DrawableMarker(coordinate: currentLocation.coordinate,
                                              heading: currentLocation.course,
                                              icon: style.vehicleIcon),
                    "destination": DrawableMarker(coordinate: destination.location, icon: style.destinationIcon),
                ]
            }
    }
}
