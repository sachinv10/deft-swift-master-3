//
//  NewDeviceController.swift
//  Wifinity
//
//  Created by Rupendra on 15/12/20.
//

import UIKit

class NewDeviceController: BaseController {
    @IBOutlet weak var messageLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "ADD DEVICE"
        self.subTitle = nil
        
        var aMessage = "Welcome to Add Device. This is where you can configure and save device with this app."
        aMessage += "\n\n"
        aMessage += "It is very simple process and we will guide you through every step. Make sure you follow the instructions properly."
        
        self.messageLabel.text = aMessage
    }
    
}

extension NewDeviceController {
    
    @IBAction func didSelectDoneButton(_ pSender: UIButton?) {
        RoutingManager.shared.gotoNewDeviceScanQrCode(controller: self)
    }
}
