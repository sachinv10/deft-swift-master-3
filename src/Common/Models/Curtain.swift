//
//  Curtain.swift
//  DEFT
//
//  Created by Rupendra on 20/09/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class Curtain: NSObject {
    var id :String?
    var title :String?
    
    var roomId :String?
    var roomTitle :String?
    
    var hardwareGeneration :Device.HardwareGeneration?
    
    var isOnline :Bool?
    var selectedAppType: String{
       var returnVal = ""
       switch scheduleLevel{
       case 2:
           returnVal = "When Curtain is Open"
       case 1:
           returnVal = "When Curtain is close"
       case 3:
           returnVal = "When Curtain is pouse"
       case .none:
           break
       case .some(_):
           break
       }
       return returnVal
   }
    var selectedcurtainThan: String{
       var returnVal = ""
       switch scheduleLevel{
       case 2:
           returnVal = "Open \(String(describing: title ?? ""))"
       case 1:
           returnVal = "close \(String(describing: title ?? ""))"
       case 3:
           returnVal = "pouse"
       case .none:
           break
       case .some(_):
           break
       }
       return returnVal
   }
    var type :CurtainType? {
        didSet {
            self.updateIcon()
        }
    }
    
    var level :Int = 0
    
    var scheduleCommand :String?
    var scheduleLevel :Int?
    
    private var _icon :UIImage?
    
    var icon :UIImage? {
        return self._icon
    }
    
    private func updateIcon() {
        switch self.type {
        case .rolling:
            self._icon = UIImage(named: "curtainsRoom")
        case .ac:
            self._icon = UIImage(named: "CurtainAc")
        default:
            self._icon = UIImage(named: "curtainsRoom")
        }
    }
    
    
    func clone() -> Curtain {
        let aCurtain = Curtain()
        
        aCurtain.id = self.id
        aCurtain.title = self.title
        aCurtain.type = self.type
        aCurtain.level = self.level
        
        return aCurtain
    }
    
    
    static func motionStateCommand(motionState pMotionState :MotionState) -> String {
        var aReturnVal = ""
        
        aReturnVal += "M012"
        aReturnVal += String(format: "%02d", pMotionState.rawValue)
        aReturnVal += "0F"
        
        return aReturnVal
    }
    
    
    static func levelCommand(curtain pCurtain :Curtain, level pLevel :Int) -> String {
        var aReturnVal = ""
        
        aReturnVal += "M012"
        aReturnVal += String(format: "%@", pCurtain.id!)
        aReturnVal += String(format: "%d", pLevel)
        aReturnVal += "0F"
        
        return aReturnVal
    }
    
    
    enum CurtainType :String {
        case rolling = "Rolling"
        case ac = "AC"
        case sliding = "Sliding"
    }
    
    
    enum MotionState :Int {
        case stop = 0
        case reverse = 1
        case forward = 2
    }
}
