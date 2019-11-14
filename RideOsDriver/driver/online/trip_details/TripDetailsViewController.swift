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

import RideOsCommon
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

public class TripDetailsViewController: UIViewController {
    private let tripDetailsViewModel: TripDetailsViewModel
    private let tripDetailsTableView = TripDetailsTableView()
    private let dialogActionButton = TripDetailsViewController.dialogActionButton()
    private let onDismiss: () -> Void
    private let urlLauncher: UrlLauncher
    private let schedulerProvider: SchedulerProvider
    private let disposeBag = DisposeBag()

    public convenience init(vehiclePlan: VehiclePlan,
                            onDismiss: @escaping () -> Void,
                            urlLauncher: UrlLauncher = DefaultUrlLauncher(),
                            schedulerProvider: SchedulerProvider = DefaultSchedulerProvider()) {
        self.init(
            tripDetailsViewModel: DefaultTripDetailsViewModel(vehiclePlan: vehiclePlan),
            onDismiss: onDismiss,
            urlLauncher: urlLauncher,
            schedulerProvider: schedulerProvider
        )
    }

    public init(tripDetailsViewModel: TripDetailsViewModel,
                onDismiss: @escaping () -> Void,
                urlLauncher: UrlLauncher = DefaultUrlLauncher(),
                schedulerProvider: SchedulerProvider = DefaultSchedulerProvider()) {
        self.tripDetailsViewModel = tripDetailsViewModel
        self.onDismiss = onDismiss
        self.urlLauncher = urlLauncher
        self.schedulerProvider = schedulerProvider

        super.init(nibName: nil, bundle: nil)

        dialogActionButton.rx.tap
            .observeOn(schedulerProvider.mainThread())
            .subscribe(onNext: { [unowned self] in self.dismissTripDetails() })
            .disposed(by: disposeBag)
    }

    required init?(coder _: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()

        view.addSubview(tripDetailsTableView)
        tripDetailsTableView.translatesAutoresizingMaskIntoConstraints = false
        tripDetailsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tripDetailsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tripDetailsTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tripDetailsTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        let bottomDialogView = TripDetailsViewController.bottomDialogView(actionButton: dialogActionButton)

        view.addSubview(bottomDialogView)
        bottomDialogView.translatesAutoresizingMaskIntoConstraints = false
        bottomDialogView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomDialogView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bottomDialogView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bottomDialogView.heightAnchor.constraint(equalToConstant: 104.0).isActive = true

        let dataSource = RxTableViewSectionedReloadDataSource<TripDetailSection>(
            configureCell: { _, _, _, item in
                switch item {
                case let .passengerItem(passengerText, contactUrl):
                    let contactAction: (() -> Void)?
                    if let contactUrl = contactUrl {
                        contactAction = { [unowned self] in
                            self.urlLauncher.launch(url: contactUrl, parentViewController: self)
                        }
                    } else {
                        contactAction = nil
                    }

                    return self.tripDetailsTableView.passengersTableViewCell(
                        passengerDisplayText: passengerText,
                        contactAction: contactAction,
                        disposeBag: self.disposeBag
                    )
                case let .pickupAddressItem(addressText):
                    return self.tripDetailsTableView.pickupLocationCell(addressText: addressText)
                case let .dropoffAddressItem(addressText):
                    return self.tripDetailsTableView.dropoffLocationCell(addressText: addressText)
                case let .tripActionItem(actionText, action):
                    return self.tripDetailsTableView.tripActionCell(
                        text: actionText.actionText,
                        action: { [unowned self] in
                            let alert = TripDetailsViewController.confirmActionAlertController(
                                alertTitle: actionText.confirmationTitle,
                                alertMessage: actionText.confirmationMessage,
                                alertConfirmActionTitle: actionText.confirmationActionTitle,
                                action: action
                            )
                            self.present(alert, animated: true, completion: nil)
                        },
                        disposeBag: self.disposeBag
                    )
                }
            }
        )

        tripDetailsViewModel.tripDetailSections
            .bind(to: tripDetailsTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    private func setupNavigationBar() {
        guard let navigationController = navigationController else {
            return
        }

        let cancelButtonBarItem = TripDetailsViewController.cancelBarButtonItem(
            target: self,
            selector: #selector(dismissTripDetails)
        )

        navigationController.isNavigationBarHidden = false
        navigationController.navigationBar.topItem?.leftBarButtonItem = cancelButtonBarItem
        navigationController.navigationBar.topItem?.titleView = TripDetailsViewController.navigationBarTitleView()
    }

    @objc
    private func dismissTripDetails() {
        navigationController?.isNavigationBarHidden = true
        onDismiss()
    }
}

extension TripDetailsViewController {
    private static func navigationBarTitleView() -> UIView {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.text = RideOsDriverResourceLoader.instance.getString(
            "ai.rideos.driver.trip-details.view-controller.title"
        )
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)

        return titleLabel
    }

    private static func cancelBarButtonItem(target: Any?, selector: Selector?) -> UIBarButtonItem {
        let cancelBarButtonItem = UIBarButtonItem(image: DriverImages.clear(),
                                                  style: .plain,
                                                  target: target,
                                                  action: selector)
        cancelBarButtonItem.imageInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)

        return cancelBarButtonItem
    }

    private static func dialogActionButton() -> UIButton {
        let actionButton = UIButton(type: .custom)
        actionButton.setTitle(
            RideOsDriverResourceLoader.instance.getString("ai.rideos.driver.trip-details.dialog.action.done"),
            for: .normal
        )
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 20.0)
        actionButton.layer.cornerRadius = 4.0
        actionButton.backgroundColor = UIColor(red: 0, green: 0.48, blue: 1, alpha: 1)

        return actionButton
    }

    private static func bottomDialogView(actionButton: UIButton) -> UIView {
        let dialogView = UIView(frame: .zero)
        dialogView.backgroundColor = UIColor(red: 0.15, green: 0.21, blue: 0.34, alpha: 1)

        dialogView.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.topAnchor.constraint(equalTo: dialogView.topAnchor, constant: 16.0).isActive = true
        actionButton.leftAnchor.constraint(equalTo: dialogView.leftAnchor, constant: 16.0).isActive = true
        actionButton.rightAnchor.constraint(equalTo: dialogView.rightAnchor, constant: -16.0).isActive = true
        actionButton.heightAnchor.constraint(equalToConstant: 56.0).isActive = true

        return dialogView
    }

    private static func confirmActionAlertController(alertTitle: String,
                                                     alertMessage: String,
                                                     alertConfirmActionTitle: String,
                                                     action: @escaping () -> Void) -> UIAlertController {
        let alertController = UIAlertController(
            title: alertTitle,
            message: alertMessage,
            preferredStyle: UIAlertController.Style.alert
        )

        alertController.addAction(
            UIAlertAction(
                title: RideOsDriverResourceLoader.instance.getString(
                    "ai.rideos.driver.trip-details.confirm-trip-action-alert.cancel.title"
                ),
                style: UIAlertAction.Style.default
            )
        )

        alertController.addAction(
            UIAlertAction(
                title: alertConfirmActionTitle,
                style: UIAlertAction.Style.destructive,
                handler: { _ in action() }
            )
        )

        return alertController
    }
}
