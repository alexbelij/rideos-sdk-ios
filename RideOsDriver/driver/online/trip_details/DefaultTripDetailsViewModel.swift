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
import RxCocoa
import RxSwift

public class DefaultTripDetailsViewModel: NSObject, TripDetailsViewModel {
    public typealias TripDetailActionTextProvider = (TripDetail.ActionToPerform) -> TripDetailActionText

    public static let defaultTripDetailActionTextProvider: TripDetailActionTextProvider = { actionToPerform in
        let actionText: String
        let confirmationTitle: String
        let confirmationMessage: String
        let confirmationActionTitle: String

        switch actionToPerform {
        case .rejectTrip:
            actionText = RideOsDriverResourceLoader.instance.getString(
                "ai.rideos.driver.trip-details.action.reject-trip"
            )
            confirmationTitle = RideOsDriverResourceLoader.instance.getString(
                "ai.rideos.driver.trip-details.confirm-reject-trip-alert.title"
            )
            confirmationMessage = RideOsDriverResourceLoader.instance.getString(
                "ai.rideos.driver.trip-details.confirm-reject-trip-alert.message"
            )
            confirmationActionTitle = RideOsDriverResourceLoader.instance.getString(
                "ai.rideos.driver.trip-details.confirm-reject-trip-alert.confirm.title"
            )
        case .cancelTrip:
            actionText = RideOsDriverResourceLoader.instance.getString(
                "ai.rideos.driver.trip-details.action.cancel-trip"
            )
            confirmationTitle = RideOsDriverResourceLoader.instance.getString(
                "ai.rideos.driver.trip-details.confirm-cancel-trip-alert.title"
            )
            confirmationMessage = RideOsDriverResourceLoader.instance.getString(
                "ai.rideos.driver.trip-details.confirm-cancel-trip-alert.message"
            )
            confirmationActionTitle = RideOsDriverResourceLoader.instance.getString(
                "ai.rideos.driver.trip-details.confirm-cancel-trip-alert.confirm.title"
            )
        case .endTrip:
            actionText = RideOsDriverResourceLoader.instance.getString(
                "ai.rideos.driver.trip-details.action.end-trip"
            )
            confirmationTitle = RideOsDriverResourceLoader.instance.getString(
                "ai.rideos.driver.trip-details.confirm-end-trip-alert.title"
            )
            confirmationMessage = RideOsDriverResourceLoader.instance.getString(
                "ai.rideos.driver.trip-details.confirm-end-trip-alert.message"
            )
            confirmationActionTitle = RideOsDriverResourceLoader.instance.getString(
                "ai.rideos.driver.trip-details.confirm-end-trip-alert.confirm.title"
            )
        }

        return TripDetailActionText(
            actionText: actionText,
            confirmationTitle: confirmationTitle,
            confirmationMessage: confirmationMessage,
            confirmationActionTitle: confirmationActionTitle
        )
    }

    public struct Style {
        public let passengerTextProvider: TripResourceInfo.PassengerTextProvider
        public let tripDetailActionTextProvider: TripDetailActionTextProvider

        public init(
            passengerTextProvider: @escaping TripResourceInfo.PassengerTextProvider =
                TripResourceInfo.defaultPassengerTextProvider,
            tripDetailActionTextProvider: @escaping TripDetailActionTextProvider = defaultTripDetailActionTextProvider
        ) {
            self.passengerTextProvider = passengerTextProvider
            self.tripDetailActionTextProvider = tripDetailActionTextProvider
        }
    }

    public var tripDetailSections: Observable<[TripDetailSection]> {
        return tripDetails.map { tripDetails in
            tripDetails.map { [unowned self] tripDetail in
                let actionText = self.style.tripDetailActionTextProvider(tripDetail.actionToPerform)
                let actionCompletable: Completable

                switch tripDetail.actionToPerform {
                case .rejectTrip:
                    actionCompletable = self.driverVehicleInteractor.rejectTrip(
                        vehicleId: self.userStorageReader.userId,
                        tripId: tripDetail.nextWaypoint.taskId
                    )
                case .cancelTrip:
                    actionCompletable = self.driverVehicleInteractor.cancelTrip(tripId: tripDetail.nextWaypoint.taskId)
                case .endTrip:
                    actionCompletable = self.driverVehicleInteractor.finishSteps(
                        vehicleId: self.userStorageReader.userId,
                        taskId: tripDetail.nextWaypoint.taskId,
                        stepIds: [String](tripDetail.nextWaypoint.stepIds)
                    )
                }

                let action = { actionCompletable.subscribe().disposed(by: self.disposeBag) }

                if let pickupLocationDisplayName = tripDetail.pickupLocationDisplayName {
                    return TripDetailSection(items: [
                        .passengerItem(
                            passengerText: tripDetail.passengerDisplayText,
                            contactUrl: tripDetail.passengerContactUrl
                        ),
                        .pickupAddressItem(addressText: pickupLocationDisplayName),
                        .dropoffAddressItem(addressText: tripDetail.dropoffLocationDisplayName),
                        .tripActionItem(actionText: actionText, action: action),
                    ])
                } else {
                    return TripDetailSection(items: [
                        .passengerItem(
                            passengerText: tripDetail.passengerDisplayText,
                            contactUrl: tripDetail.passengerContactUrl
                        ),
                        .dropoffAddressItem(addressText: tripDetail.dropoffLocationDisplayName),
                        .tripActionItem(actionText: actionText, action: action),
                    ])
                }
            }
        }
        .asObservable()
    }

