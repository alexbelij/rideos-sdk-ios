import RideOsCommon
import RideOsDriver
import RideOsTestHelpers
import RxCocoa
import RxSwift
import RxTest
import XCTest

class DefaultVehicleRegistrationViewModelTest: ReactiveTestCase {
    var viewModelUnderTest: DefaultVehicleRegistrationViewModel!
    var isSubmitActionEnabledRecorder: TestableObserver<Bool>!
    var fixedDriverVehicleInteractor: FixedDriverVehicleInteractor!

    override func setUp() {
        super.setUp()
        ResolvedFleet.instance.set(resolvedFleet: FleetInfo.defaultFleetInfo)
        fixedDriverVehicleInteractor = FixedDriverVehicleInteractor()
        viewModelUnderTest =
            DefaultVehicleRegistrationViewModel(schedulerProvider: TestSchedulerProvider(scheduler: scheduler),
                                                driverVehicleInteractor: fixedDriverVehicleInteractor,
                                                userStorageReader: UserDefaultsUserStorageReader(
                                                    userDefaults: TemporaryUserDefaults(
                                                        stringValues: [CommonUserStorageKeys.userId: "user id"]
                                                    )
                                                ))

        isSubmitActionEnabledRecorder = scheduler.createObserver(Bool.self)
        viewModelUnderTest.isSubmitActionEnabled()
            .asDriver(onErrorJustReturn: false)
            .drive(isSubmitActionEnabledRecorder)
            .disposed(by: disposeBag)

        assertNil(viewModelUnderTest, after: { self.viewModelUnderTest = nil })
    }

    func testIsSumbitActionEnabledWhenAllFieldsValid() {
        scheduler.scheduleAt(1) { self.viewModelUnderTest.setPreferredNameText("FirstName") }
        scheduler.scheduleAt(2) { self.viewModelUnderTest.setPhoneNumberText("000-000-0000") }
        scheduler.scheduleAt(3) { self.viewModelUnderTest.setLicensePlateText("ABC1234") }
        scheduler.scheduleAt(4) { self.viewModelUnderTest.setRiderCapacityText("4") }
        
        scheduler.start()

        XCTAssertEqual(isSubmitActionEnabledRecorder.events, [
            next(0, false),
            next(1, false),
            next(2, false),
            next(3, false),
            next(4, true),
        ])
    }

    func testSubmitFailsIfFieldsAreInvalid() {
        let submitActionRecorder = scheduler.record(viewModelUnderTest.submit())
        
        scheduler.start()

        XCTAssertEqual(submitActionRecorder.events, [
            error(0, InvalidVehicleRegistrationInfoError.invalidInfo("Invalid registration info")),
            ])
    }

    func testSubmitSucceedsIfAllFieldsAreValid() {
        viewModelUnderTest.setPreferredNameText("FirstName")
        viewModelUnderTest.setPhoneNumberText("000-000-0000")
        viewModelUnderTest.setLicensePlateText("ABC1234")
        viewModelUnderTest.setRiderCapacityText("4")

        let submitActionRecorder = scheduler.record(viewModelUnderTest.submit())
        
        scheduler.start()
        
        XCTAssertEqual(fixedDriverVehicleInteractor.methodCalls, ["createVehicle(vehicleId:fleetId:vehicleInfo:)"])
        XCTAssertEqual(submitActionRecorder.events, [
            completed(0),
            ])
    }
}
