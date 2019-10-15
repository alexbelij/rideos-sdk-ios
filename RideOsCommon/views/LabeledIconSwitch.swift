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

import UIKit

open class LabeledIconSwitch: UIControl {
    private static let onLabelLeftPadding: CGFloat = 16.0
    private static let offLabelRightPadding: CGFloat = 16.0
    private static let thumbIconInsetFromThumb: CGFloat = 4.0
    private static let thumbInsetFromTrack: CGFloat = 8.0
    private static let thumbStretchAdditionalWidth: CGFloat = 8.0

    private static let thumbStretchAnimationTransitionInterval: TimeInterval = 0.1
    private static let onOffAnimationTransitionInterval: TimeInterval = 0.3

    public var isOn: Bool {
        get {
            return isOnCurrently
        }
        set {
            let shouldUpdateAppearance = isOnCurrently != newValue
            isOnCurrently = newValue

            if shouldUpdateAppearance {
                updateOnOffAppearance(animated: false)
            }
        }
    }

    public var onTrackColor: UIColor = UIColor(red: 0.0, green: 0.84, blue: 0.86, alpha: 1.0)
    public var offTrackColor: UIColor = UIColor(red: 0.58, green: 0.65, blue: 0.75, alpha: 1.0)
    public var onThumbTintColor: UIColor = UIColor(red: 0.23, green: 0.29, blue: 0.37, alpha: 1.0)
    public var offThumbTintColor: UIColor = UIColor(red: 0.58, green: 0.65, blue: 0.75, alpha: 1.0)

    public var onText: String {
        get {
            return onLabel.text ?? ""
        } set {
            onLabel.text = newValue
        }
    }

    public var offText: String {
        get {
            return offLabel.text ?? ""
        } set {
            offLabel.text = newValue
        }
    }

