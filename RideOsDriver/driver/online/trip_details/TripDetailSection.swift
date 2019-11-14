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
import RxDataSources

public struct TripDetailSection {
    public var items: [Item]
}

public enum TripDetailSectionItem: Equatable {
    case passengerItem(passengerText: String, contactUrl: URL?)
    case pickupAddressItem(addressText: String)
    case dropoffAddressItem(addressText: String)
    case tripActionItem(
        actionText: TripDetailActionText,
        action: () -> Void
    )

    public static func == (lhs: TripDetailSectionItem, rhs: TripDetailSectionItem) -> Bool {
        switch (lhs, rhs) {
        case (let .passengerItem(lhsPassengerText, lhsContactUrl), let .passengerItem(rhsPassengerText, rhsContactUrl)):
            return lhsPassengerText == rhsPassengerText && lhsContactUrl == rhsContactUrl
        case let (.pickupAddressItem(lhsAddressText), .pickupAddressItem(rhsAddressText)):
            return lhsAddressText == rhsAddressText
        case let (.dropoffAddressItem(lhsAddressText), .dropoffAddressItem(rhsAddressText)):
            return lhsAddressText == rhsAddressText
        case (let .tripActionItem(lhsActionText, _), let .tripActionItem(rhsActionText, _)):
            return lhsActionText == rhsActionText
        default:
            return false
        }
    }
}

extension TripDetailSection: Equatable {}

extension TripDetailSection {
    public init(_ items: [TripDetailSectionItem]) {
        self.items = items
    }
}

extension TripDetailSection: SectionModelType {
    public typealias Item = TripDetailSectionItem

    public init(original: TripDetailSection, items: [Item]) {
        self = original
        self.items = items
    }
}
