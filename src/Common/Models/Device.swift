//
//  Device.swift
//  Wifinity
//
//  Created by Rupendra on 12/12/20.
//

import UIKit

class Device: NSObject {
    var id :String?
    var title :String?
    
    var isOnline :Bool?
    
    var networkSsid :String?
    var networkPassword :String?
    
    var hardwareType :Device.HardwareType? {
        var aReturnVal :Device.HardwareType? = nil
        if let anId = self.id {
            aReturnVal = Device.getHardwareType(id: anId)
        }
        return aReturnVal
    }
    
    var switchCount :Int? {
        var aReturnVal :Int? = nil
        if let aHardwareType = self.hardwareType {
            aReturnVal = Device.getSwitchCount(hardwareType: aHardwareType)
        }
        return aReturnVal
    }
    
    var room :Room?
    
    var addedAppliances :Array<Appliance>?
    
    var firebaseUserId :String?
    
    var lockPassword :String?
    
    
    func clone() -> Device {
        let aReturnVal = Device()
        
        aReturnVal.id = self.id
        aReturnVal.title = self.title
        
        aReturnVal.networkSsid = self.networkSsid
        aReturnVal.networkPassword = self.networkPassword
        
        aReturnVal.room = self.room?.clone()
        
        aReturnVal.addedAppliances = self.addedAppliances
        
        aReturnVal.firebaseUserId = self.firebaseUserId
        
        aReturnVal.lockPassword = self.lockPassword
        
        return aReturnVal
    }
    
    
    enum HardwareType :Int {
        case oneSwitch
        case twoSwitch
        case threeSwitch
        case fourSwitch
        case fiveSwitch
        case sixSwitch
        case sevenSwitch
        case eightSwitch
        case nineSwitch
        case tenSwitch
        
        // CL is rgb-strip, wc-stript switch
        case clOneSwitch
        
        // CT is 100 dimming switch
        case ctOneSwitch
        case ctTwoSwitch
        case ctThreeSwitch
        case ctFourSwitch
        case ctFiveSwitch
        case ctSixSwitch
        case ctSevenSwitch
        case ctEightSwitch
        case ctNineSwitch
        case ctTenSwitch
        case VDP
        case smartSensor // S10 is smart sensor
        case smokeDetector // S01 is smoke detector
        case thermalSensor // S02 is thermal sensor
        case uvSensor // S03 is UV sensor
        case smartSecuritySensor // S04 is smart security sensor
        case smartSensorBattery // S10 is smart sensor battery
        case smokeDetectorBattery // S11 is smoke detector battery
        // M00 is rolling curtain
        case rollingCurtain
        
        // M01 is sliding curtain
        case slidingCurtain
        
        // I00 is ir
        case ir
        
        // L is lock
        case lock
        
        // G is gate-controller-lock
        case gateLock
        
        // G is  water tank
        case waterTank
        case waterTank2
        
        case CSoneSwitch
        case CStwoSwitch
        case CSthreeSwitch
        case CSfourSwitch
        case CSfiveSwitch
        case CSsixSwitch
        case CSsevenSwitch
        case CSeightSwitch
        case CSnineSwitch
        case CStenSwitch
        // Occupy sensor
        case Occupy
        
