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
    var doneButton: UIButton!
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
    var delegate: ColorPickerControllerDelegate?
    
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
        if self.doneButton == nil {
            self.doneButton = UIButton(frame: CGRect(x: self.frame.size.width - 140.0, y: self.frame.size.height - 30, width: 100.0, height: 30.0))
            self.doneButton.setTitle("done", for: .normal)
             doneButton.setTitleColor(UIColor.blue, for: .normal)
            doneButton.addTarget(self, action: #selector(didtappedDonebtn(pSender: )), for: .touchUpInside)
            self.addSubview(self.doneButton)
        }
        self.reloadAllView()
    }
    @objc func didtappedDonebtn(pSender: UIButton){
        print("color tapped done")
        delegate?.didtappedDonebtn()
    }
    
    func reloadAllView() {
        self.colorPickerWheelView.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.height, height: self.frame.size.height)
        self.colorPickerWheelView.color = UIColor(hue: self.colorPickerHue, saturation: self.colorPickerSaturation, brightness: 1.0, alpha: 1.0)
        
        self.colorPickerBrightnessView.frame = CGRect(x: self.frame.size.width - 40.0, y: 40.0, width: 30.0, height: self.frame.size.height - 40.0)
        self.colorPickerBrightnessView.color = UIColor(hue: self.colorPickerHue, saturation: self.colorPickerSaturation, brightness: self.colorPickerBrightness, alpha: 1.0)
        
        self.colorPickerPreviewView.frame = CGRect(x: self.frame.size.width - 40.0, y: 0.0, width: 30.0, height: 30.0)
        self.colorPickerPreviewView.backgroundColor = UIColor(hue: self.colorPickerHue, saturation: self.colorPickerSaturation, brightness: self.colorPickerBrightness, alpha: 1.0)
    }
    
    func rgbToHex(red: CGFloat, green: CGFloat, blue: CGFloat) -> String {
        // Ensure that the values are within the valid range
        let clampedRed = min(1.0, max(0.0, red))
        let clampedGreen = min(1.0, max(0.0, green))
        let clampedBlue = min(1.0, max(0.0, blue))

        // Convert the RGB values to hexadecimal
        let hexRed = String(format: "%02X", Int(red))
        let hexGreen = String(format: "%02X", Int(green))
        let hexBlue = String(format: "%02X", Int(blue))

        // Concatenate the components to form the hex color code
        let hexColor = "#" + hexRed + hexGreen + hexBlue

        return hexColor
    }

}


protocol  ColorPickerControllerDelegate:AnyObject{
    func didtappedDonebtn()
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
