//
//  DataContractManagerFireBase.swift
//  Wifinity
//
//  Created by Rupendra on 03/01/21.
//

import UIKit

class DataContractManagerFireBase: NSObject {
    
}



// MARK:- User

extension DataContractManagerFireBase {
    
    static func user(dict pDict :Dictionary<String,Any>) -> User {
        let aReturnVal :User = User()
        
        aReturnVal.lockPassword = pDict["customerLockPassword"] as? String
        
        return aReturnVal
    }
    
}



// MARK:- Room

extension DataContractManagerFireBase {
    
    static func rooms(dict pDict :Dictionary<String,Dictionary<String,Any>>) -> Array<Room>? {
        var aReturnVal :Array<Room>? = Array<Room>()
        
        for aRoomDict in pDict.values {
            let aRoom = Room()
            
            aRoom.id = aRoomDict["roomId"] as? String
            
            if let aTitle = aRoomDict["roomName"] as? String {
                aRoom.title = aTitle.capitalized
            }
            
            if let aLastActive = aRoomDict["lastActive"] as? Int {
                aRoom.lastActiveDate = Date(timeIntervalSince1970: TimeInterval(aLastActive))
            }
            
            aReturnVal!.append(aRoom)
        }
        if aReturnVal!.count <= 0 {
            aReturnVal = nil
        }
        
        return aReturnVal
    }
    
    
    static func scheduleRooms(array pArray :Array<Dictionary<String,Any>>) -> Array<Room>? {
        var aReturnVal :Array<Room>? = Array<Room>()
        
        for aRoomDict in pArray {
            var aRoom :Room?
            if let aRoomId = aRoomDict["roomId"] as? String {
                aRoom = aReturnVal?.first(where: { (pRoom) -> Bool in
                    return pRoom.id == aRoomId
                })
            }
            if aRoom == nil {
                aRoom = Room()
                
                aRoom?.id = aRoomDict["roomId"] as? String
                
                if let aTitle = aRoomDict["roomName"] as? String {
                    aRoom?.title = aTitle.capitalized
                }
                
                if let aLastActive = aRoomDict["lastActive"] as? Int {
                    aRoom?.lastActiveDate = Date(timeIntervalSince1970: TimeInterval(aLastActive))
                }
                
                aReturnVal!.append(aRoom!)
            }
            
            if let aHardwareId = aRoomDict["controllerId"] as? String {
                let aHardwareType = Device.getHardwareType(id: aHardwareId)
                if aHardwareType == Device.HardwareType.smartSensor
                    || aHardwareType == Device.HardwareType.smokeDetector
                    || aHardwareType == Device.HardwareType.thermalSensor
                    || aHardwareType == Device.HardwareType.uvSensor
                    || aHardwareType == Device.HardwareType.smartSecuritySensor {
                    let aSensor = Sensor()
                    aSensor.id = aHardwareId
                    
                    let anIsSensorActivatedSelected = (aRoomDict["sensorActivatedSelected"] as? Bool) ?? false
                    let anIsSensorActivated = (aRoomDict["sensorActivated"] as? Bool) ?? false
                    if anIsSensorActivatedSelected {
                        if anIsSensorActivated {
                            aSensor.scheduleSensorActivatedState = Sensor.OnlineState.on
                        } else {
                            aSensor.scheduleSensorActivatedState = Sensor.OnlineState.off
                        }
                    } else {
                        aSensor.scheduleSensorActivatedState = nil
                    }
                    
                    let anIsLightActivatedSelected = (aRoomDict["lightActivatedSelected"] as? Bool) ?? false
                    let anIsLightActivated = (aRoomDict["lightActivated"] as? Bool) ?? false
                    if anIsLightActivatedSelected {
                        if anIsLightActivated {
                            aSensor.scheduleMotionLightActivatedState = Sensor.LightState.on
                        } else {
                            aSensor.scheduleMotionLightActivatedState = Sensor.LightState.off
                        }
                    } else {
                        aSensor.scheduleMotionLightActivatedState = nil
                    }
                    
                    let anIsSirenActivatedSelected = (aRoomDict["sirenActivatedSelected"] as? Bool) ?? false
                    let anIsSirenActivated = (aRoomDict["sirenActivated"] as? Bool) ?? false
                    if anIsSirenActivatedSelected == true {
                        if anIsSirenActivated == true {
                            aSensor.scheduleSirenActivatedState = Sensor.SirenState.on
                        } else {
                            aSensor.scheduleSirenActivatedState = Sensor.SirenState.off
                        }
                    } else {
                        aSensor.scheduleSirenActivatedState = nil
                    }
                    
                    if let aValue = aRoomDict["command"] as? Array<String> {
                        aSensor.scheduleCommands = aValue
                    }
                    
                    if aRoom!.sensors == nil {
                        aRoom!.sensors = Array<Sensor>()
                    }
                    aRoom!.sensors?.append(aSensor)
                } else if aHardwareType == Device.HardwareType.rollingCurtain
                || aHardwareType == Device.HardwareType.slidingCurtain {
                    let aCurtain = Curtain()
                    aCurtain.id = aHardwareId
                    aCurtain.scheduleLevel = aRoomDict["level"] as? Int
                    if let aValue = aRoomDict["command"] as? String {
                        aCurtain.scheduleCommand = aValue
                    }
                    if aRoom!.curtains == nil {
                        aRoom!.curtains = Array<Curtain>()
                    }
                    aRoom!.curtains?.append(aCurtain)
                } else if aHardwareType == Device.HardwareType.ir {
                    let aRemote = Remote()
                    aRemote.id = (aRoomDict["remoteId"] as? String)
                    aRemote.hardwareId = aHardwareId
                    let aRemoteKey = RemoteKey()
                    aRemoteKey.id = (aRoomDict["keyId"] as? String)
                    aRemote.selectedRemoteKeys = Array<RemoteKey>()
                    aRemote.selectedRemoteKeys?.append(aRemoteKey)
                    if aRoom!.remotes == nil {
                        aRoom!.remotes = Array<Remote>()
                    }
                    aRoom!.remotes?.append(aRemote)
                } else {
                    let anAppliance = Appliance()
                    anAppliance.id = (aRoomDict["appId"] as? String) ?? (aRoomDict["applianceId"] as? String)
                    anAppliance.hardwareId = aHardwareId
                    if let aValue = aRoomDict["dimValue"] as? String {
                        anAppliance.scheduleDimmableValue = Int(aValue)
                    } else if let aValue = aRoomDict["dimValue"] as? Int {
                        anAppliance.scheduleDimmableValue = aValue
                    }
                    if let aValue = aRoomDict["command"] as? String {
                        anAppliance.scheduleCommand = aValue
                    }
                    if let aValue = aRoomDict["state"] as? Bool {
                        anAppliance.scheduleState = aValue
                    }
                    if aRoom!.appliances == nil {
                        aRoom!.appliances = Array<Appliance>()
                    }
                    aRoom!.appliances?.append(anAppliance)
                }
            }
        }
        
        // Sort remote keys
        if let aRoomArray = aReturnVal {
            for aRoom in aRoomArray {
                if let aRemoteArray = aRoom.remotes {
                    var aFilteredRemoteArray = Array<Remote>()
                    for aRemote in aRemoteArray {
                        if let anAddedRemote = aFilteredRemoteArray.first(where: { (pRemote) -> Bool in
                            return pRemote.id == aRemote.id
                        }) {
                            if let aRemoteKeyArray = aRemote.selectedRemoteKeys {
                                if anAddedRemote.selectedRemoteKeys == nil {
                                    anAddedRemote.selectedRemoteKeys = Array<RemoteKey>()
                                }
                                anAddedRemote.selectedRemoteKeys?.append(contentsOf: aRemoteKeyArray)
                            }
                        } else {
                            aFilteredRemoteArray.append(aRemote)
                        }
                    }
                    aRoom.remotes = aFilteredRemoteArray
                }
            }
        }
        
        if aReturnVal!.count <= 0 {
            aReturnVal = nil
        }
        
        return aReturnVal
    }
    
}

