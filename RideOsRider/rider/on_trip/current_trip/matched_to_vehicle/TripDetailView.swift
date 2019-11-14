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

public class TripDetailView: UIView {
    private static let leftColumnHorizontalInset: CGFloat = 44.0
    private static let rightColumnHorizontalInset: CGFloat = 77.0

    public var pickupLabel: String? {
        get {
            return pickupAddressLabel.text
        }
        set {
            pickupAddressLabel.text = newValue
        }
    }

    public var dropoffLabel: String? {
        get {
            return dropoffAddressLabel.text
        }
        set {
            dropoffAddressLabel.text = newValue
        }
    }

    public var editPickupButtonTapEvents: ControlEvent<Void> {
        return editPickupButton.rx.tap
    }

    public var editDropoffButtonTapEvents: ControlEvent<Void> {
        return editDropoffButton.rx.tap
    }

    required init?(coder _: NSCoder) {
        fatalError("\(#function) is unimplemented")
    }

    private let pickupAddressLabel: UILabel = TripDetailView.pickupAddressLabel()
    private let editPickupButton: UIButton = TripDetailView.editButton()
    private let dropoffAddressLabel: UILabel = TripDetailView.dropoffAddressLabel()
    private let editDropoffButton: UIButton = TripDetailView.editButton()

    public init(showEditPickupButton: Bool, showEditDropoffButton: Bool) {
        super.init(frame: .zero)

        let tripDetailsLabel = TripDetailView.tripDetailsLabel()
        addSubview(tripDetailsLabel)
        tripDetailsLabel.translatesAutoresizingMaskIntoConstraints = false
        tripDetailsLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tripDetailsLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tripDetailsLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        let pickupLabel = TripDetailView.pickupLabel()
        addSubview(pickupLabel)
        pickupLabel.translatesAutoresizingMaskIntoConstraints = false
        pickupLabel.topAnchor.constraint(equalTo: tripDetailsLabel.bottomAnchor, constant: 24.0).isActive = true
        pickupLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor,
                                             constant: TripDetailView.rightColumnHorizontalInset).isActive = true

        let pickupPin = TripDetailView.pickupPin()
        addSubview(pickupPin)
        pickupPin.translatesAutoresizingMaskIntoConstraints = false
        pickupPin.topAnchor.constraint(equalTo: pickupLabel.bottomAnchor, constant: 7.0).isActive = true
        pickupPin.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor,
                                           constant: TripDetailView.leftColumnHorizontalInset).isActive = true

        addSubview(pickupAddressLabel)
        pickupAddressLabel.translatesAutoresizingMaskIntoConstraints = false
        pickupAddressLabel.centerYAnchor.constraint(equalTo: pickupPin.centerYAnchor).isActive = true
        pickupAddressLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor,
                                                    constant: TripDetailView.rightColumnHorizontalInset).isActive = true

        addSubview(editPickupButton)
        editPickupButton.isHidden = !showEditPickupButton
        editPickupButton.translatesAutoresizingMaskIntoConstraints = false
        editPickupButton.centerYAnchor.constraint(equalTo: pickupAddressLabel.centerYAnchor).isActive = true
        editPickupButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0).isActive = true
        pickupAddressLabel.trailingAnchor.constraint(equalTo: editPickupButton.leadingAnchor).isActive = true

        let solidVerticalBar = TripDetailView.solidVerticalBar()
        addSubview(solidVerticalBar)
        solidVerticalBar.translatesAutoresizingMaskIntoConstraints = false
        solidVerticalBar.centerXAnchor.constraint(equalTo: pickupPin.centerXAnchor).isActive = true
        solidVerticalBar.topAnchor.constraint(equalTo: pickupPin.bottomAnchor, constant: 10.0).isActive = true

        let dropoffLabel = TripDetailView.dropoffLabel()
        addSubview(dropoffLabel)
        dropoffLabel.translatesAutoresizingMaskIntoConstraints = false
        dropoffLabel.topAnchor.constraint(equalTo: pickupAddressLabel.bottomAnchor, constant: 62.0).isActive = true
        dropoffLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor,
                                              constant: TripDetailView.rightColumnHorizontalInset).isActive = true

        let dropoffPin = TripDetailView.dropoffPin()
        addSubview(dropoffPin)
        dropoffPin.translatesAutoresizingMaskIntoConstraints = false
        dropoffPin.topAnchor.constraint(equalTo: solidVerticalBar.bottomAnchor, constant: 10.0).isActive = true
        dropoffPin.leadingAnchor.constraint(equalTo: pickupPin.leadingAnchor).isActive = true

        addSubview(dropoffAddressLabel)
        dropoffAddressLabel.translatesAutoresizingMaskIntoConstraints = false
        dropoffAddressLabel.centerYAnchor.constraint(equalTo: dropoffPin.centerYAnchor).isActive = true
        dropoffAddressLabel.leadingAnchor.constraint(equalTo: pickupAddressLabel.leadingAnchor).isActive = true
        dropoffAddressLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        addSubview(editDropoffButton)
        editDropoffButton.isHidden = !showEditDropoffButton
        editDropoffButton.translatesAutoresizingMaskIntoConstraints = false
        editDropoffButton.centerYAnchor.constraint(equalTo: dropoffAddressLabel.centerYAnchor).isActive = true
        editDropoffButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0).isActive = true
        dropoffAddressLabel.trailingAnchor.constraint(equalTo: editDropoffButton.leadingAnchor).isActive = true
    }
}

extension TripDetailView {
    private static func tripDetailsLabel() -> UILabel {
        let label = UILabel()
        label.text = RideOsRiderResourceLoader.instance.getString("ai.rideos.rider.on-trip.trip-details.header")
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }

    private static func pickupLabel() -> UILabel {
        let label = UILabel()
        label.text = RideOsRiderResourceLoader.instance.getString("ai.rideos.rider.on-trip.trip-details.pickup")
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        return label
    }

    private static func editButton() -> UIButton {
        let button = UIButton(type: .custom)
        let image = RiderImages.pencil()
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: image.size.height).isActive = true
        button.widthAnchor.constraint(equalToConstant: image.size.width).isActive = true
        return button
    }

    private static func pickupAddressLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        return label
    }

    private static func solidVerticalBar() -> UIImageView {
        return UIImageView(
            image: RideOsRiderResourceLoader.instance.getImage(
                "ai.rideos.rider.on-trip.trip-detail.vertical-bar-solid"
            )
        )
    }

    private static func pickupPin() -> UIImageView {
        return UIImageView(
            image: RideOsRiderResourceLoader.instance.getImage(
                "ai.rideos.rider.on-trip.trip-detail.green-pin-no-shadow"
            )
        )
    }

    private static func dropoffPin() -> UIImageView {
        return UIImageView(
            image: RideOsRiderResourceLoader.instance.getImage(
                "ai.rideos.rider.on-trip.trip-detail.red-pin-no-shadow"
            )
        )
    }

    private static func dropoffLabel() -> UILabel {
        let label = UILabel()
        label.text = RideOsRiderResourceLoader.instance.getString("ai.rideos.rider.on-trip.trip-details.drop-off")
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        return label
    }

    private static func dropoffAddressLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        return label
    }
}
