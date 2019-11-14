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

public class DefaultOnlineViewModel: OnlineViewModel {
    private static let getPlanPollInterval: RxTimeInterval = 2.0
    private static let syncVehicleStateUpdateInterval: RxTimeInterval = 2.0
    private static let interactorRetryCount = 2

    public var onlineViewState: Observable<OnlineViewState> {
        return Observable.combineLatest(shouldShowTripDetailsSubject, currentPlan)
            .observeOn(schedulerProvider.computation())
            .map { shouldShowTripDetailsAndVehiclePlan -> OnlineViewState in
                let shouldShowTripDetails = shouldShowTripDetailsAndVehiclePlan.0
                let plan = shouldShowTripDetailsAndVehiclePlan.1

                if shouldShowTripDetails {
                    return .tripDetails(plan: plan)
                }

                guard !plan.waypoints.isEmpty else {
                    return .idle
                }

                let currentWaypoint = plan.waypoints[0]
                switch currentWaypoint.action.actionType {
                case .driveToPickup:
                    return .drivingToPickup(waypoint: currentWaypoint)
                case .driveToDropoff:
                    return .drivingToDropoff(waypoint: currentWaypoint)
                case .loadResource:
                    return .waitingForPassenger(waypoint: currentWaypoint)
                }
            }
            .distinctUntilChanged()
    }

    private let disposeBag = DisposeBag()

    private let forceGetPlanSubject = PublishSubject<Bool>()
    private let currentPlan = BehaviorSubject(value: VehiclePlan(waypoints: []))
    private let shouldShowTripDetailsSubject = BehaviorSubject(value: false)

    private weak var goOfflineListener: GoOfflineListener?
    private let driverPlanInteractor: DriverPlanInteractor
    private let vehicleStateSynchronizer: VehicleStateSynchronizer
    private let userStorageReader: UserStorageReader
    private let deviceLocator: DeviceLocator
    private let schedulerProvider: SchedulerProvider
    private let logger: Logger

    public init(goOfflineListener: GoOfflineListener,
                driverPlanInteractor: DriverPlanInteractor = DefaultDriverPlanInteractor(),
                vehicleStateSynchronizer: VehicleStateSynchronizer = DefaultVehicleStateSynchronizer(),
                userStorageReader: UserStorageReader = UserDefaultsUserStorageReader(),
                deviceLocator: DeviceLocator = PotentiallySimulatedDeviceLocator(),
                schedulerProvider: SchedulerProvider = DefaultSchedulerProvider(),
                logger: Logger = LoggerDependencyRegistry.instance.logger) {
        self.goOfflineListener = goOfflineListener
        self.driverPlanInteractor = driverPlanInteractor
        self.vehicleStateSynchronizer = vehicleStateSynchronizer
        self.userStorageReader = userStorageReader
        self.deviceLocator = deviceLocator
        self.schedulerProvider = schedulerProvider
        self.logger = logger

        startPollingForPlanUpdates()
        startSynchronizingVehicleState(deviceLocator: deviceLocator)
    }

    public func openTripDetails() {
        shouldShowTripDetailsSubject.onNext(true)
    }

    public func closeTripDetails() {
        shouldShowTripDetailsSubject.onNext(false)
    }

    private func startPollingForPlanUpdates() {
        Observable.combineLatest(Observable<Int>.interval(DefaultOnlineViewModel.getPlanPollInterval,
                                                          scheduler: schedulerProvider.io()),
                                 forceGetPlanSubject.startWith(true))
            .observeOn(schedulerProvider.io())
            .flatMapLatest { [unowned self] _ -> Observable<VehiclePlan> in
                self.getPlanWithRetry()
                    .logErrors(logger: self.logger)
                    .catchErrorJustComplete()
            }
            .subscribe(onNext: { [currentPlan] latestPlan in currentPlan.onNext(latestPlan) })
            .disposed(by: disposeBag)
    }

    private func startSynchronizingVehicleState(deviceLocator: DeviceLocator) {
        Observable.combineLatest(Observable<Int>.interval(DefaultOnlineViewModel.syncVehicleStateUpdateInterval,
                                                          scheduler: schedulerProvider.io()),
                                 forceGetPlanSubject.startWith(true))
            .observeOn(schedulerProvider.io())
            .withLatestFrom(deviceLocator.observeCurrentLocation())
            .flatMapLatest { [unowned self] latestLocation -> Completable in
                self.vehicleStateSynchronizer.synchronizeVehicleState(vehicleId: self.userStorageReader.userId,
                                                                      vehicleCoordinate: latestLocation.coordinate,
                                                                      vehicleHeading: latestLocation.course)
                    .asObservable()
                    .logErrors(logger: self.logger)
                    .catchErrorJustComplete()
                    .asCompletable()
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    private func getPlanWithRetry() -> Observable<VehiclePlan> {
        return driverPlanInteractor.getPlanForVehicle(vehicleId: userStorageReader.userId)
            .retry(DefaultOnlineViewModel.interactorRetryCount)
    }
}

// MARK: GoOfflineListener

extension DefaultOnlineViewModel: GoOfflineListener {
    public func didGoOffline() {
        goOfflineListener?.didGoOffline()
    }
}