// Mark:- Controller Setting
extension DataContractManagerFireBase {
    
     
    
    
    
    
    static func devicecontroller(dict pDict :Dictionary<String,Any>) -> ControllerAppliance? {
        var aReturnVal :ControllerAppliance? = nil
        
        if let aUserId = pDict["id"] as? String
           , aUserId.count > 0 {
            let aDevice = ControllerAppliance()
            if let aRoomId = pDict["id"] as? String {
            aDevice.id = aRoomId
            }
 
            if let aRoomId = pDict["roomId"] as? String {
                aDevice.roomId = aRoomId
            }
            if let namex = pDict["name"] as? String{
                aDevice.name = namex
            }
            if let namex = pDict["roomName"] as? String{
                aDevice.roomName = namex
            }
            if let namex = pDict["online"] as? Bool{
                aDevice.online = namex
            }
            if let lastactivity = pDict["lastActive"] as? Double{
                aDevice.lastOperated = lastactivity
            }
            if let wifiPassword = pDict["wifiPassword"] as? String{
                aDevice.wifiPassword = wifiPassword
            }
            if let wifiSsid = pDict["wifiSsid"] as? String{
                aDevice.wifiSsid = wifiSsid
            }
            if let wifiSignalStrength = pDict["wifiSignalStrength"] as? String{
                aDevice.wifiSignalStrength = wifiSignalStrength
            }
            aDevice.clone()
            aReturnVal = aDevice
        }
        
         return aReturnVal
    }
    
}

// MARK:- Device

extension DataContractManagerFireBase {
    
