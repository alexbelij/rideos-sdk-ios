import CoreLocation
import RideOsCommon
import RideOsDriver
import RideOsTestHelpers
import RxTest
import XCTest

class DefaultTripDetailsViewModelTest: ReactiveTestCase {
    private static let contactInfo = ContactInfo(name: "test_name")
    private static let tripResourceInfo = TripResourceInfo(numberOfPassengers: 4, contactInfo: contactInfo)
    
    private static let pickupAction = VehiclePlanAction(
        destination: CLLocationCoordinate2D(latitude: 1, longitude: 2),
        actionType: .driveToPickup,
        tripResourceInfo: tripResourceInfo
    )
    private static let pickupWaypoint = VehiclePlan.Waypoint(taskId: "task_id",
                                                             stepIds: ["pickup_step_id"],
                                                             action: DefaultTripDetailsViewModelTest.pickupAction)
    
    private static let dropoffAction = VehiclePlanAction(
        destination: CLLocationCoordinate2D(latitude: 3, longitude: 4),
        actionType: .driveToDropoff,
        tripResourceInfo: tripResourceInfo
    )
    private static let dropoffWaypoint = VehiclePlan.Waypoint(taskId: "task_id",
                                                             stepIds: ["dropoff_step_id"],
                                                             action: DefaultTripDetailsViewModelTest.dropoffAction)
    
    private static let passengerTextProvider: TripResourceInfo.PassengerTextProvider = {
        "requester_name: \($0.contactInfo.name), number_of_passengers: \($0.numberOfPassengers)"
    }
    
    
    private static let tripDetailActionTextProvider: DefaultTripDetailsViewModel.TripDetailActionTextProvider = { _ in
        TripDetailActionText(
            actionText: "test_action_text",
            confirmationTitle: "test_action_confirmation_title",
            confirmationMessage: "test_action_confirmation_message",
            confirmationActionTitle: "test_action_confirmation_action_title"
        )
    }
    
    private static let style = DefaultTripDetailsViewModel.Style(
        passengerTextProvider: passengerTextProvider,
        tripDetailActionTextProvider: tripDetailActionTextProvider
    )
    
    private var viewModelUnderTest: DefaultTripDetailsViewModel!
    private var tableDetailSectionsRecorder: TestableObserver<[TripDetailSection]>!
    
    func setUp(with plan: VehiclePlan) {
        viewModelUnderTest = DefaultTripDetailsViewModel(
            vehiclePlan: plan,
            userStorageReader: UserDefaultsUserStorageReader(
            userDefaults: TemporaryUserDefaults(stringValues: [CommonUserStorageKeys.userId: "user id"])
            ),
            driverVehicleInteractor: FixedDriverVehicleInteractor(),
            geocodeInteractor: EchoGeocodeInteractor(scheduler: scheduler),
            style: DefaultTripDetailsViewModelTest.style,
            schedulerProvider: TestSchedulerProvider(scheduler: scheduler)
        )
        
        tableDetailSectionsRecorder = scheduler.record(viewModelUnderTest.tripDetailSections)
    }
    
    func testViewModelReflectsExpectedTripDetailSections() {
        setUp(with: VehiclePlan(waypoints: [
            DefaultTripDetailsViewModelTest.pickupWaypoint,
            DefaultTripDetailsViewModelTest.dropoffWaypoint,
            ])
        )

        let expectedPassengerText = DefaultTripDetailsViewModelTest.passengerTextProvider(
            DefaultTripDetailsViewModelTest.tripResourceInfo
        )
        let expectedActionText = DefaultTripDetailsViewModelTest.tripDetailActionTextProvider(.endTrip)
        
        let expectedSections = [
            TripDetailSection([
                TripDetailSectionItem.passengerItem(
                    passengerText: expectedPassengerText,
                    contactUrl: DefaultTripDetailsViewModelTest.contactInfo.url
                ),
                TripDetailSectionItem.pickupAddressItem(addressText: EchoGeocodeInteractor.displayName),
                TripDetailSectionItem.dropoffAddressItem(addressText: EchoGeocodeInteractor.displayName),
                TripDetailSectionItem.tripActionItem(actionText: expectedActionText, action: { })
                ]),
        ]
        
        scheduler.start()
        
        XCTAssertEqual(tableDetailSectionsRecorder.events, [
            next(4, expectedSections),
            completed(5),
            ])
    }
}
