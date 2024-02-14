//
//  ControllerSetting.swift
//  Wifinity
//
//  Created by Apple on 11/10/23.
//

import UIKit

class ControllerAppliance: NSObject {
    
    var id :String?
    var name :String?
    var roomName :String?
    var online :Bool?
    
    var roomId :String?
    var hardwareId :String?
    var title :String?
    var lastOperated :Double?
    var wifiSignalStrength :String?
    var wifiSsid : String?
    var wifiPassword : String?
    var controllerType : String?
    var macId : String?
    var touchLedMode: String?
    var childLock :Bool = false
    var cleaningMode :Bool = false
    var stateRetention: Bool = false
    var version :String?
    var isSelected: Bool = false
    
    func clone() -> ControllerAppliance {
        let anAppliance = ControllerAppliance()
        
        anAppliance.id = self.id
        anAppliance.title = self.title
        anAppliance.roomId = self.roomId
        anAppliance.name = self.name
        anAppliance.roomName = self.roomName
        anAppliance.hardwareId = self.hardwareId
        anAppliance.online = self.online
        anAppliance.lastOperated = self.lastOperated
        anAppliance.wifiSignalStrength = self.wifiSignalStrength
        anAppliance.wifiSsid = self.wifiSsid
        anAppliance.wifiPassword = self.wifiPassword
        anAppliance.macId = self.macId
        anAppliance.touchLedMode = self.touchLedMode
        anAppliance.childLock = self.childLock
        anAppliance.cleaningMode = self.cleaningMode
        anAppliance.stateRetention = self.stateRetention
        anAppliance.version = self.version
        return anAppliance
    }
    enum ControllerChoice{
        case Delete
        case Reset
    }
    enum touchModeCmd {
        case Led
        case cleaning
        case clild
        case retaintion
    }
}

