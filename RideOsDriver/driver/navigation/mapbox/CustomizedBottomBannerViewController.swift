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

import MapboxNavigation
import UIKit

public class CustomizedBottomBannerViewController: BottomBannerViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()

        if let verticalDividerHeightConstraint =
            (verticalDividerView.constraints.filter { $0.firstAttribute == .height }.first) {
            verticalDividerHeightConstraint.constant = 60.0
        }

        let secondaryTitleLabel = UILabel()
        secondaryTitleLabel.font = UIFont.systemFont(ofSize: 10.0)
        secondaryTitleLabel.text = RideOsDriverResourceLoader.instance.getString(
            "ai.rideos.driver.turn-by-turn-navigation.exit-navigation.title"
        )
        // DismissButton.appearance().textColor takes into account the current daytime / nightime style being applied
        // to the BottomBannerViewController. This ensures the label's text is visible when either style is applied.
        secondaryTitleLabel.textColor = DismissButton.appearance().textColor

        cancelButton.addSubview(secondaryTitleLabel)
        secondaryTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryTitleLabel.centerXAnchor.constraint(
            equalTo: cancelButton.centerXAnchor
        ).isActive = true
        secondaryTitleLabel.centerYAnchor.constraint(
            equalTo: cancelButton.centerYAnchor,
            constant: 18.0
        ).isActive = true
    }
}