    private let thumbIconView = UIImageView()
    private let thumbIconContainerView = UIView(frame: .zero)
    private var thumbIconContainerViewWidthContraint: NSLayoutConstraint!
    private var thumbOnPositionContraint: NSLayoutConstraint!
    private var thumbOffPositionContraint: NSLayoutConstraint!
    private var thumbIconOnPositionContraint: NSLayoutConstraint!
    private var thumbIconOffPositionContraint: NSLayoutConstraint!
    private let onLabel = LabeledIconSwitch.label()
    private let offLabel = LabeledIconSwitch.label()
    private var onOffTransitionAnimator: UIViewPropertyAnimator?
    private var isTouchDownCurrently = false
    private var isOnCurrently = false

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeControl()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initializeControl()
    }

    private func initializeControl() {
        thumbIconContainerView.backgroundColor = UIColor.white

        addSubview(onLabel)
        onLabel.translatesAutoresizingMaskIntoConstraints = false
        onLabel.leftAnchor.constraint(
            equalTo: leftAnchor,
            constant: LabeledIconSwitch.onLabelLeftPadding
        ).isActive = true
        onLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        addSubview(offLabel)
        offLabel.translatesAutoresizingMaskIntoConstraints = false
        offLabel.rightAnchor.constraint(
            equalTo: rightAnchor,
            constant: -LabeledIconSwitch.offLabelRightPadding
        ).isActive = true
        offLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        addSubview(thumbIconContainerView)
        thumbIconContainerView.translatesAutoresizingMaskIntoConstraints = false
        thumbIconContainerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        thumbOnPositionContraint = thumbIconContainerView.rightAnchor.constraint(
            equalTo: rightAnchor,
            constant: -LabeledIconSwitch.thumbIconInsetFromThumb
        )
        thumbOffPositionContraint = thumbIconContainerView.leftAnchor.constraint(
            equalTo: leftAnchor,
            constant: LabeledIconSwitch.thumbIconInsetFromThumb
        )
        thumbIconContainerViewWidthContraint = thumbIconContainerView.widthAnchor.constraint(
            equalTo: heightAnchor,
            constant: -LabeledIconSwitch.thumbInsetFromTrack
        )
        thumbIconContainerViewWidthContraint.priority = UILayoutPriority.defaultHigh
        thumbIconContainerViewWidthContraint.isActive = true

        let thumbIconContainerViewHeightAnchor = thumbIconContainerView.heightAnchor.constraint(
            equalTo: heightAnchor,
            constant: -LabeledIconSwitch.thumbInsetFromTrack
        )
        thumbIconContainerViewHeightAnchor.priority = UILayoutPriority.defaultHigh
        thumbIconContainerViewHeightAnchor.isActive = true

        thumbIconContainerView.addSubview(thumbIconView)
        thumbIconView.translatesAutoresizingMaskIntoConstraints = false
        thumbIconView.centerYAnchor.constraint(equalTo: thumbIconContainerView.centerYAnchor).isActive = true
        thumbIconOnPositionContraint = thumbIconView.rightAnchor.constraint(
            equalTo: thumbIconContainerView.rightAnchor,
            constant: -LabeledIconSwitch.thumbInsetFromTrack
        )
        thumbIconOffPositionContraint = thumbIconView.leftAnchor.constraint(
            equalTo: thumbIconContainerView.leftAnchor,
            constant: LabeledIconSwitch.thumbInsetFromTrack
        )

        addTarget(self, action: #selector(onTouchDown), for: .touchDown)
        addTarget(self, action: #selector(onTouchUp), for: .touchUpInside)
        addTarget(self, action: #selector(onTouchUp), for: .touchUpOutside)

        let longTapGestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(onThumbIconLongTouch(sender:))
        )
        longTapGestureRecognizer.minimumPressDuration = 0.05
        thumbIconContainerView.addGestureRecognizer(longTapGestureRecognizer)

        updateOnOffAppearance(animated: false)
    }

    public func set(thumbIcon icon: UIImage) {
        thumbIconView.image = icon.withRenderingMode(.alwaysTemplate)
    }

    public func set(isOn: Bool, animated: Bool) {
        isOnCurrently = isOn
        updateOnOffAppearance(animated: animated)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.height / 2.0
        thumbIconContainerView.layer.cornerRadius = thumbIconContainerView.frame.size.height / 2.0
    }

    // MARK: Handle Touch Events

    @objc
    private func onThumbIconLongTouch(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            onTouchDown()
        } else if sender.state == .ended {
            onTouchUp()
        }
    }

    @objc
    private func onTouchDown() {
        isTouchDownCurrently = true
        updateThumbStretch()
    }

    @objc
    private func onTouchUp() {
        isTouchDownCurrently = false
        updateThumbStretch()
        set(isOn: !isOnCurrently, animated: true)
    }

    // MARK: Handle Appearance

    private func updateThumbStretch() {
        if isTouchDownCurrently {
            thumbIconContainerViewWidthContraint.constant += LabeledIconSwitch.thumbStretchAdditionalWidth
        } else {
            thumbIconContainerViewWidthContraint.constant -= LabeledIconSwitch.thumbStretchAdditionalWidth
        }

        setNeedsUpdateConstraints()

        UIView.animate(withDuration: LabeledIconSwitch.thumbStretchAnimationTransitionInterval) {
            self.layoutIfNeeded()
        }
    }

    private func updateOnOffAppearance(animated: Bool = true) {
        onOffTransitionAnimator?.stopAnimation(true)

        let trackColor: UIColor
        let thumbTintColor: UIColor
        let onLabelAlpha: CGFloat
        let offLabelAlpha: CGFloat

        if isOn {
            trackColor = onTrackColor
            thumbTintColor = onThumbTintColor
            onLabelAlpha = 1.0
            offLabelAlpha = 0.0

            thumbOffPositionContraint.isActive = false
            thumbOnPositionContraint.isActive = true

            thumbIconOffPositionContraint.isActive = false
            thumbIconOnPositionContraint.isActive = true
        } else {
            trackColor = offTrackColor
            thumbTintColor = offThumbTintColor
            onLabelAlpha = 0.0
            offLabelAlpha = 1.0

            thumbOnPositionContraint.isActive = false
            thumbOffPositionContraint.isActive = true

            thumbIconOnPositionContraint.isActive = false
            thumbIconOffPositionContraint.isActive = true
        }

        setNeedsUpdateConstraints()

        if animated {
            onOffTransitionAnimator = UIViewPropertyAnimator(
                duration: LabeledIconSwitch.onOffAnimationTransitionInterval,
                curve: .easeInOut
            ) {
                self.setOnOffAppearance(
                    trackColor: trackColor,
                    thumbTintColor: thumbTintColor,
                    onLabelAlpha: onLabelAlpha,
                    offLabelAlpha: offLabelAlpha
                )
            }

            onOffTransitionAnimator?.addCompletion { [weak self] position in
                guard let self = self else { return }

                if position == .end {
                    self.sendActions(for: .valueChanged)
                }
            }

            onOffTransitionAnimator?.startAnimation()
        } else {
            setOnOffAppearance(
                trackColor: trackColor,
                thumbTintColor: thumbTintColor,
                onLabelAlpha: onLabelAlpha,
                offLabelAlpha: offLabelAlpha
            )

            sendActions(for: .valueChanged)
        }
    }

    private func setOnOffAppearance(trackColor: UIColor,
                                    thumbTintColor: UIColor,
                                    onLabelAlpha: CGFloat,
                                    offLabelAlpha: CGFloat) {
        backgroundColor = trackColor
        thumbIconView.tintColor = thumbTintColor
        onLabel.alpha = onLabelAlpha
        offLabel.alpha = offLabelAlpha
        layoutIfNeeded()
    }
}

extension LabeledIconSwitch {
    public static func label() -> UILabel {
        let label = UILabel(frame: .zero)
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 17.0)

        return label
    }
}
