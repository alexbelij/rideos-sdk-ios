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
import Pulley
import RideOsCommon

public class BackgroundMapWithDrawerViewController: UIViewController {
    public let backgroundMapViewController: BackgroundMapViewController

    private let drawerViewController: UIViewController

    public required init?(coder _: NSCoder) {
        fatalError("#(function) is unimplemented")
    }

    public init(backgroundMapViewController: BackgroundMapViewController, drawerContentView: UIView) {
        self.backgroundMapViewController = backgroundMapViewController
        drawerViewController = BackgroundMapWithDrawerViewController.drawerViewController(withView: drawerContentView)

        super.init(nibName: nil, bundle: nil)

        let pulleyViewController = BackgroundMapWithDrawerViewController.pulleyViewController(
            withContentViewController: self.backgroundMapViewController,
            drawerViewController: drawerViewController
        )
        pulleyViewController.delegate = self
        addChild(pulleyViewController)
        view.addSubview(pulleyViewController.view)
        pulleyViewController.didMove(toParent: self)
    }
}

extension BackgroundMapWithDrawerViewController {
    private static func drawerViewController(withView view: UIView) -> UIViewController {
        let vc = UIViewController()
        vc.view.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: vc.view.topAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: vc.view.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: vc.view.rightAnchor).isActive = true
        return vc
    }

    private static func pulleyViewController(withContentViewController contentViewController: UIViewController,
                                             drawerViewController: UIViewController) -> PulleyViewController {
        let pulleyViewController = PulleyViewController(contentViewController: contentViewController,
                                                        drawerViewController: drawerViewController)
        pulleyViewController.initialDrawerPosition = .partiallyRevealed
        let backgroundVisualEffectView = UIVisualEffectView()
        backgroundVisualEffectView.backgroundColor = .white
        pulleyViewController.drawerBackgroundVisualEffectView = backgroundVisualEffectView
        pulleyViewController.drawerCornerRadius = 0
        pulleyViewController.allowsUserDrawerPositionChange = false
        return pulleyViewController
    }
}

extension BackgroundMapWithDrawerViewController: PulleyDelegate {
    // If there is less than this amount of space (in points) between the top of the drawer and the top of this view,
    // don't attempt to fit the map content into such a small space (otherwise the map zooms way out awkwardly)
    private static let minimumRemainingSpaceAtTopOfScreen: CGFloat = 300.0

    public func drawerChangedDistanceFromBottom(drawer _: PulleyViewController,
                                                distance: CGFloat,
                                                bottomSafeArea _: CGFloat) {
        let remainingSpaceAtTopOfScreen = view.frame.height - distance
        let bottomInset = view.frame.height - max(
            remainingSpaceAtTopOfScreen,
            BackgroundMapWithDrawerViewController.minimumRemainingSpaceAtTopOfScreen
        )
        backgroundMapViewController.mapViewController.mapInsets = UIEdgeInsets(top: 0,
                                                                               left: 0,
                                                                               bottom: bottomInset,
                                                                               right: 0)
    }
}
