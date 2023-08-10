//
//  SharedFunction.swift
//  Wifinity
//
//  Created by Apple on 01/07/22.
//

import UIKit

class SharedFunction: NSObject {
    static var shared :SharedFunction = {
        return SharedFunction()
    }()
    
    
}

extension SharedFunction{
    func gotoTimetampTodayConvert(time: Double) -> String {
        let timestamp = NSDate().timeIntervalSince1970
        let diff = timestamp - time
        let myTimeInterval = TimeInterval(diff)
        let minute = myTimeInterval / 60
        let hours = minute / 60
        let day = hours / 24
        let month = day / 30
        let year = month / 12
        if myTimeInterval < 60{
            return "a few seconds ago"
        }else if minute < 60{
            return "\(String(Int(minute))) Minute ago"
        }else if hours <= 24{
            return "\(String(Int(hours))) hours ago"
        }else if day < 31 {
            return "\(String(Int(day))) day ago"
        }else if month < 12 {
            return "\(String(Int(month))) month ago"
        }else{
            return "\(String(Int(year))) year ago"
        }
    }
    
}


extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if cString.count != 6 {
            self.init(red: 0, green: 0, blue: 0, alpha: alpha)
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

