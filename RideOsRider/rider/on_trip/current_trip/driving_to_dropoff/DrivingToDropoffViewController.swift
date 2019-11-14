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
import RxSwift

public class DrivingToDropoffViewController: MatchedToVehicleViewController {
    public required init?(coder _: NSCoder) {
        fatalError("DrivingToDropoffViewController does not support NSCoder")
    }

    public init(
        mapViewController: MapViewController,
        initialPassengerState: RiderTripStateModel,
        cancelListener: @escaping () -> Void,
        editDropoffListener: @escaping () -> Void,
        schedulerProvider: SchedulerProvider = DefaultSchedulerProvider(),
        enableDestinationEdits: Bool = DrivingToDropoffViewController.defaultEnableDestinationEdits()
    ) {
        super.init(dialogView: MatchedToVehicleDialog(cancelButtonTitle: nil,
                                                      showEditPickupButton: false,
                                                      showEditDropoffButton: enableDestinationEdits),
                   mapViewController: mapViewController,
                   viewModel: DefaultDrivingToDropoffViewModel(initialPassengerState: initialPassengerState,
                                                               currentDateProvider: { Date() }),
                   cancelListener: cancelListener,
                   editPickupListener: nil,
                   editDropoffListener: editDropoffListener,
                   schedulerProvider: schedulerProvider)
    }

    public static func defaultEnableDestinationEdits() -> Bool {
        guard let info = Bundle.main.infoDictionary else {
            fatalError("Can't load Info.plist")
        }

        guard let enableDestinationEdits = info["EnableEditingDestinationAfterPickup"] as? Bool else {
            return true
        }

        return enableDestinationEdits
    }
}
