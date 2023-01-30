//
//  RoutingManager.swift
//  Wifinity
//
//  Created by Rupendra on 17/01/21.
//

import UIKit


class RoutingManager: NSObject {
    
    static var shared :RoutingManager = {
        return RoutingManager()
    }()
    
    
    func goBackToController(_ pController :UIViewController) {
        pController.navigationController?.popToViewController(pController, animated: true)
    }
    
    func goToPreviousScreen(_ pController :UIViewController) {
        pController.navigationController?.popViewController(animated: true)
    }
}



// MARK:- User

extension RoutingManager {
    
    func goBackToLogin() {
        if let aRootController = UIApplication.shared.keyWindow?.rootViewController {
            if let aNavController = aRootController as? UINavigationController {
                if let aLoginController = aNavController.viewControllers.first as? LoginController {
                    aNavController.popToViewController(aLoginController, animated: true)
                }
            }
        }
    }
    
    func forgotPasswordControllerUsingStoryboard() -> ForgotPasswordController {
        return UIStoryboard(name: "Login", bundle: Bundle.main).instantiateViewController(withIdentifier: "ForgotPasswordControllerId") as! ForgotPasswordController
    }
    
    func gotoForgotPassword(
        controller pController :UIViewController
        , emailAddress pEmailAddress :String?
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.forgotPasswordControllerUsingStoryboard()
        aDestinationController.emailAddress = pEmailAddress
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    func CreateAccountControllerUsingStoryboard() -> CreateAccountViewController {
        return UIStoryboard(name: "Login", bundle: Bundle.main).instantiateViewController(withIdentifier: "CreateAccountViewController") as! CreateAccountViewController
    }
    func gotoCreateAccount(
        controller pController :UIViewController
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.CreateAccountControllerUsingStoryboard()
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    func veryfyOtpControllerUsingStoryboard() -> OTPVerifyViewController {
        return UIStoryboard(name: "Login", bundle: Bundle.main).instantiateViewController(withIdentifier: "OTPVerifyViewController") as! OTPVerifyViewController
    }
    // common
    func demologin() -> UIStoryboard {
      return UIStoryboard(name: "Login", bundle: Bundle.main)
    }
    func demolog(uiviwe: UIViewController, xstory: UIStoryboard) -> UIViewController {
        xstory.instantiateViewController(withIdentifier: uiviwe.restorationIdentifier!)
        return uiviwe
    }
    func gotoVerifyOtp(
        controller pController :UIViewController
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false, msg: String, userName: String, phoneN: String, password: String,otp: String, email: String) {
        let aDestinationController = self.veryfyOtpControllerUsingStoryboard()
            aDestinationController.msg = msg
            aDestinationController.userName = userName
            aDestinationController.phoneNumber = phoneN
            aDestinationController.password = password
            aDestinationController.OTP = otp
            aDestinationController.email = email
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
}



// MARK:- Dashboard

extension RoutingManager {
    
    func dashboardControllerUsingStoryboard() -> DashboardController {
        return UIStoryboard(name: "Dashboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "DashboardControllerId") as! DashboardController
    }
    
    func gotoDashboard(
        controller pController :UIViewController
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.dashboardControllerUsingStoryboard()
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    func goBackToDashboard() {
        if let aRootController = UIApplication.shared.keyWindow?.rootViewController {
            if let aNavController = aRootController as? UINavigationController {
                if aNavController.viewControllers.count > 2, let aDashboardController = aNavController.viewControllers[1] as? DashboardController {
                    aNavController.popToViewController(aDashboardController, animated: true)
                }
            }
        }
    }
    
    
    func drawerControllerUsingStoryboard() -> DrawerController {
        return UIStoryboard(name: "Dashboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "DrawerControllerId") as! DrawerController
    }
}



// MARK:- Room

extension RoutingManager {
    
    func selectRoomControllerUsingStoryboard() -> SelectRoomController {
        return UIStoryboard(name: "Room", bundle: Bundle.main).instantiateViewController(withIdentifier: "SelectRoomControllerId") as! SelectRoomController
    }
    
    func gotoSelectRoom(
        controller pController :UIViewController
        , roomSelectionType pRoomSelectionType :SelectRoomController.SelectionType
        , delegate pDelegate :SelectRoomControllerDelegate
        , shouldAllowAddRoom pShouldAllowAddRoom :Bool
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false
        , selectedRooms pSelectedRoomArray :Array<Room>?) {
        let aDestinationController = self.selectRoomControllerUsingStoryboard()
        aDestinationController.selectionType = pRoomSelectionType
        aDestinationController.delegate = pDelegate
        aDestinationController.shouldAllowAddRoom = pShouldAllowAddRoom
        if let aSelectedRoomArray = pSelectedRoomArray {
            aDestinationController.selectedRooms = aSelectedRoomArray
        }
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    
    func selectComponentControllerUsingStoryboard() -> SelectComponentController {
        return UIStoryboard(name: "Appliance", bundle: Bundle.main).instantiateViewController(withIdentifier: "SelectComponentControllerId") as! SelectComponentController
    }
    
    func gotoSelectComponent(
        controller pController :UIViewController
        , componentTypes pComponentTypeArray :Array<SelectComponentController.ComponentType>
        , selectedRoom pSelectedRoom :Room
        , delegate pDelegate :SelectComponentControllerDelegate
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.selectComponentControllerUsingStoryboard()
        aDestinationController.componentTypes = pComponentTypeArray
        aDestinationController.selectedRoom = pSelectedRoom
        aDestinationController.delegate = pDelegate
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
}



// MARK:- Device

extension RoutingManager {
    
    #if APP_WIFINITY
    
    func newDeviceControllerUsingStoryboard() -> NewDeviceController {
        return UIStoryboard(name: "Device", bundle: Bundle.main).instantiateViewController(withIdentifier: "NewDeviceControllerId") as! NewDeviceController
    }
    
    func gotoNewDevice(
        controller pController :UIViewController
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.newDeviceControllerUsingStoryboard()
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    
    func newDeviceScanQrCodeControllerUsingStoryboard() -> NewDeviceScanQrCodeController {
        return UIStoryboard(name: "Device", bundle: Bundle.main).instantiateViewController(withIdentifier: "NewDeviceScanQrCodeControllerId") as! NewDeviceScanQrCodeController
    }
    
    func gotoNewDeviceScanQrCode(
        controller pController :UIViewController
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.newDeviceScanQrCodeControllerUsingStoryboard()
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    
    func newDeviceConnectDeviceHotspotControllerUsingStoryboard() -> NewDeviceConnectDeviceHotspotController {
        return UIStoryboard(name: "Device", bundle: Bundle.main).instantiateViewController(withIdentifier: "NewDeviceConnectDeviceHotspotControllerId") as! NewDeviceConnectDeviceHotspotController
    }
    
    func gotoNewDeviceConnectDeviceHotspot(
        controller pController :UIViewController
        , selectedDevice pSelectedDevice :Device
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.newDeviceConnectDeviceHotspotControllerUsingStoryboard()
        aDestinationController.device = pSelectedDevice
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    
    func newDeviceConfigureDeviceControllerUsingStoryboard() -> NewDeviceConfigureDeviceController {
        return UIStoryboard(name: "Device", bundle: Bundle.main).instantiateViewController(withIdentifier: "NewDeviceConfigureDeviceControllerId") as! NewDeviceConfigureDeviceController
    }
    
    func gotoNewDeviceConfigureDevice(
        controller pController :UIViewController
        , selectedDevice pSelectedDevice :Device
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.newDeviceConfigureDeviceControllerUsingStoryboard()
        aDestinationController.device = pSelectedDevice
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    
    func newDeviceReconnectInternetControllerUsingStoryboard() -> NewDeviceReconnectInternetController {
        return UIStoryboard(name: "Device", bundle: Bundle.main).instantiateViewController(withIdentifier: "NewDeviceReconnectInternetControllerId") as! NewDeviceReconnectInternetController
    }
    
    func gotoNewDeviceReconnectInternet(
        controller pController :UIViewController
        , selectedDevice pSelectedDevice :Device
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.newDeviceReconnectInternetControllerUsingStoryboard()
        aDestinationController.device = pSelectedDevice
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    
    func newDeviceSelectRoomControllerUsingStoryboard() -> NewDeviceSelectRoomController {
        return UIStoryboard(name: "Device", bundle: Bundle.main).instantiateViewController(withIdentifier: "NewDeviceSelectRoomControllerId") as! NewDeviceSelectRoomController
    }
    
    func gotoNewDeviceSelectRoom(
        controller pController :UIViewController
        , selectedDevice pSelectedDevice :Device
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.newDeviceSelectRoomControllerUsingStoryboard()
        aDestinationController.device = pSelectedDevice
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    
    func newDeviceInputPasswordControllerUsingStoryboard() -> NewDeviceInputPasswordController {
        return UIStoryboard(name: "Device", bundle: Bundle.main).instantiateViewController(withIdentifier: "NewDeviceInputPasswordControllerId") as! NewDeviceInputPasswordController
    }
    
    func gotoNewDeviceInputPassword(
        controller pController :UIViewController
        , selectedDevice pSelectedDevice :Device
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.newDeviceInputPasswordControllerUsingStoryboard()
        aDestinationController.device = pSelectedDevice
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    #endif
    
    
    #if !APP_WIFINITY
    
    func searchDeviceControllerUsingStoryboard() -> SearchDeviceController {
        return UIStoryboard(name: "Device", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchDeviceControllerId") as! SearchDeviceController
    }
    
    func gotoSearchDevice(
        controller pController :UIViewController
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.searchDeviceControllerUsingStoryboard()
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    #endif
    
    
    #if APP_WIFINITY
    
    func selectDeviceControllerUsingStoryboard() -> SelectDeviceController {
        return UIStoryboard(name: "Device", bundle: Bundle.main).instantiateViewController(withIdentifier: "SelectDeviceControllerId") as! SelectDeviceController
    }
    
    func gotoSelectDevice(
        controller pController :UIViewController
        , delegate pDelegate :SelectDeviceControllerDelegate
        , room pRoom :Room?
        , hardwareTypes pHardwareTypeArray :Array<Device.HardwareType>?
        , shouldCheckForAddedApplianceCount pShouldCheckForAddedApplianceCount :Bool = false
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.selectDeviceControllerUsingStoryboard()
        aDestinationController.delegate = pDelegate
        aDestinationController.room = pRoom
        aDestinationController.hardwareTypes = pHardwareTypeArray
        aDestinationController.shouldCheckForAddedApplianceCount = pShouldCheckForAddedApplianceCount
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    #endif
}

// MARK: - OFFLINE DATABASE
extension RoutingManager{
    func selectOflineTypeControllerUsingStoryboard() -> OfflineApplinceViewController {
        return UIStoryboard(name: "Offline", bundle: Bundle.main).instantiateViewController(withIdentifier: "OfflineApplinceViewController") as! OfflineApplinceViewController
    }
}

// MARK:- Appliance

extension RoutingManager {
    
    func selectApplianceTypeControllerUsingStoryboard() -> SelectApplianceTypeController {
        return UIStoryboard(name: "Appliance", bundle: Bundle.main).instantiateViewController(withIdentifier: "SelectApplianceTypeControllerId") as! SelectApplianceTypeController
    }
    
    func gotoSelectApplianceType(
        controller pController :UIViewController
        , delegate pDelegate :SelectApplianceTypeControllerDelegate
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.selectApplianceTypeControllerUsingStoryboard()
        aDestinationController.delegate = pDelegate
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    
    func selectDimTypeControllerUsingStoryboard() -> SelectDimTypeController {
        return UIStoryboard(name: "Appliance", bundle: Bundle.main).instantiateViewController(withIdentifier: "SelectDimTypeControllerId") as! SelectDimTypeController
    }
    
    func gotoSelectDimType(
        controller pController :UIViewController
        , delegate pDelegate :SelectDimTypeControllerDelegate
        , hardwareType pHardwareType :Device.HardwareType?
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.selectDimTypeControllerUsingStoryboard()
        aDestinationController.delegate = pDelegate
        aDestinationController.hardwareType = pHardwareType
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    
    func newApplianceControllerUsingStoryboard() -> NewApplianceController {
        return UIStoryboard(name: "Appliance", bundle: Bundle.main).instantiateViewController(withIdentifier: "NewApplianceControllerId") as! NewApplianceController
    }
    
    func gotoNewAppliance(
        controller pController :UIViewController
        , selectedRoom pSelectedRoom :Room
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.newApplianceControllerUsingStoryboard()
        aDestinationController.room = pSelectedRoom
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    
    func searchApplianceControllerUsingStoryboard() -> SearchApplianceController {
        return UIStoryboard(name: "Appliance", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchApplianceControllerId") as! SearchApplianceController
    }
    
    func gotoSearchAppliance(
        controller pController :UIViewController
        , selectedRoom pSelectedRoom :Room?
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.searchApplianceControllerUsingStoryboard()
        aDestinationController.selectedRoom = pSelectedRoom
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    func gotoOfferZone(
        controller pController :UIViewController
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.selectOfferZonrControllerUsingStoryboard()
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    func gotoCore(
        controller pController :UIViewController
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.selectCoreControllerUsingStoryboard()
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }

    func gotoOffline(
        controller pController :UIViewController
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.selectOfflineControllerUsingStoryboard()
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    func gotoCameras(
        controller pController :UIViewController
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.selectCamerasControllerUsingStoryboard()
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    func gotoVDPCameras(
        controller pController :UIViewController
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.selectVDPCamerasControllerUsingStoryboard()
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    func gotoVDPCustom(
        controller pController :UIViewController
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false,vdpmodul: VDPModul) {
        let aDestinationController = self.selectVDPCustommsgControllerUsingStoryboard()
            aDestinationController.vdpmodule = vdpmodul
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    func gotoHelp(
        controller pController :UIViewController
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.selectHelpControllerUsingStoryboard()
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    func gotoSupport(
        controller pController :UIViewController
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.selectSupportControllerUsingStoryboard()
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    func gotoProductManual(
        controller pController :UIViewController
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.selectProductManualControllerUsingStoryboard()
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    func gotoSubmitSupport(
        controller pController :UIViewController
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false, name: String) {
        let aDestinationController = self.selectSubmitSupportControllerUsingStoryboard()
            aDestinationController.appType = name
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    func gotoResolveVC(
        controller pController :UIViewController
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.selectResolveVCControllerUsingStoryboard()
         //   aDestinationController.appType = name
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    func gotoResolveDetialVC(
        controller pController :UIViewController
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false, pcomplent: Complents) {
        let aDestinationController = self.selectResolvedetailVCControllerUsingStoryboard()
             aDestinationController.pcomplent = pcomplent
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    func gotoOnGoingVC(
        controller pController :UIViewController
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.selectOnGoingVCControllerUsingStoryboard()
         //   aDestinationController.appType = name
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    func gotoOfflineApplinces(
        controller pController :UIViewController, controllerId: [String], controller_kId: [String], alldatajson: [String]
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.selectOfflineApplincesControllerUsingStoryboard()
            aDestinationController.controller_id = controllerId
            aDestinationController.controller_Kid = controller_kId
            aDestinationController.alldataJson = alldatajson
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    func selectOfflineApplincesControllerUsingStoryboard() -> OfflineApplinceViewController {
        return UIStoryboard(name: "Offline", bundle: Bundle.main).instantiateViewController(withIdentifier: "OfflineApplinceViewController") as! OfflineApplinceViewController
    }
    func selectCamerasControllerUsingStoryboard() -> CamerasViewController {
        return UIStoryboard(name: "CameraBoard", bundle: Bundle.main).instantiateViewController(withIdentifier: "CamerasViewController") as! CamerasViewController
    }
    func selectVDPCamerasControllerUsingStoryboard() -> VDPListViewController {
        return UIStoryboard(name: "VDP", bundle: Bundle.main).instantiateViewController(withIdentifier: "VDPListViewController") as! VDPListViewController
    }
    func selectVDPCustommsgControllerUsingStoryboard() -> CustomMsgViewController {
        return UIStoryboard(name: "VDP", bundle: Bundle.main).instantiateViewController(withIdentifier: "CustomMsgViewController") as! CustomMsgViewController
    }
    func selectHelpControllerUsingStoryboard() -> SelectTypeViewController {
        return UIStoryboard(name: "HelpAndSupport", bundle: Bundle.main).instantiateViewController(withIdentifier: "SelectTypeViewController") as! SelectTypeViewController
    }
    func selectSupportControllerUsingStoryboard() -> SupportViewController {
        return UIStoryboard(name: "HelpAndSupport", bundle: Bundle.main).instantiateViewController(withIdentifier: "SupportViewController") as! SupportViewController
    }
    func selectProductManualControllerUsingStoryboard() -> ProductManualViewController {
        return UIStoryboard(name: "HelpAndSupport", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProductManualViewController") as! ProductManualViewController
    }
    
    func selectSubmitSupportControllerUsingStoryboard() -> SubmitViewController {
        return UIStoryboard(name: "HelpAndSupport", bundle: Bundle.main).instantiateViewController(withIdentifier: "SubmitViewController") as! SubmitViewController
    }
    func selectResolveVCControllerUsingStoryboard() -> ResolveIssueViewController {
        return UIStoryboard(name: "HelpAndSupport", bundle: Bundle.main).instantiateViewController(withIdentifier: "ResolveIssueViewController") as! ResolveIssueViewController
    }
    func selectResolvedetailVCControllerUsingStoryboard() -> detailResolveViewController {
        return UIStoryboard(name: "HelpAndSupport", bundle: Bundle.main).instantiateViewController(withIdentifier: "detailResolveViewController") as! detailResolveViewController
    }
    func selectOnGoingVCControllerUsingStoryboard() -> OnGoingIssieViewController {
        return UIStoryboard(name: "HelpAndSupport", bundle: Bundle.main).instantiateViewController(withIdentifier: "OnGoingIssieViewController") as! OnGoingIssieViewController
    }
    func selectOfferZonrControllerUsingStoryboard() -> OfferZoneViewController {
        return UIStoryboard(name: "OfferZone", bundle: Bundle.main).instantiateViewController(withIdentifier: "OfferZoneViewController") as! OfferZoneViewController
    }
    func selectOfflineControllerUsingStoryboard() -> PingViewController {
        return UIStoryboard(name: "Offline", bundle: Bundle.main).instantiateViewController(withIdentifier: "PingViewController") as! PingViewController
    }
    func selectCoreControllerUsingStoryboard() -> CoreViewController {
        return UIStoryboard(name: "Core", bundle: Bundle.main).instantiateViewController(withIdentifier: "CoreViewController") as! CoreViewController
    }
    //
    func gotoApplianceDetails(
        controller pController :UIViewController
        , selectedAppliance pSelectedAppliance :Appliance
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.newApplianceControllerUsingStoryboard()
        aDestinationController.appliance = pSelectedAppliance
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    func selectOfferDetailControllerUsingStoryboard() -> OfferDetailViewController {
        return UIStoryboard(name: "OfferZone", bundle: Bundle.main).instantiateViewController(withIdentifier: "OfferDetailViewController") as! OfferDetailViewController
    }
    
    func goToOfferDetailViewController(
        controller pController :UIViewController
        , selectedOffer offerData :OfferData
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.selectOfferDetailControllerUsingStoryboard()
        aDestinationController.offerData = offerData
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
}

extension RoutingManager{
    func selectvdpdetailControllerUsingStoryboard() -> VdpViewController {
        return UIStoryboard(name: "VDP", bundle: Bundle.main).instantiateViewController(withIdentifier: "VdpViewController") as! VdpViewController
    }
    func gotoVDPPlay(
        controller pController :UIViewController
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false, Obj: VDPModul) {
        let aDestinationController = self.selectvdpdetailControllerUsingStoryboard()
            aDestinationController.vdpmodule = Obj
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
}

// MARK:- Lock

extension RoutingManager {
    
    func searchLockControllerUsingStoryboard() -> SearchLockController {
        return UIStoryboard(name: "Lock", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchLockControllerId") as! SearchLockController
    }
    
    
    func gotoSearchLock(controller pController :UIViewController, shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        pController.navigationController?.pushViewController(self.searchLockControllerUsingStoryboard(), animated: true)
    }
    
}


// MARK:- TankRegulator
//#if !APP_WIFINITY

extension RoutingManager {
    
    func searchTankRegulatorControllerUsingStoryboard() -> SearchTankRegulatorController {
        return UIStoryboard(name: "TankRegulator", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchTankRegulatorControllerId") as! SearchTankRegulatorController
    }
    
    
    func gotoSearchTankRegulator(controller pController :UIViewController, shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        pController.navigationController?.pushViewController(self.searchTankRegulatorControllerUsingStoryboard(), animated: true)
    }
    
}

//#endif


// MARK:- Schedule

extension RoutingManager {
    
    func newScheduleControllerUsingStoryboard() -> NewScheduleController {
        return UIStoryboard(name: "Schedule", bundle: Bundle.main).instantiateViewController(withIdentifier: "NewScheduleControllerId") as! NewScheduleController
    }
    
    func gotoNewSchedule(
        controller pController :UIViewController
        , delegate pDelegate :NewScheduleControllerDelegate
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.newScheduleControllerUsingStoryboard()
        aDestinationController.delegate = pDelegate
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    func gotoScheduleDetails(
        controller pController :UIViewController
        , selectedSchedule pSelectedSchedule :Schedule
        , delegate pDelegate :NewScheduleControllerDelegate
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.newScheduleControllerUsingStoryboard()
        aDestinationController.schedule = pSelectedSchedule
        aDestinationController.delegate = pDelegate
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    
    func searchScheduleControllerUsingStoryboard() -> SearchScheduleController {
        return UIStoryboard(name: "Schedule", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchScheduleControllerId") as! SearchScheduleController
    }
    
    
    func gotoSearchSchedule(controller pController :UIViewController, shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        pController.navigationController?.pushViewController(self.searchScheduleControllerUsingStoryboard(), animated: true)
    }
    
}



// MARK:- AppNotification

extension RoutingManager {
    
    func searchAppNotificationTypeControllerUsingStoryboard() -> SearchAppNotificationTypeController {
        return UIStoryboard(name: "AppNotification", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchAppNotificationTypeControllerId") as! SearchAppNotificationTypeController
    }
    
    func gotoSearchAppNotificationType(
        controller pController :UIViewController
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.searchAppNotificationTypeControllerUsingStoryboard()
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    
    func searchAppNotificationControllerUsingStoryboard() -> SearchAppNotificationController {
        return UIStoryboard(name: "AppNotification", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchAppNotificationControllerId") as! SearchAppNotificationController
    }
    
    func gotoSearchAppNotification(
        controller pController :UIViewController
        , selectedAppNotificationType pSelectedAppNotificationType :AppNotification.AppNotificationType
        , hardwareId pHardwareId :String? = nil
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.searchAppNotificationControllerUsingStoryboard()
        aDestinationController.selectedAppNotificationType = pSelectedAppNotificationType
        aDestinationController.selectedHardwareId = pHardwareId
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    
    func appNotificationSettingsControllerUsingStoryboard() -> AppNotificationSettingsController {
        return UIStoryboard(name: "AppNotification", bundle: Bundle.main).instantiateViewController(withIdentifier: "AppNotificationSettingsControllerId") as! AppNotificationSettingsController
    }
    
    func gotoAppNotificationSettings(
        controller pController :UIViewController
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.appNotificationSettingsControllerUsingStoryboard()
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
}



// MARK:- Rule

extension RoutingManager {
    
    func searchRuleControllerUsingStoryboard() -> SearchRuleController {
        return UIStoryboard(name: "Rule", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchRuleControllerId") as! SearchRuleController
    }
    
    
    func gotoSearchRule(controller pController :UIViewController, shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        pController.navigationController?.pushViewController(self.searchRuleControllerUsingStoryboard(), animated: true)
    }
    
    
    func rulePortalControllerUsingStoryboard() -> RulePortalController {
        return UIStoryboard(name: "Rule", bundle: Bundle.main).instantiateViewController(withIdentifier: "RulePortalControllerId") as! RulePortalController
    }
    
    
    func gotoRulePortal(controller pController :UIViewController, shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        pController.navigationController?.pushViewController(self.rulePortalControllerUsingStoryboard(), animated: true)
    }
    
}


// MARK:- Support
#if !APP_WIFINITY

extension RoutingManager {
    
    func supportDetailsControllerUsingStoryboard() -> SupportDetailsController {
        return UIStoryboard(name: "Support", bundle: Bundle.main).instantiateViewController(withIdentifier: "SupportDetailsControllerId") as! SupportDetailsController
    }
    
    
    func gotoSupportDetails(controller pController :UIViewController, shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        pController.navigationController?.pushViewController(self.supportDetailsControllerUsingStoryboard(), animated: true)
    }
    
}

#endif



// MARK:- Curtain

extension RoutingManager {
    
    func searchCurtainControllerUsingStoryboard() -> SearchCurtainController {
        return UIStoryboard(name: "Curtain", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchCurtainControllerId") as! SearchCurtainController
    }
    
    
    func gotoSearchCurtain(
        controller pController :UIViewController
        , selectedRoom pSelectedRoom :Room
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.searchCurtainControllerUsingStoryboard()
        aDestinationController.selectedRoom = pSelectedRoom
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
}



// MARK:- Remote

extension RoutingManager {
    
    func newRemoteControllerUsingStoryboard() -> NewRemoteController {
        return UIStoryboard(name: "Remote", bundle: Bundle.main).instantiateViewController(withIdentifier: "NewRemoteControllerId") as! NewRemoteController
    }
    
    
    func gotoNewRemote(controller pController :UIViewController, shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        pController.navigationController?.pushViewController(self.newRemoteControllerUsingStoryboard(), animated: true)
    }
    
    
    func searchRemoteControllerUsingStoryboard() -> SearchRemoteController {
        return UIStoryboard(name: "Remote", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchRemoteControllerId") as! SearchRemoteController
    }
    
    func gotoSearchRemote(
        controller pController :UIViewController
        , selectedRoom pSelectedRoom :Room
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.searchRemoteControllerUsingStoryboard()
        aDestinationController.selectedRoom = pSelectedRoom
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    
    func remoteDetailsControllerUsingStoryboard() -> RemoteDetailsController {
        return UIStoryboard(name: "Remote", bundle: Bundle.main).instantiateViewController(withIdentifier: "RemoteDetailsControllerId") as! RemoteDetailsController
    }
    
    func gotoRemoteDetails(
        controller pController :UIViewController
        , selectedRemote pSelectedRemote :Remote
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.remoteDetailsControllerUsingStoryboard()
        aDestinationController.selectedRemote = pSelectedRemote
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    
    func updateRemoteButtonControllerUsingStoryboard() -> UpdateRemoteButtonController {
        return UIStoryboard(name: "Remote", bundle: Bundle.main).instantiateViewController(withIdentifier: "UpdateRemoteButtonControllerId") as! UpdateRemoteButtonController
    }
    
    func gotoUpdateRemoteButton(
        controller pController :UIViewController
        , selectedRemote pSelectedRemote :Remote
        , selectedRemoteKey pSelectedRemoteKey :RemoteKey
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.updateRemoteButtonControllerUsingStoryboard()
        aDestinationController.selectedRemote = pSelectedRemote
        aDestinationController.selectedRemoteKey = pSelectedRemoteKey
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    
    func selectRemoteKeyControllerUsingStoryboard() -> SelectRemoteKeyController {
        return UIStoryboard(name: "Remote", bundle: Bundle.main).instantiateViewController(withIdentifier: "SelectRemoteKeyControllerId") as! SelectRemoteKeyController
    }
    
    
    func gotoSelectRemoteKey(controller pController :UIViewController
        , remote pRemote :Remote
        , delegate pDelegate :SelectRemoteKeyControllerDelegate
        , componentType pComponentType :SelectComponentController.ComponentType
        , selectedRemoteKeys pSelectedRemoteKeyArray :Array<RemoteKey>?
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.selectRemoteKeyControllerUsingStoryboard()
        aDestinationController.remote = pRemote
        aDestinationController.componentType = pComponentType
        if let aSelectedRemoteKeyArray = pSelectedRemoteKeyArray {
            aDestinationController.selectedRemoteKeys = aSelectedRemoteKeyArray
        }
        aDestinationController.delegate = pDelegate
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    
    #if !APP_WIFINITY
    
    func selectRemoteKeySequenceControllerUsingStoryboard() -> SelectRemoteKeySequenceController {
        return UIStoryboard(name: "Remote", bundle: Bundle.main).instantiateViewController(withIdentifier: "SelectRemoteKeySequenceController") as! SelectRemoteKeySequenceController
    }
    
    
    func gotoSelectRemoteKeySequence(controller pController :UIViewController
        , remote pRemote :Remote
        , delegate pDelegate :SelectRemoteKeySequenceControllerDelegate
        , selectedRemoteKeys pSelectedRemoteKeyArray :Array<RemoteKey>?
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.selectRemoteKeySequenceControllerUsingStoryboard()
        aDestinationController.remote = pRemote
        if let aSelectedRemoteKeyArray = pSelectedRemoteKeyArray {
            aDestinationController.selectedRemoteKeys = aSelectedRemoteKeyArray
        }
        aDestinationController.delegate = pDelegate
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    #endif
    
}



// MARK:- Mood

extension RoutingManager {
    
    #if !APP_WIFINITY
    
    func newMoodControllerUsingStoryboard() -> NewMoodController {
        return UIStoryboard(name: "Mood", bundle: Bundle.main).instantiateViewController(withIdentifier: "NewMoodControllerId") as! NewMoodController
    }
    
    func gotoNewMood(
        controller pController :UIViewController
        , selectedRoom pSelectedRoom :Room
        , delegate pDelegate :NewMoodControllerDelegate
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.newMoodControllerUsingStoryboard()
        aDestinationController.editedMoodRoom = pSelectedRoom
        aDestinationController.delegate = pDelegate
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    func gotoMoodDetails(
        controller pController :UIViewController
        , selectedMood pSelectedMood :Mood
        , delegate pDelegate :NewMoodControllerDelegate
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.newMoodControllerUsingStoryboard()
        aDestinationController.mood = pSelectedMood
        aDestinationController.delegate = pDelegate
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    #endif
    
    func searchMoodControllerUsingStoryboard() -> SearchMoodController {
        return UIStoryboard(name: "Mood", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchMoodControllerId") as! SearchMoodController
    }
    
    
    func gotoSearchMood(
        controller pController :UIViewController
        , selectedRoom pSelectedRoom :Room
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.searchMoodControllerUsingStoryboard()
        aDestinationController.selectedRoom = pSelectedRoom
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
}
// MARK: - Controller Setthing
extension RoutingManager{
    
    func searchControllerlistvcUsingStoryboard() -> ControllerListViewController {
        return UIStoryboard(name: "ContollerList", bundle: Bundle.main).instantiateViewController(withIdentifier: "ControllerListViewController") as! ControllerListViewController
    }
    func ResetControllerlistvcUsingStoryboard() -> ResetWifiViewController {
        return UIStoryboard(name: "ContollerList", bundle: Bundle.main).instantiateViewController(withIdentifier: "ResetWifiViewController") as! ResetWifiViewController
    }
    
    func gotoSearchControllerSetting(controller pController :UIViewController) {
        let aDestinationController = self.searchControllerlistvcUsingStoryboard()
      //  aDestinationController.selectedRoom = pSelectedRoom
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    func gotoResetControllerSetting(controller pController :UIViewController, controller pcontroller: ControllerAppliance) {
        let aDestinationController = self.ResetControllerlistvcUsingStoryboard()
        aDestinationController.controllerApplince = pcontroller
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    func AllResetControllerlistvcUsingStoryboard() -> ResetAllViewController {
        return UIStoryboard(name: "ContollerList", bundle: Bundle.main).instantiateViewController(withIdentifier: "ResetAllViewController") as! ResetAllViewController
    }
    func gotoAllResetControllerSetting(controller pController :UIViewController, controller pcontroller: [ControllerAppliance]) {
        let aDestinationController = self.AllResetControllerlistvcUsingStoryboard()
         aDestinationController.controllerApplince = pcontroller
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
   
}


// MARK:- Sensor

extension RoutingManager {
    
    func searchSensorControllerUsingStoryboard() -> SearchSensorController {
        return UIStoryboard(name: "Sensor", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchSensorControllerId") as! SearchSensorController
    }
    
    func gotoSearchSensor(
        controller pController :UIViewController
        , selectedRoom pSelectedRoom :Room
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.searchSensorControllerUsingStoryboard()
        aDestinationController.selectedRoom = pSelectedRoom
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
    
    func sensorDetailsControllerUsingStoryboard() -> SensorDetailsController {
        return UIStoryboard(name: "Sensor", bundle: Bundle.main).instantiateViewController(withIdentifier: "SensorDetailsControllerId") as! SensorDetailsController
    }
    
    func gotoSensorDetails(
        controller pController :UIViewController
        , selectedSensor pSelectedSensor :Sensor
        , shouldAddNavigationController pShouldAddNavigationController :Bool = false) {
        let aDestinationController = self.sensorDetailsControllerUsingStoryboard()
        aDestinationController.selectedSensor = pSelectedSensor
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
}



// MARK:- Energy

extension RoutingManager {
    
    func energyDetailsControllerUsingStoryboard() -> EnergyDetailsController {
        return UIStoryboard(name: "Energy", bundle: Bundle.main).instantiateViewController(withIdentifier: "EnergyDetailsControllerId") as! EnergyDetailsController
    }
    
    func gotoEnergyDetails(
        controller pController :UIViewController
        , userId pUserId :String
        , roomId pRoomId :String) {
        let aDestinationController = self.energyDetailsControllerUsingStoryboard()
        aDestinationController.userId = pUserId
        aDestinationController.roomId = pRoomId
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    
}
// MARK: - Controller Setting and device

extension RoutingManager{
    func controllerDetailsControllerUsingStoryboard() -> DeviceSettingViewController {
        return UIStoryboard(name: "ContollerList", bundle: Bundle.main).instantiateViewController(withIdentifier: "DeviceSettingViewController") as! DeviceSettingViewController
    }
    func ResetAllControllerlistvcUsingStoryboard() -> ResetAllWifiViewController {
        return UIStoryboard(name: "ContollerList", bundle: Bundle.main).instantiateViewController(withIdentifier: "ResetAllWifiViewController") as! ResetAllWifiViewController
        
    }
    func gotoDeviceDetails(
        controller pController :UIViewController, selectedController pSelectedController :ControllerAppliance) {
        let aDestinationController = self.controllerDetailsControllerUsingStoryboard()
            aDestinationController.controllerApplince = pSelectedController
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
    func gotoResetAllControllerSetting(controller pController :UIViewController, controller pApplinces: [ControllerAppliance]) {
        let aDestinationController = self.ResetAllControllerlistvcUsingStoryboard()
         aDestinationController.controllerApplince = pApplinces
        pController.navigationController?.pushViewController(aDestinationController, animated: true)
    }
}
