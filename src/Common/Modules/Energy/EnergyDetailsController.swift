//
//  EnergyDetailsController.swift
//  DEFT
//
//  Created by Rupendra on 10/10/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit
import WebKit


class EnergyDetailsController: BaseController {
    @IBOutlet weak var webView: WKWebView!
    
    var userId: String?
    var roomId :String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "ENERGY DETAILS"
        self.subTitle = nil
        
        self.webView.backgroundColor = UIColor.white
        self.webView.scrollView.bounces = false
        
        if let aUserId = self.userId
           , let aRoomId = self.roomId {
            #if APP_WIFINITY
            let anEnergyUrl = URL(string: String(format: "http://energy.homeonetechnologies.in/energy/%@/%@", aUserId, aRoomId))
            #else
            let anEnergyUrl = URL(string: String(format: "http://energy.homeonetechnologies.in/energy_deft/%@/%@", aUserId, aRoomId))
            #endif
            if let aUrl = anEnergyUrl {
                self.webView.load(URLRequest(url: aUrl))
            }
        }
    }
    
}
