//
//  ColorPickerControl.swift
//  DEFT
//
//  Created by Rupendra on 26/08/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class ColorPickerControl: UIControl {
    var colorPickerWheelView: ColorWheel!
    var colorPickerBrightnessView: BrightnessPickerView!
    var colorPickerPreviewView: UIView!
    
    var colorPickerHue: CGFloat = 1.0
    var colorPickerSaturation: CGFloat = 1.0
    var colorPickerBrightness: CGFloat = 1.0
    
    var color :UIColor {
        get {
            return UIColor(hue: self.colorPickerHue, saturation: self.colorPickerSaturation, brightness: self.colorPickerBrightness, alpha: 1.0)
        }
        set {
            var aHue :CGFloat = 0
            var aSaturation :CGFloat = 0
            var aBrightness :CGFloat = 0
            newValue.getHue(&aHue, saturation: &aSaturation, brightness: &aBrightness, alpha: nil)
            self.colorPickerHue = aHue
            self.colorPickerSaturation = aSaturation
            self.colorPickerBrightness = aBrightness
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.setNeedsLayout()
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.colorPickerWheelView == nil {
            let aColor = UIColor(hue: self.colorPickerHue, saturation: self.colorPickerSaturation, brightness: 1.0, alpha: 1.0)
            self.colorPickerWheelView = ColorWheel(frame: CGRect(x: 0.0, y: 0.0, width: self.frame.size.height, height: self.frame.size.height), color: aColor)
            self.colorPickerWheelView.delegate = self
            self.addSubview(self.colorPickerWheelView)
        }
        if self.colorPickerBrightnessView == nil {
            self.colorPickerBrightnessView = BrightnessPickerView(frame: CGRect(x: 40.0, y: self.frame.size.height - 30.0, width: 30.0, height: self.frame.size.height - 40.0))
            self.colorPickerBrightnessView.delegate = self
            self.addSubview(self.colorPickerBrightnessView)
        }
        if self.colorPickerPreviewView == nil {
            self.colorPickerPreviewView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0))
            self.addSubview(self.colorPickerPreviewView)
        }
        
        self.reloadAllView()
    }
    
    
    func reloadAllView() {
        self.colorPickerWheelView.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.height, height: self.frame.size.height)
        self.colorPickerWheelView.color = UIColor(hue: self.colorPickerHue, saturation: self.colorPickerSaturation, brightness: 1.0, alpha: 1.0)
        
        self.colorPickerBrightnessView.frame = CGRect(x: self.frame.size.width - 30.0, y: 40.0, width: 30.0, height: self.frame.size.height - 40.0)
        self.colorPickerBrightnessView.color = UIColor(hue: self.colorPickerHue, saturation: self.colorPickerSaturation, brightness: self.colorPickerBrightness, alpha: 1.0)
        
        self.colorPickerPreviewView.frame = CGRect(x: self.frame.size.width - 30.0, y: 0.0, width: 30.0, height: 30.0)
        self.colorPickerPreviewView.backgroundColor = UIColor(hue: self.colorPickerHue, saturation: self.colorPickerSaturation, brightness: self.colorPickerBrightness, alpha: 1.0)
    }
}



extension ColorPickerControl :ColorWheelDelegate {
    func hueAndSaturationSelected(_ pHue: CGFloat, saturation pSaturation: CGFloat) {
        self.colorPickerHue = pHue
        self.colorPickerSaturation = pSaturation
        self.reloadAllView()
        self.sendActions(for: UIControl.Event.valueChanged)
    }
}



extension ColorPickerControl :BrightnessPickerViewDelegate {
    func brightnessPickerView(_ pSender: BrightnessPickerView, didSelectBrightness pBrightness: CGFloat) {
        self.colorPickerBrightness = pBrightness
        self.reloadAllView()
        self.sendActions(for: UIControl.Event.valueChanged)
    }
}
