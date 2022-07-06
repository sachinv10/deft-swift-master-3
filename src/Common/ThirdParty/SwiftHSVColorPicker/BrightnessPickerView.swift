//
//  BrightnessPickerView.swift
//  DEFT
//
//  Created by Rupendra on 25/08/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class BrightnessPickerView: UIView {
    var direction :Direction = Direction.vertical
    var color :UIColor = UIColor.black {
        didSet {
            var aBrightness: CGFloat = 0.0
            _ = self.color.getHue(nil, saturation: nil, brightness: &aBrightness, alpha: nil)
            
            var aPoint = CGPoint.zero
            if self.direction == Direction.horizontal {
                aPoint.x = (aBrightness * (self.colorLayer?.frame.size.width ?? 1.0)) + (self.thumbHeightWidth / 2)
            } else {
                aPoint.y = (aBrightness * (self.colorLayer?.frame.size.height ?? 1.0)) + (self.thumbHeightWidth / 2)
            }
            self.thumbPoint = aPoint
            
            self.reloadAllView()
        }
    }
    weak var delegate :BrightnessPickerViewDelegate?
    
    private var colorLayer :CAGradientLayer?
    private let colorLayerPadding :CGFloat = 3
    private var thumbLayer :CALayer?
    
    private var _thumbPoint :CGPoint = CGPoint.zero
    private var thumbPoint :CGPoint {
        set {
            var aPoint = newValue
            aPoint.x = aPoint.x < (self.thumbHeightWidth / 2) ? (self.thumbHeightWidth / 2) : aPoint.x
            aPoint.x = aPoint.x > (self.frame.size.width - self.thumbHeightWidth) ? (self.frame.size.width - self.thumbHeightWidth) : aPoint.x
            aPoint.y = aPoint.y < (self.thumbHeightWidth / 2) ? (self.thumbHeightWidth / 2) : aPoint.y
            aPoint.y = aPoint.y > (self.frame.size.height - (self.thumbHeightWidth / 2)) ? (self.frame.size.height - (self.thumbHeightWidth / 2)) : aPoint.y
            self._thumbPoint = aPoint
        }
        get {
            return self._thumbPoint
        }
    }
    
    
    var brightness :CGFloat {
        var aBrightness :CGFloat = 0.0
        if self.direction == Direction.horizontal {
            aBrightness = (self.thumbPoint.x - (self.thumbHeightWidth / 2)) / (self.colorLayer?.frame.size.width ?? 1.0)
        } else {
            aBrightness = (self.thumbPoint.y - (self.thumbHeightWidth / 2)) / (self.colorLayer?.frame.size.height ?? 1.0)
        }
        return aBrightness
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.setup()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setup()
    }
    
    
    func setup() {
        if self.colorLayer == nil {
            self.colorLayer = CAGradientLayer()
            self.layer.insertSublayer(self.colorLayer!, below: self.layer)
        }
        if self.thumbLayer == nil {
            self.thumbLayer = CALayer()
            self.layer.addSublayer(self.thumbLayer!)
        }
        self.backgroundColor = UIColor.clear
        self.thumbPoint = CGPoint.zero
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.reloadAllView()
    }
    
    
    var thumbHeightWidth :CGFloat {
        var aReturnVal :CGFloat = 10.0
        if self.direction == Direction.horizontal {
            aReturnVal = self.frame.size.height
        } else {
            aReturnVal = self.frame.size.width
        }
        return aReturnVal
    }
    
    
    func reloadAllView() {
        if self.direction == Direction.horizontal {
            self.colorLayer?.frame = CGRect(x: (self.thumbHeightWidth / 2), y: self.colorLayerPadding, width: self.frame.size.width - self.thumbHeightWidth, height: self.frame.size.height - (self.colorLayerPadding * 2))
        } else {
            self.colorLayer?.frame = CGRect(x: self.colorLayerPadding, y: (self.thumbHeightWidth / 2), width: self.frame.size.width - (self.colorLayerPadding * 2), height: self.frame.size.height - self.thumbHeightWidth)
        }
        
        var aHue: CGFloat = 0.0
        var aSaturation: CGFloat = 0.0
        var aBrightness: CGFloat = 0.0
        var anAlpha: CGFloat = 0.0
        // If false then color can not be converted to HSV
        _ = self.color.getHue(&aHue, saturation: &aSaturation, brightness: &aBrightness, alpha: &anAlpha)
        self.colorLayer?.colors = [
            UIColor.black.cgColor,
            UIColor(hue: aHue, saturation: aSaturation, brightness: 1, alpha: 1).cgColor
        ]
        self.colorLayer?.locations = [0.0, 1.0]
        if self.direction == .horizontal {
            self.colorLayer?.startPoint = CGPoint(x: 0.0, y: 0.5)
            self.colorLayer?.endPoint = CGPoint(x: 1.0, y: 0.5)
        } else {
            self.colorLayer?.startPoint = CGPoint(x: 0.5, y: 0.0)
            self.colorLayer?.endPoint = CGPoint(x: 0.5, y: 1.0)
        }
        
        if self.direction == Direction.horizontal {
            self.thumbLayer?.frame = CGRect(x: self.thumbPoint.x - (self.thumbHeightWidth / 2), y: 0, width: self.thumbHeightWidth, height: self.thumbHeightWidth)
        } else {
            self.thumbLayer?.frame = CGRect(x: 0, y: self.thumbPoint.y - (self.thumbHeightWidth / 2), width: self.thumbHeightWidth, height: self.thumbHeightWidth)
        }
        
        self.thumbLayer?.backgroundColor = UIColor(hue: aHue, saturation: aSaturation, brightness: self.brightness, alpha: 1).cgColor
        self.thumbLayer?.borderWidth = 2.0
        self.thumbLayer?.borderColor = UIColor.systemBlue.cgColor
        self.thumbLayer?.cornerRadius = 3.0
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let aPoint = touch.location(in: self)
            self.handleTouchPoint(aPoint)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let aPoint = touch.location(in: self)
            self.handleTouchPoint(aPoint)
        }
    }
    
    func handleTouchPoint(_ pPoint: CGPoint) {
        self.thumbPoint = pPoint
        self.reloadAllView()
        
        self.delegate?.brightnessPickerView(self, didSelectBrightness: self.brightness)
    }
    
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    
    enum Direction {
        case horizontal
        case vertical
    }
}


protocol BrightnessPickerViewDelegate :AnyObject {
    func brightnessPickerView(_ pSender :BrightnessPickerView, didSelectBrightness pBrightness: CGFloat)
}
