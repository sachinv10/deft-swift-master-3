//
//  UtilityManager.swift
//  DEFT
//
//  Created by Rupendra on 28/08/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class UtilityManager: NSObject {
    static var shared :UtilityManager = {
        return UtilityManager()
    }()
    
    enum ScreenSizeType :String {
        case small
        case medium
        case large
        case larger
        case largest
    }
    
    var screenSizeType :ScreenSizeType {
        var aReturnVal = ScreenSizeType.medium
        
        let aScreenHeight = UIScreen.main.bounds.height * UIScreen.main.scale
        if aScreenHeight <= 1136 {
            // iPhone 5, SE
            aReturnVal = ScreenSizeType.small
        } else if aScreenHeight > 1136 && aScreenHeight <= 1334 {
            // iPhone 6, 6S, 7, 8
            aReturnVal = ScreenSizeType.medium
        } else if aScreenHeight > 1334 && aScreenHeight <= 1920 {
            // iPhone 6 Plus, 6S Plus, 7 Plus, 8 Plus
            aReturnVal = ScreenSizeType.large
        } else if aScreenHeight > 1920 && aScreenHeight <= 2436 {
            // iPhone X
            aReturnVal = ScreenSizeType.larger
        } else if aScreenHeight > 2436 {
            aReturnVal = ScreenSizeType.largest
        }
        
        return aReturnVal
    }
    // type of device gatting ( ios 15 and earlier user assign device name )
    //geniric device name ( ios 13 and later)
    static var deviceName: String {return UIDevice.current.model}
    
    static var isSimulator :Bool {
        return ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil
    }
    
    static var hasTopNotch :Bool {
        return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
    }
    
    static func randomUuid() -> String {
        return UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
    }
    
    static func heightConstraint(view pView :UIView) -> NSLayoutConstraint? {
        var aReturnVal :NSLayoutConstraint?
        
        for aConstraint in pView.constraints {
            if aConstraint.firstAttribute == NSLayoutConstraint.Attribute.height {
                aReturnVal = aConstraint
                break
            }
        }
        return aReturnVal
    }
    
    
    static func dimmableValueFromSliderValue(appliance pAppliance :Appliance, sliderValue pSliderValue :Int) -> Int {
        var aReturnVal = pSliderValue
        
        if pAppliance.dimType == Appliance.DimType.triac {
            let aDimmableValueMin :Double = Double(pAppliance.dimmableValueMin ?? 0)
            var aDimmableValue: Double = 0.0
            if let maxvalue = pAppliance.dimmableValueMax{
                aDimmableValue = ((Double(pSliderValue) * (Double((Double(pAppliance.dimmableValueMax!) - aDimmableValueMin)) / 100.0)) + aDimmableValueMin)
            }else{
                  aDimmableValue = ((Double(pSliderValue) * ((99.0 - aDimmableValueMin) / 100.0)) + aDimmableValueMin)
            }
            
            if aDimmableValue < 10 {
                aDimmableValue = 10
            } else if aDimmableValue > 99 {
                aDimmableValue = 99
            }
            aReturnVal = Int(aDimmableValue)
        }
        
        return aReturnVal
    }
    
    static func dimmableValueFromCommonSliderValue(sliderValue pSliderValue :Int) -> Int {
        var aReturnVal = pSliderValue
        
            let aDimmableValueMin :Double = Double(30)
            var aDimmableValue = ((Double(pSliderValue) * ((99.0 - aDimmableValueMin) / 100.0)) + aDimmableValueMin)
            if aDimmableValue < 10 {
                aDimmableValue = 10
            } else if aDimmableValue > 99 {
                aDimmableValue = 99
            }
            aReturnVal = Int(aDimmableValue)
        
        return aReturnVal
    }
    
    static func dimmableValueFromCommonSliderValue1(sliderValue pSliderValue :Int) -> Int {
        var aReturnVal = pSliderValue
        
            let aDimmableValueMin :Double = Double(DynamicButtonContainerView.baseslidervalue ?? 30)
        print("\(DynamicButtonContainerView.baseslidervalue)")
            var aDimmableValue = ((Double(pSliderValue) * ((99.0 - aDimmableValueMin) / 100.0)) + aDimmableValueMin)
            if aDimmableValue < 10 {
                aDimmableValue = 10
            } else if aDimmableValue > 99 {
                aDimmableValue = 99
            }
            aReturnVal = Int(aDimmableValue)
        
        return aReturnVal
    }
    static func sliderValueFromDimmableValue(appliance pAppliance :Appliance, dimmableValue pDimmableValue :Int) -> Int {
        var aReturnVal = pDimmableValue
        let aSliderValue: Double
        if pAppliance.dimType == Appliance.DimType.triac {
            let aDimmableValueTriac = Double(pDimmableValue)
            let aDimmableValueMin = Double(pAppliance.dimmableValueMin ?? 0)
            
            if let maxval = pAppliance.dimmableValueMax{
                aSliderValue = (aDimmableValueTriac - aDimmableValueMin) * (100.0 / (Double(maxval) - aDimmableValueMin))
            }else{
             aSliderValue = (aDimmableValueTriac - aDimmableValueMin) * (100.0 / (99.0 - aDimmableValueMin))
            }
            aReturnVal = Int(aSliderValue)
        }
        return aReturnVal
    }
    
    
    static func property1(warmness pWarmness :Int, brightness pBrightness :Int) -> Int {
        return Int((100.0 - Double(pWarmness)) * (Double(pBrightness) / 100.0))
    }
    
    
    static func property2(warmness pWarmness :Int, brightness pBrightness :Int) -> Int {
        return Int(Double(pWarmness) * Double(pBrightness) / 100.0)
    }
    
    
    static func warmnessSliderValue(property1 pProperty1 :Int, property2 pProperty2 :Int, property3 pProperty3 :Int) -> Int {
        var aReturnVal :Int = 0
        
        if (pProperty1 + pProperty2) > 0 {
            aReturnVal = pProperty2 * 100 / (pProperty1 + pProperty2)
        }
        
        return aReturnVal
    }
    
    
    static func brightnessSliderValue(property1 pProperty1 :Int, property2 pProperty2 :Int, property3 pProperty3 :Int) -> Int {
        var aReturnVal :Int = 0
        
        aReturnVal = (pProperty1 + pProperty2)
        
        return aReturnVal
    }
     
    static func singleStripBritValue(property1 pProperty1 :Int)-> Int{
        var aReturnVal: Int = 0
        aReturnVal = pProperty1
        return aReturnVal
    }
    
    static func color(property1 pProperty1 :Int, property2 pProperty2 :Int, property3 pProperty3 :Int) -> UIColor {
        var aReturnVal :UIColor = UIColor.white
        
        aReturnVal = UIColor(red: CGFloat(pProperty1)/255.0, green: CGFloat(pProperty2)/255.0, blue: CGFloat(pProperty3)/255.0, alpha: 1.0)
        
        return aReturnVal
    }
    
    
    static func property1(color pColor :UIColor) -> Int {
        var aRed: CGFloat = 0
        pColor.getRed(&aRed, green: nil, blue: nil, alpha: nil)
        return Int(255 * aRed)
    }
    
    
    static func property2(color pColor :UIColor) -> Int {
        var aGreen: CGFloat = 0
        pColor.getRed(nil, green: &aGreen, blue: nil, alpha: nil)
        return Int(255 * aGreen)
    }
    
    
    static func property3(color pColor :UIColor) -> Int {
        var aBlue: CGFloat = 0
        pColor.getRed(nil, green: nil, blue: &aBlue, alpha: nil)
        return Int(255 * aBlue)
    }
    
    
    static func motionLightIntensityServerValue(sliderValue pSliderValue :Int) -> Int {
        var aReturnVal :Int = 0
        
        aReturnVal = Int((434.922 - Float(pSliderValue)) / 0.42387)
        if(aReturnVal > 1022) {
            aReturnVal = 1022
        }
        
        return aReturnVal
    }
    
}


extension String {
    subscript(_ i: Int) -> String {
        let idx1 = index(startIndex, offsetBy: i)
        let idx2 = index(idx1, offsetBy: 1)
        return String(self[idx1..<idx2])
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return String(self[start ..< end])
    }
    
    subscript (r: CountableClosedRange<Int>) -> String {
        let startIndex =  self.index(self.startIndex, offsetBy: r.lowerBound)
        let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
        return String(self[startIndex...endIndex])
    }
}
