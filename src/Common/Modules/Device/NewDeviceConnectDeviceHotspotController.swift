//
//  NewDeviceConnectDeviceHotspotController.swift
//  Wifinity
//
//  Created by Rupendra on 09/01/21.
//

import UIKit

class NewDeviceConnectDeviceHotspotController: BaseController {
    @IBOutlet weak var messageLabel: UILabel!
    
    var device :Device?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "ADD DEVICE"
        self.subTitle = "Connect Device Hotspot"
        
        var aMessage = String(format: "Open the wifi settings on your phone and select the network that shows like \"%@\". It may take a moment to appear.", self.device?.id ?? "C01160...")
        aMessage += "\n\n"
        aMessage += "If it is not visible then please restart the hardware-device."
        aMessage += "\n\n"
        aMessage += "Please note that the wifi hotspot is available for 90 seconds after the restart if no apps (phones/desktops) are connected to it."
        aMessage += "\n\n"
        aMessage += "Please tap on Continue after connecting to hardware-device wifi hotspot."
        
        self.messageLabel.text = aMessage
    }
    
}


extension NewDeviceConnectDeviceHotspotController {
    
    @IBAction func didSelectContinueButton(_ pSender: UIButton) {
        self.gotoNewDeviceConfigureDevice()
    }
    
    
    func gotoNewDeviceConfigureDevice() {
        if let aDevice = self.device {
            RoutingManager.shared.gotoNewDeviceConfigureDevice(controller: self, selectedDevice: aDevice)
        }
    }
    
}
