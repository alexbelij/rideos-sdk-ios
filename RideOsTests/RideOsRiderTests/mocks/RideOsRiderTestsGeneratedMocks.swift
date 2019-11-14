// MARK: - Mocks generated from file: ../RideOsRider/interactors/HistoricalSearchInteractor.swift at 2019-11-12 23:26:13 +0000

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


// MARK: - Mocks generated from file: ../RideOsRider/interactors/TripInteractor.swift at 2019-11-12 23:26:13 +0000

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

import CoreLocation
import Foundation
import RideOsCommon
import RxSwift


public class MockTripInteractor: TripInteractor, Cuckoo.ProtocolMock {
    
    public typealias MocksType = TripInteractor
    
    public typealias Stubbing = __StubbingProxy_TripInteractor
    public typealias Verification = __VerificationProxy_TripInteractor

    public let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    
    private var __defaultImplStub: TripInteractor?

    public func enableDefaultImplementation(_ stub: TripInteractor) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    

    

    
    
    
    public func createTripForPassenger(passengerId: String, contactInfo: ContactInfo, fleetId: String, numPassengers: UInt32, pickupLocation: TripLocation, dropoffLocation: TripLocation, vehicleId: String?) -> Observable<String> {
        
    return cuckoo_manager.call("createTripForPassenger(passengerId: String, contactInfo: ContactInfo, fleetId: String, numPassengers: UInt32, pickupLocation: TripLocation, dropoffLocation: TripLocation, vehicleId: String?) -> Observable<String>",
            parameters: (passengerId, contactInfo, fleetId, numPassengers, pickupLocation, dropoffLocation, vehicleId),
            escapingParameters: (passengerId, contactInfo, fleetId, numPassengers, pickupLocation, dropoffLocation, vehicleId),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.createTripForPassenger(passengerId: passengerId, contactInfo: contactInfo, fleetId: fleetId, numPassengers: numPassengers, pickupLocation: pickupLocation, dropoffLocation: dropoffLocation, vehicleId: vehicleId))
        
    }
    
    
    
    public func cancelTrip(passengerId: String, tripId: String) -> Completable {
        
    return cuckoo_manager.call("cancelTrip(passengerId: String, tripId: String) -> Completable",
            parameters: (passengerId, tripId),
            escapingParameters: (passengerId, tripId),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.cancelTrip(passengerId: passengerId, tripId: tripId))
        
    }
    
    
    
    public func getCurrentTrip(forPassenger passengerId: String) -> Observable<String?> {
        
    return cuckoo_manager.call("getCurrentTrip(forPassenger: String) -> Observable<String?>",
            parameters: (passengerId),
            escapingParameters: (passengerId),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.getCurrentTrip(forPassenger: passengerId))
        
    }
    
    
    
    public func editPickup(tripId: String, newPickupLocation: TripLocation) -> Observable<String> {
        
    return cuckoo_manager.call("editPickup(tripId: String, newPickupLocation: TripLocation) -> Observable<String>",
            parameters: (tripId, newPickupLocation),
            escapingParameters: (tripId, newPickupLocation),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.editPickup(tripId: tripId, newPickupLocation: newPickupLocation))
        
    }
    
    
    
    public func editDropoff(tripId: String, newDropoffLocation: TripLocation) -> Observable<String> {
        
    return cuckoo_manager.call("editDropoff(tripId: String, newDropoffLocation: TripLocation) -> Observable<String>",
            parameters: (tripId, newDropoffLocation),
            escapingParameters: (tripId, newDropoffLocation),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.editDropoff(tripId: tripId, newDropoffLocation: newDropoffLocation))
        
    }
    

