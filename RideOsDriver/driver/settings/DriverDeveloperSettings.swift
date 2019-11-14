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

class DriverDeveloperSettingsFormViewController: CommonDeveloperSettingsFormViewController {
    override init(fleetSelectionViewModel: FleetSelectionViewModel,
                  userStorageReader: UserStorageReader = UserDefaultsUserStorageReader(),
                  userStorageWriter: UserStorageWriter = UserDefaultsUserStorageWriter(),
                  schedulerProvider: SchedulerProvider = DefaultSchedulerProvider()) {
        super.init(fleetSelectionViewModel: fleetSelectionViewModel,
                   userStorageReader: userStorageReader,
                   userStorageWriter: userStorageWriter,
                   schedulerProvider: schedulerProvider)
    }

    public required init?(coder _: NSCoder) {
        fatalError("\(#function) is unimplemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        form +++ Section(
            RideOsDriverResourceLoader.instance.getString("ai.rideos.driver.settings.developer.navigation-section")
        )
            <<< SwitchRow { row in
                row.title = RideOsDriverResourceLoader.instance.getString(
                    "ai.rideos.driver.settings.developer.simulate-navigation"
                )
                row.value = self.userStorageReader.get(DriverDeveloperSettingsKeys.enableSimulatedNavigation)
                row.updateCell()
            }
            .onChange { row in
                if let value = row.value {
                    self.userStorageWriter.set(key: DriverDeveloperSettingsKeys.enableSimulatedNavigation,
                                               value: value)
                }
            }
    }
}
