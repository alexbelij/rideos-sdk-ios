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

public class WatingForPickupDialogView: BottomDialogStackView {
    private static let confirmPickupButtonTitle =
        RideOsDriverResourceLoader.instance.getString("ai.rideos.driver.online.waiting-for-pickup.button.title")

    public var confirmPickupTapEvents: ControlEvent<Void> {
        return confirmPickupButton.tapEvents
    }

    public var isConfirmPickupButtonEnabled: Bool {
        get {
            return confirmPickupButton.isButtonEnabled
        }
        set {
            confirmPickupButton.isButtonEnabled = newValue
        }
    }

    private let pickupPassengersLabel = WatingForPickupDialogView.pickupPassengersLabel()
    private let confirmPickupButton = StackedActionButtonContainerView(
        title: WatingForPickupDialogView.confirmPickupButtonTitle
    )

    public init(pickupPassengersText: String) {
        super.init(stackedElements: [
            .customSpacing(spacing: 24.0),
            .view(view: WatingForPickupDialogView.pickupPassengerLabelContainer(withLabel: pickupPassengersLabel)),
            .customSpacing(spacing: 24.0),
            .view(view: confirmPickupButton),
            .customSpacing(spacing: 16.0),
        ])

        pickupPassengersLabel.text = pickupPassengersText

        Shadows.enableShadows(onView: self)
    }

    required init?(coder _: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
}

extension WatingForPickupDialogView {
    private static func pickupPassengerLabelContainer(withLabel label: UILabel) -> UIView {
        let container = UIView(frame: .zero)

        container.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 16.0).isActive = true
        label.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -16.0).isActive = true

        return container
    }

    private static func pickupPassengersLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = UIColor.black
        label.adjustsFontSizeToFitWidth = true

        let minimumFontSize: CGFloat = 10.0
        label.minimumScaleFactor = minimumFontSize / label.font.pointSize

        return label
    }
}