    static func devices(dict pDict :Dictionary<String,Dictionary<String,Any>>) -> Array<Device>? {
        var aReturnVal :Array<Device>? = Array<Device>()
        
        for aDeviceDict in pDict.values {
            if let aDevice = self.device(dict: aDeviceDict) {
                aReturnVal!.append(aDevice)
            }
        }
        if aReturnVal!.count <= 0 {
            aReturnVal = nil
        }
        
        return aReturnVal
    }
    
    
    static func devices(array pArray :Array<Dictionary<String,Any>>) -> Array<Device>? {
        var aReturnVal :Array<Device>? = Array<Device>()
        
        for aDeviceDict in pArray {
            if let aDevice = self.device(dict: aDeviceDict) {
                aReturnVal!.append(aDevice)
            }
        }
        if aReturnVal!.count <= 0 {
            aReturnVal = nil
        }
        
        return aReturnVal
    }
    
    
    static func device(dict pDict :Dictionary<String,Any>) -> Device? {
        var aReturnVal :Device? = nil
        
        if let aUserId = pDict["uid"] as? String
           , aUserId.count > 0 {
            let aDevice = Device()
            
            aDevice.id = pDict["id"] as? String
            
            aDevice.title = (pDict["name"] as? String)?.capitalized
            
            // aDevice.hardwareType will be set with id prefix
            
            if let aRoomId = pDict["roomId"] as? String {
                let aRoom = Room()
                aRoom.id = aRoomId
                aRoom.title = pDict["roomName"] as? String
                aDevice.room = aRoom
            }
            
            aDevice.firebaseUserId = pDict["uid"] as? String
            
            aReturnVal = aDevice
        }
        
        return aReturnVal
    }
    
    
    static func hardwareTypeDatabaseValue(_ pHardwareType :Device.HardwareType) -> String {
        var aReturnVal = ""
        
        switch pHardwareType {
        case Device.HardwareType.oneSwitch:
            aReturnVal = "1-switch"
        case Device.HardwareType.twoSwitch:
            aReturnVal = "2-switch"
        case Device.HardwareType.threeSwitch:
            aReturnVal = "3-switch"
        case Device.HardwareType.fourSwitch:
            aReturnVal = "4-switch"
        case Device.HardwareType.fiveSwitch:
            aReturnVal = "5-switch"
        case Device.HardwareType.sixSwitch:
            aReturnVal = "6-switch"
        case Device.HardwareType.sevenSwitch:
            aReturnVal = "7-switch"
        case Device.HardwareType.eightSwitch:
            aReturnVal = "8-switch"
        case Device.HardwareType.nineSwitch:
            aReturnVal = "9-switch"
        case Device.HardwareType.tenSwitch:
            aReturnVal = "10-switch"
            
        case Device.HardwareType.clOneSwitch:
            aReturnVal = "1-switch"
            
        case Device.HardwareType.ctOneSwitch:
            aReturnVal = "1-switch"
        case Device.HardwareType.ctTwoSwitch:
            aReturnVal = "2-switch"
        case Device.HardwareType.ctThreeSwitch:
            aReturnVal = "3-switch"
        case Device.HardwareType.ctFourSwitch:
            aReturnVal = "4-switch"
        case Device.HardwareType.ctFiveSwitch:
            aReturnVal = "5-switch"
        case Device.HardwareType.ctSixSwitch:
            aReturnVal = "6-switch"
        case Device.HardwareType.ctSevenSwitch:
            aReturnVal = "7-switch"
        case Device.HardwareType.ctEightSwitch:
            aReturnVal = "8-switch"
        case Device.HardwareType.ctNineSwitch:
            aReturnVal = "9-switch"
        case Device.HardwareType.ctTenSwitch:
            aReturnVal = "10-switch"
            
        case Device.HardwareType.smartSensor:
            aReturnVal = "smartSensor"
        case Device.HardwareType.smokeDetector:
            aReturnVal = "Smoke Detector"
        case Device.HardwareType.thermalSensor:
            aReturnVal = "Thermal Sensor"
        case Device.HardwareType.uvSensor:
            aReturnVal = "UV Sensor"
        case Device.HardwareType.smartSecuritySensor:
            aReturnVal = "Smart Security Sensor"
            
        case Device.HardwareType.rollingCurtain:
            aReturnVal = "Rolling Curtain"
        case Device.HardwareType.slidingCurtain:
            aReturnVal = "Sliding Curtain"
            
        case Device.HardwareType.ir:
            aReturnVal = "IR"
            
        case Device.HardwareType.lock:
            aReturnVal = "Lock"
        case Device.HardwareType.gateLock:
            aReturnVal = "Gate Controller"
        }
        return aReturnVal
    }
    
