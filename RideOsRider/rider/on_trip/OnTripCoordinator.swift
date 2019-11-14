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

public class OnTripCoordinator: Coordinator {
    private let disposeBag = DisposeBag()

    private let viewModel: OnTripViewModel
    private let tripId: String
    private let mapViewController: MapViewController
    private let schedulerProvider: SchedulerProvider

    public convenience init(tripId: String,
                            tripFinishedListener: TripFinishedListener,
                            mapViewController: MapViewController,
                            navigationController: UINavigationController) {
        self.init(viewModel: DefaultOnTripViewModel(tripId: tripId, tripFinishedListener: tripFinishedListener),
                  tripId: tripId,
                  mapViewController: mapViewController,
                  navigationController: navigationController,
                  schedulerProvider: DefaultSchedulerProvider())
    }

    public init(viewModel: OnTripViewModel,
                tripId: String,
                mapViewController: MapViewController,
                navigationController: UINavigationController,
                schedulerProvider: SchedulerProvider = DefaultSchedulerProvider()) {
        self.viewModel = viewModel
        self.tripId = tripId
        self.mapViewController = mapViewController
        self.schedulerProvider = schedulerProvider
        super.init(navigationController: navigationController)
    }

    public override func activate() {
        viewModel.displayState
            .observeOn(schedulerProvider.mainThread())
            .subscribe(onNext: { [unowned self] displayState in
                switch displayState {
                case .currentTrip:
                    self.showCurrentTrip()
                case let .editingPickup(existingPickupLocation, existingDropoffLocation):
                    self.showEditingPickup(existingPickupLocation: existingPickupLocation,
                                           existingDropoffLocation: existingDropoffLocation)
                case let .editingDropoff(existingPickupLocation, existingDropoffLocation):
                    self.showEditingDropoff(existingPickupLocation: existingPickupLocation,
                                            existingDropoffLocation: existingDropoffLocation)
                case .updatingPickup:
                    self.showUpdatingPickup()
                case .updatingDropoff:
                    self.showUpdatingDropoff()
                }
            })
            .disposed(by: disposeBag)
    }

    private func showCurrentTrip() {
        showChild(coordinator: CurrentTripCoordinator(tripId: tripId,
                                                      listener: viewModel,
                                                      tripFinishedListener: viewModel,
                                                      mapViewController: mapViewController,
                                                      navigationController: navigationController))
    }

    private func showEditingPickup(existingPickupLocation: DesiredAndAssignedLocation,
                                   existingDropoffLocation: DesiredAndAssignedLocation) {
        showChild(coordinator: SetPickupDropoffCoordinator(
            listener: viewModel,
            mapViewController: mapViewController,
            navigationController: navigationController,
            initialPickup: PreTripLocation(desiredAndAssignedLocation: existingPickupLocation, wasConfirmed: true),
            initialDropoff: PreTripLocation(desiredAndAssignedLocation: existingDropoffLocation, wasConfirmed: true),
            initialFocus: .pickup,
            enablePickupSearch: true,
            enableDropoffSearch: false
        ))
    }

    private func showEditingDropoff(existingPickupLocation: DesiredAndAssignedLocation,
                                    existingDropoffLocation: DesiredAndAssignedLocation) {
        showChild(coordinator: SetPickupDropoffCoordinator(
            listener: viewModel,
            mapViewController: mapViewController,
            navigationController: navigationController,
            initialPickup: PreTripLocation(desiredAndAssignedLocation: existingPickupLocation, wasConfirmed: true),
            initialDropoff: PreTripLocation(desiredAndAssignedLocation: existingDropoffLocation, wasConfirmed: true),
            initialFocus: .dropoff,
            enablePickupSearch: false,
            enableDropoffSearch: true
        ))
    }

    private func showUpdatingPickup() {
        showChild(viewController: ProgressIndicatorViewController(
            mapViewController: mapViewController,
            headerText: RideOsRiderResourceLoader.instance.getString("ai.rideos.rider.on-trip.updating-pickup.header")
        ))
    }

    private func showUpdatingDropoff() {
        showChild(viewController: ProgressIndicatorViewController(
            mapViewController: mapViewController,
            headerText: RideOsRiderResourceLoader.instance.getString("ai.rideos.rider.on-trip.updating-dropoff.header")
        ))
    }
}
