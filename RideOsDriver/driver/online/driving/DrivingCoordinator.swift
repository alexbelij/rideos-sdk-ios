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
import RideOsCommon
import RxSwift

public class DrivingCoordinator: Coordinator {
    private let vehicleNavigationControllerProvider: () -> UIVehicleNavigationController
    private var drivingViewModel: DrivingViewModel?
    private var destinationWaypoint: VehiclePlan.Waypoint?
    private var destinationIcon: DrawableMarkerIcon?
    private var passengerTextFormat: String?
    private let mapViewController: MapViewController
    private let openTripDetailsListener: () -> Void
    private let schedulerProvider: SchedulerProvider
    private let logger: Logger
    private let disposeBag = DisposeBag()

    public convenience init(mapViewController: MapViewController,
                            openTripDetailsListener: @escaping () -> Void,
                            navigationController: UINavigationController,
                            userStorageReader: UserStorageReader = UserDefaultsUserStorageReader(),
                            schedulerProvider: SchedulerProvider = DefaultSchedulerProvider(),
                            logger: Logger = LoggerDependencyRegistry.instance.logger) {
        let vehicleNavigationControllerProvider: () -> UIVehicleNavigationController = {
            let simulatedDeviceLocator: SimulatedDeviceLocator?

            if userStorageReader.get(DriverDeveloperSettingsKeys.enableSimulatedNavigation) ?? false {
                simulatedDeviceLocator = SimulatedDeviceLocator.instance
            } else {
                simulatedDeviceLocator = nil
            }

            let viewModel = DefaultMapboxNavigationViewModel(schedulerProvider: schedulerProvider)

            return MapboxNavigationViewController(mapboxNavigationViewModel: viewModel,
                                                  mapViewController: mapViewController,
                                                  simulatedDeviceLocator: simulatedDeviceLocator,
                                                  schedulerProvider: schedulerProvider)
        }

        self.init(vehicleNavigationControllerProvider: vehicleNavigationControllerProvider,
                  mapViewController: mapViewController,
                  openTripDetailsListener: openTripDetailsListener,
                  navigationController: navigationController,
                  schedulerProvider: schedulerProvider,
                  logger: logger)
    }

    private init(vehicleNavigationControllerProvider: @escaping () -> UIVehicleNavigationController,
                 mapViewController: MapViewController,
                 openTripDetailsListener: @escaping () -> Void,
                 navigationController: UINavigationController,
                 schedulerProvider: SchedulerProvider = DefaultSchedulerProvider(),
                 logger: Logger = LoggerDependencyRegistry.instance.logger) {
        self.vehicleNavigationControllerProvider = vehicleNavigationControllerProvider
        self.mapViewController = mapViewController
        self.openTripDetailsListener = openTripDetailsListener
        self.schedulerProvider = schedulerProvider
        self.logger = logger

        super.init(navigationController: navigationController)
    }

    required init?(coder _: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    public func start(
        with waypoint: VehiclePlan.Waypoint,
        destinationIcon: DrawableMarkerIcon,
        passengerTextFormat: String
    ) {
        let viewModel: DrivingViewModel

        if let drivingViewModel = drivingViewModel, let currentState = try? drivingViewModel.getCurrentDrivingViewState() {
            if currentState.destination != waypoint.action.destination {
                viewModel = DefaultDrivingViewModel(destination: waypoint.action.destination)
            } else {
                viewModel = DefaultDrivingViewModel(
                    destination: waypoint.action.destination,
                    initialStep: currentState.drivingStep
                )
            }
        } else {
            viewModel = DefaultDrivingViewModel(destination: waypoint.action.destination)
        }

        drivingViewModel = viewModel
        destinationWaypoint = waypoint
        self.destinationIcon = destinationIcon
        self.passengerTextFormat = passengerTextFormat
    }

    public override func activate() {
        guard let drivingViewModel = drivingViewModel else {
            logger.logError("Must call start() before \(#function)")
            return
        }

        drivingViewModel.drivingViewState
            .observeOn(schedulerProvider.mainThread())
            .subscribe(onNext: { [unowned self] drivingState in
                switch drivingState.drivingStep {
                case .drivePending:
                    self.showDrivePending()
                case .navigating:
                    self.showNavigation()
                case let .confirmingArrival(showBackToNavigation):
                    self.showConfirmingArrival(showBackToNavgiation: showBackToNavigation)
                }
            })
            .disposed(by: disposeBag)
    }

    private func showDrivePending() {
        guard let drivingViewModel = drivingViewModel,
            let passengerTextFormat = passengerTextFormat,
            let destinationWaypoint = destinationWaypoint,
            let destinationIcon = destinationIcon else {
            logger.logError("Must call start() before \(#function)")
            return
        }

        let startNavigationListener = { [drivingViewModel] in drivingViewModel.startNavigation() }

        showChild(viewController: DrivePendingViewController(passengerTextFormat: passengerTextFormat,
                                                             destinationWaypoint: destinationWaypoint,
                                                             destinationIcon: destinationIcon,
                                                             openTripDetailsListener: openTripDetailsListener,
                                                             startNavigationListener: startNavigationListener,
                                                             mapViewController: mapViewController))
    }

    private func showNavigation() {
        guard let drivingViewModel = drivingViewModel,
            let destinationWaypoint = destinationWaypoint else {
            logger.logError("Must call start() before \(#function)")
            return
        }

        let controller = vehicleNavigationControllerProvider()
        showChild(viewController: controller)

        controller.navigate(to: destinationWaypoint.action.destination) { [drivingViewModel] didCancelNavigation in
            drivingViewModel.finishedNavigation(didCancelNavigation: didCancelNavigation)
        }
    }

    private func showConfirmingArrival(showBackToNavgiation: Bool) {
        guard let drivingViewModel = drivingViewModel,
            let passengerTextFormat = passengerTextFormat,
            let destinationWaypoint = destinationWaypoint,
            let destinationIcon = destinationIcon else {
            logger.logError("Must call start() before \(#function)")
            return
        }

        let confirmArrivalListener = { [drivingViewModel] in drivingViewModel.arrivalConfirmed() }
        let backToNavigationListener = { [drivingViewModel] in drivingViewModel.startNavigation() }

        showChild(viewController: ConfirmingArrivalViewController(passengerTextFormat: passengerTextFormat,
                                                                  destinationWaypoint: destinationWaypoint,
                                                                  destinationIcon: destinationIcon,
                                                                  openTripDetailsListener: openTripDetailsListener,
                                                                  confirmArrivalListener: confirmArrivalListener,
                                                                  backToNavigationListener: backToNavigationListener,
                                                                  mapViewController: mapViewController,
                                                                  showBackToNavigation: showBackToNavgiation))
    }
}

extension DrivingCoordinator {
    public static func startPickup(with waypoint: VehiclePlan.Waypoint, coordinator: DrivingCoordinator) {
        coordinator.start(
            with: waypoint,
            destinationIcon: DrawableMarkerIcons.pickupPin(),
            passengerTextFormat: RideOsDriverResourceLoader.instance.getString(
                "ai.rideos.driver.online.drive-to-pickup.passenger-text-format"
            )
        )
    }

    public static func startDropoff(with waypoint: VehiclePlan.Waypoint, coordinator: DrivingCoordinator) {
        coordinator.start(
            with: waypoint,
            destinationIcon: DrawableMarkerIcons.dropoffPin(),
            passengerTextFormat: RideOsDriverResourceLoader.instance.getString(
                "ai.rideos.driver.online.drive-to-dropoff.passenger-text-format"
            )
        )
    }
}