    static func hardwareTypeForAndroidDatabaseValue(_ pHardwareType :Device.HardwareType) -> String {
        var aReturnVal = ""
        
        switch pHardwareType {
        case Device.HardwareType.oneSwitch:
            aReturnVal = "1 Switch Controller"
        case Device.HardwareType.twoSwitch:
            aReturnVal = "2 Switch Controller"
        case Device.HardwareType.threeSwitch:
            aReturnVal = "3 Switch Controller"
        case Device.HardwareType.fourSwitch:
            aReturnVal = "4 Switch Controller"
        case Device.HardwareType.fiveSwitch:
            aReturnVal = "5 Switch Controller"
        case Device.HardwareType.sixSwitch:
            aReturnVal = "6 Switch Controller"
        case Device.HardwareType.sevenSwitch:
            aReturnVal = "7 Switch Controller"
        case Device.HardwareType.eightSwitch:
            aReturnVal = "8 Switch Controller"
        case Device.HardwareType.nineSwitch:
            aReturnVal = "9 Switch Controller"
        case Device.HardwareType.tenSwitch:
            aReturnVal = "10 Switch Controller"
            
        case Device.HardwareType.clOneSwitch:
            aReturnVal = "Strip Light"
            
        case Device.HardwareType.ctOneSwitch:
            aReturnVal = "1 Switch Controller"
        case Device.HardwareType.ctTwoSwitch:
            aReturnVal = "2 Switch Controller"
        case Device.HardwareType.ctThreeSwitch:
            aReturnVal = "3 Switch Controller"
        case Device.HardwareType.ctFourSwitch:
            aReturnVal = "4 Switch Controller"
        case Device.HardwareType.ctFiveSwitch:
            aReturnVal = "5 Switch Controller"
        case Device.HardwareType.ctSixSwitch:
            aReturnVal = "6 Switch Controller"
        case Device.HardwareType.ctSevenSwitch:
            aReturnVal = "7 Switch Controller"
        case Device.HardwareType.ctEightSwitch:
            aReturnVal = "8 Switch Controller"
        case Device.HardwareType.ctNineSwitch:
            aReturnVal = "9 Switch Controller"
        case Device.HardwareType.ctTenSwitch:
            aReturnVal = "10 Switch Controller"
            
        case Device.HardwareType.smartSensor:
            aReturnVal = "Smart Sensor"
        case Device.HardwareType.smokeDetector:
            aReturnVal = "Smoke Detector"
        case Device.HardwareType.thermalSensor:
            aReturnVal = "Thermal Sensor"
        case Device.HardwareType.uvSensor:
            aReturnVal = "UV Sensor"
        case Device.HardwareType.smartSecuritySensor:
            aReturnVal = "Smart Security Sensor"
            
        case Device.HardwareType.rollingCurtain:
            aReturnVal = "Rolling"
        case Device.HardwareType.slidingCurtain:
            aReturnVal = "Sliding"
            
        case Device.HardwareType.ir:
            aReturnVal = "IR"
            
        case Device.HardwareType.lock:
            aReturnVal = "Lock"
        case Device.HardwareType.gateLock:
            aReturnVal = "Gate Controller"
        }
        return aReturnVal
    }
    
}



// MARK:- Appliance

extension DataContractManagerFireBase {
    
    static func appliances(any pAny :Any?) -> Array<Appliance>? {
        var aReturnVal :Array<Appliance>? = Array<Appliance>()
        if let aDictArray = pAny as? Array<Dictionary<String,Any>?>
        , let anApplianceArray = DataContractManagerFireBase.appliances(array: aDictArray) {
            aReturnVal!.append(contentsOf: anApplianceArray)
        }
        if aReturnVal!.count <= 0 {
            aReturnVal = nil
        }
        
        return aReturnVal
    }
    
    
    private static func appliances(dict pDict :Dictionary<String,Dictionary<String,Any>>) -> Array<Appliance>? {
        var aReturnVal :Array<Appliance>? = Array<Appliance>()
        
        for anApplianceDict in pDict.values {
            if let anAppliance = self.appliance(dict: anApplianceDict) {
                aReturnVal!.append(anAppliance)
            }
        }
        if aReturnVal!.count <= 0 {
            aReturnVal = nil
        }
        
        return aReturnVal
    }
    
    
    private static func appliances(array pArray :Array<Dictionary<String,Any>?>) -> Array<Appliance>? {
        var aReturnVal :Array<Appliance>? = Array<Appliance>()
        
        for aDict in pArray {
            if let anApplianceDict = aDict, let anAppliance = self.appliance(dict: anApplianceDict) {
                aReturnVal!.append(anAppliance)
            }
        }
        if aReturnVal!.count <= 0 {
            aReturnVal = nil
        }
        
        return aReturnVal
    }
    
    
    private static func appliance(dict pDict :Dictionary<String,Any>) -> Appliance? {
        var aReturnVal :Appliance? = nil
        
        if let aName = pDict["applianceName"] as? String
           , aName.count > 0 {
            let anAppliance = Appliance()
            anAppliance.id = pDict["id"] as? String
            anAppliance.title = (pDict["applianceName"] as? String)?.capitalized
            if let anApplianceTypeId = pDict["applianceTypeId"] as? String {
                anAppliance.type = Appliance.ApplianceType(rawValue: anApplianceTypeId)
            }
            
            anAppliance.roomId = pDict["roomId"] as? String
            anAppliance.roomTitle = pDict["roomName"] as? String
            
            anAppliance.slaveId = pDict["slaveId"] as? String
            anAppliance.hardwareId = pDict["hardwareId"] as? String
            
            if let aState = pDict["state"] as? Int, aState == 1 {
                anAppliance.isOn = true
            } else if let aState = pDict["state"] as? String, aState == "1" {
                anAppliance.isOn = true
            }
            
            anAppliance.isOnline = pDict["status"] as? Bool == true
            
            anAppliance.operatedCount = pDict["applianceOperatedCount"] as? Int
            
            if let anIsDimmable = pDict["dimmable"] as? String, anIsDimmable == "1" {
                anAppliance.isDimmable = true
            } else if let anIsDimmable = pDict["dimmable"] as? Int, anIsDimmable == 1 {
                anAppliance.isDimmable = true
            }
            if let aDimType = pDict["dimType"] as? String {
                anAppliance.dimType = Appliance.DimType(rawValue: aDimType)
            }
            if let aValue = pDict["dimableValue"] as? String {
                anAppliance.dimmableValue = Int(aValue)
            } else if let aValue = pDict["dimableValue"] as? Int {
                anAppliance.dimmableValue = aValue
            }
            if let aValue = pDict["triacDimableValue"] as? String {
                anAppliance.dimmableValueTriac = Int(aValue)
            } else if let aValue = pDict["triacDimableValue"] as? Int {
                anAppliance.dimmableValueTriac = aValue
            }
            if let aValue = pDict["minDimming"] as? String {
                anAppliance.dimmableValueMin = Int(aValue)
            } else if let aValue = pDict["minDimming"] as? Int {
                anAppliance.dimmableValueMin = aValue
            }
            if let aValue = pDict["maxDimming"] as? String {
                anAppliance.dimmableValueMax = Int(aValue)
            } else if let aValue = pDict["maxDimming"] as? Int {
                anAppliance.dimmableValueMax = aValue
            }
            
            if let aStripType = pDict["stripType"] as? String {
                anAppliance.stripType = Appliance.StripType(rawValue: aStripType)
            }
            
            if let aValue = pDict["property1"] as? String {
                anAppliance.ledStripProperty1 = Int(aValue)
            } else if let aValue = pDict["property1"] as? Int {
                anAppliance.ledStripProperty1 = aValue
            }
            if let aValue = pDict["property2"] as? String {
                anAppliance.ledStripProperty2 = Int(aValue)
            } else if let aValue = pDict["property2"] as? Int {
                anAppliance.ledStripProperty2 = aValue
            }
            if let aValue = pDict["property3"] as? String {
                anAppliance.ledStripProperty3 = Int(aValue)
            } else if let aValue = pDict["property3"] as? Int {
                anAppliance.ledStripProperty3 = aValue
            }
            
            aReturnVal = anAppliance
        }
        
        return aReturnVal
    }
    
    
    static func isOnCommandValue(_ pIsOn :Bool) -> String {
        return pIsOn ? "2" : "1"
    }
    
