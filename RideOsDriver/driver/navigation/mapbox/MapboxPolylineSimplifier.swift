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

import CoreLocation
import Foundation
import RideOsCommon
import Turf

public class MapboxPolylineSimplifier: PolylineSimplifier {
    public static let maxCoordinateCount = 500
    public static let maxDistanceBetweenCoordinatesMeters: CLLocationDistance = 5000.0
    public static let simplificationThresholds = [
        DefaultPolylineSimplifier.defaultSimplificationThresholdDegrees,
        DefaultPolylineSimplifier.defaultSimplificationThresholdDegrees * 2.0,
        DefaultPolylineSimplifier.defaultSimplificationThresholdDegrees * 4.0,
    ]

    private let basePolylineSimplifiers: [PolylineSimplifier]

    public init(basePolylineSimplifiers: [PolylineSimplifier] = MapboxPolylineSimplifier.simplificationThresholds.map {
        DefaultPolylineSimplifier(toleranceDegrees: $0)
    }) {
        self.basePolylineSimplifiers = basePolylineSimplifiers
    }

    public func simplify(polyline: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
        // Apply progressively more aggressive simplification until we have <= maxCoordinateCount coordinates or we
        // run out of basePolylineSimplifiers
        var simplifiedPolyline = polyline
        var simplifierIndex = 0
        while simplifiedPolyline.count > MapboxPolylineSimplifier.maxCoordinateCount,
            simplifierIndex < basePolylineSimplifiers.count {
            simplifiedPolyline = basePolylineSimplifiers[simplifierIndex].simplify(polyline: simplifiedPolyline)
            simplifierIndex += 1
        }

        // Now that we have our simplified polyline, add interpolated points between any pair that are more than
        // maxDistanceBetweenCoordinatesMeters apart
        // Note that there's a *slight* possibility that this could end up creating a polyline with >
        // maxCoordinateCount coordinates
        return addInterpolated(toPolyline: simplifiedPolyline)
    }

    // Visible for testing
    public static func get(_ count: UInt,
                           pointsAlongDirection direction: CLLocationDirection,
                           from point: CLLocationCoordinate2D,
                           separatedByDistance distance: CLLocationDistance) -> [CLLocationCoordinate2D] {
        var points: [CLLocationCoordinate2D] = []
        for index in 1 ... count {
            points.append(point.coordinate(at: distance * Double(index), facing: direction))
        }
        return points
    }

    private func addInterpolated(toPolyline polyline: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
        var simplifiedPolyline = polyline
        var index = 1
        while index < simplifiedPolyline.count {
            let distance = simplifiedPolyline[index - 1].distance(to: simplifiedPolyline[index])
            if distance > MapboxPolylineSimplifier.maxDistanceBetweenCoordinatesMeters {
                let numPointsToAdd = Int(floor(distance / MapboxPolylineSimplifier.maxDistanceBetweenCoordinatesMeters))
                let direction = simplifiedPolyline[index - 1].direction(to: simplifiedPolyline[index])
                let separationDistance = distance / (Double(numPointsToAdd) + 1.0)
                let pointsToAdd = MapboxPolylineSimplifier.get(UInt(numPointsToAdd),
                                                               pointsAlongDirection: direction,
                                                               from: simplifiedPolyline[index - 1],
                                                               separatedByDistance: separationDistance)
                simplifiedPolyline = simplifiedPolyline[0 ..< index] + pointsToAdd + simplifiedPolyline[index...]
                index += numPointsToAdd + 1
            } else {
                index += 1
            }
        }
        return simplifiedPolyline
    }
}
