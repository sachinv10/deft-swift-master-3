//
//  SupportDetailsController.swift
//  DEFT
//
//  Created by Rupendra on 08/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SupportDetailsController: BaseController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = DrawerController.Menu.Support.title.uppercased()
        self.subTitle = nil
    }
    
}


extension SupportDetailsController {
    
    @IBAction func didSelectCallButton(_ pSender: UIButton?) {
        if let aUrl = URL(string: "tel://" + ConfigurationManager.shared.supportPhoneNumber)
           , UIApplication.shared.canOpenURL(aUrl) {
            UIApplication.shared.open(aUrl, options: [:], completionHandler: nil)
        } else {
            PopupManager.shared.displayError(message: "Your device does not have call feature.", description: nil)
        }
    }
    
}
