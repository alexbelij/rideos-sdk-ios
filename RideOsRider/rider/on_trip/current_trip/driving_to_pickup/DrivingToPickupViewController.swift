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

public class DrivingToPickupViewController: MatchedToVehicleViewController {
    private let dialogView = MatchedToVehicleDialog(
        cancelButtonTitle: RideOsRiderResourceLoader.instance.getString(
            "ai.rideos.rider.on-trip.driving-to-pickup.cancel-button-title"
        ),
        showEditPickupButton: true,
        showEditDropoffButton: true
    )
    private let disposeBag = DisposeBag()

    public required init?(coder _: NSCoder) {
        fatalError("DrivingToPickupViewController does not support NSCoder")
    }

    public init(mapViewController: MapViewController,
                passengerState: RiderTripStateModel,
                cancelListener: @escaping () -> Void,
                editPickupListener: @escaping () -> Void,
                editDropoffListener: @escaping () -> Void,
                schedulerProvider: SchedulerProvider = DefaultSchedulerProvider()) {
        super.init(dialogView: dialogView,
                   mapViewController: mapViewController,
                   viewModel: DefaultDrivingToPickupViewModel(initialPassengerState: passengerState),
                   cancelListener: cancelListener,
                   editPickupListener: editPickupListener,
                   editDropoffListener: editDropoffListener,
                   schedulerProvider: schedulerProvider)
    }
}
