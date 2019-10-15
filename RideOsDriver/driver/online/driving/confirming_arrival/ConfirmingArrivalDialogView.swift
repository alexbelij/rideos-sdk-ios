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

public class ConfirmingArrivalDialogView: BottomDialogStackView {
    private static let headerLabelTextColor =
        RideOsDriverResourceLoader.instance.getColor("ai.rideos.driver.dialog.header-label.text-color")
    private static let confirmArrivalButtonTitle =
        RideOsDriverResourceLoader.instance.getString("ai.rideos.driver.online.confirm-arrival.button.title")

    public var confirmArrivalButtonTapEvents: ControlEvent<Void> {
        return confirmArrivalButton.tapEvents
    }

    public var isConfirmArrivalButtonEnabled: Bool {
        get {
            return confirmArrivalButton.isButtonEnabled
        }
        set {
            confirmArrivalButton.isButtonEnabled = newValue
        }
    }

    private let headerLabel = ConfirmingArrivalDialogView.headerLabel()
    private let separatorView = BottomDialogStackView.separatorView()
    private let addressLabel = ConfirmingArrivalDialogView.addressLabel()
    private let confirmArrivalButton = StackedActionButtonContainerView(
        title: ConfirmingArrivalDialogView.confirmArrivalButtonTitle
    )

    public init(headerText: String) {
        super.init(stackedElements: [
            .view(view: headerLabel),
            .view(view: separatorView),
            .customSpacing(spacing: 20.0),
            .view(view: addressLabel),
            .customSpacing(spacing: 20.0),
            .view(view: confirmArrivalButton),
            .customSpacing(spacing: 16.0),
        ])

        headerLabel.text = headerText

        Shadows.enableShadows(onView: self)
    }

    required init?(coder _: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    public func set(addressText: String) {
        addressLabel.text = addressText
    }
}

extension ConfirmingArrivalDialogView {
    private static func headerLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = ConfirmingArrivalDialogView.headerLabelTextColor
        return label
    }

    private static func addressLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = UIColor.black
        return label
    }
}
