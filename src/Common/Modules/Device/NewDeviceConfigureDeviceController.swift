//
//  NewDeviceConfigureDeviceController.swift
//  Wifinity
//
//  Created by Rupendra on 11/12/20.
//

import UIKit
import SystemConfiguration.CaptiveNetwork
import CoreLocation
import NetworkExtension


class NewDeviceConfigureDeviceController: BaseController {
    @IBOutlet weak var networkSsidTextField: UITextField!
    @IBOutlet weak var networkPasswordTextField: UITextField!
    
    var device :Device?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "ADD DEVICE"
        self.subTitle = "Configure Device Network"
        
        self.setup()
    }
    
    
    func setup() {
        self.networkSsidTextField.delegate = self
        self.networkSsidTextField.returnKeyType = UIReturnKeyType.next
        self.networkPasswordTextField.delegate = self
    }
    
    
    override func reloadAllData() {
        super.reloadAllData()
    }
    
    
    private func _configureDevice(device pDevice :Device) {
        let aDevice = pDevice.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.configureDevice(completion: { (pError, pDevice) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayConfirmation(message: "Can not configure device. " + pError!.localizedDescription, description: "If you continue, it will result in unexpected system behaviour. Do you still want to continue?", completion: {
                    self.device?.networkSsid = aDevice.networkSsid
                    self.device?.networkPassword = aDevice.networkPassword
                    self.gotoReconnectInternet()
                })
            } else {
                self.device?.networkSsid = aDevice.networkSsid
                self.device?.networkPassword = aDevice.networkPassword
                PopupManager.shared.displaySuccess(message: "Device configured successfully.", description: nil, completion: {
                    self.gotoReconnectInternet()
                })
            }
        }, device: aDevice)
    }
    
    
    func configureDevice() {
        do {
            let aNetworkSsid = self.networkSsidTextField.text ?? self.device?.networkSsid
            if (aNetworkSsid?.count ?? 0) <= 0 {
                throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Please provide network details."])
            }
            
            let aNetworkPassword = self.networkPasswordTextField.text ?? self.device?.networkPassword
            
            let aDevice = self.device?.clone() ?? Device()
            aDevice.networkSsid = aNetworkSsid
            aDevice.networkPassword = aNetworkPassword
            self._configureDevice(device: aDevice)
        } catch {
            PopupManager.shared.displayError(message: error.localizedDescription, description: nil)
        }
    }
    
}


extension NewDeviceConfigureDeviceController {
    
    @IBAction func didSelectDoneButton(_ pSender: UIButton) {
        self.configureDevice()
    }
    
    
    func gotoReconnectInternet() {
        if let aDevice = self.device {
            RoutingManager.shared.gotoNewDeviceReconnectInternet(controller: self, selectedDevice: aDevice)
        }
    }
    
}


extension NewDeviceConfigureDeviceController :UITextFieldDelegate {
    
    func textFieldShouldReturn(_ pTextField: UITextField) -> Bool {
        if pTextField.isEqual(self.networkSsidTextField) {
            self.networkPasswordTextField.becomeFirstResponder()
        } else if pTextField.isEqual(self.networkPasswordTextField) {
            self.view.endEditing(true)
        }
        return true
    }
    
}
