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

public class LabeledIndeterminateProgressView: UIView {
    private static let progressLabelTextColor =
        RideOsCommonResourceLoader.instance.getColor("ai.rideos.common.dialog.color.header-text")

    public override var intrinsicContentSize: CGSize {
        return progressLabel.intrinsicContentSize
    }

    private let progressLabel = LabeledIndeterminateProgressView.progressLabel()
    private let progressIndicatorView = IndeterminateProgressView()

    public init(progressText: String) {
        super.init(frame: .zero)

        progressLabel.text = progressText

        addSubview(progressLabel)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        progressLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        progressLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        addSubview(progressIndicatorView)
        progressIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        progressIndicatorView.topAnchor.constraint(equalTo: progressLabel.bottomAnchor,
                                                   constant: 8.0).isActive = true
        progressIndicatorView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        progressIndicatorView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }

    required init?(coder _: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    public func set(isAnimatingProgress: Bool) {
        progressIndicatorView.set(isAnimatingProgress: isAnimatingProgress)
    }
}

extension LabeledIndeterminateProgressView {
    private static func progressLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = LabeledIndeterminateProgressView.progressLabelTextColor
        return label
    }
}
