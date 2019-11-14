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

public class WaitingForPickupViewController: MatchedToVehicleViewController {
    public required init?(coder _: NSCoder) {
        fatalError("WaitingForPickupViewController does not support NSCoder")
    }

    public init(mapViewController: MapViewController,
                initialPassengerState: RiderTripStateModel,
                cancelListener: @escaping () -> Void,
                editDropoffListener: @escaping () -> Void,
                schedulerProvider: SchedulerProvider = DefaultSchedulerProvider()) {
        // TODO(chrism): Once https://github.com/rideOS/pangea/issues/5322 is fixed, change showEditPickupButton to
        // true
        let dialogView = MatchedToVehicleDialog(
            cancelButtonTitle: RideOsRiderResourceLoader.instance.getString(
                "ai.rideos.rider.on-trip.waiting-for-pickup.cancel-button-title"
            ),
            showEditPickupButton: false,
            showEditDropoffButton: true
        )
        super.init(dialogView: dialogView,
                   mapViewController: mapViewController,
                   viewModel: DefaultWaitingForPickupViewModel(initialPassengerState: initialPassengerState),
                   cancelListener: cancelListener,
                   editPickupListener: nil,
                   editDropoffListener: editDropoffListener,
                   schedulerProvider: schedulerProvider)
    }
}
