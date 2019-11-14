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
import RxSwift
import UIKit

public class VehicleSettingsFormViewController: FormViewController {
    private let viewModel: VehicleSettingsViewModel
    private let schedulerProvider: SchedulerProvider
    private let disposeBag = DisposeBag()

    public init(viewModel: VehicleSettingsViewModel = DefaultVehicleSettingsViewModel(),
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

        navigationItem.title = RideOsDriverResourceLoader.instance.getString(
            "ai.rideos.driver.settings.vehicle-info.title"
        )

        let licensePlateSectionTitle = RideOsDriverResourceLoader.instance.getString(
            "ai.rideos.driver.settings.vehicle-info.license-plate-section"
        )

        let licensePlateRow = TextRow().cellSetup { [unowned self] cell, row in
            cell.textField.keyboardType = .default
            cell.textField.autocorrectionType = .no
            cell.textField.autocapitalizationType = .allCharacters

            cell.textField.rx.controlEvent(.editingDidEnd)
                .bind(onNext: {
                    guard let updatedLicensePlate = cell.textField.text else {
                        return
                    }

                    self.viewModel.update(licensePlate: updatedLicensePlate)
                        .subscribe()
                        .disposed(by: self.disposeBag)
                })
                .disposed(by: self.disposeBag)

            row.value = try? self.viewModel.licensePlate.value()
        }

        form +++ Section(licensePlateSectionTitle)
            <<< licensePlateRow

        viewModel.licensePlate
            .observeOn(schedulerProvider.mainThread())
            .subscribe(onNext: { [tableView] licensePlate in
                licensePlateRow.value = licensePlate
                tableView?.reloadData()
            })
            .disposed(by: disposeBag)
    }
}
