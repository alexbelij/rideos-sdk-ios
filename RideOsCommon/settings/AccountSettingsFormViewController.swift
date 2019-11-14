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
import RxSwift
import UIKit

public class AccountSettingsFormViewController: FormViewController {
    private let viewModel: AccountSettingsViewModel
    private let schedulerProvider: SchedulerProvider
    private let disposeBag = DisposeBag()

    public init(viewModel: AccountSettingsViewModel = DefaultAccountSettingsViewModel(),
                schedulerProvider: SchedulerProvider = DefaultSchedulerProvider()) {
        self.viewModel = viewModel
        self.schedulerProvider = schedulerProvider
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder _: NSCoder) {
        fatalError("\(#function) is unimplemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = MainSettingsFormViewController.editProfileString

        let preferredNameSectionTitle = RideOsCommonResourceLoader.instance.getString(
            "ai.rideos.common.settings.account.preferred-name"
        )

        let preferredNameRow = TextRow().cellSetup { [unowned self] cell, row in
            cell.textField.keyboardType = .namePhonePad
            cell.textField.autocorrectionType = .no

            cell.textField.rx.controlEvent(.editingDidEnd)
                .bind(onNext: {
                    guard let updatedPreferredName = cell.textField.text else {
                        return
                    }

                    self.viewModel.update(preferredName: updatedPreferredName)
                        .subscribe()
                        .disposed(by: self.disposeBag)
                })
                .disposed(by: self.disposeBag)

            row.value = try? self.viewModel.preferredName.value()
        }

        form +++ Section(preferredNameSectionTitle)
            <<< preferredNameRow

        viewModel.preferredName
            .observeOn(schedulerProvider.computation())
            .distinctUntilChanged()
            .observeOn(schedulerProvider.mainThread())
            .subscribe(onNext: { [tableView] preferredName in
                preferredNameRow.value = preferredName
                tableView?.reloadData()
            })
            .disposed(by: disposeBag)

        let phoneNumberSectionTitle = RideOsCommonResourceLoader.instance.getString(
            "ai.rideos.common.settings.account.phone-number"
        )

        let phoneNumberRow = TextRow().cellSetup { [unowned self] cell, row in
            cell.textField.keyboardType = .phonePad
            cell.textField.autocorrectionType = .no

            cell.textField.rx.controlEvent(.editingDidEnd)
                .bind(onNext: {
                    guard let updatedPhoneNumber = cell.textField.text else {
                        return
                    }

                    self.viewModel.update(phoneNumber: updatedPhoneNumber)
                        .subscribe()
                        .disposed(by: self.disposeBag)
                })
                .disposed(by: self.disposeBag)

            row.value = try? self.viewModel.phoneNumber.value()
        }

        form +++ Section(phoneNumberSectionTitle)
            <<< phoneNumberRow

        viewModel.phoneNumber
            .observeOn(schedulerProvider.computation())
            .distinctUntilChanged()
            .observeOn(schedulerProvider.mainThread())
            .subscribe(onNext: { [tableView] preferredName in
                phoneNumberRow.value = preferredName
                tableView?.reloadData()
            })
            .disposed(by: disposeBag)

        let emailAddressSectionTitle = RideOsCommonResourceLoader.instance.getString(
            "ai.rideos.common.settings.account.email-address"
        )
        let emailRow = LabelRow { row in
            row.baseCell.backgroundColor = self.tableView.backgroundColor
        }

        form +++ Section(emailAddressSectionTitle)
            <<< emailRow

        viewModel.email
            .observeOn(schedulerProvider.mainThread())
            .subscribe(onSuccess: { [tableView] email in
                emailRow.title = email
                tableView?.reloadData()
            })
            .disposed(by: disposeBag)
    }
}
