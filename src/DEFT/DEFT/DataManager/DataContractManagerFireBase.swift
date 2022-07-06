//
//  DataContractManagerFireBase.swift
//  DEFT
//
//  Created by Rupendra on 03/01/21.
//  Copyright © 2021 Example. All rights reserved.
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
            
            aDevice.isOnline = pDict["online"] as? Bool
            
            aReturnVal = aDevice
        }
        
        return aReturnVal
    }
}



// MARK:- Appliance

extension DataContractManagerFireBase {
    
    static func isOnCommandValue(_ pIsOn :Bool) -> String {
        return pIsOn ? "2" : "1"
    }
    
    static func isDimmableCommandValue(_ pIsOn :Bool) -> String {
        return pIsOn ? "1" : "0"
    }
    
    static func tankRegulatorMotorPowerStateCommandValue(_ pIsOn :Bool) -> String {
        return pIsOn ? "7" : "8"
    }
    
    
    static func appliances(dict pDict :Dictionary<String,Dictionary<String,Any>>) -> Array<Appliance>? {
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
    
    
    private static func appliance(dict pDict :Dictionary<String,Any>) -> Appliance? {
        var aReturnVal :Appliance? = nil
        
        let anAppliance = Appliance()
        
        let anApplianceDict = pDict
        
        anAppliance.id = anApplianceDict["id"] as? String
        if let aValue = anApplianceDict["uuid"] as? String {
            anAppliance.uuid = aValue
        } else if let aValue = anApplianceDict["applianceUuid"] as? String {
            anAppliance.uuid = aValue
        }
        anAppliance.title = (anApplianceDict["applianceName"] as? String)?.capitalized
        if let anApplianceTypeId = anApplianceDict["applianceTypeId"] as? String {
            anAppliance.type = Appliance.ApplianceType(rawValue: anApplianceTypeId)
        }
        
        anAppliance.roomId = anApplianceDict["roomId"] as? String
        anAppliance.roomTitle = anApplianceDict["roomName"] as? String
        
        anAppliance.slaveId = anApplianceDict["slaveId"] as? String
        anAppliance.hardwareId = anApplianceDict["hardwareId"] as? String
        
        if let aState = anApplianceDict["state"] as? Int, aState == 1 {
            anAppliance.isOn = true
        } else if let aState = anApplianceDict["state"] as? String, aState == "1" {
            anAppliance.isOn = true
        }
        
        anAppliance.isOnline = anApplianceDict["status"] as? Bool == true
        
        anAppliance.operatedCount = anApplianceDict["applianceOperatedCount"] as? Int
        
        if let anIsDimmable = anApplianceDict["dimmable"] as? String, anIsDimmable == "1" {
            anAppliance.isDimmable = true
        } else if let anIsDimmable = anApplianceDict["dimmable"] as? Int, anIsDimmable == 1 {
            anAppliance.isDimmable = true
        }
        if let aDimType = anApplianceDict["dimType"] as? String {
            anAppliance.dimType = Appliance.DimType(rawValue: aDimType)
        }
        if let aValue = anApplianceDict["dimableValue"] as? String {
            anAppliance.dimmableValue = Int(aValue)
        } else if let aValue = anApplianceDict["dimableValue"] as? Int {
            anAppliance.dimmableValue = aValue
        }
        if let aValue = anApplianceDict["triacDimableValue"] as? String {
            anAppliance.dimmableValueTriac = Int(aValue)
        } else if let aValue = anApplianceDict["triacDimableValue"] as? Int {
            anAppliance.dimmableValueTriac = aValue
        }
        if let aValue = anApplianceDict["minDimming"] as? String {
            anAppliance.dimmableValueMin = Int(aValue)
        } else if let aValue = anApplianceDict["minDimming"] as? Int {
            anAppliance.dimmableValueMin = aValue
        }
        if let aValue = anApplianceDict["maxDimming"] as? String {
            anAppliance.dimmableValueMax = Int(aValue)
        } else if let aValue = anApplianceDict["maxDimming"] as? Int {
            anAppliance.dimmableValueMax = aValue
        }
        
        if let aStripType = anApplianceDict["stripType"] as? String {
            anAppliance.stripType = Appliance.StripType(rawValue: aStripType)
        }
        
        if let aValue = anApplianceDict["property1"] as? String {
            anAppliance.ledStripProperty1 = Int(aValue)
        } else if let aValue = anApplianceDict["property1"] as? Int {
            anAppliance.ledStripProperty1 = aValue
        }
        if let aValue = anApplianceDict["property2"] as? String {
            anAppliance.ledStripProperty2 = Int(aValue)
        } else if let aValue = anApplianceDict["property2"] as? Int {
            anAppliance.ledStripProperty2 = aValue
        }
        if let aValue = anApplianceDict["property3"] as? String {
            anAppliance.ledStripProperty3 = Int(aValue)
        } else if let aValue = anApplianceDict["property3"] as? Int {
            anAppliance.ledStripProperty3 = aValue
        }
        
        if let aValue = anApplianceDict["dimValue"] as? String {
            anAppliance.scheduleDimmableValue = Int(aValue)
        } else if let aValue = anApplianceDict["dimValue"] as? Int {
            anAppliance.scheduleDimmableValue = aValue
        }
        if let aValue = anApplianceDict["command"] as? String {
            anAppliance.scheduleCommand = aValue
        }
        if let aValue = anApplianceDict["state"] as? Bool {
            anAppliance.scheduleState = aValue
        }
        
        aReturnVal = anAppliance
        
        return aReturnVal
    }
    
}



// MARK:- AppNotification

extension DataContractManagerFireBase {
    
