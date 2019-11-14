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
import RxSwift
import UIKit

public class ConfirmingArrivalDialogView: BottomDialogStackView {
    private static let headerLabelTextColor =
        RideOsDriverResourceLoader.instance.getColor("ai.rideos.driver.dialog.header-label.text-color")
    private static let mainLabelTextColor =
        RideOsDriverResourceLoader.instance.getColor("ai.rideos.driver.dialog.main-label.text-color")
    private static let showDetailsIcon =
        RideOsDriverResourceLoader.instance.getImage("ai.rideos.driver.arrow-down")
    private static let confirmArrivalButtonTitle =
        RideOsDriverResourceLoader.instance.getString("ai.rideos.driver.online.confirm-arrival.button.title")

    public var showDetailsTapEvents: ControlEvent<Void> {
        return showDetailsButton.rx.tap
    }

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

    public var backToNavigationButtonTapEvents: ControlEvent<Void> {
        return backToNavigationButton.rx.tap
    }

    private let separatorView = BottomDialogStackView.separatorView()
    private let showDetailsButton = ConfirmingArrivalDialogView.showDetailsButton()
    private let mainTextLabel = ConfirmingArrivalDialogView.mainTextLabel()
    private let confirmArrivalButton = StackedActionButtonContainerView(
        title: ConfirmingArrivalDialogView.confirmArrivalButtonTitle
    )
    private let backToNavigationButton = ConfirmingArrivalDialogView.backToNavigationButton()
    private let disposeBag = DisposeBag()

    public init(headerText: String,
                showBackToNavigationButton: Bool) {
        let headerView = ConfirmingArrivalDialogView.headerView(
            labelText: headerText,
            showDetailsButton: showDetailsButton,
            disposeBag: disposeBag
        )

        var stackedElements = [
            StackedElement.view(view: headerView),
            StackedElement.view(view: separatorView),
            StackedElement.customSpacing(spacing: 20.0),
            StackedElement.view(view: mainTextLabel),
            StackedElement.customSpacing(spacing: 20.0),
            StackedElement.view(view: confirmArrivalButton),
            StackedElement.customSpacing(spacing: 16.0),
        ]

        if showBackToNavigationButton {
            stackedElements += [
                StackedElement.view(view: backToNavigationButton),
                StackedElement.customSpacing(spacing: 8.0),
            ]
        }

        super.init(stackedElements: stackedElements)

        Shadows.enableShadows(onView: self)
    }

    required init?(coder _: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    public func set(mainText: String) {
        mainTextLabel.text = mainText
    }
}

extension ConfirmingArrivalDialogView {
    private static func headerView(labelText: String,
                                   showDetailsButton: UIButton,
                                   disposeBag: DisposeBag) -> UIView {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .left
        label.textColor = ConfirmingArrivalDialogView.headerLabelTextColor
        label.text = labelText

        let headerView = UIView(frame: .zero)
        headerView.heightAnchor.constraint(equalToConstant: 48.0).isActive = true

        headerView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 16.0).isActive = true
        label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true

        headerView.addSubview(showDetailsButton)
        showDetailsButton.translatesAutoresizingMaskIntoConstraints = false
        showDetailsButton.rightAnchor.constraint(equalTo: headerView.rightAnchor).isActive = true
        showDetailsButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true

        let tapGestureRecognizer = UITapGestureRecognizer(target: nil, action: nil)
        tapGestureRecognizer.rx.event.subscribe { _ in
            showDetailsButton.sendActions(for: .touchUpInside)
        }
        .disposed(by: disposeBag)

        label.addGestureRecognizer(tapGestureRecognizer)
        headerView.addGestureRecognizer(tapGestureRecognizer)

        return headerView
    }

    private static func showDetailsButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(ConfirmingArrivalDialogView.showDetailsIcon, for: .normal)

        return button
    }

    private static func mainTextLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textAlignment = .center
        label.textColor = ConfirmingArrivalDialogView.mainLabelTextColor
        return label
    }

    private static func backToNavigationButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(
            RideOsDriverResourceLoader.instance.getString("ai.rideos.driver.online.back-to-navigation.button.title"),
            for: .normal
        )
        button.setTitleColor(
            RideOsDriverResourceLoader.instance.getColor("ai.rideos.driver.return-to-navigaion.color.enabled"),
            for: .normal
        )
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)

        return button
    }
}
