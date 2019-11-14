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

public struct ContactInfo: Equatable, Codable {
    public let name: String?
    public let phoneNumber: String?
    public let url: URL?

    public init(name: String? = nil, phoneNumber: String? = nil, contactURL: String? = nil) {
        self.name = name
        self.phoneNumber = phoneNumber

        if let contactURL = contactURL, contactURL.isNotEmpty {
            url = URL(string: contactURL)
        } else if let phoneNumber = phoneNumber, phoneNumber.isNotEmpty {
            url = URL(string: "tel://" + phoneNumber)
        } else {
            url = nil
        }
    }
}
