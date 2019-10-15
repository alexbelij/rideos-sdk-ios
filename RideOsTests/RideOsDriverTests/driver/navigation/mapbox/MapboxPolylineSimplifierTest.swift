import CoreLocation
import Cuckoo
import RideOsDriver
import XCTest

class MapboxPolylineSimplifierTest: XCTestCase {
    private static let expectedFloatingPointAccuracy = 1.0e-6
    private static let nullIsland = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    func testGetPointsAlongDirectionReturnsExpectedResults() {
        let startPoint = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        let direction = 45.0
        let distance = 100.0
        let points = MapboxPolylineSimplifier.get(3,
                                                  pointsAlongDirection: direction,
                                                  from: startPoint,
                                                  separatedByDistance: distance)
        XCTAssertEqual(points.count, 3)
        XCTAssertEqual(startPoint.direction(to: points[0]),
                       direction,
                       accuracy: MapboxPolylineSimplifierTest.expectedFloatingPointAccuracy)
        XCTAssertEqual(startPoint.distance(to: points[0]),
                       distance,
                       accuracy: MapboxPolylineSimplifierTest.expectedFloatingPointAccuracy)
        for index in 1..<points.count {
            XCTAssertEqual(points[index - 1].direction(to: points[index]),
                           direction,
                           accuracy: MapboxPolylineSimplifierTest.expectedFloatingPointAccuracy)
            XCTAssertEqual(points[index - 1].distance(to: points[index]),
                           distance,
                           accuracy: MapboxPolylineSimplifierTest.expectedFloatingPointAccuracy)
        }
    }
    
    func testSimplifyDoesNotCallBasePolylineSimplifierIfPointCountBelowThreshold() {
        let basePolylineSimplifierMock = MockPolylineSimplifier()
        let polylineSimplifierUnderTest =
            MapboxPolylineSimplifier(basePolylineSimplifiers: [basePolylineSimplifierMock])
        let polyline = [MapboxPolylineSimplifierTest.nullIsland,
                        MapboxPolylineSimplifierTest.nullIsland.coordinate(at: 100.0, facing: 45.0)]
        let result = polylineSimplifierUnderTest.simplify(polyline: polyline)
        
        verifyNoMoreInteractions(basePolylineSimplifierMock)
        XCTAssertEqual(result, polyline)
    }
    
    func testSimplifyCallsBaseSimplifiersUntilNumberOfCoordinatesIsUnderLimit() {
        let basePolylineSimplifierMocks = [
            MockPolylineSimplifier(),
            MockPolylineSimplifier(),
            MockPolylineSimplifier()
        ]
        let polylineSimplifierUnderTest =
            MapboxPolylineSimplifier(basePolylineSimplifiers: basePolylineSimplifierMocks)
        
        let originalPolyline = (0..<MapboxPolylineSimplifier.maxCoordinateCount+2).map {
            MapboxPolylineSimplifierTest.nullIsland.coordinate(at: 100.0 * Double($0), facing: 45.0)
        }
        let simplifiedPolylineFromFirstSimplifier =
            Array(originalPolyline[0...MapboxPolylineSimplifier.maxCoordinateCount])
        let simplifiedPolylineFromSecondSimplifier =
            Array(originalPolyline[0..<MapboxPolylineSimplifier.maxCoordinateCount])
        
        stub(basePolylineSimplifierMocks[0]) { stub in
            when(stub.simplify(polyline: any())).then { _ in
                return simplifiedPolylineFromFirstSimplifier
            }
        }
        stub(basePolylineSimplifierMocks[1]) { stub in
            when(stub.simplify(polyline: any())).then { _ in
                return simplifiedPolylineFromSecondSimplifier
            }
        }
        
        let result = polylineSimplifierUnderTest.simplify(polyline: originalPolyline)
        
        verify(basePolylineSimplifierMocks[0], times(1)).simplify(polyline: any())
        verify(basePolylineSimplifierMocks[1], times(1)).simplify(polyline: any())
        basePolylineSimplifierMocks.forEach { verifyNoMoreInteractions($0) }
        XCTAssertEqual(result, simplifiedPolylineFromSecondSimplifier)
    }
    
