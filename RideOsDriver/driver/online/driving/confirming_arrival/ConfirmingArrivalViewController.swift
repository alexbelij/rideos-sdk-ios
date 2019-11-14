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

public class ConfirmingArrivalViewController: BackgroundMapViewController {
    private let openTripDetailsListener: () -> Void
    private let confirmArrivalListener: () -> Void
    private let backToNavigationListener: () -> Void
    private let confirmingArrivalDialogView: ConfirmingArrivalDialogView
    private let confirmingArrivalViewModel: ConfirmingArrivalViewModel
    private let schedulerProvider: SchedulerProvider
    private let disposeBag = DisposeBag()

    public convenience init(passengerTextFormat: String,
                            destinationWaypoint: VehiclePlan.Waypoint,
                            destinationIcon: DrawableMarkerIcon,
                            openTripDetailsListener: @escaping () -> Void,
                            confirmArrivalListener: @escaping () -> Void,
                            backToNavigationListener: @escaping () -> Void,
                            mapViewController: MapViewController,
                            showBackToNavigation: Bool,
                            schedulerProvider: SchedulerProvider = DefaultSchedulerProvider()) {
        let passengerTextProvider: TripResourceInfo.PassengerTextProvider = { tripResourceInfo in
            String(format: passengerTextFormat, TripResourceInfo.defaultPassengerTextProvider(tripResourceInfo))
        }

        let style = DefaultConfirmingArrivalViewModel.Style(
            passengerTextProvider: passengerTextProvider,
            destinationIcon: destinationIcon
        )

        self.init(confirmingArrivalViewModel: DefaultConfirmingArrivalViewModel(
            destinationWaypoint: destinationWaypoint,
            style: style
        ),
                  openTripDetailsListener: openTripDetailsListener,
                  confirmArrivalListener: confirmArrivalListener,
                  backToNavigationListener: backToNavigationListener,
                  mapViewController: mapViewController,
                  showBackToNavigation: showBackToNavigation,
                  schedulerProvider: schedulerProvider)
    }

    public init(confirmingArrivalViewModel: ConfirmingArrivalViewModel,
                openTripDetailsListener: @escaping () -> Void,
                confirmArrivalListener: @escaping () -> Void,
                backToNavigationListener: @escaping () -> Void,
                mapViewController: MapViewController,
                showBackToNavigation: Bool,
                schedulerProvider: SchedulerProvider = DefaultSchedulerProvider()) {
        self.confirmingArrivalViewModel = confirmingArrivalViewModel
        self.openTripDetailsListener = openTripDetailsListener
        self.confirmArrivalListener = confirmArrivalListener
        self.backToNavigationListener = backToNavigationListener
        self.schedulerProvider = schedulerProvider

        confirmingArrivalDialogView = ConfirmingArrivalDialogView(
            headerText: confirmingArrivalViewModel.passengersText,
            showBackToNavigationButton: showBackToNavigation
        )

        super.init(mapViewController: mapViewController)
    }

    required init?(coder _: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        confirmingArrivalDialogView.showDetailsTapEvents
            .observeOn(schedulerProvider.mainThread())
            .subscribe(onNext: { [openTripDetailsListener] _ in openTripDetailsListener() })
            .disposed(by: disposeBag)

        confirmingArrivalDialogView.confirmArrivalButtonTapEvents
            .observeOn(schedulerProvider.mainThread())
            .subscribe(onNext: { [confirmingArrivalViewModel] _ in confirmingArrivalViewModel.confirmArrival() })
            .disposed(by: disposeBag)

        confirmingArrivalDialogView.backToNavigationButtonTapEvents
            .observeOn(schedulerProvider.mainThread())
            .subscribe(onNext: { [backToNavigationListener] _ in backToNavigationListener() })
            .disposed(by: disposeBag)

        confirmingArrivalViewModel.addressText
            .observeOn(schedulerProvider.mainThread())
            .subscribe(onNext: { [confirmingArrivalDialogView] in confirmingArrivalDialogView.set(mainText: $0) })
            .disposed(by: disposeBag)

        confirmingArrivalViewModel.confirmingArrivalState
            .observeOn(schedulerProvider.mainThread())
            .subscribe(onNext: { [unowned self] currentState in
                switch currentState {
                case .arrivalUnconfirmed:
                    self.confirmingArrivalDialogView.isConfirmArrivalButtonEnabled = true
                case .confirmingArrival:
                    self.confirmingArrivalDialogView.isConfirmArrivalButtonEnabled = false
                case .confirmedArrival:
                    self.confirmingArrivalDialogView.isConfirmArrivalButtonEnabled = false
                    self.confirmArrivalListener()
                case .failedToConfirmArrival:
                    self.confirmingArrivalDialogView.isConfirmArrivalButtonEnabled = true
                    self.present(self.confirmArrivalFailedAlertController(),
                                 animated: true,
                                 completion: nil)
                }

            })
            .disposed(by: disposeBag)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presentBottomDialogStackView(confirmingArrivalDialogView) { [mapViewController, confirmingArrivalViewModel] in
            mapViewController.connect(mapStateProvider: confirmingArrivalViewModel)
        }
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        dismissBottomDialogStackView(confirmingArrivalDialogView)
    }
}

extension ConfirmingArrivalViewController {
    private func confirmArrivalFailedAlertController() -> UIAlertController {
        let alertController = UIAlertController(
            title: RideOsDriverResourceLoader.instance.getString(
                "ai.rideos.driver.online.confirm-arrival-failed-alert.title"
            ),
            message: RideOsDriverResourceLoader.instance.getString(
                "ai.rideos.driver.online.confirm-arrival-failed-alert.message"
            ),
            preferredStyle: UIAlertController.Style.alert
        )

        alertController.addAction(
            UIAlertAction(
                title: RideOsDriverResourceLoader.instance.getString(
                    "ai.rideos.driver.online.confirm-arrival-failed-alert.action.ok"
                ),
                style: UIAlertAction.Style.default
            )
        )
        return alertController
    }
}
