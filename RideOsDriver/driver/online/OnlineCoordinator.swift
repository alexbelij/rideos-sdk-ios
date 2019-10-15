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

        super.init(navigationController: navigationController)
    }

    public override func activate() {
        onlineViewModel.getOnlineViewState()
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
                }
            })
            .disposed(by: disposeBag)
    }

    private func showIdle() {
        showChild(viewController: IdleViewController(goOfflineListener: onlineViewModel,
                                                     mapViewController: mapViewController))
    }

    private func showDrivingToPickup(waypoint: VehiclePlan.Waypoint) {
        showChild(coordinator: DrivingCoordinator.forPickup(destinationWaypoint: waypoint,
                                                            mapViewController: mapViewController,
                                                            navigationController: navigationController))
    }

    private func showWaitingForPassengers(waypoint: VehiclePlan.Waypoint) {
        showChild(viewController: WaitingForPickupViewController(pickupWaypoint: waypoint,
                                                                 mapViewController: mapViewController))
    }

    private func showDrivingToDropoff(waypoint: VehiclePlan.Waypoint) {
        showChild(coordinator: DrivingCoordinator.forDropoff(destinationWaypoint: waypoint,
                                                             mapViewController: mapViewController,
                                                             navigationController: navigationController))
    }
}
