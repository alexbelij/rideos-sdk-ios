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
import RxSwiftExt

public class DefaultDrivePendingViewModel: DrivePendingViewModel {
    private static let geocodeRepeatBehavior = RepeatBehavior.immediate(maxCount: 2)

    public struct Style {
        public static let defaultPassengerTextProvider: TripResourceInfo.PassengerTextProvider = { tripResourceInfo in
            String(
                format: RideOsDriverResourceLoader.instance.getString(
                    "ai.rideos.driver.online.drive-to-pickup.passenger-text-format"
                ),
                TripResourceInfo.defaultPassengerTextProvider(tripResourceInfo)
            )
        }

        public let passengerTextProvider: TripResourceInfo.PassengerTextProvider
        public let drawablePathWidth: Float
        public let drawablePathColor: UIColor
        public let destinationIcon: DrawableMarkerIcon
        public let vehicleIcon: DrawableMarkerIcon

        public init(passengerTextProvider: @escaping TripResourceInfo.PassengerTextProvider,
                    drawablePathWidth: Float = 4.0,
                    drawablePathColor: UIColor = .gray,
                    destinationIcon: DrawableMarkerIcon = DrawableMarkerIcons.dropoffPin(),
                    vehicleIcon: DrawableMarkerIcon = DrawableMarkerIcons.car()) {
            self.passengerTextProvider = passengerTextProvider
            self.drawablePathWidth = drawablePathWidth
            self.drawablePathColor = drawablePathColor
            self.destinationIcon = destinationIcon
            self.vehicleIcon = vehicleIcon
        }
    }

    public var passengersText: String {
        return style.passengerTextProvider(tripResourceInfo)
    }

    public var addressText: Observable<String> {
        return reverseGeocodeObservable().map { $0.displayName }
    }

    private let tripResourceInfo: TripResourceInfo
    private let destinationWaypoint: VehiclePlan.Waypoint
    private let style: Style
    private let deviceLocator: DeviceLocator
    private let geocodeInteractor: GeocodeInteractor
    private let routeInteractor: RouteInteractor
    private let schedulerProvider: SchedulerProvider
    private let logger: Logger
    private let disposeBag = DisposeBag()

    public init(destinationWaypoint: VehiclePlan.Waypoint,
                style: Style,
                deviceLocator: DeviceLocator = PotentiallySimulatedDeviceLocator(),
                routeInteractor: RouteInteractor = RideOsRouteInteractor(),
                geocodeInteractor: GeocodeInteractor =
                    DriverDependencyRegistry.instance.mapsDependencyFactory.geocodeInteractor,
                schedulerProvider: SchedulerProvider = DefaultSchedulerProvider(),
                logger: Logger = LoggerDependencyRegistry.instance.logger) {
        self.destinationWaypoint = destinationWaypoint
        self.style = style
        self.deviceLocator = deviceLocator
        self.routeInteractor = routeInteractor
        self.geocodeInteractor = geocodeInteractor
        self.schedulerProvider = schedulerProvider
        self.logger = logger

        tripResourceInfo = destinationWaypoint.action.tripResourceInfo
    }

    private func routeFromCurrentLocationToDestination() -> Observable<RouteInfoModel> {
        return deviceLocator
            .observeCurrentLocation()
            .observeOn(schedulerProvider.io())
            .take(1)
            .flatMap { [routeInteractor, destinationWaypoint] in
                routeInteractor.getRoute(origin: $0.coordinate, destination: destinationWaypoint.action.destination)
            }
            .observeOn(schedulerProvider.computation())
            .map {
                RouteInfoModel(route: $0.coordinates,
                               travelTimeInSeconds: $0.travelTime,
                               travelDistanceInMeters: $0.travelDistanceMeters)
            }
            .share(replay: 1)
    }

    private func reverseGeocodeObservable() -> Observable<GeocodedLocationModel> {
        return geocodeInteractor.reverseGeocode(location: destinationWaypoint.action.destination, maxResults: 1)
            .observeOn(schedulerProvider.computation())
            .logErrors(logger: logger)
            .retry(DefaultDrivePendingViewModel.geocodeRepeatBehavior)
            .map { $0.first }
            .filterNil()
            .share(replay: 1)
    }
}

// MARK: MapStateProvider

extension DefaultDrivePendingViewModel: MapStateProvider {
    public func getMapSettings() -> Observable<MapSettings> {
        return Observable.just(MapSettings(shouldShowUserLocation: false))
    }

    public func getCameraUpdates() -> Observable<CameraUpdate> {
        return routeFromCurrentLocationToDestination().map {
            CameraUpdate.fitLatLngBounds(LatLngBounds(containingCoordinates: $0.route))
        }
    }

    public func getPaths() -> Observable<[DrawablePath]> {
        return routeFromCurrentLocationToDestination().map { [style] in
            [DrawablePath(coordinates: $0.route, width: style.drawablePathWidth, color: style.drawablePathColor)]
        }
    }

    public func getMarkers() -> Observable<[String: DrawableMarker]> {
        return Observable.combineLatest(deviceLocator.observeCurrentLocation(), routeFromCurrentLocationToDestination())
            .map { [style] currentLocation, routeInfo in
                guard let destination = routeInfo.route.last else {
                    logError("Route to pending drive destintation has no coordinate.")
                    return [String: DrawableMarker]()
                }

                return [
                    "vehicle": DrawableMarker(coordinate: currentLocation.coordinate,
                                              heading: currentLocation.course,
                                              icon: style.vehicleIcon),
                    "destination": DrawableMarker(coordinate: destination, icon: style.destinationIcon),
                ]
            }
    }
}
