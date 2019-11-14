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

import Foundation
import RideOsCommon
import RxCocoa
import RxSwift

public class MatchedToVehicleViewController: BackgroundMapWithDrawerViewController, PassengerStateObserver {
    private let disposeBag = DisposeBag()

    private let dialogView: MatchedToVehicleDialog
    private let viewModel: MatchedToVehicleViewModel
    private let urlLauncher: UrlLauncher

    public required init?(coder _: NSCoder) {
        fatalError("\(#function) is unimplemented")
    }

    public init(dialogView: MatchedToVehicleDialog,
                mapViewController: MapViewController,
                viewModel: MatchedToVehicleViewModel,
                cancelListener: @escaping () -> Void,
                editPickupListener: (() -> Void)?,
                editDropoffListener: (() -> Void)?,
                schedulerProvider: SchedulerProvider) {
        self.dialogView = dialogView
        self.viewModel = viewModel
        urlLauncher = DefaultUrlLauncher()

        super.init(backgroundMapViewController: BackgroundMapViewController(mapViewController: mapViewController),
                   drawerContentView: dialogView)
        dialogView.delegate = self
        viewModel.dialogModel
            .observeOn(schedulerProvider.mainThread())
            .subscribe(onNext: { [dialogView] in
                dialogView.headerText = $0.status
                dialogView.waypointLabel = $0.nextWaypoint
                dialogView.licensePlate = $0.vehicleInfo.licensePlate
                dialogView.contactButtonStyle =
                    MatchedToVehicleViewController.contactButtonStyle(for: $0.vehicleInfo.contactInfo)
                dialogView.pickupLabel = $0.pickupLabel
                dialogView.dropoffLabel = $0.dropoffLabel
            })
            .disposed(by: disposeBag)

        dialogView.contactButtonTapEvents
            .observeOn(schedulerProvider.mainThread())
            .withLatestFrom(viewModel.dialogModel)
            .subscribe(onNext: { [unowned self] in
                if let contactUrl = $0.vehicleInfo.contactInfo.url {
                    self.urlLauncher.launch(url: contactUrl, parentViewController: self)
                }
            })
            .disposed(by: disposeBag)

        dialogView.cancelButtonTapEvents
            .observeOn(schedulerProvider.mainThread())
            .subscribe(onNext: { [unowned self] in
                let alertController =
                    CancelTripAlertController.cancelTripAlertController(withConfirmationListener: cancelListener)
                self.present(alertController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        dialogView.editPickupButtonTapEvents
            .observeOn(schedulerProvider.mainThread())
            .subscribe(onNext: { [editPickupListener] in editPickupListener?() })
            .disposed(by: disposeBag)

        dialogView.editDropoffButtonTapEvents
            .observeOn(schedulerProvider.mainThread())
            .subscribe(onNext: { [editDropoffListener] in editDropoffListener?() })
            .disposed(by: disposeBag)
    }

    public func updatePassengerState(_ state: RiderTripStateModel) {
        viewModel.updatePassengerState(state)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundMapViewController.mapViewController.connect(mapStateProvider: viewModel)
    }

    private static func contactButtonStyle(for contactInfo: ContactInfo)
        -> LicensePlateAndContactButtonView.ContactButtonStyle {
        guard let scheme = contactInfo.url?.scheme?.lowercased() else {
            return .hidden
        }
        if scheme == "tel" {
            return .phone
        } else {
            return .chatBubble
        }
    }
}

extension MatchedToVehicleViewController: MatchedToVehicleDialogDelegate {
    public func matchedToVehicleDialog(_: MatchedToVehicleDialog,
                                       didChangeCollapsedHeightTo collapsedHeight: CGFloat) {
        collapsedDrawerHeight = collapsedHeight
    }

    public func matchedToVehicleDialog(_: MatchedToVehicleDialog,
                                       didChangeExpandedHeightTo expandedHeight: CGFloat) {
        expandedDrawerHeight = expandedHeight
    }
}
