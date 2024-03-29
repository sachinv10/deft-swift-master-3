//
//  Sensor.swift
//  DEFT
//
//  Created by Rupendra on 26/09/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class Sensor: NSObject {
    var id :String?
    var title :String?
    var controllerType :String?
    var roomId :String?
    var roomTitle :String?
    var calibrated :Bool?
    var uidAssign :Bool?
    var lastOperation :String?
    var peopleCount :Int?
    var lastOperationTime :Double?
    var Batterysevermode :String?
    var BatteryPercentage :String?
    var sensorSensitivity :String?
    var routineType :String?
    var optators :String?
    var sensorTypeId: Int?
    var hardwareGeneration :Device.HardwareGeneration?
    var subLine: String?
    var operatosSelection: String{
       var returnVal = ""
       switch optators{
       case ">":
           returnVal = "above"
       case "<":
           returnVal = "bellow"
       case "=":
           returnVal = "equal to"
       case .none:
           break
       case .some(_):
           break
       }
       return returnVal
   }
    var selectedAppType: String{
       var returnVal = ""
       switch sensorTypeId{
       case 1:
           returnVal = "When temprature \(operatosSelection) \(String(describing: temperature ?? 50))"
       case 2:
           returnVal = "When light \(operatosSelection) \(String(describing: temperature ?? 100))"
       case 3:
           returnVal = "When motion is detect"
       case .none:
           break
       case .some(_):
           break
       }
       return returnVal
   }
    
    var hardwareType :Device.HardwareType? {
        var aReturnVal :Device.HardwareType? = nil
        if let anId = self.id {
            aReturnVal = Device.getHardwareType(id: anId)
        }
        return aReturnVal
    }
    
    var occupancyState :OccupancyState?
    
    var lightState :LightState?
    
    var motionState :MotionState?
    
    var sirenState :SirenState?
    
    var onlineState :OnlineState?
    
    var icon :UIImage? = UIImage(named: "SensorMiscellaneous")
    
    var lightIntensity :Int?
    
    var lastMotionDate :Date?
    
    var temperature :Int?
    
    var smoke :Int?
    var smokeThreshold :Int?
    
    var co2 :Int?
    var co2Threshold :Int?
    
    var lpg :Int?
    var lpgThreshold :Int?
    
    // Settings
    var lightSettingsState :LightState?
    var motionLightTimeout :Int?
    var motionLightIntensity :Int?
    
    var sirenSettingsState :SirenState?
    var sirenTimeout :Int?
    
    var notificationSettingsState :Bool = false
    var notificationSoundState :Bool = false
    
    var scheduleCommands :Array<String>?
    var scheduleSensorActivatedState :Sensor.OnlineState?
    var scheduleMotionLightActivatedState :Sensor.LightState?
    var scheduleSirenActivatedState :Sensor.SirenState?
    
    func clone() -> Sensor {
        let aSensor = Sensor()
        
        aSensor.id = self.id
        aSensor.title = self.title
        aSensor.uidAssign = self.uidAssign
        aSensor.lastOperation = self.lastOperation
        aSensor.peopleCount = self.peopleCount
        aSensor.lastOperationTime = self.lastOperationTime
        aSensor.roomId = self.roomId
        aSensor.roomTitle = self.roomTitle
        aSensor.calibrated = self.calibrated
        aSensor.hardwareGeneration = self.hardwareGeneration
        
        aSensor.occupancyState = self.occupancyState
        aSensor.lightState = self.lightState
        aSensor.motionState = self.motionState
        aSensor.sirenState = self.sirenState
        aSensor.onlineState = self.onlineState
        
        aSensor.lightIntensity = self.lightIntensity
        aSensor.lastMotionDate = self.lastMotionDate
        aSensor.temperature = self.temperature
        
        aSensor.smoke = self.smoke
        aSensor.co2 = self.co2
        aSensor.lpg = self.lpg
        aSensor.Batterysevermode = self.Batterysevermode
        aSensor.BatteryPercentage = self.BatteryPercentage
        return aSensor
    }
    
    func update(sensor pSensor :Sensor) {
        self.lightSettingsState = pSensor.lightSettingsState
        self.motionLightTimeout = pSensor.motionLightTimeout
        self.motionLightIntensity = pSensor.motionLightIntensity
        self.sirenSettingsState = pSensor.sirenSettingsState
        self.sirenTimeout = pSensor.sirenTimeout
    }
    
    
    enum OccupancyState :Int {
        case armed = 2
        case disarmed = 1
    }
    
    enum LightState :Int {
        case on = 2
        case off = 1
    }
    
    enum MotionState :Int {
        case on = 2
        case off = 1
    }
    
    enum SirenState :Int {
        case on = 3
        case off = 4
    }
    
    enum OnlineState :Int {
        case on = 2
        case off = 1
    }
    
}