    func testSimplifyCallsBaseSimplifiersUntilNumberOfCoordinatesIsUnderLimitOrAllSimplifiersHaveBeenUsed() {
        let basePolylineSimplifierMocks = [
            MockPolylineSimplifier()
        ]
        let polylineSimplifierUnderTest =
            MapboxPolylineSimplifier(basePolylineSimplifiers: basePolylineSimplifierMocks)
        
        let originalPolyline = (0..<MapboxPolylineSimplifier.maxCoordinateCount+2).map {
            MapboxPolylineSimplifierTest.nullIsland.coordinate(at: 100.0 * Double($0), facing: 45.0)
        }
        let simplifiedPolyline = Array(originalPolyline[0...MapboxPolylineSimplifier.maxCoordinateCount])
        
        stub(basePolylineSimplifierMocks[0]) { stub in
            when(stub.simplify(polyline: any())).then { _ in
                return simplifiedPolyline
            }
        }
        
        let result = polylineSimplifierUnderTest.simplify(polyline: originalPolyline)
        
        verify(basePolylineSimplifierMocks[0], times(1)).simplify(polyline: any())
        basePolylineSimplifierMocks.forEach { verifyNoMoreInteractions($0) }
        XCTAssertEqual(result, simplifiedPolyline)
    }
    
    func testSimplifyInsertsAdditionalPointsOnLongStretches() {
        let basePolylineSimplifierMocks = [
            MockPolylineSimplifier()
        ]
        let polylineSimplifierUnderTest =
            MapboxPolylineSimplifier(basePolylineSimplifiers: basePolylineSimplifierMocks)
        let largeDistance = MapboxPolylineSimplifier.maxDistanceBetweenCoordinatesMeters * 3 + 1
        let polyline = [
            MapboxPolylineSimplifierTest.nullIsland,
            MapboxPolylineSimplifierTest.nullIsland
                .coordinate(at: 100.0, facing: 45.0),
            MapboxPolylineSimplifierTest.nullIsland
                .coordinate(at: 100.0, facing: 45.0)
                .coordinate(at: largeDistance, facing: 45.0),
            MapboxPolylineSimplifierTest.nullIsland
                .coordinate(at: 100.0, facing: 45.0)
                .coordinate(at: largeDistance, facing: 45.0)
                .coordinate(at: 100.0, facing: 45.0)
        ]
        let expectedSimplifiedPolyline = [
            MapboxPolylineSimplifierTest.nullIsland,
            MapboxPolylineSimplifierTest.nullIsland
                .coordinate(at: 100.0, facing: 45.0),
            MapboxPolylineSimplifierTest.nullIsland
                .coordinate(at: 100.0, facing: 45.0)
                .coordinate(at: largeDistance / 4.0, facing: 45.0),
            MapboxPolylineSimplifierTest.nullIsland
                .coordinate(at: 100.0, facing: 45.0)
                .coordinate(at: largeDistance / 4.0 * 2.0, facing: 45.0),
            MapboxPolylineSimplifierTest.nullIsland
                .coordinate(at: 100.0, facing: 45.0)
                .coordinate(at: largeDistance / 4.0 * 3.0, facing: 45.0),
            MapboxPolylineSimplifierTest.nullIsland
                .coordinate(at: 100.0, facing: 45.0)
                .coordinate(at: largeDistance, facing: 45.0),
            MapboxPolylineSimplifierTest.nullIsland
                .coordinate(at: 100.0, facing: 45.0)
                .coordinate(at: largeDistance, facing: 45.0)
                .coordinate(at: 100.0, facing: 45.0)
        ]
        
        let result = polylineSimplifierUnderTest.simplify(polyline: polyline)
        XCTAssertEqual(result.count, expectedSimplifiedPolyline.count)
        (0..<result.count).forEach {
            XCTAssertEqual(
                result[$0].latitude,
                expectedSimplifiedPolyline[$0].latitude,
                accuracy: MapboxPolylineSimplifierTest.expectedFloatingPointAccuracy
            )
            XCTAssertEqual(
                result[$0].longitude,
                expectedSimplifiedPolyline[$0].longitude,
                accuracy: MapboxPolylineSimplifierTest.expectedFloatingPointAccuracy
            )
        }
        basePolylineSimplifierMocks.forEach { verifyNoMoreInteractions($0) }
    }
}