    static func isDimmableCommandValue(_ pIsOn :Bool) -> String {
        return pIsOn ? "1" : "0"
    }
    
}



// MARK:- AppNotification

extension DataContractManagerFireBase {
    
    static func appNotifications(array pArray :Array<Dictionary<String,Any>>) -> Array<AppNotification>? {
        var aReturnVal :Array<AppNotification>? = Array<AppNotification>()
        
        for anAppNotificationDict in pArray {
            let anAppNotification = AppNotification()
            
            anAppNotification.id = anAppNotificationDict["id"] as? String
            
            if let aMessage = anAppNotificationDict["message"] as? String {
                anAppNotification.message = aMessage
            }
            
            if let aDateString = anAppNotificationDict["datetime"] as? String {
                let aDateFormatter = DateFormatter()
                aDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                anAppNotification.date = aDateFormatter.date(from: aDateString)
            }
            
            aReturnVal!.append(anAppNotification)
        }
        if aReturnVal!.count <= 0 {
            aReturnVal = nil
        }
        
        return aReturnVal
    }
    
}



// MARK:- Curtain

extension DataContractManagerFireBase {
    
    static func curtains(dict pDict :Dictionary<String,Dictionary<String,Any>>) -> Array<Curtain>? {
        var aReturnVal :Array<Curtain>? = Array<Curtain>()
        
        for aCurtainDict in pDict.values {
            if let aCurtain = self.curtain(dict: aCurtainDict) {
                aReturnVal!.append(aCurtain)
            }
        }
        if aReturnVal!.count <= 0 {
            aReturnVal = nil
        }
        
        return aReturnVal
    }
    
    
    static func curtains(array pArray :Array<Dictionary<String,Any>>) -> Array<Curtain>? {
        var aReturnVal :Array<Curtain>? = Array<Curtain>()
        
        for anObject in pArray {
            if let aCurtain = self.curtain(dict: anObject) {
                aReturnVal!.append(aCurtain)
            }
        }
        if aReturnVal!.count <= 0 {
            aReturnVal = nil
        }
        
        return aReturnVal
    }
    
    
    static func curtain(dict pDict :Dictionary<String,Any>) -> Curtain? {
        var aReturnVal :Curtain? = nil
        
        if let aCurtainId = pDict["id"] as? String
           , aCurtainId.count > 0 {
            let aCurtain = Curtain()
            aCurtain.id = pDict["id"] as? String
            aCurtain.title = (pDict["name"] as? String)?.capitalized
            if let aCurtainType = pDict["type"] as? String {
                aCurtain.type = Curtain.CurtainType(rawValue: aCurtainType)
            }
            
            aCurtain.roomId = pDict["roomId"] as? String
            aCurtain.roomTitle = pDict["roomName"] as? String
            
            aCurtain.level = pDict["level"] as? Int ?? 0
            
            aCurtain.isOnline = pDict["online"] as? Bool
            
            aReturnVal = aCurtain
        }
        
        return aReturnVal
    }
    
}



