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
import RxSwift
import UIKit

public class TripDetailsTableView: UITableView {
    private static let rowHeight: CGFloat = 62.0

    public init() {
        super.init(frame: .zero, style: .grouped)
        rowHeight = TripDetailsTableView.rowHeight
    }

    required init?(coder _: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
}

extension TripDetailsTableView {
    public func passengersTableViewCell(passengerDisplayText: String,
                                        contactAction: (() -> Void)?,
                                        disposeBag: DisposeBag) -> UITableViewCell {
        let reuseIdentifier = "ai.rideos.driver.TripDetailsTableView.passenger-cell"

        let cell: UITableViewCell
        if let reusableCell = dequeueReusableCell(withIdentifier: reuseIdentifier) {
            cell = reusableCell
        } else {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
            cell.textLabel?.text = RideOsDriverResourceLoader.instance.getString(
                "ai.rideos.driver.trip-details.passenger-cell.label"
            )
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17.0)
            cell.selectionStyle = .none
        }

        cell.detailTextLabel?.text = passengerDisplayText

        if let contactAction = contactAction {
            let contactButtonImage = RideOsDriverResourceLoader.instance.getImage("ai.rideos.driver.phone")
            let contactButton = UIButton(type: .custom)
            contactButton.setImage(contactButtonImage, for: .normal)
            contactButton.frame.size = contactButtonImage.size
            contactButton.rx.tap.subscribe(onNext: { contactAction() }).disposed(by: disposeBag)

            cell.accessoryView = contactButton
        } else {
            cell.accessoryView = UIView(frame: .zero)
        }

        return cell
    }

    public func pickupLocationCell(addressText: String) -> UITableViewCell {
        let reuseIdentifier = "ai.rideos.driver.TripDetailsTableView.pickup-location-cell"

        let cell: UITableViewCell
        if let reusableCell = dequeueReusableCell(withIdentifier: reuseIdentifier) {
            cell = reusableCell
        } else {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
            cell.textLabel?.text = RideOsDriverResourceLoader.instance.getString(
                "ai.rideos.driver.trip-details.pickup-location-cell.label"
            )
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17.0)
            cell.selectionStyle = .none
        }

        cell.detailTextLabel?.text = addressText

        return cell
    }

    public func dropoffLocationCell(addressText: String) -> UITableViewCell {
        let reuseIdentifier = "ai.rideos.driver.TripDetailsTableView.dropoff-location-cell"

        let cell: UITableViewCell
        if let reusableCell = dequeueReusableCell(withIdentifier: reuseIdentifier) {
            cell = reusableCell
        } else {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
            cell.textLabel?.text = RideOsDriverResourceLoader.instance.getString(
                "ai.rideos.driver.trip-details.drop-off-location-cell.label"
            )
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17.0)
            cell.selectionStyle = .none
        }

        cell.detailTextLabel?.text = addressText

        return cell
    }

    public func tripActionCell(text: String,
                               action: @escaping () -> Void,
                               disposeBag: DisposeBag) -> UITableViewCell {
        let actionButton = UIButton(type: .custom)
        actionButton.setTitle(text, for: .normal)
        actionButton.setTitleColor(UIColor(red: 0, green: 0.48, blue: 1, alpha: 1), for: .normal)
        actionButton.rx.tap.subscribe(onNext: { action() }).disposed(by: disposeBag)

        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.contentView.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor).isActive = true
        actionButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
        cell.selectionStyle = .none

        return cell
    }
}
