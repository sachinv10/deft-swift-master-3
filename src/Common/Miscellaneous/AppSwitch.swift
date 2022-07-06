//
//  AppSwitch.swift
//  DEFT
//
//  Created by Rupendra on 10/10/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class AppSwitch: UISwitch {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.thumbTintColor = UIColor(named: "SecondaryLightestColor")
        self.layer.borderWidth = 1.0
        if self.isEnabled {
            self.layer.borderColor = UIColor(named: "ControlNormalColor")?.cgColor
        } else {
            self.layer.borderColor = UIColor(named: "ControlDisabledColor")?.cgColor
        }
        self.layer.cornerRadius = self.frame.size.height / 2
    }
    
}
