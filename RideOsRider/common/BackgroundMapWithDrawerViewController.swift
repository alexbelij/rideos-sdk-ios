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
import OverlayContainer
import RideOsCommon

public class BackgroundMapWithDrawerViewController: UIViewController {
    public let backgroundMapViewController: BackgroundMapViewController

    public let drawerViewController: DrawerViewController

    private let containerViewController: OverlayContainerViewController

    public var collapsedDrawerHeight: CGFloat = 0.0 {
        didSet {
            containerViewController.invalidateNotchHeights()
        }
    }

    public var expandedDrawerHeight: CGFloat = 0.0 {
        didSet {
            containerViewController.invalidateNotchHeights()
        }
    }

    public required init?(coder _: NSCoder) {
        fatalError("\(#function) is unimplemented")
    }

    public init(backgroundMapViewController: BackgroundMapViewController, drawerContentView: UIView) {
        self.backgroundMapViewController = backgroundMapViewController
        drawerViewController = DrawerViewController(contentView: drawerContentView)
        containerViewController = OverlayContainerViewController(style: .rigid)

        super.init(nibName: nil, bundle: nil)

        containerViewController.delegate = self
        containerViewController.viewControllers = [self.backgroundMapViewController, drawerViewController]
        addChild(containerViewController)
        view.addSubview(containerViewController.view)
        view.activateMaxSizeConstraintsOnSubview(containerViewController.view)
        containerViewController.didMove(toParent: self)
    }
}

extension BackgroundMapWithDrawerViewController: OverlayContainerViewControllerDelegate {
    enum OverlayNotch: Int, CaseIterable {
        case collapsed, expanded
    }

    // If there is less than this amount of space (in points) between the top of the drawer and the top of this view,
    // don't attempt to fit the map content into such a small space (otherwise the map zooms way out awkwardly)
    private static let minimumRemainingSpaceAtTopOfScreen: CGFloat = 50.0

    public func numberOfNotches(in _: OverlayContainerViewController) -> Int {
        return OverlayNotch.allCases.count
    }

    public func overlayContainerViewController(_: OverlayContainerViewController,
                                               heightForNotchAt index: Int,
                                               availableSpace _: CGFloat) -> CGFloat {
        return heightOf(notch: OverlayNotch.allCases[index])
    }

    private func heightOf(notch: OverlayNotch) -> CGFloat {
        let collapsedHeight = collapsedDrawerHeight + drawerViewController.contentTopInset
        switch notch {
        case .collapsed:
            return collapsedHeight
        case .expanded:
            // Return the max of the desired expanded height and the collapsed height. This is because
            // OverlayContainer throws an exception if the height of notch i is less than the height of notch i-1
            return max(
                expandedDrawerHeight
                    + drawerViewController.contentTopInset
                    + containerViewController.view.safeAreaInsets.bottom,
                collapsedHeight
            )
        }
    }

    public func overlayContainerViewController(_: OverlayContainerViewController,
                                               didMoveOverlay _: UIViewController,
                                               toNotchAt index: Int) {
        let remainingSpaceAtTopOfScreen = view.frame.height - heightOf(notch: OverlayNotch.allCases[index])
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
