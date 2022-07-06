//
//  AppSegmentButton.swift
//  DEFT
//
//  Created by Rupendra on 18/10/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class AppSegmentButton: UIButton {
    var segments :Array<AppSegment>? {
        didSet {
            self._selectedSegment = self.segments?.first
        }
    }
    
    private var _selectedSegment :AppSegment?
    var selectedSegment :AppSegment? {
        return self._selectedSegment
    }
    
    func setSelectedSegmentIndex(_ pIndex :Int) {
        if let aSegmentArray = self.segments, pIndex < aSegmentArray.count {
            self._selectedSegment = aSegmentArray[pIndex]
        } else {
            self._selectedSegment = nil
        }
        self.setNeedsLayout()
    }
    
    func setSelectedSegmentValue(_ pValue :String) {
        if let aSegment = try? self.segments?.first(where: { (pAppSegment) -> Bool in
            return pAppSegment.value == pValue
        }) {
            self._selectedSegment = aSegment
        } else {
            self._selectedSegment = nil
        }
        self.setNeedsLayout()
    }
    
    
    private func selectNextSegment() {
        var aSelectedSegmentIndex :Int = -1
        
        if let aSegmentArray = self.segments {
            for (anIndex, aSegment) in aSegmentArray.enumerated() {
                if self.selectedSegment?.value == aSegment.value {
                    aSelectedSegmentIndex = anIndex + 1
                    break
                }
            }
        }
        
        if aSelectedSegmentIndex >= (self.segments?.count ?? 0) {
            aSelectedSegmentIndex = 0
        }
        
        self.setSelectedSegmentIndex(aSelectedSegmentIndex)
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
        
        self.backgroundColor = UIColor(named: "SecondaryLightestColor")
        self.tintColor = UIColor(named: "ControlNormalColor")
        self.setTitle(self.selectedSegment?.title, for: UIControl.State.normal)
        
        let aHorizontalPadding :CGFloat = 10.0
        let aTitleHeight :CGFloat = Swift.max((self.titleLabel?.frame.size.height ?? 0), 21.0)
        var aTitleAbscissa :CGFloat = (self.imageView?.frame.origin.x ?? 0) + (self.imageView?.frame.size.width ?? 0) + aHorizontalPadding
        let aCenterTitleAbscissa = (self.frame.size.width - (self.titleLabel?.intrinsicContentSize.width ?? 0)) / 2
        aTitleAbscissa = Swift.max(aTitleAbscissa, aCenterTitleAbscissa)
        let aTitleWidth :CGFloat = self.titleLabel?.intrinsicContentSize.width ?? 30.0
        self.titleLabel?.frame = CGRect(x: aTitleAbscissa, y: (self.frame.size.height - aTitleHeight) / 2, width: aTitleWidth, height: aTitleHeight)
        
        self.setTitleColor(UIColor(named: "ControlNormalColor"), for: UIControl.State.normal)
    }
    
    
    override func touchesEnded(_ pTouches: Set<UITouch>, with pEvent: UIEvent?) {
        super.touchesEnded(pTouches, with: pEvent)
        if pTouches.first?.tapCount == 1 {
            self.selectNextSegment()
        }
    }
    
    
    @objc private func didLongPressButton(_ pSender :UILongPressGestureRecognizer) {
        if pSender.state == UIGestureRecognizer.State.began {
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
}


class AppSegment {
    var title :String?
    var value :String?
    
    
    convenience init(title pTitle :String, value pValue :String) {
        self.init()
        
        self.title = pTitle
        self.value = pValue
    }
}