// MARK:- Lock

extension DataContractManagerFireBase {
    
    static func locks(dict pDict :Dictionary<String,Dictionary<String,Any>>) -> Array<Lock>? {
        var aReturnVal :Array<Lock>? = Array<Lock>()
        
        for aLockDict in pDict.values {
            aReturnVal!.append(self.lock(dict: aLockDict))
        }
        if aReturnVal!.count <= 0 {
            aReturnVal = nil
        }
        
        return aReturnVal
    }
    
    
    static func lock(dict pDict :Dictionary<String,Any>) -> Lock {
        let aReturnVal :Lock = Lock()
        
        aReturnVal.id = pDict["id"] as? String
        
        if let aTitle = pDict["name"] as? String {
            aReturnVal.title = aTitle.capitalized
        }
        
        if let aLockState = pDict["state"] as? Bool {
            aReturnVal.isOpen = aLockState
        }
        
        if let aLockPassword = pDict["lockPassword"] as? String {
            aReturnVal.password = aLockPassword
        }
        
        return aReturnVal
    }
    
}



// MARK:- Mood

extension DataContractManagerFireBase {
    
    static func moods(dict pDict :Dictionary<String,Dictionary<String,Any>>) -> Array<Mood>? {
        var aReturnVal :Array<Mood>? = Array<Mood>()
        
        for aMoodDict in pDict.values {
            let aMood = Mood()
            
            aMood.id = aMoodDict["modeId"] as? String
            
            if let aTitle = aMoodDict["moodName"] as? String {
                aMood.title = aTitle.capitalized
            }
            
            aMood.isOn = aMoodDict["state"] as? Bool ?? false
            
            if let aValue = aMoodDict["roomId"] as? String {
                let aRoom = Room()
                aRoom.id = aValue
                aRoom.title = aMoodDict["roomName"] as? String
                aMood.room = aRoom
            }
            
            aMood.applianceCount = aMoodDict["lightCount"] as? Int
            
            aMood.curtainCount = aMoodDict["curtainCount"] as? Int
            
            aMood.remoteCount = aMoodDict["remoteCount"] as? Int
            
            aReturnVal!.append(aMood)
        }
        if aReturnVal!.count <= 0 {
            aReturnVal = nil
        }
        
        return aReturnVal
    }
    
}



// MARK:- Remote

extension DataContractManagerFireBase {
    
    static func remotes(dict pDict :Dictionary<String,Dictionary<String,Any>>) -> Array<Remote>? {
        var aReturnVal :Array<Remote>? = Array<Remote>()
        
        for aRemoteDict in pDict.values {
            aReturnVal!.append(self.remote(dict: aRemoteDict))
        }
        if aReturnVal!.count <= 0 {
            aReturnVal = nil
        }
        
        return aReturnVal
    }
    
    
    static func remote(dict pDict :Dictionary<String,Any>) -> Remote {
        let aReturnVal :Remote = Remote()
        
        aReturnVal.id = pDict["remoteId"] as? String
        
        aReturnVal.title = (pDict["remoteName"] as? String)?.capitalized
        if let aRemoteType = pDict["remoteType"] as? String {
            aReturnVal.type = Remote.RemoteType(rawValue: aRemoteType.uppercased())
        }
        
        aReturnVal.irId = pDict["IRId"] as? String
        
        aReturnVal.hardwareId = pDict["hardwareId"] as? String
        
        aReturnVal.roomId = pDict["roomId"] as? String
        aReturnVal.roomTitle = pDict["roomName"] as? String
        
        return aReturnVal
    }
    
    
    static func remoteKeys(dict pDict :Dictionary<String,Dictionary<String,Any>>) -> Array<RemoteKey>? {
        var aReturnVal :Array<RemoteKey>? = Array<RemoteKey>()
        
        for aRemoteKeyDict in pDict.values {
            let aRemoteKey = self.remoteKey(dict: aRemoteKeyDict)
            if aRemoteKey.tag != RemoteKey.Tag.none
                || ((aRemoteKey.command?.count ?? 0) > 0
                        && aRemoteKey.command != "aa") {
                aReturnVal!.append(aRemoteKey)
            }
        }
        // Sort frequently operated appliances
        aReturnVal?.sort { (pLhs, pRhs) -> Bool in
            return (pLhs.title?.lowercased() ?? "", pLhs.id?.lowercased() ?? "") < (pRhs.title?.lowercased() ?? "", pRhs.id?.lowercased() ?? "")
        }
        
        if aReturnVal!.count <= 0 {
            aReturnVal = nil
        }
        
        return aReturnVal
    }
    
    
    static func remoteKey(dict pDict :Dictionary<String,Any>) -> RemoteKey {
        let aReturnVal :RemoteKey = RemoteKey()
        
        aReturnVal.id = pDict["keyid"] as? String
        
        if let aTitle = (pDict["newKeyName"] as? String)?.capitalized, aTitle.count > 0 {
            aReturnVal.title = aTitle
        }
        
        if let aRemoteType = pDict["keyTag"] as? String {
            aReturnVal.tag = RemoteKey.Tag(rawValue: aRemoteType)
        }
        aReturnVal.timestamp = pDict["timestamp"] as? Int ?? 0
        
        aReturnVal.irId = pDict["irid"] as? String
        
        aReturnVal.isStatic = pDict["isStatic"] as? Bool ?? false
        
        aReturnVal.command = pDict["command"] as? String
        
        aReturnVal.recordCommand = pDict["keyRecordCommand"] as? String
        
        return aReturnVal
    }

}