	public struct __StubbingProxy_TripInteractor: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	    public init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    func createTripForPassenger<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable, M4: Cuckoo.Matchable, M5: Cuckoo.Matchable, M6: Cuckoo.Matchable, M7: Cuckoo.OptionalMatchable>(passengerId: M1, contactInfo: M2, fleetId: M3, numPassengers: M4, pickupLocation: M5, dropoffLocation: M6, vehicleId: M7) -> Cuckoo.ProtocolStubFunction<(String, ContactInfo, String, UInt32, TripLocation, TripLocation, String?), Observable<String>> where M1.MatchedType == String, M2.MatchedType == ContactInfo, M3.MatchedType == String, M4.MatchedType == UInt32, M5.MatchedType == TripLocation, M6.MatchedType == TripLocation, M7.OptionalMatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String, ContactInfo, String, UInt32, TripLocation, TripLocation, String?)>] = [wrap(matchable: passengerId) { $0.0 }, wrap(matchable: contactInfo) { $0.1 }, wrap(matchable: fleetId) { $0.2 }, wrap(matchable: numPassengers) { $0.3 }, wrap(matchable: pickupLocation) { $0.4 }, wrap(matchable: dropoffLocation) { $0.5 }, wrap(matchable: vehicleId) { $0.6 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockTripInteractor.self, method: "createTripForPassenger(passengerId: String, contactInfo: ContactInfo, fleetId: String, numPassengers: UInt32, pickupLocation: TripLocation, dropoffLocation: TripLocation, vehicleId: String?) -> Observable<String>", parameterMatchers: matchers))
	    }
	    
	    func cancelTrip<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(passengerId: M1, tripId: M2) -> Cuckoo.ProtocolStubFunction<(String, String), Completable> where M1.MatchedType == String, M2.MatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String, String)>] = [wrap(matchable: passengerId) { $0.0 }, wrap(matchable: tripId) { $0.1 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockTripInteractor.self, method: "cancelTrip(passengerId: String, tripId: String) -> Completable", parameterMatchers: matchers))
	    }
	    
	    func getCurrentTrip<M1: Cuckoo.Matchable>(forPassenger passengerId: M1) -> Cuckoo.ProtocolStubFunction<(String), Observable<String?>> where M1.MatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: passengerId) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockTripInteractor.self, method: "getCurrentTrip(forPassenger: String) -> Observable<String?>", parameterMatchers: matchers))
	    }
	    
	    func editPickup<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(tripId: M1, newPickupLocation: M2) -> Cuckoo.ProtocolStubFunction<(String, TripLocation), Observable<String>> where M1.MatchedType == String, M2.MatchedType == TripLocation {
	        let matchers: [Cuckoo.ParameterMatcher<(String, TripLocation)>] = [wrap(matchable: tripId) { $0.0 }, wrap(matchable: newPickupLocation) { $0.1 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockTripInteractor.self, method: "editPickup(tripId: String, newPickupLocation: TripLocation) -> Observable<String>", parameterMatchers: matchers))
	    }
	    
	    func editDropoff<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(tripId: M1, newDropoffLocation: M2) -> Cuckoo.ProtocolStubFunction<(String, TripLocation), Observable<String>> where M1.MatchedType == String, M2.MatchedType == TripLocation {
	        let matchers: [Cuckoo.ParameterMatcher<(String, TripLocation)>] = [wrap(matchable: tripId) { $0.0 }, wrap(matchable: newDropoffLocation) { $0.1 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockTripInteractor.self, method: "editDropoff(tripId: String, newDropoffLocation: TripLocation) -> Observable<String>", parameterMatchers: matchers))
	    }
	    
	}

	public struct __VerificationProxy_TripInteractor: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	    public init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	
	    
	    @discardableResult
	    func createTripForPassenger<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable, M4: Cuckoo.Matchable, M5: Cuckoo.Matchable, M6: Cuckoo.Matchable, M7: Cuckoo.OptionalMatchable>(passengerId: M1, contactInfo: M2, fleetId: M3, numPassengers: M4, pickupLocation: M5, dropoffLocation: M6, vehicleId: M7) -> Cuckoo.__DoNotUse<(String, ContactInfo, String, UInt32, TripLocation, TripLocation, String?), Observable<String>> where M1.MatchedType == String, M2.MatchedType == ContactInfo, M3.MatchedType == String, M4.MatchedType == UInt32, M5.MatchedType == TripLocation, M6.MatchedType == TripLocation, M7.OptionalMatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String, ContactInfo, String, UInt32, TripLocation, TripLocation, String?)>] = [wrap(matchable: passengerId) { $0.0 }, wrap(matchable: contactInfo) { $0.1 }, wrap(matchable: fleetId) { $0.2 }, wrap(matchable: numPassengers) { $0.3 }, wrap(matchable: pickupLocation) { $0.4 }, wrap(matchable: dropoffLocation) { $0.5 }, wrap(matchable: vehicleId) { $0.6 }]
	        return cuckoo_manager.verify("createTripForPassenger(passengerId: String, contactInfo: ContactInfo, fleetId: String, numPassengers: UInt32, pickupLocation: TripLocation, dropoffLocation: TripLocation, vehicleId: String?) -> Observable<String>", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func cancelTrip<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(passengerId: M1, tripId: M2) -> Cuckoo.__DoNotUse<(String, String), Completable> where M1.MatchedType == String, M2.MatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String, String)>] = [wrap(matchable: passengerId) { $0.0 }, wrap(matchable: tripId) { $0.1 }]
	        return cuckoo_manager.verify("cancelTrip(passengerId: String, tripId: String) -> Completable", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func getCurrentTrip<M1: Cuckoo.Matchable>(forPassenger passengerId: M1) -> Cuckoo.__DoNotUse<(String), Observable<String?>> where M1.MatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: passengerId) { $0 }]
	        return cuckoo_manager.verify("getCurrentTrip(forPassenger: String) -> Observable<String?>", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func editPickup<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(tripId: M1, newPickupLocation: M2) -> Cuckoo.__DoNotUse<(String, TripLocation), Observable<String>> where M1.MatchedType == String, M2.MatchedType == TripLocation {
	        let matchers: [Cuckoo.ParameterMatcher<(String, TripLocation)>] = [wrap(matchable: tripId) { $0.0 }, wrap(matchable: newPickupLocation) { $0.1 }]
	        return cuckoo_manager.verify("editPickup(tripId: String, newPickupLocation: TripLocation) -> Observable<String>", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func editDropoff<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(tripId: M1, newDropoffLocation: M2) -> Cuckoo.__DoNotUse<(String, TripLocation), Observable<String>> where M1.MatchedType == String, M2.MatchedType == TripLocation {
	        let matchers: [Cuckoo.ParameterMatcher<(String, TripLocation)>] = [wrap(matchable: tripId) { $0.0 }, wrap(matchable: newDropoffLocation) { $0.1 }]
	        return cuckoo_manager.verify("editDropoff(tripId: String, newDropoffLocation: TripLocation) -> Observable<String>", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

public class TripInteractorStub: TripInteractor {
    

    

    
    public func createTripForPassenger(passengerId: String, contactInfo: ContactInfo, fleetId: String, numPassengers: UInt32, pickupLocation: TripLocation, dropoffLocation: TripLocation, vehicleId: String?) -> Observable<String>  {
        return DefaultValueRegistry.defaultValue(for: (Observable<String>).self)
    }
    
    public func cancelTrip(passengerId: String, tripId: String) -> Completable  {
        return DefaultValueRegistry.defaultValue(for: (Completable).self)
    }
    
    public func getCurrentTrip(forPassenger passengerId: String) -> Observable<String?>  {
        return DefaultValueRegistry.defaultValue(for: (Observable<String?>).self)
    }
    
    public func editPickup(tripId: String, newPickupLocation: TripLocation) -> Observable<String>  {
        return DefaultValueRegistry.defaultValue(for: (Observable<String>).self)
    }
    
    public func editDropoff(tripId: String, newDropoffLocation: TripLocation) -> Observable<String>  {
        return DefaultValueRegistry.defaultValue(for: (Observable<String>).self)
    }
    
}


// MARK: - Mocks generated from file: ../RideOsRider/rider/on_trip/current_trip/CurrentTripListener.swift at 2019-11-12 23:26:13 +0000

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

import CoreLocation
import Foundation


public class MockCurrentTripListener: CurrentTripListener, Cuckoo.ProtocolMock {
    
    public typealias MocksType = CurrentTripListener
    
    public typealias Stubbing = __StubbingProxy_CurrentTripListener
    public typealias Verification = __VerificationProxy_CurrentTripListener

    public let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    
    private var __defaultImplStub: CurrentTripListener?

    public func enableDefaultImplementation(_ stub: CurrentTripListener) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    

    

    
    
    
    public func editPickup(existingPickupLocation: DesiredAndAssignedLocation, existingDropoffLocation: DesiredAndAssignedLocation)  {
        
    return cuckoo_manager.call("editPickup(existingPickupLocation: DesiredAndAssignedLocation, existingDropoffLocation: DesiredAndAssignedLocation)",
            parameters: (existingPickupLocation, existingDropoffLocation),
            escapingParameters: (existingPickupLocation, existingDropoffLocation),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.editPickup(existingPickupLocation: existingPickupLocation, existingDropoffLocation: existingDropoffLocation))
        
    }
    
    
    
    public func editDropoff(existingPickupLocation: DesiredAndAssignedLocation, existingDropoffLocation: DesiredAndAssignedLocation)  {
        
    return cuckoo_manager.call("editDropoff(existingPickupLocation: DesiredAndAssignedLocation, existingDropoffLocation: DesiredAndAssignedLocation)",
            parameters: (existingPickupLocation, existingDropoffLocation),
            escapingParameters: (existingPickupLocation, existingDropoffLocation),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.editDropoff(existingPickupLocation: existingPickupLocation, existingDropoffLocation: existingDropoffLocation))
        
    }
    

	public struct __StubbingProxy_CurrentTripListener: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	    public init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    func editPickup<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(existingPickupLocation: M1, existingDropoffLocation: M2) -> Cuckoo.ProtocolStubNoReturnFunction<(DesiredAndAssignedLocation, DesiredAndAssignedLocation)> where M1.MatchedType == DesiredAndAssignedLocation, M2.MatchedType == DesiredAndAssignedLocation {
	        let matchers: [Cuckoo.ParameterMatcher<(DesiredAndAssignedLocation, DesiredAndAssignedLocation)>] = [wrap(matchable: existingPickupLocation) { $0.0 }, wrap(matchable: existingDropoffLocation) { $0.1 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockCurrentTripListener.self, method: "editPickup(existingPickupLocation: DesiredAndAssignedLocation, existingDropoffLocation: DesiredAndAssignedLocation)", parameterMatchers: matchers))
	    }
	    
	    func editDropoff<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(existingPickupLocation: M1, existingDropoffLocation: M2) -> Cuckoo.ProtocolStubNoReturnFunction<(DesiredAndAssignedLocation, DesiredAndAssignedLocation)> where M1.MatchedType == DesiredAndAssignedLocation, M2.MatchedType == DesiredAndAssignedLocation {
	        let matchers: [Cuckoo.ParameterMatcher<(DesiredAndAssignedLocation, DesiredAndAssignedLocation)>] = [wrap(matchable: existingPickupLocation) { $0.0 }, wrap(matchable: existingDropoffLocation) { $0.1 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockCurrentTripListener.self, method: "editDropoff(existingPickupLocation: DesiredAndAssignedLocation, existingDropoffLocation: DesiredAndAssignedLocation)", parameterMatchers: matchers))
	    }
	    
	}

	public struct __VerificationProxy_CurrentTripListener: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	    public init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	
	    
	    @discardableResult
	    func editPickup<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(existingPickupLocation: M1, existingDropoffLocation: M2) -> Cuckoo.__DoNotUse<(DesiredAndAssignedLocation, DesiredAndAssignedLocation), Void> where M1.MatchedType == DesiredAndAssignedLocation, M2.MatchedType == DesiredAndAssignedLocation {
	        let matchers: [Cuckoo.ParameterMatcher<(DesiredAndAssignedLocation, DesiredAndAssignedLocation)>] = [wrap(matchable: existingPickupLocation) { $0.0 }, wrap(matchable: existingDropoffLocation) { $0.1 }]
	        return cuckoo_manager.verify("editPickup(existingPickupLocation: DesiredAndAssignedLocation, existingDropoffLocation: DesiredAndAssignedLocation)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func editDropoff<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(existingPickupLocation: M1, existingDropoffLocation: M2) -> Cuckoo.__DoNotUse<(DesiredAndAssignedLocation, DesiredAndAssignedLocation), Void> where M1.MatchedType == DesiredAndAssignedLocation, M2.MatchedType == DesiredAndAssignedLocation {
	        let matchers: [Cuckoo.ParameterMatcher<(DesiredAndAssignedLocation, DesiredAndAssignedLocation)>] = [wrap(matchable: existingPickupLocation) { $0.0 }, wrap(matchable: existingDropoffLocation) { $0.1 }]
	        return cuckoo_manager.verify("editDropoff(existingPickupLocation: DesiredAndAssignedLocation, existingDropoffLocation: DesiredAndAssignedLocation)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

public class CurrentTripListenerStub: CurrentTripListener {
    

    

    
    public func editPickup(existingPickupLocation: DesiredAndAssignedLocation, existingDropoffLocation: DesiredAndAssignedLocation)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
    public func editDropoff(existingPickupLocation: DesiredAndAssignedLocation, existingDropoffLocation: DesiredAndAssignedLocation)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
}


// MARK: - Mocks generated from file: ../RideOsRider/rider/pre_trip/PreTripListener.swift at 2019-11-12 23:26:13 +0000

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


public class MockPreTripListener: PreTripListener, Cuckoo.ProtocolMock {
    
    public typealias MocksType = PreTripListener
    
    public typealias Stubbing = __StubbingProxy_PreTripListener
    public typealias Verification = __VerificationProxy_PreTripListener

    public let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    
    private var __defaultImplStub: PreTripListener?

    public func enableDefaultImplementation(_ stub: PreTripListener) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    

    

    
    
    
    public func onTripCreated(tripId: String)  {
        
    return cuckoo_manager.call("onTripCreated(tripId: String)",
            parameters: (tripId),
            escapingParameters: (tripId),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.onTripCreated(tripId: tripId))
        
    }
    
    
    
    public func cancelPreTrip()  {
        
    return cuckoo_manager.call("cancelPreTrip()",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.cancelPreTrip())
        
    }
    

	public struct __StubbingProxy_PreTripListener: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	    public init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    func onTripCreated<M1: Cuckoo.Matchable>(tripId: M1) -> Cuckoo.ProtocolStubNoReturnFunction<(String)> where M1.MatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: tripId) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockPreTripListener.self, method: "onTripCreated(tripId: String)", parameterMatchers: matchers))
	    }
	    
	    func cancelPreTrip() -> Cuckoo.ProtocolStubNoReturnFunction<()> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockPreTripListener.self, method: "cancelPreTrip()", parameterMatchers: matchers))
	    }
	    
	}

	public struct __VerificationProxy_PreTripListener: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	    public init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	
	    
	    @discardableResult
	    func onTripCreated<M1: Cuckoo.Matchable>(tripId: M1) -> Cuckoo.__DoNotUse<(String), Void> where M1.MatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: tripId) { $0 }]
	        return cuckoo_manager.verify("onTripCreated(tripId: String)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func cancelPreTrip() -> Cuckoo.__DoNotUse<(), Void> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("cancelPreTrip()", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

public class PreTripListenerStub: PreTripListener {
    

    

    
    public func onTripCreated(tripId: String)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
    public func cancelPreTrip()   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
}


// MARK: - Mocks generated from file: ../RideOsRider/rider/set_pickup_dropoff/SetPickupDropoffListener.swift at 2019-11-12 23:26:13 +0000

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


public class MockSetPickupDropoffListener: SetPickupDropoffListener, Cuckoo.ProtocolMock {
    
    public typealias MocksType = SetPickupDropoffListener
    
    public typealias Stubbing = __StubbingProxy_SetPickupDropoffListener
    public typealias Verification = __VerificationProxy_SetPickupDropoffListener

    public let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    
    private var __defaultImplStub: SetPickupDropoffListener?

    public func enableDefaultImplementation(_ stub: SetPickupDropoffListener) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    

    

    
    
    
    public func set(pickup: PreTripLocation, dropoff: PreTripLocation)  {
        
    return cuckoo_manager.call("set(pickup: PreTripLocation, dropoff: PreTripLocation)",
            parameters: (pickup, dropoff),
            escapingParameters: (pickup, dropoff),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.set(pickup: pickup, dropoff: dropoff))
        
    }
    
    
    
    public func cancelSetPickupDropoff()  {
        
    return cuckoo_manager.call("cancelSetPickupDropoff()",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.cancelSetPickupDropoff())
        
    }
    

	public struct __StubbingProxy_SetPickupDropoffListener: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	    public init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    func set<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(pickup: M1, dropoff: M2) -> Cuckoo.ProtocolStubNoReturnFunction<(PreTripLocation, PreTripLocation)> where M1.MatchedType == PreTripLocation, M2.MatchedType == PreTripLocation {
	        let matchers: [Cuckoo.ParameterMatcher<(PreTripLocation, PreTripLocation)>] = [wrap(matchable: pickup) { $0.0 }, wrap(matchable: dropoff) { $0.1 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockSetPickupDropoffListener.self, method: "set(pickup: PreTripLocation, dropoff: PreTripLocation)", parameterMatchers: matchers))
	    }
	    
	    func cancelSetPickupDropoff() -> Cuckoo.ProtocolStubNoReturnFunction<()> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockSetPickupDropoffListener.self, method: "cancelSetPickupDropoff()", parameterMatchers: matchers))
	    }
	    
	}

	public struct __VerificationProxy_SetPickupDropoffListener: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	    public init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	
	    
	    @discardableResult
	    func set<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(pickup: M1, dropoff: M2) -> Cuckoo.__DoNotUse<(PreTripLocation, PreTripLocation), Void> where M1.MatchedType == PreTripLocation, M2.MatchedType == PreTripLocation {
	        let matchers: [Cuckoo.ParameterMatcher<(PreTripLocation, PreTripLocation)>] = [wrap(matchable: pickup) { $0.0 }, wrap(matchable: dropoff) { $0.1 }]
	        return cuckoo_manager.verify("set(pickup: PreTripLocation, dropoff: PreTripLocation)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func cancelSetPickupDropoff() -> Cuckoo.__DoNotUse<(), Void> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("cancelSetPickupDropoff()", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

public class SetPickupDropoffListenerStub: SetPickupDropoffListener {
    

    

    
    public func set(pickup: PreTripLocation, dropoff: PreTripLocation)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
    public func cancelSetPickupDropoff()   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
}