    private let vehiclePlan: VehiclePlan
    private let userStorageReader: UserStorageReader
    private let driverVehicleInteractor: DriverVehicleInteractor
    private let geocodeInteractor: GeocodeInteractor
    private let style: Style
    private let schedulerProvider: SchedulerProvider
    private let disposeBag = DisposeBag()

    public init(vehiclePlan: VehiclePlan,
                userStorageReader: UserStorageReader = UserDefaultsUserStorageReader(),
                driverVehicleInteractor: DriverVehicleInteractor = DefaultDriverVehicleInteractor(),
                geocodeInteractor: GeocodeInteractor =
                    DriverDependencyRegistry.instance.mapsDependencyFactory.geocodeInteractor,
                style: Style = Style(),
                schedulerProvider: SchedulerProvider = DefaultSchedulerProvider()) {
        self.vehiclePlan = vehiclePlan
        self.userStorageReader = userStorageReader
        self.driverVehicleInteractor = driverVehicleInteractor
        self.geocodeInteractor = geocodeInteractor
        self.style = style
        self.schedulerProvider = schedulerProvider

        super.init()
    }

    private var tripDetails: Single<[TripDetail]> {
        var tripsAndNextWaypoint = [String: VehiclePlan.Waypoint]()
        var tripPickupLocations = [String: CLLocationCoordinate2D]()
        var tripDropoffLocations = [String: CLLocationCoordinate2D]()

        for waypoint in vehiclePlan.waypoints {
            if tripsAndNextWaypoint[waypoint.taskId] == nil {
                tripsAndNextWaypoint[waypoint.taskId] = waypoint
            }

            switch waypoint.action.actionType {
            case .driveToPickup, .loadResource:
                tripPickupLocations[waypoint.taskId] = waypoint.action.destination
            case .driveToDropoff:
                tripDropoffLocations[waypoint.taskId] = waypoint.action.destination
            }
        }

        let passengerDisplayTextProvider = style.passengerTextProvider

        return Single.zip(geocodeLocationCollection(tripPickupLocations),
                          geocodeLocationCollection(tripDropoffLocations))
            .observeOn(schedulerProvider.computation())
            .map { geocodedPickupAndDropoffs -> [TripDetail] in
                let geocodedPickups = geocodedPickupAndDropoffs.0
                let geocodedDropoffs = geocodedPickupAndDropoffs.1

                return tripsAndNextWaypoint.values.map { waypoint in
                    TripDetail(
                        nextWaypoint: waypoint,
                        actionToPerform: DefaultTripDetailsViewModel.actionForWaypoint(waypoint),
                        passengerDisplayText: passengerDisplayTextProvider(waypoint.action.tripResourceInfo),
                        passengerContactUrl: waypoint.action.tripResourceInfo.contactInfo.url,
                        pickupLocationDisplayName: geocodedPickups[waypoint.taskId],
                        dropoffLocationDisplayName: geocodedDropoffs[waypoint.taskId] ?? ""
                    )
                }
            }
    }

    private static func actionForWaypoint(_ waypoint: VehiclePlan.Waypoint) -> TripDetail.ActionToPerform {
        switch waypoint.action.actionType {
        case .driveToPickup:
            return .rejectTrip
        case .loadResource:
            return .cancelTrip
        case .driveToDropoff:
            return .endTrip
        }
    }

    private func geocodeLocationCollection(_ locations: [String: CLLocationCoordinate2D]) -> Single<[String: String]> {
        let taskIdAndLocationDisplayNamePairsObservable: [Observable<(String, String)>] =
            locations.map { taskId, locationCoordinate in
                geocodeInteractor.reverseGeocode(location: locationCoordinate, maxResults: 1)
                    .observeOn(schedulerProvider.computation())
                    .map { geocodedLocationModels in
                        guard let geocodedLocationModel = geocodedLocationModels.first else {
                            return (taskId, "")
                        }

                        return (taskId, geocodedLocationModel.displayName)
                    }
            }

        return Observable.merge(taskIdAndLocationDisplayNamePairsObservable)
            .observeOn(schedulerProvider.computation())
            .toArray()
            .map { taskIdAndLocationDisplayNamePairs in
                taskIdAndLocationDisplayNamePairs.reduce(into: [:]) { result, taskIdAndLocationDisplayNamePair in
                    result[taskIdAndLocationDisplayNamePair.0] = taskIdAndLocationDisplayNamePair.1
                }
            }
            .asSingle()
    }
}
