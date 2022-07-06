//
//  AppFloatingButton.swift
//  DEFT
//
//  Created by Rupendra on 01/12/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class AppFloatingButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setup()
    }
    
    func setup() {
        self.backgroundColor = UIColor(named: "ControlNormalColor")
        self.layer.cornerRadius = self.frame.size.height / 2.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = self.backgroundColor?.cgColor
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 5.0
        self.layer.shadowOffset = CGSize.zero
    }
}
