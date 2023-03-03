//
//  NewDeviceSelectRoomController.swift
//  Wifinity
//
//  Created by Rupendra on 10/01/21.
//

import UIKit

class NewDeviceSelectRoomController: BaseController {
    @IBOutlet weak var roomNameTextField: UITextField!
    
    var device :Device?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "ADD DEVICE"
        self.subTitle = "Room Details"
        
        self.roomNameTextField.delegate = self
    }
    
    
    func reloadAllView() {
        self.roomNameTextField.text = self.device?.room?.title
    }
    
    func gotoSelectRoom() {
        RoutingManager.shared.gotoSelectRoom(controller: self, roomSelectionType: SelectRoomController.SelectionType.room, delegate: self, shouldAllowAddRoom: true, selectedRooms: nil)
    }
    
    
    func saveDevice(device pDevice :Device) {
        let aDevice = pDevice.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.saveDevice(completion: { (pError, pDevice) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not save device.", description: pError!.localizedDescription)
            } else {
                aDevice.id = pDevice?.id
                self.device = aDevice
                PopupManager.shared.displaySuccess(message: "Device saved successfully.", description: nil, completion: {
                    self.gotoDashboard()
                })
            }
        }, device: aDevice)
    }
    
    
    func saveDevice() {
        do {
            let aTitle = self.device?.title
            if (aTitle?.count ?? 0) <= 0 {
                throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Please provide device details."])
            }
            
            let aNetworkSsid = self.device?.networkSsid
            if (aNetworkSsid?.count ?? 0) <= 0 {
                throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Please provide network details."])
            }
            
            let aNetworkPassword = self.device?.networkPassword
            
            let aRoom = self.device?.room
            if (aRoom?.id?.count ?? 0) <= 0 {
                throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Please provide room details."])
            }
            
            let aDevice = self.device?.clone() ?? Device()
            aDevice.title = aTitle
            aDevice.networkSsid = aNetworkSsid
            aDevice.networkPassword = aNetworkPassword
            aDevice.room = aRoom
            self.saveDevice(device: aDevice)
        } catch {
            PopupManager.shared.displayError(message: error.localizedDescription, description: nil)
        }
    }
    
    
    func gotoDashboard() {
        RoutingManager.shared.goBackToDashboard()
    }
}


extension NewDeviceSelectRoomController {
    
    @IBAction func didSelectDoneButton(_ pSender: UIButton) {
        self.saveDevice()
    }
    
}


extension NewDeviceSelectRoomController :UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.gotoSelectRoom()
        return false
    }
}


extension NewDeviceSelectRoomController :SelectRoomControllerDelegate {
    
    func selectRoomController(_ pSender: SelectRoomController, didSelectRooms pRoomArray: Array<Room>?) {
        self.device?.room = pRoomArray?.first
        self.reloadAllView()
        RoutingManager.shared.goBackToController(self)
    }
    
}
