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
import UIKit

public class PreRegistrationDialogView: BottomDialogStackView {
    public var registerVehicleTapEvents: ControlEvent<Void> {
        return registerVehicleButton.tapEvents
    }

    private let registerVehicleButton = StackedActionButtonContainerView(
        title: RideOsDriverResourceLoader.instance.getString(
            "ai.rideos.driver.vehicle-unregistered.register-vehicle-button.title"
        )
    )

    public init() {
        super.init(stackedElements: [
            .customSpacing(spacing: 48.0),
            .view(view: PreRegistrationDialogView.alertIconWithLabelView()),
            .customSpacing(spacing: 48.0),
            .view(view: registerVehicleButton),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
}

extension PreRegistrationDialogView {
    private static func alertIconWithLabelView() -> UIView {
        let containerView = UIView(frame: .zero)

        let alertIconView = UIImageView(image: DriverImages.alert())

        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = RideOsDriverResourceLoader.instance.getString("ai.rideos.driver.vehicle-unregistered.header-text")
        label.textAlignment = .center
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.left

        containerView.addSubview(alertIconView)
        alertIconView.translatesAutoresizingMaskIntoConstraints = false
        alertIconView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16.0).isActive = true
        alertIconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true

        containerView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leftAnchor.constraint(equalTo: alertIconView.rightAnchor, constant: 16.0).isActive = true
        label.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16.0).isActive = true
        label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true

        return containerView
    }
}
