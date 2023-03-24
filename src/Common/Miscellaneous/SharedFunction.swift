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