// MARK:- Schedule

extension DataContractManagerFireBase {
    
    static func schedules(dict pDict :Dictionary<String,Dictionary<String,Any>>) -> Array<Schedule>? {
        var aReturnVal :Array<Schedule>? = Array<Schedule>()
        
        for aScheduleDict in pDict.values {
            let aSchedule = DataContractManagerFireBase.schedule(dict: aScheduleDict)
            aReturnVal!.append(aSchedule)
        }
        if aReturnVal!.count <= 0 {
            aReturnVal = nil
        }
        
        return aReturnVal
    }
    
    static func schedule(dict pDict :Dictionary<String,Any>) -> Schedule {
        let aReturnVal :Schedule = Schedule()
        
        aReturnVal.id = pDict["id"] as? String
        
        if let aTitle = pDict["name"] as? String {
            aReturnVal.title = aTitle.capitalized
        }
        
        if let aPowerState = pDict["activated"] as? Bool {
            aReturnVal.isOn = aPowerState
        }
        
        if let aTime = pDict["time"] as? String {
            aReturnVal.time = aTime
        }
        
        if let aRepetitionStringArray = pDict["days"] as? Array<String> {
            var aRepetitionArray = Array<Schedule.Day>()
            for aRepetitionString in aRepetitionStringArray {
                if let aRepetition = Schedule.Day(rawValue: aRepetitionString) {
                    aRepetitionArray.append(aRepetition)
                }
            }
            aReturnVal.repetitions = aRepetitionArray
        }
        
        aReturnVal.applianceCount = pDict["applianceCount"] as? Int
        
        aReturnVal.curtainCount = pDict["curtainCount"] as? Int
        
        aReturnVal.remoteCount = pDict["remoteCount"] as? Int
        
        aReturnVal.sensorCount = pDict["sensorCount"] as? Int
        
        return aReturnVal
    }
    
    static func scheduleDayDatabaseValue(schedule pSchedule :Schedule) -> [String] {
        var aReturnVal :[String] = []
        
        if let aRepetitionArray = pSchedule.repetitions {
            for aRepetition in aRepetitionArray {
                aReturnVal.append(aRepetition.rawValue)
            }
        }
        
        return aReturnVal
    }

}



// MARK:- Sensor

extension DataContractManagerFireBase {
    
