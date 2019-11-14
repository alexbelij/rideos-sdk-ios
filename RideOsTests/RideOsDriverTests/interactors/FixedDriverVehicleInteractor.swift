import CoreLocation
import Foundation
import RideOsApi
import RideOsCommon
import RideOsDriver
import RideOsTestHelpers
import RxSwift

public class FixedDriverVehicleInteractor: MethodCallRecorder, DriverVehicleInteractor {
    private let vehicleStatus: VehicleStatus
    private let vehicleState: RideHailCommonsVehicleState
    private let markVehicleReadyError: Error?
    private let markVehicleNotReadyError: Error?
    private let finishStepsError: Error?

    public init(vehicleStatus: VehicleStatus = .unregistered,
                vehicleState: RideHailCommonsVehicleState = RideHailCommonsVehicleState(),
                markVehicleReadyError: Error? = nil,
                markVehicleNotReadyError: Error? = nil,
                finishStepsError: Error? = nil) {
        self.vehicleStatus = vehicleStatus
        self.vehicleState = vehicleState
        self.markVehicleReadyError = markVehicleReadyError
        self.markVehicleNotReadyError = markVehicleNotReadyError
        self.finishStepsError = finishStepsError
    }

    public func createVehicle(vehicleId _: String,
                              fleetId: String,
                              vehicleInfo: VehicleRegistration) -> Completable {
        recordMethodCall(#function)
        return Completable.empty()
    }

    public func markVehicleReady(vehicleId _: String) -> Completable {
        recordMethodCall(#function)
        if let markVehicleReadyError = markVehicleReadyError {
            return Completable.error(markVehicleReadyError)
        }
        
        return Completable.empty()
    }

    public func markVehicleNotReady(vehicleId _: String) -> Completable {
        recordMethodCall(#function)
        if let markVehicleNotReadyError = markVehicleNotReadyError {
            return Completable.error(markVehicleNotReadyError)
        }
        
        return Completable.empty()
    }

    public func finishSteps(vehicleId _: String, taskId _: String, stepIds _: [String]) -> Completable {
        recordMethodCall(#function)
        if let finishStepsError = finishStepsError {
            return Completable.error(finishStepsError)
        }
        
        return Completable.empty()
    }
    
    public func rejectTrip(vehicleId: String, tripId: String) -> Completable {
        return Completable.empty()
    }
    
    public func cancelTrip(tripId: String) -> Completable {
        return Completable.empty()
    }
    
    public func getVehicleStatus(vehicleId: String) -> Single<VehicleStatus> {
        recordMethodCall(#function)
        return Single.just(vehicleStatus)
    }

    public func getVehicleState(vehicleId _: String) -> Single<RideHailCommonsVehicleState> {
        recordMethodCall(#function)
        return Single.just(vehicleState)
    }

    public func updateVehiclePose(vehicleId _: String,
                                  vehicleCoordinate _: CLLocationCoordinate2D,
                                  vehicleHeading _: CLLocationDirection) -> Completable {
        recordMethodCall(#function)
        return Completable.empty()
    }

    public func updateVehicleRouteLegs(
        vehicleId _: String,
        legs _: [RideHailDriverUpdateVehicleStateRequest_SetRouteLegs_LegDefinition]
    ) -> Completable {
        recordMethodCall(#function)
        return Completable.empty()
    }
    
    public func updateContactInfo(vehicleId: String, contactInfo: ContactInfo) -> Completable {
        recordMethodCall(#function)
        return Completable.empty()
    }
    
    public func updateLicensePlate(vehicleId: String, licensePlate: String) -> Completable {
        recordMethodCall(#function)
        return Completable.empty()
    }
    
    public func getVehicleInfo(vehicleId: String) -> Single<VehicleInfo> {
        recordMethodCall(#function)
        return Single.just(VehicleInfo(licensePlate: "", contactInfo: ContactInfo()))
    }
}