        var prefix :String {
            var aReturnVal = ""
            
            switch self {
            case HardwareType.oneSwitch:
                aReturnVal = "C01"
            case HardwareType.twoSwitch:
                aReturnVal = "C02"
            case HardwareType.threeSwitch:
                aReturnVal = "C03"
            case HardwareType.fourSwitch:
                aReturnVal = "C04"
            case HardwareType.fiveSwitch:
                aReturnVal = "C05"
            case HardwareType.sixSwitch:
                aReturnVal = "C06"
            case HardwareType.sevenSwitch:
                aReturnVal = "C07"
            case HardwareType.eightSwitch:
                aReturnVal = "C08"
            case HardwareType.nineSwitch:
                aReturnVal = "C09"
            case HardwareType.tenSwitch:
                aReturnVal = "C10"
                
            case HardwareType.clOneSwitch:
                aReturnVal = "CL"
                
            case HardwareType.ctOneSwitch:
                aReturnVal = "CT01"
            case HardwareType.ctTwoSwitch:
                aReturnVal = "CT02"
            case HardwareType.ctThreeSwitch:
                aReturnVal = "CT03"
            case HardwareType.ctFourSwitch:
                aReturnVal = "CT04"
            case HardwareType.ctFiveSwitch:
                aReturnVal = "CT05"
            case HardwareType.ctSixSwitch:
                aReturnVal = "CT06"
            case HardwareType.ctSevenSwitch:
                aReturnVal = "CT07"
            case HardwareType.ctEightSwitch:
                aReturnVal = "CT08"
            case HardwareType.ctNineSwitch:
                aReturnVal = "CT09"
            case HardwareType.ctTenSwitch:
                aReturnVal = "CT10"
                
            case HardwareType.smartSensor:
                aReturnVal = "S00"
            case HardwareType.smokeDetector:
                aReturnVal = "S01"
            case HardwareType.smartSensorBattery:
                aReturnVal = "S10"
            case HardwareType.smokeDetectorBattery:
                aReturnVal = "S11"
            case HardwareType.thermalSensor:
                aReturnVal = "S02"
            case HardwareType.uvSensor:
                aReturnVal = "S03"
            case HardwareType.smartSecuritySensor:
                aReturnVal = "S04"
                
            case HardwareType.rollingCurtain:
                aReturnVal = "M00"
            case HardwareType.slidingCurtain:
                aReturnVal = "M01"
                
            case HardwareType.ir:
                aReturnVal = "I00"
                
            case HardwareType.lock:
                aReturnVal = "L"
            case HardwareType.gateLock:
                aReturnVal = "G"
                
            case HardwareType.waterTank:
                aReturnVal = "F01"
            case HardwareType.waterTank2:
                aReturnVal = "F02"
            case .CSoneSwitch:
                aReturnVal = "CS01"
            case .CStwoSwitch:
                aReturnVal = "CS02"
            case .CSthreeSwitch:
                aReturnVal = "CS03"
            case .CSfourSwitch:
                aReturnVal = "CS04"
            case .CSfiveSwitch:
                aReturnVal = "CS05"
            case .CSsixSwitch:
                aReturnVal = "CS06"
            case .CSsevenSwitch:
                aReturnVal = "CS07"
            case .CSeightSwitch:
                aReturnVal = "CS08"
            case .CSnineSwitch:
                aReturnVal = "CS09"
            case .CStenSwitch:
                aReturnVal = "CS10"
            case .Occupy:
                aReturnVal = "P00"
            case .VDP:
                aReturnVal = "V00"
            }
            return aReturnVal
        }
    }
    
    
    enum HardwareGeneration {
        case deft
        case wifinity
    }
    
}


extension Device {
    
