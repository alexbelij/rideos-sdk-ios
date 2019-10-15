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

import Eureka
import Foundation
import RideOsCommon
import RxCocoa
import RxSwift

public class VehicleRegistrationViewController: FormViewController {
    private weak var registerVehicleListener: RegisterVehicleListener?
    private let vehicleRegistrationViewModel: VehicleRegistrationViewModel
    private let schedulerProvider: SchedulerProvider
    private let logger: Logger
    private let disposeBag = DisposeBag()

    public required init?(coder _: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    public init(registerVehicleListener: RegisterVehicleListener,
                vehicleRegistrationViewModel: VehicleRegistrationViewModel = DefaultVehicleRegistrationViewModel(),
                schedulerProvider: SchedulerProvider = DefaultSchedulerProvider(),
                logger: Logger = LoggerDependencyRegistry.instance.logger) {
        self.registerVehicleListener = registerVehicleListener
        self.vehicleRegistrationViewModel = vehicleRegistrationViewModel
        self.schedulerProvider = schedulerProvider
        self.logger = logger

        super.init(nibName: nil, bundle: nil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        navigationOptions = RowNavigationOptions.Enabled.union(.StopDisabledRow)

        setupNavigationBar()
        setupForm()
    }

    private func setupNavigationBar() {
        guard let navigationController = navigationController else {
            return
        }

        let cancelButtonBarItem = VehicleRegistrationViewController.cancelBarButtonItem(
            target: self,
            selector: #selector(cancelRegistration)
        )
        let submitButtonBarItem = VehicleRegistrationViewController.submitBarButtonItem(
            target: self,
            selector: #selector(submitRegistration)
        )

        navigationController.isNavigationBarHidden = false
        navigationController.navigationBar.topItem?.leftBarButtonItem = cancelButtonBarItem
        navigationController.navigationBar.topItem?.rightBarButtonItem = submitButtonBarItem

        navigationController.navigationBar.topItem?.titleView =
            VehicleRegistrationViewController.navigationBarTitleView()

        vehicleRegistrationViewModel.isSubmitActionEnabled()
            .observeOn(schedulerProvider.mainThread())
            .subscribe(onNext: { [submitButtonBarItem] isSubmitEnabled in
                submitButtonBarItem.isEnabled = isSubmitEnabled
            })
            .disposed(by: disposeBag)
    }

    private func setupForm() {
        let disclaimerText =
            RideOsDriverResourceLoader.instance.getString("ai.rideos.driver.settings.account.info-disclaimer")

        form +++ Section(disclaimerText)
            +++ Section(RideOsDriverResourceLoader.instance.getString("ai.rideos.driver.settings.account.name"))
            <<< TextRow().cellSetup { [vehicleRegistrationViewModel, disposeBag] cell, _ in
                cell.textField.keyboardType = .namePhonePad
                cell.textField.autocorrectionType = .no

                cell.textField.rx.text
                    .orEmpty
                    .distinctUntilChanged()
                    .bind(onNext: { vehicleRegistrationViewModel.setPreferredNameText($0) })
                    .disposed(by: disposeBag)
            }

            +++ Section(RideOsDriverResourceLoader.instance.getString("ai.rideos.driver.settings.vehicle.license-plate"))
            <<< TextRow().cellSetup { [vehicleRegistrationViewModel, disposeBag] cell, _ in
                cell.textField.autocapitalizationType = .allCharacters
                cell.textField.autocorrectionType = .no

                cell.textField.rx.text
                    .orEmpty
                    .distinctUntilChanged()
                    .bind(onNext: { vehicleRegistrationViewModel.setLicensePlateText($0) })
                    .disposed(by: disposeBag)
            }

            +++ Section(RideOsDriverResourceLoader.instance.getString("ai.rideos.driver.settings.account.phone-number"))
            <<< TextRow().cellSetup { [vehicleRegistrationViewModel, disposeBag] cell, _ in
                cell.textField.keyboardType = .phonePad

                cell.textField.rx.text
                    .orEmpty
                    .distinctUntilChanged()
                    .bind(onNext: { vehicleRegistrationViewModel.setPhoneNumberText($0) })
                    .disposed(by: disposeBag)
            }

            +++ Section(RideOsDriverResourceLoader.instance.getString("ai.rideos.driver.settings.vehicle.rider-capacity"))
            <<< TextRow().cellSetup { [unowned self] cell, _ in
                cell.textField.keyboardType = .numberPad

                cell.textField.rx.text
                    .orEmpty
                    .distinctUntilChanged()
                    .bind(onNext: { self.vehicleRegistrationViewModel.setRiderCapacityText($0) })
                    .disposed(by: self.disposeBag)
            }
    }

    @objc
    private func cancelRegistration() {
        navigationController?.isNavigationBarHidden = true
        registerVehicleListener?.cancelVehicleRegistration()
    }

    @objc
    private func submitRegistration() {
        vehicleRegistrationViewModel.submit()
            .subscribe(onCompleted: { [unowned self] in
                self.navigationController?.isNavigationBarHidden = true
                self.registerVehicleListener?.finishVehicleRegistration()
            }) { [unowned self] error in
                self.logger.logError("Error completing registration: \(error)")
                self.present(VehicleRegistrationViewController.registrationErrorAlertController(),
                             animated: true,
                             completion: nil)
            }
            .disposed(by: disposeBag)
    }
}

extension VehicleRegistrationViewController {
    private static func navigationBarTitleView() -> UIView {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.text = RideOsDriverResourceLoader.instance.getString("ai.rideos.driver.settings.account.form-title")
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

    private static func submitBarButtonItem(target: Any?, selector: Selector?) -> UIBarButtonItem {
        return UIBarButtonItem(
            title: RideOsDriverResourceLoader.instance.getString("ai.rideos.driver.settings.submit.button.title"),
            style: .done,
            target: target,
            action: selector
        )
    }

    private static func registrationErrorAlertController() -> UIAlertController {
        let alertController = UIAlertController(
            title: RideOsDriverResourceLoader.instance.getString(
                "ai.rideos.driver.settings.account-registration-failed-alert.title"
            ),
            message: RideOsDriverResourceLoader.instance.getString(
                "ai.rideos.driver.settings.account-registration-failed-alert.message"
            ),
            preferredStyle: UIAlertController.Style.alert
        )

        alertController.addAction(
            UIAlertAction(
                title: RideOsDriverResourceLoader.instance.getString(
                    "ai.rideos.driver.settings.account-registration-failed-alert.action.ok"
                ),
                style: UIAlertAction.Style.default
            )
        )
        return alertController
    }
}