    static func appNotifications(array pArray :Array<Dictionary<String,Any>>) -> Array<AppNotification>? {
        var aReturnVal :Array<AppNotification>? = Array<AppNotification>()
        
        for anAppNotificationDict in pArray {
            let anAppNotification = AppNotification()
            
            anAppNotification.id = anAppNotificationDict["id"] as? String
            
            if let aMessage = anAppNotificationDict["notificationMessage"] as? String {
                anAppNotification.message = aMessage
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
        
        if ((pDict["curtainId"] as? String)?.count ?? 0) > 0
        || ((pDict["id"] as? String)?.count ?? 0) > 0 {
            let aCurtain = Curtain()
            
            if let aValue = pDict["curtainId"] as? String {
                aCurtain.id = aValue
            } else if let aValue = pDict["id"] as? String {
                aCurtain.id = aValue
            }
            
            if let aValue = pDict["curtainName"] as? String {
                aCurtain.title = aValue.capitalized
            } else if let aValue = pDict["name"] as? String {
                aCurtain.title = aValue.capitalized
            }
            
            if let aValue = pDict["curtainType"] as? String {
                aCurtain.type = Curtain.CurtainType(rawValue: aValue)
            } else if let aValue = pDict["type"] as? String {
                aCurtain.type = Curtain.CurtainType(rawValue: aValue)
            }
            
            aCurtain.roomId = pDict["roomId"] as? String
            
            aCurtain.roomTitle = pDict["roomName"] as? String
            
            if let aValue = pDict["level"] as? Int {
                aCurtain.level = aValue
            }
            
            aCurtain.scheduleLevel = pDict["curtainLevel"] as? Int
            
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
        
        aReturnVal.id = pDict["lockId"] as? String
        
        if let aTitle = pDict["lockName"] as? String {
            aReturnVal.title = aTitle.capitalized
        }
        
        if let aLockState = pDict["lockState"] as? Bool {
            aReturnVal.isOpen = aLockState
        }
        
        if let aLockPassword = pDict["lockPassword"] as? String {
            aReturnVal.password = aLockPassword
        }
        
        if let aValue = pDict["type"] as? String {
            aReturnVal.deftLockType = aValue
        }
        
        return aReturnVal
    }
    
}



// MARK:- Mood

extension DataContractManagerFireBase {
    
    static func mood(dict pDict :Dictionary<String,Any>) -> Mood {
        let aReturnVal :Mood = Mood()
        
        let aMoodDict = pDict
        
        aReturnVal.uuid = aMoodDict["uuid"] as? String
        
        if let aTitle = aMoodDict["moodName"] as? String {
            aReturnVal.title = aTitle.capitalized
        }
        
        if let aValue = aMoodDict["roomId"] as? String {
            let aRoom = Room()
            aRoom.id = aValue
            aRoom.title = aMoodDict["roomName"] as? String
            aReturnVal.room = aRoom
        }
        
        if let aValue = aMoodDict["applianceCount"] as? Int {
            aReturnVal.applianceCount = aValue
        } else if let aValue = aMoodDict["applianceCount"] as? String {
            aReturnVal.applianceCount = Int(aValue)
        }
        
        if let aValue = aMoodDict["curtainCount"] as? Int {
            aReturnVal.curtainCount = aValue
        } else if let aValue = aMoodDict["curtainCount"] as? String {
            aReturnVal.curtainCount = Int(aValue)
        }
        
        if let aValue = aMoodDict["remoteCount"] as? Int {
            aReturnVal.remoteCount = aValue
        } else if let aValue = aMoodDict["remoteCount"] as? String {
            aReturnVal.remoteCount = Int(aValue)
        }
        
        aReturnVal.isOn = aMoodDict["state"] as? Bool ?? false
        
        return aReturnVal
    }
    
    static func moods(dict pDict :Dictionary<String,Dictionary<String,Any>>) -> Array<Mood>? {
        var aReturnVal :Array<Mood>? = Array<Mood>()
        
        for aMoodDict in pDict.values {
            aReturnVal?.append(self.mood(dict: aMoodDict))
        }
        if aReturnVal!.count <= 0 {
            aReturnVal = nil
        }
        
        return aReturnVal
    }
    
    static func moodDict(mood pMood :Mood) -> Dictionary<String,Any?> {
        var aReturnVal :Dictionary<String,Any?>
        
        var aMoodDict = Dictionary<String,Any?>()
        aMoodDict["uuid"] = pMood.uuid
        aMoodDict["moodName"] = pMood.title
        aMoodDict["applianceCount"] = pMood.calculatedApplianceCount
        aMoodDict["curtainCount"] = pMood.calculatedCurtainCount
        aMoodDict["remoteCount"] = pMood.calculatedRemoteCount
        aMoodDict["roomId"] = pMood.room?.id
        aMoodDict["roomName"] = pMood.room?.title
        aMoodDict["state"] = pMood.isOn
        
        aReturnVal = aMoodDict
        
        return aReturnVal
    }
    
    static func moodComponentDict(room pRoom :Room) -> Dictionary<String,Any?> {
        var aReturnVal = Dictionary<String,Any?>()
        
        let aRoom = pRoom
        
        var aCommandDictArray = Array<Dictionary<String,Any?>>()
        if let anArray = aRoom.appliances {
            let aComponentDictArray = self.moodApplianceDictArray(applianceArray: anArray, room: aRoom)
            aCommandDictArray.append(contentsOf: aComponentDictArray)
        }
        if let anArray = aRoom.curtains {
            let aComponentDictArray = self.moodCurtainDictArray(curtainArray: anArray, room: aRoom)
            aCommandDictArray.append(contentsOf: aComponentDictArray)
        }
        aReturnVal["commands"] = aCommandDictArray
        
        var aMoodOnTimeCommandDictArray = Array<Dictionary<String,Any?>>()
        if let anArray = aRoom.moodOnRemotes {
            let aComponentDictArray = self.moodRemoteDictArray(remoteArray: anArray, room: aRoom)
            aMoodOnTimeCommandDictArray.append(contentsOf: aComponentDictArray)
        }
        var aMoodOffTimeCommandDictArray = Array<Dictionary<String,Any?>>()
        if let anArray = aRoom.moodOffRemotes {
            let aComponentDictArray = self.moodRemoteDictArray(remoteArray: anArray, room: aRoom)
            aMoodOffTimeCommandDictArray.append(contentsOf: aComponentDictArray)
        }
        
        aReturnVal["staticCommands"] = [
            "moodOnTime" : aMoodOnTimeCommandDictArray
            , "moodOffTime" : aMoodOffTimeCommandDictArray
        ]
        
        return aReturnVal
    }
    
    static func moodApplianceDictArray(applianceArray pApplianceArray :Array<Appliance>, room pRoom :Room) -> Array<Dictionary<String,Any?>> {
        var aReturnVal = Array<[String:Any?]>()
        
        for anAppliance in pApplianceArray {
            let aDict :[String:Any?] = [
                "controllerId": anAppliance.hardwareId
                , "command": anAppliance.scheduleCommand
                , "roomId": pRoom.id
                , "applianceId": anAppliance.id
                , "applianceUuid": anAppliance.uuid
                , "dimValue": anAppliance.scheduleDimmableValue
                , "state": anAppliance.scheduleState
                , "moodComponentType": Mood.ComponentType.appliance.rawValue
            ]
            aReturnVal.append(aDict)
        }
        
        return aReturnVal
    }
    
    static func moodCurtainDictArray(curtainArray pCurtainArray :Array<Curtain>, room pRoom :Room) -> Array<Dictionary<String,Any?>> {
        var aReturnVal = Array<[String:Any?]>()
        
        for aCurtain in pCurtainArray {
            let aDict :[String:Any?] = [
                "curtainId": aCurtain.id
                , "command": aCurtain.scheduleCommand
                , "roomId": pRoom.id
                , "level": aCurtain.level
                , "curtainLevel": aCurtain.scheduleLevel
                , "moodComponentType": Mood.ComponentType.curtain.rawValue
            ]
            aReturnVal.append(aDict)
        }
        
        return aReturnVal
    }
    
    static func moodRemoteDictArray(remoteArray pRemoteArray :Array<Remote>, room pRoom :Room) -> Array<Dictionary<String,Any?>> {
        var aReturnVal = Array<[String:Any?]>()
        
        for aRemote in pRemoteArray {
            if let aRemoteKeyArray = aRemote.selectedRemoteKeys {
                for aRemoteKey in aRemoteKeyArray {
                    var aMoodComponentDict :[String:Any?] = [:]
                    if aRemote.hardwareGeneration == .wifinity {
                        aMoodComponentDict["controllerId"] = aRemote.hardwareId
                    } else {
                        aMoodComponentDict["irId"] = aRemote.irId
                    }
                    aMoodComponentDict["remoteId"] = aRemote.id
                    aMoodComponentDict["remoteName"] = aRemote.title
                    aMoodComponentDict["keyId"] = aRemoteKey.id
                    aMoodComponentDict["keyName"] = aRemoteKey.title ?? aRemoteKey.tag?.rawValue
                    aMoodComponentDict["command"] = aRemoteKey.command
                    aMoodComponentDict["roomId"] = pRoom.id
                    aMoodComponentDict["moodComponentType"] = Mood.ComponentType.remoteKey.rawValue
                    aReturnVal.append(aMoodComponentDict)
                }
            }
        }
        
        return aReturnVal
    }
    
    static func moodRoom(dict pDict :Dictionary<String,Any>) -> Room? {
        var aReturnVal :Room? = nil
        
        // Assign appliances and curtains
        if let aComponentDictArray = pDict["commands"] as? Array<Dictionary<String,Any>> {
            let aRoom = Room()
            for aComponentDict in aComponentDictArray {
                if let aRoomId = aComponentDict["roomId"] as? String {
                    aRoom.id = aRoomId
                }
                let aComponentType = aComponentDict["moodComponentType"] as? String
                if aComponentType == Mood.ComponentType.appliance.rawValue {
                    if let aComponent = self.appliance(dict: aComponentDict) {
                        if aRoom.appliances == nil {
                            aRoom.appliances = Array<Appliance>()
                        }
                        aRoom.appliances?.append(aComponent)
                    }
                } else if aComponentType == Mood.ComponentType.curtain.rawValue {
                    if let aComponent = self.curtain(dict: aComponentDict) {
                        if aRoom.curtains == nil {
                            aRoom.curtains = Array<Curtain>()
                        }
                        aRoom.curtains?.append(aComponent)
                    }
                }
            }
            if aReturnVal == nil {
                aReturnVal = aRoom
            } else {
                aReturnVal?.appliances = aRoom.appliances
                aReturnVal?.curtains = aRoom.curtains
            }
        }
        
        // Assign remotes
        if let aComponentContainerDict = pDict["staticCommands"] as? Dictionary<String,Any> {
            if let aComponentDictArray = aComponentContainerDict["moodOnTime"] as? Array<Dictionary<String,Any>>, let aRoomId = aComponentDictArray.first?["roomId"] as? String {
                if aReturnVal == nil {
                    aReturnVal = Room()
                    aReturnVal?.id = aRoomId
                }
                aReturnVal?.moodOnRemotes = self.moodRemotes(dictArray: aComponentDictArray)
            }
            if let aComponentDictArray = aComponentContainerDict["moodOffTime"] as? Array<Dictionary<String,Any>>, let aRoomId = aComponentDictArray.first?["roomId"] as? String {
                if aReturnVal == nil {
                    aReturnVal = Room()
                    aReturnVal?.id = aRoomId
                }
                aReturnVal?.moodOffRemotes = self.moodRemotes(dictArray: aComponentDictArray)
            }
        }
        
        return aReturnVal
    }
    
    static func moodRemotes(dictArray pDictArray :Array<Dictionary<String,Any>>) -> Array<Remote>? {
        var aReturnVal :Array<Remote>? = nil
        
        let aRoom = Room()
        for aRemoteDict in pDictArray {
            if let aRoomId = aRemoteDict["roomId"] as? String {
                aRoom.id = aRoomId
            }
            let aComponent = self.remoteKey(dict: aRemoteDict)
            let aRemote = Remote()
            aRemote.id = (aRemoteDict["remoteId"] as? String)
            aRemote.selectedRemoteKeys = Array<RemoteKey>()
            aRemote.selectedRemoteKeys?.append(aComponent)
            if aRoom.remotes == nil {
                aRoom.remotes = Array<Remote>()
            }
            aRoom.remotes?.append(aRemote)
        }
        // Sort remote keys
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
        
        if (aRoom.remotes?.count ?? 0) > 0 {
            aReturnVal = aRoom.remotes
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
            aReturnVal.type = Remote.RemoteType(rawValue: aRemoteType)
        }
        
        aReturnVal.irId = pDict["IRId"] as? String
        if aReturnVal.irId?.hasPrefix("I") == true {
            aReturnVal.hardwareGeneration = Device.HardwareGeneration.wifinity
        } else {
            aReturnVal.hardwareGeneration = Device.HardwareGeneration.deft
        }
        
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
        
        aReturnVal.id = pDict["keyId"] as? String ?? pDict["keyid"] as? String
        
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
    
    static func schedule(dict pDict :Dictionary<String,Any>) -> Schedule {
        let aReturnVal :Schedule = Schedule()
        
        aReturnVal.id = pDict["id"] as? String
        
        aReturnVal.uuid = pDict["uuid"] as? String
        
        if let aTitle = pDict["name"] as? String {
            aReturnVal.title = aTitle.capitalized
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
        
        if let aDictArray = pDict["rooms"] as? Array<Dictionary<String, Any>> {
            aReturnVal.rooms = self.scheduleRooms(array: aDictArray)
        }
        
        aReturnVal.isOn = pDict["activated"] as? Bool ?? false
        
        return aReturnVal
    }
    
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
    
    static func scheduleRooms(dict pDict :Dictionary<String,Any>) -> Array<Room>? {
        var aReturnVal :Array<Room>? = Array<Room>()
        
        var aDictArray = Array<Dictionary<String,Any>>()
        if let aComponentDictArray = pDict["commands"] as? Array<Dictionary<String,Any>> {
            aDictArray.append(contentsOf: aComponentDictArray)
        }
        if let aComponentDictArray = pDict["delayedCommands"] as? Array<Dictionary<String,Any>> {
            aDictArray.append(contentsOf: aComponentDictArray)
        }
        
        aReturnVal = self.scheduleRooms(array: aDictArray)
        
        return aReturnVal
    }
    
    static func scheduleRooms(array pArray :Array<Dictionary<String,Any>>) -> Array<Room>? {
        var aReturnVal :Array<Room>? = Array<Room>()
        
        for aComponentDict in pArray {
            var aRoom :Room?
            if let aRoomId = aComponentDict["roomId"] as? String {
                aRoom = aReturnVal?.first(where: { (pRoom) -> Bool in
                    return pRoom.id == aRoomId
                })
            }
            if aRoom == nil {
                aRoom = Room()
                
                aRoom?.id = aComponentDict["roomId"] as? String
                
                if let aTitle = aComponentDict["roomName"] as? String {
                    aRoom?.title = aTitle.capitalized
                }
                
                if let aLastActive = aComponentDict["lastActive"] as? Int {
                    aRoom?.lastActiveDate = Date(timeIntervalSince1970: TimeInterval(aLastActive))
                }
                
                aReturnVal!.append(aRoom!)
            }
            
            // Assign component
            if let aComponentType = aComponentDict["scheduleComponentType"] as? String {
                if aComponentType == Schedule.ComponentType.appliance.rawValue {
                    if let aComponent = self.appliance(dict: aComponentDict) {
                        if aRoom?.appliances == nil {
                            aRoom?.appliances = Array<Appliance>()
                        }
                        aRoom?.appliances?.append(aComponent)
                    }
                } else if aComponentType == Schedule.ComponentType.curtain.rawValue {
                    if let aComponent = self.curtain(dict: aComponentDict) {
                        if aRoom?.curtains == nil {
                            aRoom?.curtains = Array<Curtain>()
                        }
                        aRoom?.curtains?.append(aComponent)
                    }
                } else if aComponentType == Schedule.ComponentType.remoteKey.rawValue {
                    let aComponent = self.remoteKey(dict: aComponentDict)
                    let aRemote = Remote()
                    aRemote.id = (aComponentDict["remoteId"] as? String)
                    aRemote.selectedRemoteKeys = Array<RemoteKey>()
                    aRemote.selectedRemoteKeys?.append(aComponent)
                    if aRoom?.remotes == nil {
                        aRoom?.remotes = Array<Remote>()
                    }
                    aRoom?.remotes?.append(aRemote)
                } else if aComponentType == Schedule.ComponentType.sensor.rawValue {
                    if let aComponent = self.sensor(dict: aComponentDict) {
                        if aRoom?.sensors == nil {
                            aRoom?.sensors = Array<Sensor>()
                        }
                        aRoom?.sensors?.append(aComponent)
                    }
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
    
    static func scheduleDayDatabaseValue(schedule pSchedule :Schedule) -> [String] {
        var aReturnVal :[String] = []
        
        if let aRepetitionArray = pSchedule.repetitions {
            for aRepetition in aRepetitionArray {
                aReturnVal.append(aRepetition.rawValue)
            }
        }
        
        return aReturnVal
    }
    
    
    static func scheduleDict(schedule pSchedule :Schedule) -> Dictionary<String,Any?> {
        var aReturnVal :Dictionary<String,Any?>
        
        var aScheduleDict = Dictionary<String,Any?>()
        aScheduleDict["uuid"] = pSchedule.uuid
        aScheduleDict["name"] = pSchedule.title
        aScheduleDict["time"] = pSchedule.time
        aScheduleDict["activated"] = false
        aScheduleDict["applianceCount"] = pSchedule.calculatedApplianceCount
        aScheduleDict["curtainCount"] = pSchedule.calculatedCurtainCount
        aScheduleDict["remoteCount"] = pSchedule.calculatedRemoteCount
        aScheduleDict["sensorCount"] = pSchedule.calculatedSensorCount
        aScheduleDict["repeating"] = (pSchedule.repetitions?.count ?? 0) > 0 ? true : false
        aScheduleDict["days"] = DataContractManagerFireBase.scheduleDayDatabaseValue(schedule: pSchedule)
        
        aReturnVal = aScheduleDict
        
        return aReturnVal
    }
    
    
    static func scheduleComponentDict(rooms pRoomArray :Array<Room>) -> Dictionary<String,Any?> {
        var aReturnVal = Dictionary<String,Any?>()
        
        var aCommandDictArray = Array<Dictionary<String,Any?>>()
        var aDelayedCommandDictArray = Array<Dictionary<String,Any?>>()
        for aRoom in pRoomArray {
            if let anArray = aRoom.appliances {
                let aComponentDictArray = self.scheduleApplianceDictArray(applianceArray: anArray, room: aRoom)
                aCommandDictArray.append(contentsOf: aComponentDictArray)
            }
            if let anArray = aRoom.curtains {
                let aComponentDictArray = self.scheduleCurtainDictArray(curtainArray: anArray, room: aRoom)
                aCommandDictArray.append(contentsOf: aComponentDictArray)
            }
            if let anArray = aRoom.sensors {
                let aComponentDictArray = self.scheduleSensorDictArray(sensorArray: anArray, room: aRoom)
                aCommandDictArray.append(contentsOf: aComponentDictArray)
            }
            
            if let anArray = aRoom.remotes {
                let aComponentDictArray = self.scheduleRemoteDictArray(remoteArray: anArray, room: aRoom)
                aDelayedCommandDictArray.append(contentsOf: aComponentDictArray)
            }
        }
        
        aReturnVal["commands"] = aCommandDictArray
        aReturnVal["delayedCommands"] = aDelayedCommandDictArray
        
        return aReturnVal
    }
    
    static func scheduleApplianceDictArray(applianceArray pApplianceArray :Array<Appliance>, room pRoom :Room) -> Array<Dictionary<String,Any?>> {
        var aReturnVal = Array<[String:Any?]>()
        
        for anAppliance in pApplianceArray {
            let aDict :[String:Any?] = [
                "controllerId": anAppliance.hardwareId
                , "command": anAppliance.scheduleCommand
                , "roomId": pRoom.id
                , "applianceId": anAppliance.id
                , "applianceUuid": anAppliance.uuid
                , "dimValue": anAppliance.scheduleDimmableValue
                , "state": anAppliance.scheduleState
                , "scheduleComponentType": Schedule.ComponentType.appliance.rawValue
            ]
            aReturnVal.append(aDict)
        }
        
        return aReturnVal
    }
    
    static func scheduleCurtainDictArray(curtainArray pCurtainArray :Array<Curtain>, room pRoom :Room) -> Array<Dictionary<String,Any?>> {
        var aReturnVal = Array<[String:Any?]>()
        
        for aCurtain in pCurtainArray {
            let aDict :[String:Any?] = [
                "curtainId": aCurtain.id
                , "command": aCurtain.scheduleCommand
                , "roomId": pRoom.id
                , "level": aCurtain.level
                , "curtainLevel": aCurtain.scheduleLevel
                , "scheduleComponentType": Schedule.ComponentType.curtain.rawValue
            ]
            aReturnVal.append(aDict)
        }
        
        return aReturnVal
    }
    
    static func scheduleRemoteDictArray(remoteArray pRemoteArray :Array<Remote>, room pRoom :Room) -> Array<Dictionary<String,Any?>> {
        var aReturnVal = Array<[String:Any?]>()
        
        for aRemote in pRemoteArray {
            if let aRemoteKeyArray = aRemote.selectedRemoteKeys {
                for aRemoteKey in aRemoteKeyArray {
                    var aScheduleComponentDict :[String:Any?] = [:]
                    if aRemote.hardwareGeneration == .wifinity {
                        aScheduleComponentDict["controllerId"] = aRemote.irId
                    } else {
                        aScheduleComponentDict["irId"] = aRemote.irId
                    }
                    aScheduleComponentDict["remoteId"] = aRemote.id
                    aScheduleComponentDict["remoteName"] = aRemote.title
                    aScheduleComponentDict["keyId"] = aRemoteKey.id
                    aScheduleComponentDict["keyName"] = aRemoteKey.title ?? aRemoteKey.tag?.rawValue
                    aScheduleComponentDict["command"] = aRemoteKey.command
                    aScheduleComponentDict["roomId"] = pRoom.id
                    aScheduleComponentDict["scheduleComponentType"] = Schedule.ComponentType.remoteKey.rawValue
                    aReturnVal.append(aScheduleComponentDict)
                }
            }
        }
        
        return aReturnVal
    }
    
    static func scheduleSensorDictArray(sensorArray pSensorArray :Array<Sensor>, room pRoom :Room) -> Array<Dictionary<String,Any?>> {
        var aReturnVal = Array<[String:Any?]>()
        
        for aSensor in pSensorArray {
            var anIsSensorActivatedSelected = false
            var anIsSensorActivated = false
            if aSensor.scheduleSensorActivatedState == Sensor.OnlineState.on {
                anIsSensorActivatedSelected = true
                anIsSensorActivated = true
            } else if aSensor.scheduleSensorActivatedState == Sensor.OnlineState.off {
                anIsSensorActivatedSelected = true
                anIsSensorActivated = false
            } else {
                anIsSensorActivatedSelected = false
                anIsSensorActivated = false
            }
            
            var anIsMotionLightActivatedSelected = false
            var anIsMotionLightActivated = false
            if aSensor.scheduleMotionLightActivatedState == Sensor.LightState.on {
                anIsMotionLightActivatedSelected = true
                anIsMotionLightActivated = true
            } else if aSensor.scheduleMotionLightActivatedState == Sensor.LightState.off {
                anIsMotionLightActivatedSelected = true
                anIsMotionLightActivated = false
            } else {
                anIsMotionLightActivatedSelected = false
                anIsMotionLightActivated = false
            }
            
            var anIsSirenActivatedSelected = false
            var anIsSirenActivated = false
            if aSensor.scheduleSirenActivatedState == Sensor.SirenState.on {
                anIsSirenActivatedSelected = true
                anIsSirenActivated = true
            } else if aSensor.scheduleSirenActivatedState == Sensor.SirenState.off {
                anIsSirenActivatedSelected = true
                anIsSirenActivated = false
            } else {
                anIsSirenActivatedSelected = false
                anIsSirenActivated = false
            }
            
            var aSensorComponentDict :[String:Any?] = [:]
            if aSensor.hardwareGeneration == .wifinity {
                aSensorComponentDict["controllerId"] = aSensor.id
            } else {
                aSensorComponentDict["id"] = aSensor.id
            }
            aSensorComponentDict["command"] = aSensor.scheduleCommands
            aSensorComponentDict["roomId"] = pRoom.id
            aSensorComponentDict["lightActivated"] = anIsMotionLightActivated
            aSensorComponentDict["lightActivatedSelected"] = anIsMotionLightActivatedSelected
            aSensorComponentDict["relay1Activated"] = false
            aSensorComponentDict["relay2Activated"] = false
            aSensorComponentDict["sensorActivated"] = anIsSensorActivated
            aSensorComponentDict["sensorActivatedSelected"] = anIsSensorActivatedSelected
            aSensorComponentDict["sensorProperty"] = true
            aSensorComponentDict["sensorRelayProperty"] = false
            aSensorComponentDict["sirenActivated"] = anIsSirenActivated
            aSensorComponentDict["sirenActivatedSelected"] = anIsSirenActivatedSelected
            aSensorComponentDict["scheduleComponentType"] = Schedule.ComponentType.sensor.rawValue
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
            
            if aSensor.id?.hasPrefix("S") == true {
                aSensor.hardwareGeneration = Device.HardwareGeneration.wifinity
            } else {
                aSensor.hardwareGeneration = Device.HardwareGeneration.deft
            }
            
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
            
            let anIsSensorActivatedSelected = (pDict["sensorActivatedSelected"] as? Bool) ?? false
            let anIsSensorActivated = (pDict["sensorActivated"] as? Bool) ?? false
            if anIsSensorActivatedSelected {
                if anIsSensorActivated {
                    aSensor.scheduleSensorActivatedState = Sensor.OnlineState.on
                } else {
                    aSensor.scheduleSensorActivatedState = Sensor.OnlineState.off
                }
            } else {
                aSensor.scheduleSensorActivatedState = nil
            }
            
            let anIsLightActivatedSelected = (pDict["lightActivatedSelected"] as? Bool) ?? false
            let anIsLightActivated = (pDict["lightActivated"] as? Bool) ?? false
            if anIsLightActivatedSelected {
                if anIsLightActivated {
                    aSensor.scheduleMotionLightActivatedState = Sensor.LightState.on
                } else {
                    aSensor.scheduleMotionLightActivatedState = Sensor.LightState.off
                }
            } else {
                aSensor.scheduleMotionLightActivatedState = nil
            }
            
            let anIsSirenActivatedSelected = (pDict["sirenActivatedSelected"] as? Bool) ?? false
            let anIsSirenActivated = (pDict["sirenActivated"] as? Bool) ?? false
            if anIsSirenActivatedSelected == true {
                if anIsSirenActivated == true {
                    aSensor.scheduleSirenActivatedState = Sensor.SirenState.on
                } else {
                    aSensor.scheduleSirenActivatedState = Sensor.SirenState.off
                }
            } else {
                aSensor.scheduleSirenActivatedState = nil
            }
            
            if let aValue = pDict["command"] as? Array<String> {
                aSensor.scheduleCommands = aValue
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


// MARK:- Sensor

extension DataContractManagerFireBase {
    
    static func tankRegulators(dict pDict :Dictionary<String,Dictionary<String,Any>>) -> Array<TankRegulator>? {
        var aReturnVal :Array<TankRegulator>? = Array<TankRegulator>()
        
        for aTankRegulatorDict in pDict.values {
            if let aTankRegulator = self.tankRegulator(dict: aTankRegulatorDict) {
                aReturnVal!.append(aTankRegulator)
            }
        }
        if aReturnVal!.count <= 0 {
            aReturnVal = nil
        }
        
        return aReturnVal
    }
    
    
    static func tankRegulator(dict pDict :Dictionary<String,Any>) -> TankRegulator? {
        var aReturnVal :TankRegulator? = nil
        
        let aTankRegulator = TankRegulator()
        
        aTankRegulator.id = pDict["id"] as? String
        
        if let aValue = pDict["name"] as? String {
            aTankRegulator.title = aValue.capitalized
        }
        
        if let aValue = pDict["tankCount"] as? Int {
            aTankRegulator.tankCount = aValue
        }
        
        if let aValue = pDict["autoModeActivated"] as? Bool {
            aTankRegulator.isAutoModeActivated = aValue
        }
        
        if let aValue = pDict["motorState"] as? Bool {
            aTankRegulator.isMotorOn = aValue
        }
        
        if let aValue = pDict["lowerTankFillPercentage1"] as? Int {
            aTankRegulator.lowerTankFillPercent = aValue
        }
        
        if let aValue = pDict["upperTankFillPercentage1"] as? Int {
            aTankRegulator.upperTankFillPercent = aValue
        }
        
        if let aValue = pDict["online"] as? Bool {
            aTankRegulator.isOnline = aValue
        }
        
        aReturnVal = aTankRegulator
        
        return aReturnVal
    }

}


// MARK:- Rule

extension DataContractManagerFireBase {
    
    static func rules(dict pDict :Dictionary<String,Dictionary<String,Any>>) -> Array<Rule>? {
        var aReturnVal :Array<Rule>? = Array<Rule>()
        
        for aRuleDict in pDict.values {
            aReturnVal!.append(self.rule(dict: aRuleDict))
        }
        if aReturnVal!.count <= 0 {
            aReturnVal = nil
        }
        
        return aReturnVal
    }
    
    static func rule(dict pDict :Dictionary<String,Any>) -> Rule {
        let aReturnVal :Rule = Rule()
        
        aReturnVal.id = pDict["ruleId"] as? String
        
        if let aTitle = pDict["ruleName"] as? String {
            aReturnVal.title = aTitle.capitalized
        }
        
        if let aRuleState = pDict["state"] as? Bool {
            aReturnVal.isOn = aRuleState
        }
        
        return aReturnVal
    }
    
}

