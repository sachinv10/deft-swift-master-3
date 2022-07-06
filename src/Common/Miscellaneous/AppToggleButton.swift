//
//  AppToggleButton.swift
//  DEFT
//
//  Created by Rupendra on 07/10/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class AppToggleButton: UIButton {
    var checkedButtonTitle :String?
    var uncheckedButtonTitle :String?
    
    
    var isChecked :Bool = false {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let aGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.didLongPressButton(_:)))
        aGestureRecognizer.minimumPressDuration = 1
        self.addGestureRecognizer(aGestureRecognizer)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setTitleColor(UIColor(named: "ControlDisabledColor"), for: UIControl.State.disabled)
        
        self.backgroundColor = UIColor(named: "SecondaryLightestColor")
        self.layer.borderWidth = 1.0
        if self.isEnabled {
            self.layer.borderColor = UIColor(named: "ControlNormalColor")?.cgColor
        } else {
            self.layer.borderColor = UIColor(named: "ControlDisabledColor")?.cgColor
        }
        self.layer.cornerRadius = self.frame.size.height / 2
        
        if self.isChecked {
            self.backgroundColor = UIColor(named: "ControlCheckedColor")
            self.tintColor = UIColor(named: "SecondaryLightestColor")
            self.setTitle(self.checkedButtonTitle, for: UIControl.State.normal)
            self.setTitleColor(UIColor(named: "SecondaryLightestColor"), for: UIControl.State.normal)
        } else {
            self.backgroundColor = UIColor(named: "SecondaryLightestColor")
            self.tintColor = UIColor(named: "ControlNormalColor")
            self.setTitle(self.uncheckedButtonTitle, for: UIControl.State.normal)
            self.setTitleColor(UIColor(named: "ControlNormalColor"), for: UIControl.State.normal)
        }
    }
    
    
    override func touchesEnded(_ pTouches: Set<UITouch>, with pEvent: UIEvent?) {
        super.touchesEnded(pTouches, with: pEvent)
        if pTouches.first?.tapCount == 1 {
            self.isChecked = !self.isChecked
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    
    @objc private func didLongPressButton(_ pSender :UILongPressGestureRecognizer) {
        if pSender.state == UIGestureRecognizer.State.began {
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
}
