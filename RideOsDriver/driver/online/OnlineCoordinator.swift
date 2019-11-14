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

public class OnlineCoordinator: Coordinator {
    private let disposeBag = DisposeBag()

    private let onlineViewModel: OnlineViewModel
    private var drivingCoordinator: DrivingCoordinator
    private let mapViewController: MapViewController
    private let schedulerProvider: SchedulerProvider

    public convenience init(goOfflineListener: GoOfflineListener,
                            mapViewController: MapViewController,
                            navigationController: UINavigationController) {
        self.init(mapViewController: mapViewController,
                  onlineViewModel: DefaultOnlineViewModel(goOfflineListener: goOfflineListener),
                  navigationController: navigationController,
                  schedulerProvider: DefaultSchedulerProvider())
    }

    public init(mapViewController: MapViewController,
                onlineViewModel: OnlineViewModel,
                navigationController: UINavigationController,
                schedulerProvider: SchedulerProvider) {
        self.onlineViewModel = onlineViewModel
        self.mapViewController = mapViewController
        self.schedulerProvider = schedulerProvider

        drivingCoordinator = DrivingCoordinator(
            mapViewController: mapViewController,
            openTripDetailsListener: { [onlineViewModel] in onlineViewModel.openTripDetails() },
            navigationController: navigationController
        )

        super.init(navigationController: navigationController)
    }

    public override func activate() {
        onlineViewModel.onlineViewState
            .observeOn(schedulerProvider.mainThread())
            .subscribe(onNext: { [unowned self] onlineViewState in
                switch onlineViewState {
                case .idle:
                    self.showIdle()
                case let .drivingToPickup(waypoint):
                    self.showDrivingToPickup(waypoint: waypoint)
                case let .waitingForPassenger(waypoint):
                    self.showWaitingForPassengers(waypoint: waypoint)
                case let .drivingToDropoff(waypoint):
                    self.showDrivingToDropoff(waypoint: waypoint)
                case let .tripDetails(plan):
                    self.showTripDetails(plan: plan)
                }
            })
            .disposed(by: disposeBag)
    }

    private func showIdle() {
        showChild(viewController: IdleViewController(goOfflineListener: onlineViewModel,
                                                     mapViewController: mapViewController))
    }

    private func showDrivingToPickup(waypoint: VehiclePlan.Waypoint) {
        DrivingCoordinator.startPickup(with: waypoint, coordinator: drivingCoordinator)

        showChild(coordinator: drivingCoordinator)
    }

    private func showWaitingForPassengers(waypoint: VehiclePlan.Waypoint) {
        let openTripDetailsListener = { [onlineViewModel] in onlineViewModel.openTripDetails() }

        showChild(viewController: WaitingForPickupViewController(pickupWaypoint: waypoint,
                                                                 mapViewController: mapViewController,
                                                                 openTripDetailsListener: openTripDetailsListener))
    }

    private func showDrivingToDropoff(waypoint: VehiclePlan.Waypoint) {
        DrivingCoordinator.startDropoff(with: waypoint, coordinator: drivingCoordinator)

        showChild(coordinator: drivingCoordinator)
    }

    private func showTripDetails(plan: VehiclePlan) {
        let onDismiss = { [onlineViewModel] in
            onlineViewModel.closeTripDetails()
        }

        showChild(viewController: TripDetailsViewController(vehiclePlan: plan, onDismiss: onDismiss))
    }
}
