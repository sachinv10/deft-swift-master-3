//
//  Appliance.swift
//  DEFT
//
//  Created by Rupendra on 21/08/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class Appliance: NSObject {
    var uuid :String?
    var id :String?
    var title :String?
    
    var brandTitle :String?
    
    var roomId :String?
    var roomTitle :String?
    
    var slaveId :String?
    var hardwareId :String?
    
    var isOnline :Bool?
    
    var isDimmable :Bool = false
    var dimType :DimType?
    var dimmableValue :Int?
    var dimmableValueTriac :Int?
    var dimmableValueMax :Int?
    var dimmableValueMin :Int?
    
    var ledStripProperty1 :Int?
    var ledStripProperty2 :Int?
    var ledStripProperty3 :Int?
    
    var type :ApplianceType? {
        didSet {
            self.updateIcon()
        }
    }
    
    private var _icon :UIImage?
    
    var icon :UIImage? {
        return self._icon
    }
    
    private func updateIcon() {
        switch self.type {
        case .light:
            self._icon = UIImage(named: "ApplianceLight")
        case .ledStrip:
            self._icon = UIImage(named: "ApplianceLedStrip")
        case .fan:
            self._icon = UIImage(named: "ApplianceFan")
        case .tv:
            self._icon = UIImage(named: "ApplianceTv")
        case .ac:
            self._icon = UIImage(named: "ApplianceAc")
        default:
            self._icon = UIImage(named: "ApplianceMiscellaneous")
        }
    }
    
    var isOn :Bool = false
    var operatedCount :Int?
    
    var stripType :StripType?
    
    var scheduleCommand :String?
    var scheduleState :Bool = false
    var scheduleDimmableValue :Int?
    
    
    func clone() -> Appliance {
        let anAppliance = Appliance()
        
        anAppliance.id = self.id
        anAppliance.title = self.title
        anAppliance.type = self.type
        
        anAppliance.roomId = self.roomId
        anAppliance.roomTitle = self.roomTitle
        
        anAppliance.slaveId = self.slaveId
        anAppliance.hardwareId = self.hardwareId
        
        anAppliance.isOn = self.isOn
        anAppliance.operatedCount = self.operatedCount
        
        anAppliance.isDimmable = self.isDimmable
        anAppliance.dimType = self.dimType
        anAppliance.dimmableValue = self.dimmableValue
        anAppliance.dimmableValueTriac = self.dimmableValueTriac
        anAppliance.dimmableValueMin = self.dimmableValueMin
        anAppliance.dimmableValueMax = self.dimmableValueMax
        
        anAppliance.stripType = self.stripType
        anAppliance.ledStripProperty1 = self.ledStripProperty1
        anAppliance.ledStripProperty2 = self.ledStripProperty2
        anAppliance.ledStripProperty3 = self.ledStripProperty3
        
        anAppliance.scheduleCommand = self.scheduleCommand
        anAppliance.scheduleState = self.scheduleState
        anAppliance.scheduleDimmableValue = self.scheduleDimmableValue
        
        return anAppliance
    }
    
    
    static func command(appliance pAppliance :Appliance, powerState pPowerState :Bool, dimValue pDimValue :Int) -> String {
        var aMessageValue = ""
        
        if pAppliance.hardwareId?.starts(with: "C0") == true || pAppliance.hardwareId?.starts(with: "CS") == true {
            aMessageValue += "C"
            aMessageValue += "023"
            aMessageValue += pAppliance.id!
            aMessageValue += DataContractManagerFireBase.isOnCommandValue(pPowerState)
            aMessageValue += DataContractManagerFireBase.isDimmableCommandValue(pAppliance.isDimmable)
            aMessageValue += String(format: "%d", pDimValue)
            aMessageValue += "F"
        } else if pAppliance.hardwareId?.starts(with: "CT") == true {
            aMessageValue += "C"
            aMessageValue += "023"
            aMessageValue += pAppliance.id!
            aMessageValue += DataContractManagerFireBase.isOnCommandValue(pPowerState)
            aMessageValue += DataContractManagerFireBase.isDimmableCommandValue(pAppliance.isDimmable)
            if pAppliance.dimType == Appliance.DimType.rc {
                aMessageValue += String(format: "%d", pDimValue)
                aMessageValue += "99" // Fixed 99 to make command length proper. Ignored by hardware.
            } else if pAppliance.dimType == Appliance.DimType.triac {
                aMessageValue += "5" // Fixed 5 to make command length proper. Ignored by hardware.
                aMessageValue += String(format: "%02d", pDimValue)
            } else {
                aMessageValue += "599" // Fixed 599 to make command length proper. Ignored by hardware.
            }
            aMessageValue += "F"
        } else if pAppliance.hardwareId?.starts(with: "CL") == true {
            // This will be handled in updateAppliance:property1:property2:property3
        } else if pAppliance.slaveId != nil {
            // https://gitlab.com/mohan.homeone/deft-swift/-/issues/57 - Make short command of DEFT appliances in MOOD and Scheduler - DEFT PRO
            aMessageValue += "C"
            aMessageValue += pAppliance.roomId!
            aMessageValue += pAppliance.slaveId!
            aMessageValue += pAppliance.id!
            aMessageValue += DataContractManagerFireBase.isOnCommandValue(pPowerState)
            aMessageValue += DataContractManagerFireBase.isDimmableCommandValue(pAppliance.isDimmable)
            if pAppliance.dimType == Appliance.DimType.rc {
                aMessageValue += String(format: "%d", pDimValue)
                aMessageValue += "99F"
            } else if pAppliance.dimType == Appliance.DimType.triac {
                aMessageValue += "5"
                aMessageValue += String(format: "%02d", pDimValue)
                aMessageValue += "000F"
            } else {
                aMessageValue += String(format: "%d", pDimValue)
                aMessageValue += "99F"
            }
        }
        
        return aMessageValue
    }
    
    
    enum ApplianceType :String {
        case light = "0"
        case fan = "1"
        case tv = "2"
        case refrigerator = "3"
        case washingMachine = "4"
        case geyser = "5"
        case musicSystem = "6"
        case sockets = "7"
        case ac = "8"
        case waterPump = "9"
        case projector = "10"
        case dvd = "11"
        case setTopBox = "12"
        case moodLight = "13"
        case dummy = "14"
        case ledStrip = "15"
        
        var title :String {
            var aReturnVal :String = ""
            
            switch self {
            case ApplianceType.light:
                aReturnVal = "Light"
            case ApplianceType.fan:
                aReturnVal = "Fan"
            case ApplianceType.tv:
                aReturnVal = "TV"
            case ApplianceType.refrigerator:
                aReturnVal = "Refrigerator"
            case ApplianceType.washingMachine:
                aReturnVal = "Washing Machine"
            case ApplianceType.geyser:
                aReturnVal = "Geyser"
            case ApplianceType.musicSystem:
                aReturnVal = "Music System"
            case ApplianceType.sockets:
                aReturnVal = "Sockets"
            case ApplianceType.ac:
                aReturnVal = "AC"
            case ApplianceType.waterPump:
                aReturnVal = "Water Pump"
            case ApplianceType.projector:
                aReturnVal = "Projector"
            case ApplianceType.dvd:
                aReturnVal = "DVD"
            case ApplianceType.setTopBox:
                aReturnVal = "Set Top Box"
            case ApplianceType.moodLight:
                aReturnVal = "Mood Light"
            case ApplianceType.dummy:
                aReturnVal = "Dummy"
            case ApplianceType.ledStrip:
                aReturnVal = "Strip Light"
            }
            
            return aReturnVal
        }
    }
    
    enum StripType :String {
        case rgb = "RGB"
        case wc = "WC"
        case singleStrip = "Single Strip"
        
        var title :String {
            var aReturnVal :String = ""
            
            switch self {
            case StripType.rgb:
                aReturnVal = "RGB"
            case StripType.wc:
                aReturnVal = "WC"
            case StripType.singleStrip:
                aReturnVal = "Single Strip"
            }
            
            return aReturnVal
        }
    }

    
    enum GlowPatternType :Int {
        case on = 0
        case rgb = 1
        case off = 2
        
        case shock = 3
        case dimBlink = 4
        case colourJump = 5
        case flicker = 6
        case colourFlash = 7
        case strobe = 8
        case alternate = 9
        case singleFade = 10
        case mountain = 11
        case flash = 12
        case auto = 14
    }
    
    
    enum DimType :String {
        case none = "Not Dimmable"
        case triac = "Triac" // 100 dimming
        case rc = "RC" // 5 dimming
        
        var title :String {
            return self.rawValue
        }
    }
    
}
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
        return anAppliance
    }
}
