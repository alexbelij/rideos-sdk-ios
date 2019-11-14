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

public class DrawerViewController: UIViewController {
    private static let handleTopMargin: CGFloat = 8.0

    private let handleImageView: UIImageView

    public let contentTopInset: CGFloat

    public required init?(coder _: NSCoder) {
        fatalError("\(#function) is unimplemented")
    }

    public init(contentView: UIView) {
        handleImageView = UIImageView(image: RiderImages.drawerHandle())
        contentTopInset = handleImageView.bounds.height + DrawerViewController.handleTopMargin
        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = .white
        view.layer.cornerRadius = 10

        view.addSubview(handleImageView)
        handleImageView.translatesAutoresizingMaskIntoConstraints = false
        handleImageView.topAnchor.constraint(equalTo: view.topAnchor,
                                             constant: DrawerViewController.handleTopMargin).isActive = true
        handleImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: handleImageView.bottomAnchor, constant: 0.0).isActive = true
        contentView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
}
