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
import RxSwift

public protocol MatchedToVehicleDialogDelegate: class {
    func matchedToVehicleDialog(_ matchedToVehicleDialog: MatchedToVehicleDialog,
                                didChangeCollapsedHeightTo collapsedHeight: CGFloat)
    func matchedToVehicleDialog(_ matchedToVehicleDialog: MatchedToVehicleDialog,
                                didChangeExpandedHeightTo expandedHeight: CGFloat)
}

public class MatchedToVehicleDialog: BottomDialogStackView {
    private let headerLabel = BottomDialogStackView.headerLabel(withText: "")
    private let pickupDropoffLabel = MatchedToVehicleDialog.pickupDropoffLabel()
    private let cancelButton: StackedActionButtonContainerView
    private let licensePlateAndContactButton = LicensePlateAndContactButtonView()

    private let tripDetailView: TripDetailView

    // The elements shown when the dialog is partially collapsed (i.e. the user hasn't pulled the drawer to its fully
    // open state)
    private let previewElements: [StackedElement]

    public var headerText: String? {
        get {
            return headerLabel.text
        }
        set {
            headerLabel.text = newValue
            setNeedsLayout()
        }
    }

    public var waypointLabel: String? {
        get {
            return pickupDropoffLabel.text
        }
        set {
            pickupDropoffLabel.text = newValue
            setNeedsLayout()
        }
    }

    public var licensePlate: String? {
        get {
            return licensePlateAndContactButton.licensePlate
        }
        set {
            licensePlateAndContactButton.licensePlate = newValue
            setNeedsLayout()
        }
    }

    public var contactButtonStyle: LicensePlateAndContactButtonView.ContactButtonStyle {
        get {
            return licensePlateAndContactButton.contactButtonStyle
        }
        set {
            licensePlateAndContactButton.contactButtonStyle = newValue
            setNeedsLayout()
        }
    }

    public var contactButtonTapEvents: ControlEvent<Void> {
        return licensePlateAndContactButton.contactButtonTapEvents
    }

    public var cancelButtonTapEvents: ControlEvent<Void> {
        return cancelButton.tapEvents
    }

    public var editPickupButtonTapEvents: ControlEvent<Void> {
        return tripDetailView.editPickupButtonTapEvents
    }

    public var editDropoffButtonTapEvents: ControlEvent<Void> {
        return tripDetailView.editDropoffButtonTapEvents
    }

    public var pickupLabel: String? {
        get {
            return tripDetailView.pickupLabel
        }
        set {
            tripDetailView.pickupLabel = newValue
            setNeedsLayout()
        }
    }

    public var dropoffLabel: String? {
        get {
            return tripDetailView.dropoffLabel
        }
        set {
            tripDetailView.dropoffLabel = newValue
            setNeedsLayout()
        }
    }

    public weak var delegate: MatchedToVehicleDialogDelegate?

    public init(cancelButtonTitle: String?, showEditPickupButton: Bool, showEditDropoffButton: Bool) {
        cancelButton = StackedActionButtonContainerView(title: cancelButtonTitle ?? "")
        tripDetailView = TripDetailView(showEditPickupButton: showEditPickupButton,
                                        showEditDropoffButton: showEditDropoffButton)
        previewElements = [
            .customSpacing(spacing: 8),
            .view(view: headerLabel),
            .customSpacing(spacing: 8.0),
            .view(view: pickupDropoffLabel),
            .customSpacing(spacing: 16.0),
            .view(view: BottomDialogStackView.insetSeparatorView()),
            .customSpacing(spacing: 22.0),
            .view(view: licensePlateAndContactButton),
            .customSpacing(spacing: 22.0),
        ]
        let cancelButtonElements: [StackedElement]
        if cancelButtonTitle != nil {
            cancelButtonElements = [.customSpacing(spacing: 30.0), .view(view: cancelButton)]
        } else {
            cancelButtonElements = []
        }

        licensePlateAndContactButton.contactButtonStyle = .phone

        super.init(stackedElements:
            previewElements
                + [.view(view: BottomDialogStackView.insetSeparatorView())]
                + [.customSpacing(spacing: 20.0), .view(view: tripDetailView)]
                + cancelButtonElements)
    }

    required init?(coder _: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    private var previewElementsHeight: CGFloat {
        return previewElements
            .map {
                switch $0 {
                case let .view(view):
                    return view.bounds.height
                case let .customSpacing(spacing):
                    return spacing
                }
            }
            .reduce(0.0, +)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        delegate?.matchedToVehicleDialog(self, didChangeCollapsedHeightTo: previewElementsHeight)
        delegate?.matchedToVehicleDialog(self, didChangeExpandedHeightTo: bounds.height)
    }
}

extension MatchedToVehicleDialog {
    private static func pickupDropoffLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }
}
