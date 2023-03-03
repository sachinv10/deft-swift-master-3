//
//  NewDeviceInputPasswordController.swift
//  Wifinity
//
//  Created by Rupendra on 25/05/21.
//

import UIKit

class NewDeviceInputPasswordController: BaseController {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var device :Device?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "ADD DEVICE"
        if self.device?.hardwareType == Device.HardwareType.lock
        || self.device?.hardwareType == Device.HardwareType.gateLock {
            self.subTitle = "Input Password"
        } else {
            self.subTitle = nil
        }
        
        self.passwordTextField.delegate = self
        
        self.reloadAllView()
    }
    
    
    func reloadAllView() {
        if self.device?.hardwareType == Device.HardwareType.lock
        || self.device?.hardwareType == Device.HardwareType.gateLock {
            var aMessage = "It looks like you are adding lock type of device."
            aMessage += "\n\n"
            aMessage += "Here you can provide password for the lock that you are adding."
            self.messageLabel.text = aMessage
            self.passwordTextField.isHidden = false
        } else {
            var aMessage = "It looks like you are adding lock type of device."
            aMessage += "\n\n"
            aMessage += "Tap on Done to save the lock."
            self.messageLabel.text = aMessage
            self.passwordTextField.isHidden = true
        }
    }
}


extension NewDeviceInputPasswordController {
    
    @IBAction func didSelectContinueButton(_ pSender: UIButton) {
        self.saveDevice()
    }
    
    
    func gotoDashboard() {
        RoutingManager.shared.goBackToDashboard()
    }
    
}



extension NewDeviceInputPasswordController :UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString pString: String) -> Bool {
        var aReturnVal = false
        if CharacterSet(charactersIn: pString).isSubset(of: CharacterSet(charactersIn: "0123456789")) {
            aReturnVal = true
        }
        return aReturnVal
    }
    
}


extension NewDeviceInputPasswordController {
    
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
            
            let aLockPassword = self.passwordTextField.text
            
            let aDevice = self.device?.clone() ?? Device()
            aDevice.title = aTitle
            aDevice.networkSsid = aNetworkSsid
            aDevice.networkPassword = aNetworkPassword
            aDevice.room = nil
            aDevice.lockPassword = aLockPassword
            self.saveDevice(device: aDevice)
        } catch {
            PopupManager.shared.displayError(message: error.localizedDescription, description: nil)
        }
    }
    
}
