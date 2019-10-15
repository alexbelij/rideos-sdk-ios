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

public class TopDetailView: UIView {
    private static let menuButtonLeftInset: CGFloat = 16.0
    private static let bottomInset: CGFloat = 11.0

    private static let driverStatusSwitchWidth: CGFloat = 139.0
    private static let driverStatusSwitchHeight: CGFloat = 44.0

    public var menuButtonTapEvents: ControlEvent<Void> {
        return menuButton.tapEvents
    }

    public var isDriverStatusSwitchOn: Bool {
        get {
            return driverStatusSwitch.isOn
        }
        set {
            driverStatusSwitch.isOn = newValue
        }
    }

    public var driverStatusSwitchValueChangedEvents: ControlEvent<Void> {
        return driverStatusSwitch.rx.controlEvent(.valueChanged)
    }

    private let menuButton = SquareImageButton(image: CommonImages.menu(), enableShadows: false)
    private let driverStatusSwitch = LabeledIconSwitch(frame: .zero)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initializeView()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeView()
    }

    public func setDriverStatusSwitch(isOn: Bool, animated: Bool) {
        driverStatusSwitch.set(isOn: isOn, animated: animated)
    }

    private func initializeView() {
        backgroundColor = UIColor.white
        Shadows.enableShadows(onView: self)

        driverStatusSwitch.onText =
            RideOsDriverResourceLoader.instance.getString("ai.rideos.driver.driver-status-switch.online-text")
        driverStatusSwitch.offText =
            RideOsDriverResourceLoader.instance.getString("ai.rideos.driver.driver-status-switch.offline-text")
        driverStatusSwitch.set(thumbIcon:
            RideOsDriverResourceLoader.instance.getImage("ai.rideos.driver.car-front"))
        driverStatusSwitch.offTrackColor =
            RideOsDriverResourceLoader.instance.getColor("ai.rideos.driver-status-switch.offline-track-color")
        driverStatusSwitch.onTrackColor =
            RideOsDriverResourceLoader.instance.getColor("ai.rideos.driver-status-switch.online-track-color")
        driverStatusSwitch.offThumbTintColor =
            RideOsDriverResourceLoader.instance.getColor("ai.rideos.driver-status-switch.offline-thumb-tint")
        driverStatusSwitch.onThumbTintColor =
            RideOsDriverResourceLoader.instance.getColor("ai.rideos.driver-status-switch.online-thumb-tint")

        addSubview(menuButton)
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.leftAnchor.constraint(
            equalTo: leftAnchor,
            constant: TopDetailView.menuButtonLeftInset
        ).isActive = true
        menuButton.bottomAnchor.constraint(
            equalTo: bottomAnchor,
            constant: -TopDetailView.bottomInset
        ).isActive = true

        addSubview(driverStatusSwitch)
        driverStatusSwitch.translatesAutoresizingMaskIntoConstraints = false
        driverStatusSwitch.widthAnchor.constraint(
            equalToConstant: TopDetailView.driverStatusSwitchWidth
        ).isActive = true
        driverStatusSwitch.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        driverStatusSwitch.heightAnchor.constraint(
            equalToConstant: TopDetailView.driverStatusSwitchHeight
        ).isActive = true
        driverStatusSwitch.bottomAnchor.constraint(
            equalTo: bottomAnchor,
            constant: -TopDetailView.bottomInset
        ).isActive = true
    }
}