    static func getHardwareType(id pId :String) -> HardwareType? {
        var aReturnVal :HardwareType? = nil
        
        if pId.hasPrefix(HardwareType.oneSwitch.prefix) == true {
            aReturnVal = HardwareType.oneSwitch
        } else if pId.hasPrefix(HardwareType.twoSwitch.prefix) == true {
            aReturnVal = HardwareType.twoSwitch
        } else if pId.hasPrefix(HardwareType.threeSwitch.prefix) == true {
            aReturnVal = HardwareType.threeSwitch
        } else if pId.hasPrefix(HardwareType.fourSwitch.prefix) == true {
            aReturnVal = HardwareType.fourSwitch
        } else if pId.hasPrefix(HardwareType.fiveSwitch.prefix) == true {
            aReturnVal = HardwareType.fiveSwitch
        } else if pId.hasPrefix(HardwareType.sixSwitch.prefix) == true {
            aReturnVal = HardwareType.sixSwitch
        } else if pId.hasPrefix(HardwareType.sevenSwitch.prefix) == true {
            aReturnVal = HardwareType.sevenSwitch
        } else if pId.hasPrefix(HardwareType.eightSwitch.prefix) == true {
            aReturnVal = HardwareType.eightSwitch
        } else if pId.hasPrefix(HardwareType.nineSwitch.prefix) == true {
            aReturnVal = HardwareType.nineSwitch
        } else if pId.hasPrefix(HardwareType.tenSwitch.prefix) == true {
            aReturnVal = HardwareType.tenSwitch
        }else if pId.hasPrefix(HardwareType.VDP.prefix) == true {
            aReturnVal = HardwareType.VDP
        }else if pId.hasPrefix(HardwareType.clOneSwitch.prefix) == true {
            aReturnVal = HardwareType.clOneSwitch
        }
        
        else if pId.hasPrefix(HardwareType.ctOneSwitch.prefix) == true {
            aReturnVal = HardwareType.ctOneSwitch
        } else if pId.hasPrefix(HardwareType.ctTwoSwitch.prefix) == true {
            aReturnVal = HardwareType.ctTwoSwitch
        } else if pId.hasPrefix(HardwareType.ctThreeSwitch.prefix) == true {
            aReturnVal = HardwareType.ctThreeSwitch
        } else if pId.hasPrefix(HardwareType.ctFourSwitch.prefix) == true {
            aReturnVal = HardwareType.ctFourSwitch
        } else if pId.hasPrefix(HardwareType.ctFiveSwitch.prefix) == true {
            aReturnVal = HardwareType.ctFiveSwitch
        } else if pId.hasPrefix(HardwareType.ctSixSwitch.prefix) == true {
            aReturnVal = HardwareType.ctSixSwitch
        } else if pId.hasPrefix(HardwareType.ctSevenSwitch.prefix) == true {
            aReturnVal = HardwareType.ctSevenSwitch
        } else if pId.hasPrefix(HardwareType.ctEightSwitch.prefix) == true {
            aReturnVal = HardwareType.ctEightSwitch
        } else if pId.hasPrefix(HardwareType.ctNineSwitch.prefix) == true {
            aReturnVal = HardwareType.ctNineSwitch
        } else if pId.hasPrefix(HardwareType.ctTenSwitch.prefix) == true {
            aReturnVal = HardwareType.ctTenSwitch
        }
        
        else if pId.hasPrefix(HardwareType.smartSensor.prefix) == true {
            aReturnVal = HardwareType.smartSensor
        } else if pId.hasPrefix(HardwareType.smokeDetector.prefix) == true {
            aReturnVal = HardwareType.smokeDetector
        }  else if pId.hasPrefix(HardwareType.smartSensorBattery.prefix) == true {
            aReturnVal = HardwareType.smartSensorBattery
        } else if pId.hasPrefix(HardwareType.smokeDetectorBattery.prefix) == true {
            aReturnVal = HardwareType.smokeDetectorBattery
        } else if pId.hasPrefix(HardwareType.thermalSensor.prefix) == true {
            aReturnVal = HardwareType.thermalSensor
        } else if pId.hasPrefix(HardwareType.uvSensor.prefix) == true {
            aReturnVal = HardwareType.uvSensor
        } else if pId.hasPrefix(HardwareType.smartSecuritySensor.prefix) == true {
            aReturnVal = HardwareType.smartSecuritySensor
        }
        
        else if pId.hasPrefix(HardwareType.rollingCurtain.prefix) == true {
            aReturnVal = HardwareType.rollingCurtain
        } else if pId.hasPrefix(HardwareType.slidingCurtain.prefix) == true {
            aReturnVal = HardwareType.slidingCurtain
        }
        
        else if pId.hasPrefix(HardwareType.ir.prefix) == true {
            aReturnVal = HardwareType.ir
        }
        
        else if pId.hasPrefix(HardwareType.lock.prefix) == true {
            aReturnVal = HardwareType.lock
        } else if pId.hasPrefix(HardwareType.gateLock.prefix) == true {
            aReturnVal = HardwareType.gateLock
        }else if pId.hasPrefix(HardwareType.waterTank.prefix) == true {
            aReturnVal = HardwareType.waterTank
        }else if pId.hasPrefix(HardwareType.waterTank2.prefix) == true {
            aReturnVal = HardwareType.waterTank2
        }else if pId.hasPrefix(HardwareType.CSoneSwitch.prefix) == true {
            aReturnVal = HardwareType.CSoneSwitch
        }else if pId.hasPrefix(HardwareType.CStwoSwitch.prefix) == true {
            aReturnVal = HardwareType.CSoneSwitch
        }else if pId.hasPrefix(HardwareType.CSthreeSwitch.prefix) == true {
            aReturnVal = HardwareType.CSoneSwitch
        }else if pId.hasPrefix(HardwareType.CSfourSwitch.prefix) == true {
            aReturnVal = HardwareType.CSoneSwitch
        }else if pId.hasPrefix(HardwareType.CSfiveSwitch.prefix) == true {
            aReturnVal = HardwareType.CSoneSwitch
        }else if pId.hasPrefix(HardwareType.Occupy.prefix) == true {
            aReturnVal = HardwareType.Occupy
        }
        
        return aReturnVal
    }
    
    
    static func getSwitchCount(hardwareType pHardwareType :Device.HardwareType) -> Int? {
        var aReturnVal :Int? = nil
        
        switch pHardwareType {
        case Device.HardwareType.oneSwitch:
            aReturnVal = 1
        case HardwareType.twoSwitch:
            aReturnVal = 2
        case HardwareType.threeSwitch:
            aReturnVal = 3
        case HardwareType.fourSwitch:
            aReturnVal = 4
        case HardwareType.fiveSwitch:
            aReturnVal = 5
        case HardwareType.sixSwitch:
            aReturnVal = 6
        case HardwareType.sevenSwitch:
            aReturnVal = 7
        case HardwareType.eightSwitch:
            aReturnVal = 8
        case HardwareType.nineSwitch:
            aReturnVal = 9
        case HardwareType.tenSwitch:
            aReturnVal = 10
            
        case HardwareType.clOneSwitch:
            aReturnVal = 1
            
        case HardwareType.ctOneSwitch:
            aReturnVal = 1
        case HardwareType.ctTwoSwitch:
            aReturnVal = 2
        case HardwareType.ctThreeSwitch:
            aReturnVal = 3
        case HardwareType.ctFourSwitch:
            aReturnVal = 4
        case HardwareType.ctFiveSwitch:
            aReturnVal = 5
        case HardwareType.ctSixSwitch:
            aReturnVal = 6
        case HardwareType.ctSevenSwitch:
            aReturnVal = 7
        case HardwareType.ctEightSwitch:
            aReturnVal = 8
        case HardwareType.ctNineSwitch:
            aReturnVal = 9
        case HardwareType.ctTenSwitch:
            aReturnVal = 10
            
        case Device.HardwareType.smartSensor:
            aReturnVal = 1
        case Device.HardwareType.smokeDetector:
            aReturnVal = 1
        case Device.HardwareType.smartSensorBattery:
            aReturnVal = 1
        case Device.HardwareType.smokeDetectorBattery:
            aReturnVal = 1
        case Device.HardwareType.thermalSensor:
            aReturnVal = 1
        case Device.HardwareType.uvSensor:
            aReturnVal = 1
        case Device.HardwareType.smartSecuritySensor:
            aReturnVal = 1
            
        case Device.HardwareType.rollingCurtain:
            aReturnVal = 1
        case Device.HardwareType.slidingCurtain:
            aReturnVal = 1
            
        case Device.HardwareType.ir:
            aReturnVal = 1
            
        case Device.HardwareType.lock:
            aReturnVal = 1
        case Device.HardwareType.gateLock:
            aReturnVal = 1
        case Device.HardwareType.waterTank:
            aReturnVal = 1
        case Device.HardwareType.waterTank2:
            aReturnVal = 2
        case .CSoneSwitch:
            aReturnVal = 5
        case .CStwoSwitch:
            aReturnVal = 2
        case .CSthreeSwitch:
            aReturnVal = 3
        case .CSfourSwitch:
            aReturnVal = 4
        case .CSfiveSwitch:
            aReturnVal = 5
        case .CSsixSwitch:
            aReturnVal = 6
        case .CSsevenSwitch:
            aReturnVal = 7
        case .CSeightSwitch:
            aReturnVal = 8
        case .CSnineSwitch:
            aReturnVal = 9
        case .CStenSwitch:
            aReturnVal = 10
        case .Occupy:
            aReturnVal = 1
        case .VDP:
            aReturnVal = 1
        }
        
        return aReturnVal
    }
    
}
