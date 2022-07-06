//
//  RemoteButton.swift
//  DEFT
//
//  Created by Rupendra on 03/10/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit


@IBDesignable class RemoteButton :UIButton {
    @IBInspectable var shouldHideBorder: Bool = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clear
        
        self.tintColor = UIColor(named: "ControlNormalColor")
        self.layer.borderColor = UIColor(named: "ControlNormalColor")?.cgColor
        self.layer.cornerRadius = self.frame.size.height / 2.0
        
        self.titleEdgeInsets = UIEdgeInsets(top: 3.0, left: 8.0, bottom: 3.0, right: 8.0)
        self.titleLabel?.textAlignment = .center
        self.titleLabel?.numberOfLines = 2
        
        let aGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.didLongPressButton(_:)))
        aGestureRecognizer.minimumPressDuration = 1
        self.addGestureRecognizer(aGestureRecognizer)
    }
    
    
    override func draw(_ pRect: CGRect) {
        super.draw(pRect)
        
        self.layer.borderWidth = self.shouldHideBorder ? 0.0 : 1.0
        self.layer.cornerRadius = self.frame.size.height / 2.0
        
        let aBezierPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius)
        UIColor(named: "SecondaryLightestColor")?.set()
        aBezierPath.fill()
    }
    
    
    @objc private func didLongPressButton(_ pSender :UILongPressGestureRecognizer) {
        if pSender.state == UIGestureRecognizer.State.began {
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
}

