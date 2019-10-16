// MARK: - Mocks generated from file: ../RideOsRider/interactors/HistoricalSearchInteractor.swift at 2019-10-16 18:09:12 +0000

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
@testable import RideOsRider
@testable import RideOsCommon

import Foundation
import RideOsCommon
import RxSwift


public class MockHistoricalSearchInteractor: HistoricalSearchInteractor, Cuckoo.ProtocolMock {
    
    public typealias MocksType = HistoricalSearchInteractor
    
    public typealias Stubbing = __StubbingProxy_HistoricalSearchInteractor
    public typealias Verification = __VerificationProxy_HistoricalSearchInteractor

    public let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    
    private var __defaultImplStub: HistoricalSearchInteractor?

    public func enableDefaultImplementation(_ stub: HistoricalSearchInteractor) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    
    
    
    public var historicalSearchOptions: Observable<[LocationAutocompleteResult]> {
        get {
            return cuckoo_manager.getter("historicalSearchOptions",
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.historicalSearchOptions)
        }
        
    }
    

    

    
    
    
    public func store(searchOption: LocationAutocompleteResult) -> Completable {
        
    return cuckoo_manager.call("store(searchOption: LocationAutocompleteResult) -> Completable",
            parameters: (searchOption),
            escapingParameters: (searchOption),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.store(searchOption: searchOption))
        
    }
    

	public struct __StubbingProxy_HistoricalSearchInteractor: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	    public init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    var historicalSearchOptions: Cuckoo.ProtocolToBeStubbedReadOnlyProperty<MockHistoricalSearchInteractor, Observable<[LocationAutocompleteResult]>> {
	        return .init(manager: cuckoo_manager, name: "historicalSearchOptions")
	    }
	    
	    
	    func store<M1: Cuckoo.Matchable>(searchOption: M1) -> Cuckoo.ProtocolStubFunction<(LocationAutocompleteResult), Completable> where M1.MatchedType == LocationAutocompleteResult {
	        let matchers: [Cuckoo.ParameterMatcher<(LocationAutocompleteResult)>] = [wrap(matchable: searchOption) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockHistoricalSearchInteractor.self, method: "store(searchOption: LocationAutocompleteResult) -> Completable", parameterMatchers: matchers))
	    }
	    
	}

	public struct __VerificationProxy_HistoricalSearchInteractor: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	    public init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	    
	    var historicalSearchOptions: Cuckoo.VerifyReadOnlyProperty<Observable<[LocationAutocompleteResult]>> {
	        return .init(manager: cuckoo_manager, name: "historicalSearchOptions", callMatcher: callMatcher, sourceLocation: sourceLocation)
	    }
	    
	
	    
	    @discardableResult
	    func store<M1: Cuckoo.Matchable>(searchOption: M1) -> Cuckoo.__DoNotUse<(LocationAutocompleteResult), Completable> where M1.MatchedType == LocationAutocompleteResult {
	        let matchers: [Cuckoo.ParameterMatcher<(LocationAutocompleteResult)>] = [wrap(matchable: searchOption) { $0 }]
	        return cuckoo_manager.verify("store(searchOption: LocationAutocompleteResult) -> Completable", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

public class HistoricalSearchInteractorStub: HistoricalSearchInteractor {
    
    
    public var historicalSearchOptions: Observable<[LocationAutocompleteResult]> {
        get {
            return DefaultValueRegistry.defaultValue(for: (Observable<[LocationAutocompleteResult]>).self)
        }
        
    }
    

    

    
    public func store(searchOption: LocationAutocompleteResult) -> Completable  {
        return DefaultValueRegistry.defaultValue(for: (Completable).self)
    }
    
}