    static func sensors(dict pDict :Dictionary<String,Dictionary<String,Any>>) -> Array<Sensor>? {
        var aReturnVal :Array<Sensor>? = Array<Sensor>()
        
        for aSensorDict in pDict.values {
            if let aSensor = self.sensor(dict: aSensorDict) {
                aReturnVal!.append(aSensor)
            }
        }
        if aReturnVal!.count <= 0 {
            aReturnVal = nil
        }
        
        return aReturnVal
    }
    
    
    static func sensor(dict pDict :Dictionary<String,Any>) -> Sensor? {
        var aReturnVal :Sensor? = nil
        
        if let aSensorId = pDict["id"] as? String
           , aSensorId.count > 0 {
            let aSensor = Sensor()
            
            aSensor.id = pDict["id"] as? String
            if let uidassin = pDict["uidAssign"]{
                
                aSensor.uidAssign = uidassin as? Bool
            }
            if let lastOperation = pDict["lastOperation"]{
                
                aSensor.lastOperation = lastOperation as? String
            }
            if let peopleCount = pDict["peopleCount"]{
                
                aSensor.peopleCount = peopleCount as? Int
            }
            if let lastOperationTime :Double = pDict["lastOperationTime"] as? Double{
                let date = NSDate(timeIntervalSince1970: lastOperationTime / 1000)
                //Date formatting
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd, MM yyyy HH:mm:a"
                dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                let dateString = dateFormatter.string(from: date as Date)
                print("formatted date is =  \(dateString)")
                
                aSensor.lastOperationTime = (lastOperationTime / 1000)
            }
            
            aSensor.hardwareGeneration = Device.HardwareGeneration.wifinity
            
            if let aTitle = pDict["sensorName"] as? String {
                aSensor.title = aTitle.capitalized
            } else if let aTitle = pDict["name"] as? String {
                aSensor.title = aTitle.capitalized
            }
            
            aSensor.roomId = pDict["roomId"] as? String
            
            aSensor.roomTitle = pDict["roomName"] as? String
            
            if let anOccupancyState = pDict["occupancyState"] as? Bool {
                aSensor.occupancyState = anOccupancyState ? Sensor.OccupancyState.armed : Sensor.OccupancyState.disarmed
            } else if let anOccupancyState = pDict["state"] as? Bool {
                aSensor.occupancyState = anOccupancyState ? Sensor.OccupancyState.armed : Sensor.OccupancyState.disarmed
            }
            
            if let aLightState = pDict["motionLightStatus"] as? Bool {
                aSensor.lightState = aLightState ? Sensor.LightState.on : Sensor.LightState.off
            }
            
            if let aMotionState = pDict["motionState"] as? Bool {
                aSensor.motionState = aMotionState ? Sensor.MotionState.on : Sensor.MotionState.off
            }
            
            if let aSirenState = pDict["sirenStatus"] as? Bool {
                aSensor.sirenState = aSirenState ? Sensor.SirenState.on : Sensor.SirenState.off
            }
            
            if let anOnlineState = pDict["online"] as? Bool {
                aSensor.onlineState = anOnlineState ? Sensor.OnlineState.on : Sensor.OnlineState.off
            }
            
            if let aLightIntensity = pDict["lightIntensity"] as? Int {
                aSensor.lightIntensity = aLightIntensity
            } else if let aLightIntensityString = pDict["lightIntensity"] as? String {
                aSensor.lightIntensity = Int(aLightIntensityString)
            } else if let aLightIntensity = pDict["light"] as? Int {
                aSensor.lightIntensity = aLightIntensity
            }
            
            if let aTemperature = pDict["temperature"] as? Int {
                aSensor.temperature = aTemperature
            } else if let aTemperatureString = pDict["temperature"] as? String {
                aSensor.temperature = Int(aTemperatureString)
            } else if let aTemperature = pDict["currentTemp"] as? Int {
                aSensor.temperature = aTemperature
            } else if let aTemperatureString = pDict["currentTemp"] as? String {
                aSensor.temperature = Int(aTemperatureString)
            }
            
            var aMotionTimeStamp :TimeInterval? = nil
            aMotionTimeStamp = pDict["lastMotionTimeStamp"] as? TimeInterval
            if aMotionTimeStamp != nil {
                aSensor.lastMotionDate = Date(timeIntervalSince1970: (aMotionTimeStamp! / 1000))
            }
            if aSensor.lastMotionDate == nil {
                var aMotionDateString :String? = nil
                aMotionDateString = pDict["motion"] as? String
                if aMotionDateString == nil {
                    aMotionDateString = pDict["lastMotion"] as? String
                }
                if aMotionDateString != nil {
                    let aDateFormatter = DateFormatter()
                    aDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 2019-12-13 09:28:32
                    aSensor.lastMotionDate = aDateFormatter.date(from: aMotionDateString!)
                }
            }
            
            if let aSmoke = pDict["smoke"] as? Int {
                aSensor.smoke = aSmoke
            } else if let aSmokeString = pDict["smoke"] as? String {
                aSensor.smoke = Int(aSmokeString)
            }
            
            if let aSmokeThreshold = pDict["smokeThreshold"] as? Int {
                aSensor.smokeThreshold = aSmokeThreshold
            } else if let aSmokeThresholdString = pDict["smokeThreshold"] as? String {
                aSensor.smokeThreshold = Int(aSmokeThresholdString)
            }
            
            if let aCo2 = pDict["co2"] as? Int {
                aSensor.co2 = aCo2
            } else if let aCo2String = pDict["co2"] as? String {
                aSensor.co2 = Int(aCo2String)
            }
            
            if let aCo2Threshold = pDict["co2Threshold"] as? Int {
                aSensor.co2Threshold = aCo2Threshold
            } else if let aCo2ThresholdString = pDict["co2Threshold"] as? String {
                aSensor.co2Threshold = Int(aCo2ThresholdString)
            }
            
            if let anLpg = pDict["lpg"] as? Int {
                aSensor.lpg = anLpg
            } else if let anLpgString = pDict["lpg"] as? String {
                aSensor.lpg = Int(anLpgString)
            }
            
            if let anLpgThreshold = pDict["lpgThreshold"] as? Int {
                aSensor.lpgThreshold = anLpgThreshold
            } else if let anLpgThresholdString = pDict["lpgThreshold"] as? String {
                aSensor.lpgThreshold = Int(anLpgThresholdString)
            }
            
            aReturnVal = aSensor
        } else {
            let aSensor = Sensor()
            
            if let aLightState = pDict["motionLightState"] as? Int {
                aSensor.lightSettingsState = Sensor.LightState(rawValue: aLightState)
            }
            aSensor.motionLightTimeout = pDict["motionLightTimeout"] as? Int
            aSensor.motionLightIntensity = pDict["lightIntensityLimit"] as? Int
            
            if let aSirenState = pDict["sirenState"] as? Int {
                aSensor.sirenSettingsState = aSirenState == 2 ? Sensor.SirenState.on : Sensor.SirenState.off
            }
            aSensor.sirenTimeout = pDict["sirenTimeout"] as? Int
            
            aReturnVal = aSensor
        }
        
        return aReturnVal
    }
    
}
