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

public class WaitingForPickupViewController: BackgroundMapViewController {
    private let waitingForPickupDialogView: WatingForPickupDialogView
    private let waitingForPickupViewModel: WaitingForPickupViewModel
    private let openTripDetailsListener: () -> Void
    private let schedulerProvider: SchedulerProvider
    private let disposeBag = DisposeBag()

    public convenience init(pickupWaypoint: VehiclePlan.Waypoint,
                            mapViewController: MapViewController,
                            openTripDetailsListener: @escaping () -> Void,
                            schedulerProvider: SchedulerProvider = DefaultSchedulerProvider()) {
        let viewModel = DefaultWaitingForPickupViewModel(pickupWaypoint: pickupWaypoint)

        self.init(viewModel: viewModel,
                  mapViewController: mapViewController,
                  openTripDetailsListener: openTripDetailsListener,
                  schedulerProvider: schedulerProvider)
    }

    public init(viewModel: WaitingForPickupViewModel,
                mapViewController: MapViewController,
                openTripDetailsListener: @escaping () -> Void,
                schedulerProvider: SchedulerProvider = DefaultSchedulerProvider()) {
        self.openTripDetailsListener = openTripDetailsListener
        self.schedulerProvider = schedulerProvider
        waitingForPickupViewModel = viewModel

        waitingForPickupDialogView = WatingForPickupDialogView(headerText: viewModel.passengersText)

        super.init(mapViewController: mapViewController)
    }

    required init?(coder _: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        waitingForPickupDialogView.showDetailsTapEvents
            .observeOn(schedulerProvider.mainThread())
            .subscribe(onNext: { [openTripDetailsListener] _ in openTripDetailsListener() })
            .disposed(by: disposeBag)

        waitingForPickupDialogView.confirmPickupTapEvents
            .observeOn(schedulerProvider.mainThread())
            .subscribe(onNext: { [waitingForPickupViewModel] _ in waitingForPickupViewModel.confirmPickup() })
            .disposed(by: disposeBag)

        waitingForPickupViewModel.addressText
            .observeOn(schedulerProvider.mainThread())
            .subscribe(onNext: { [waitingForPickupDialogView] in waitingForPickupDialogView.set(mainText: $0) })
            .disposed(by: disposeBag)

        waitingForPickupViewModel.confirmingPickupState
            .observeOn(schedulerProvider.mainThread())
            .subscribe(onNext: { [unowned self] currentState in
                switch currentState {
                case .pickupUnconfirmed:
                    self.waitingForPickupDialogView.isConfirmPickupButtonEnabled = true
                case .confirmingPickup:
                    self.waitingForPickupDialogView.isConfirmPickupButtonEnabled = false
                case .confirmedPickup:
                    self.waitingForPickupDialogView.isConfirmPickupButtonEnabled = false
                case .failedToConfirmPickup:
                    self.waitingForPickupDialogView.isConfirmPickupButtonEnabled = true
                    self.present(self.confirmPickupFailedAlertController(),
                                 animated: true,
                                 completion: nil)
                }

            })
            .disposed(by: disposeBag)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presentBottomDialogStackView(waitingForPickupDialogView) { [mapViewController, waitingForPickupViewModel] in
            mapViewController.connect(mapStateProvider: waitingForPickupViewModel)
        }
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        dismissBottomDialogStackView(waitingForPickupDialogView)
    }
}

extension WaitingForPickupViewController {
    private func confirmPickupFailedAlertController() -> UIAlertController {
        let alertController = UIAlertController(
            title: RideOsDriverResourceLoader.instance.getString(
                "ai.rideos.driver.online.confirm-pickup-failed-alert.title"
            ),
            message: RideOsDriverResourceLoader.instance.getString(
                "ai.rideos.driver.online.confirm-pickup-failed-alert.message"
            ),
            preferredStyle: UIAlertController.Style.alert
        )

        alertController.addAction(
            UIAlertAction(
                title: RideOsDriverResourceLoader.instance.getString(
                    "ai.rideos.driver.online.confirm-pickup-failed-alert.action.ok"
                ),
                style: UIAlertAction.Style.default
            )
        )
        return alertController
    }
}
