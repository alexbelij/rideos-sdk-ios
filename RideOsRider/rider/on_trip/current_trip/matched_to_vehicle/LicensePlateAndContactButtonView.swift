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

public class LicensePlateAndContactButtonView: UIView {
    public enum ContactButtonStyle {
        case hidden
        case phone
        case chatBubble
    }

    private static let contactButtonStyleToImage = [
        ContactButtonStyle.phone: RiderImages.phone(),
        ContactButtonStyle.chatBubble: RiderImages.chatBubble(),
    ]

    private let contactButton = LicensePlateAndContactButtonView.contactButton()
    private let licensePlateIconAndLabel = LicensePlateAndContactButtonView.licensePlateIconAndLabel()

    public var licensePlate: String? {
        get {
            return licensePlateIconAndLabel.label.text
        }
        set {
            licensePlateIconAndLabel.label.text = newValue
        }
    }

    public var contactButtonStyle: ContactButtonStyle = .hidden {
        didSet {
            if contactButtonStyle == .hidden {
                contactButton.isHidden = true
            } else {
                contactButton.isHidden = false
                contactButton.setImage(LicensePlateAndContactButtonView.contactButtonStyleToImage[contactButtonStyle],
                                       for: .normal)
            }
        }
    }

    public var contactButtonTapEvents: ControlEvent<Void> {
        return contactButton.rx.tap
    }

    public init() {
        super.init(frame: .zero)

        let stackView = BottomDialogStackView.rowWith(stretchedLeftView: licensePlateIconAndLabel,
                                                      rightView: contactButton)
        addSubview(stackView)
        activateMaxSizeConstraintsOnSubview(stackView)
    }

    required init?(coder _: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
}

extension LicensePlateAndContactButtonView {
    private static func contactButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(LicensePlateAndContactButtonView.contactButtonStyleToImage[.phone], for: .normal)
        button.contentHorizontalAlignment = .right
        return button
    }

    private static func licensePlateIconAndLabel() -> IconLabelView {
        let licensePlateIconAndLabel = IconLabelView(isCentered: false)
        licensePlateIconAndLabel.icon.image = RiderImages.carFront()
        licensePlateIconAndLabel.label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        licensePlateIconAndLabel.label.textColor = .black
        return licensePlateIconAndLabel
    }
}
