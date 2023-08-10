//
//  WaterLevelWebviewViewController.swift
//  Wifinity
//
//  Created by Apple on 07/07/23.
//

import UIKit
import WebKit
class WaterLevelWebviewViewController: BaseController {

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "WATER LEVEL CONTROLLERS"
        subTitle = nil
        
        self.webView.backgroundColor = UIColor.white
        self.webView.scrollView.bounces = false

            let anEnergyUrl = URL(string: String(format: "http://energy.homeonetechnologies.in/energy/%@/%@"))
 
            if let aUrl = anEnergyUrl {
                self.webView.load(URLRequest(url: aUrl))
            }
      
    }
    
 

}
