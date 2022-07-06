//
//  RulePortalController.swift
//  DEFT
//
//  Created by Rupendra on 13/11/21.
//  Copyright © 2021 Example. All rights reserved.
//

import UIKit
import WebKit


class RulePortalController: BaseController {
    @IBOutlet weak var webView: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "RULES"
        self.subTitle = nil
        
        self.webView.backgroundColor = UIColor.white
        self.webView.scrollView.bounces = false
        
        if let anEmailAddress = KeychainManager.shared.getValue(forKey: "emailAddress"), let aPassword = KeychainManager.shared.getValue(forKey: "password") {
            #if APP_WIFINITY
            let anEnergyUrl = URL(string: String(format: "http://deftcore.homeonetechnologies.in/core/%@/%@", anEmailAddress, aPassword))
            #else
            let anEnergyUrl = URL(string: String(format: "http://deftcore.homeonetechnologies.in/core/%@/%@", anEmailAddress, aPassword))
            #endif
            if let aUrl = anEnergyUrl {
                self.webView.load(URLRequest(url: aUrl))
            }
        }
    }
    
}

