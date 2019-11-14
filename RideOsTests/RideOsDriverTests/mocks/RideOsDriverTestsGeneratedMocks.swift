// MARK: - Mocks generated from file: ../RideOsCommon/geo/PolylineSimplifier.swift at 2019-11-12 23:23:21 +0000

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

import Cuckoo
@testable import RideOsDriver
@testable import RideOsCommon

import CoreLocation
import Foundation


public class MockPolylineSimplifier: PolylineSimplifier, Cuckoo.ProtocolMock {
    
    public typealias MocksType = PolylineSimplifier
    
    public typealias Stubbing = __StubbingProxy_PolylineSimplifier
    public typealias Verification = __VerificationProxy_PolylineSimplifier

    public let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    
    private var __defaultImplStub: PolylineSimplifier?

    public func enableDefaultImplementation(_ stub: PolylineSimplifier) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    

    

    
    
    
    public func simplify(polyline: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
        
    return cuckoo_manager.call("simplify(polyline: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D]",
            parameters: (polyline),
            escapingParameters: (polyline),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.simplify(polyline: polyline))
        
    }
    

	public struct __StubbingProxy_PolylineSimplifier: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	    public init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    func simplify<M1: Cuckoo.Matchable>(polyline: M1) -> Cuckoo.ProtocolStubFunction<([CLLocationCoordinate2D]), [CLLocationCoordinate2D]> where M1.MatchedType == [CLLocationCoordinate2D] {
	        let matchers: [Cuckoo.ParameterMatcher<([CLLocationCoordinate2D])>] = [wrap(matchable: polyline) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockPolylineSimplifier.self, method: "simplify(polyline: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D]", parameterMatchers: matchers))
	    }
	    
	}

	public struct __VerificationProxy_PolylineSimplifier: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	    public init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	
	    
	    @discardableResult
	    func simplify<M1: Cuckoo.Matchable>(polyline: M1) -> Cuckoo.__DoNotUse<([CLLocationCoordinate2D]), [CLLocationCoordinate2D]> where M1.MatchedType == [CLLocationCoordinate2D] {
	        let matchers: [Cuckoo.ParameterMatcher<([CLLocationCoordinate2D])>] = [wrap(matchable: polyline) { $0 }]
	        return cuckoo_manager.verify("simplify(polyline: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D]", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

public class PolylineSimplifierStub: PolylineSimplifier {
    

    

    
    public func simplify(polyline: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D]  {
        return DefaultValueRegistry.defaultValue(for: ([CLLocationCoordinate2D]).self)
    }
    
}

