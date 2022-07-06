//
//  AppSlider.swift
//  DEFT
//
//  Created by Rupendra on 29/08/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class AppSlider: UISlider {
    var label :UILabel?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.label == nil {
            self.label = UILabel()
            self.label?.font = UIFont.systemFont(ofSize: 12.0)
            self.label?.minimumScaleFactor = 0.5
            self.label?.textAlignment = NSTextAlignment.center
            self.addSubview(self.label!)
        }
        
        self.label?.frame = self.thumbRect
        self.label?.text = String(format: "%d", Int(self.value))
        self.label?.textColor = self.tintColor
    }
    
    
    var thumbRect: CGRect {
        let aTrackRect = self.trackRect(forBounds: self.bounds)
        let aReturnVal = self.thumbRect(forBounds: self.bounds, trackRect: aTrackRect, value: self.value)
        return aReturnVal
    }
}
