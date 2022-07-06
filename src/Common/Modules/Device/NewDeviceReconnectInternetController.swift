//
//  NewDeviceReconnectInternetController.swift
//  Wifinity
//
//  Created by Rupendra on 24/01/21.
//

import UIKit

class NewDeviceReconnectInternetController: BaseController {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var connectionStatusLabel: UILabel!
    
    private var connectionStatusIsConnected :Bool = false
    private var connectionStatusTimer :Timer?
    private var connectionStatusTimerCounter :Int = 0
    
    var device :Device?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "ADD DEVICE"
        self.subTitle = "Reconnect Internet"
        
        var aMessage = "Please reconnect to the internet now. You can use your usual wifi or mobile data to connect to the internet."
        aMessage += "\n\n"
        aMessage += "Please note that the app will require internet after this step to work properly."
        aMessage += "\n\n"
        aMessage += "Please tap on Continue after connecting to internet."
        
        self.messageLabel.text = aMessage
        
        self.reloadAllView()
        
        self.connectionStatusTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (pTimer) in
            self.reloadAllView()
            if self.connectionStatusTimerCounter % 5 == 0 {
                self.checkInternetConnection()
            }
            self.connectionStatusTimerCounter += 1
        }
    }
    
    
    func reloadAllView() {
        if self.connectionStatusIsConnected == true {
            self.connectionStatusLabel.text = "Connected"
            self.connectionStatusLabel.textColor = UIColor(named: "ControlCheckedColor")
        } else {
            self.connectionStatusLabel.text = "Connecting " +  String(repeating: ".", count: (self.connectionStatusTimerCounter % 5) + 1)
            self.connectionStatusLabel.textColor = UIColor(named: "ControlDisabledColor")
        }
    }
    
    
    func checkInternetConnection() {
        DataFetchManager.shared.checkInternetConnection { (pError) in
            if pError == nil {
                self.connectionStatusIsConnected = true
                self.reloadAllView()
                self.connectionStatusTimer?.invalidate()
                self.connectionStatusTimer = nil
            } else {
                self.connectionStatusIsConnected = false
            }
        }
    }
    
}


extension NewDeviceReconnectInternetController {
    
    @IBAction func didSelectContinueButton(_ pSender: UIButton) {
        if let aDevice = self.device
           , (aDevice.hardwareType == Device.HardwareType.lock || aDevice.hardwareType == Device.HardwareType.gateLock) {
            self.gotoInputPassword()
        } else {
            self.gotoSelectRoom()
        }
    }
    
    
    func gotoSelectRoom() {
        if let aDevice = self.device {
            RoutingManager.shared.gotoNewDeviceSelectRoom(controller: self, selectedDevice: aDevice)
        }
    }
    
    
    func gotoInputPassword() {
        if let aDevice = self.device {
            RoutingManager.shared.gotoNewDeviceInputPassword(controller: self, selectedDevice: aDevice)
        }
    }
    
}
