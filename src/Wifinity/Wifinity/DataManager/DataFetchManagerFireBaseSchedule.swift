//
//  DataFetchManagerFireBaseSchedule.swift
//  DEFT
//
//  Created by Rupendra on 08/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase


extension DataFetchManagerFireBase {
    
    func searchSchedule(completion pCompletion: @escaping (Error?, Array<Schedule>?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aScheduleArray :Array<Schedule>? = Array<Schedule>()
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Fetch DEFT schedules
                let aScheduleDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("schedulerDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        
                        var aDeftScheduleArray :Array<Schedule>?
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Dictionary<String,Any>> {
                            aDeftScheduleArray = DataContractManagerFireBase.schedules(dict: aDict)
                        }
                        
                        // Sort frequently operated appliances
                        aDeftScheduleArray?.sort { (pLhs, pRhs) -> Bool in
                            return (pLhs.title?.lowercased() ?? "") < (pRhs.title?.lowercased() ?? "")
                        }
                        
                        if aDeftScheduleArray != nil {
                            aScheduleArray?.append(contentsOf: aDeftScheduleArray!)
                        }
                        
                        aScheduleDispatchSemaphore.signal()
                    }
                _ = aScheduleDispatchSemaphore.wait(timeout: .distantFuture)
                
                if (aScheduleArray?.count ?? 0) <= 0 {
                    aScheduleArray = nil
                }
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, aScheduleArray)
            }
        }
        
    }
    
    
    func scheduleDetails(completion pCompletion: @escaping (Error?, Schedule?) -> Void, schedule pSchedule :Schedule) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aSchedule :Schedule?
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                if (pSchedule.id?.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Schedule ID can not be empty."])
                }
                
                // Fetch schedule settings
                let aRemoteDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("schedulerDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .child(pSchedule.id!)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Any> {
                            aSchedule = DataContractManagerFireBase.schedule(dict: aDict)
                        }
                        aRemoteDispatchSemaphore.signal()
                    }
                _ = aRemoteDispatchSemaphore.wait(timeout: .distantFuture)
                
                
                // Fetch schedulerDeviceDetails
                var aRoomArray = Array<Room>()
                
                let aRoomDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("schedulerDeviceDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .child(aSchedule!.id!)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        if let aValue = pDataSnapshot.value as? Array<Dictionary<String,Any>>
                           , let aScheduleRoomArray = DataContractManagerFireBase.scheduleRooms(array: aValue) {
                            aRoomArray.append(contentsOf: aScheduleRoomArray)
                        }
                        aRoomDispatchSemaphore.signal()
                    }
                _ = aRoomDispatchSemaphore.wait(timeout: .distantFuture)
                
                if aRoomArray.count > 0 {
                    for aRoom in aRoomArray {
                        // Fetch room name
                        if let aRoomId = aRoom.id {
                            let aTitleDispatchSemaphore = DispatchSemaphore(value: 0)
                            self.database
                                .child("rooms")
                                .child(Auth.auth().currentUser!.uid)
                                .child(aRoomId)
                                .child("roomName")
                                .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                                    if let aValue = pDataSnapshot.value as? String {
                                        aRoom.title = aValue
                                    }
                                    aTitleDispatchSemaphore.signal()
                                }
                            _ = aTitleDispatchSemaphore.wait(timeout: .distantFuture)
                        }
                        
                        // Fetch appliance name
                        if let anApplianceArray = aRoom.appliances {
                            for anAppliance in anApplianceArray {
                                if let aControllerId = anAppliance.hardwareId {
                                    let aTitleDispatchSemaphore = DispatchSemaphore(value: 0)
                                    self.database
                                        .child("applianceDetails")
                                        .child(aControllerId)
                                        .child(anAppliance.id!)
                                        .child("applianceName")
                                        .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                                            if let aValue = pDataSnapshot.value as? String {
                                                anAppliance.title = aValue
                                            }
                                            aTitleDispatchSemaphore.signal()
                                        }
                                    _ = aTitleDispatchSemaphore.wait(timeout: .distantFuture)
                                }
                            }
                        }
                        
                        // Fetch curtain name
                        if let aCurtainArray = aRoom.curtains {
                            for aCurtain in aCurtainArray {
                                if let aControllerId = aCurtain.id {
                                    let aTitleDispatchSemaphore = DispatchSemaphore(value: 0)
                                    self.database
                                        .child("devices")
                                        .child(aControllerId)
                                        .child("name")
                                        .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                                            if let aValue = pDataSnapshot.value as? String {
                                                aCurtain.title = aValue
                                            }
                                            aTitleDispatchSemaphore.signal()
                                        }
                                    _ = aTitleDispatchSemaphore.wait(timeout: .distantFuture)
                                }
                            }
                        }
                        
                        // Fetch remote name
                        if let aRemoteArray = aRoom.remotes {
                            for aRemote in aRemoteArray {
                                if let aControllerId = aRemote.hardwareId, let aRemoteId = aRemote.id {
                                    let aTitleDispatchSemaphore = DispatchSemaphore(value: 0)
                                    self.database
                                        .child("remoteDetails1")
                                        .child(aControllerId)
                                        .child(aRemoteId)
                                        .child("remoteName")
                                        .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                                            if let aValue = pDataSnapshot.value as? String {
                                                aRemote.title = aValue
                                            }
                                            aTitleDispatchSemaphore.signal()
                                        }
                                    _ = aTitleDispatchSemaphore.wait(timeout: .distantFuture)
                                }
                            }
                        }
                        
                        // Fetch sensor name
                        if let aSensorArray = aRoom.sensors {
                            for aSensor in aSensorArray {
                                if let aControllerId = aSensor.id {
                                    let aTitleDispatchSemaphore = DispatchSemaphore(value: 0)
                                    self.database
                                        .child("devices")
                                        .child(aControllerId)
                                        .child("name")
                                        .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                                            if let aValue = pDataSnapshot.value as? String {
                                                aSensor.title = aValue
                                            }
                                            aTitleDispatchSemaphore.signal()
                                        }
                                    _ = aTitleDispatchSemaphore.wait(timeout: .distantFuture)
                                }
                            }
                        }
                    }
                    
                    aSchedule?.rooms = aRoomArray
                }
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, aSchedule)
            }
        }
        
    }
    
    
    func updateSchedulePowerState(completion pCompletion: @escaping (Error?) -> Void, schedule pSchedule :Schedule, powerState pPowerState :Bool) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Update activated flag
                let anActivatedFlagDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("schedulerDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .child(pSchedule.id!)
                    .child("activated")
                    .setValue(pSchedule.isOn, withCompletionBlock: { (pError, pDatabaseReference) in
                        anError = pError
                        anActivatedFlagDispatchSemaphore.signal()
                    })
                _ = anActivatedFlagDispatchSemaphore.wait(timeout: .distantFuture)
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError)
            }
        }
        
    }
    
    
    func saveSchedule(completion pCompletion: @escaping (Error?, Schedule?) -> Void, schedule pSchedule :Schedule) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                let aKey = pSchedule.id ?? self.getNextKey(dataBasePath: "schedulerDetails/" + Auth.auth().currentUser!.uid, length: 2)
                
                // Save schedule
                let aScheduleDict :[String:Any?] = [
                    "id": aKey
                    , "name": pSchedule.title
                    , "time": pSchedule.time
                    , "activated": false
                    , "applianceCount": pSchedule.calculatedApplianceCount
                    , "curtainCount": pSchedule.calculatedCurtainCount
                    , "remoteCount": pSchedule.calculatedRemoteCount
                    , "sensorCount": pSchedule.calculatedSensorCount
                    , "repeating": (pSchedule.repetitions?.count ?? 0) > 0 ? true : false
                    , "days": DataContractManagerFireBase.scheduleDayDatabaseValue(schedule: pSchedule)
                ]
                
                let aScheduleDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("schedulerDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .child(aKey)
                    .setValue(aScheduleDict, withCompletionBlock: { (pError, pDatabaseReference) in
                        anError = pError
                        pSchedule.id = aKey
                        aScheduleDispatchSemaphore.signal()
                    })
                _ = aScheduleDispatchSemaphore.wait(timeout: .distantFuture)
                
                // Save schedule components
                var aScheduleComponentDictArray = Array<[String:Any?]>()
                if let aRoomArray = pSchedule.rooms {
                    for aRoom in aRoomArray {
                        if let anApplianceArray = aRoom.appliances {
                            for anAppliance in anApplianceArray {
                                let aScheduleComponentDict :[String:Any?] = [
                                    "controllerId": anAppliance.hardwareId
                                    , "command": anAppliance.scheduleCommand
                                    , "roomId": aRoom.id
                                    , "applianceId": anAppliance.id
                                    , "dimValue": anAppliance.scheduleDimmableValue
                                    , "state": anAppliance.scheduleState
                                ]
                                aScheduleComponentDictArray.append(aScheduleComponentDict)
                            }
                        }
                        if let aCurtainArray = aRoom.curtains {
                            for aCurtain in aCurtainArray {
                                let aScheduleComponentDict :[String:Any?] = [
                                    "controllerId": aCurtain.id
                                    , "command": aCurtain.scheduleCommand
                                    , "roomId": aRoom.id
                                    , "level": aCurtain.scheduleLevel
                                ]
                                aScheduleComponentDictArray.append(aScheduleComponentDict)
                            }
                        }
                        if let aRemoteArray = aRoom.remotes {
                            for aRemote in aRemoteArray {
                                if let aRemoteKeyArray = aRemote.selectedRemoteKeys {
                                    for aRemoteKey in aRemoteKeyArray {
                                        let aScheduleComponentDict :[String:Any?] = [
                                            "controllerId": aRemote.hardwareId
                                            , "remoteId": aRemote.id
                                            , "keyId": aRemoteKey.id
                                            , "command": aRemoteKey.command
                                            , "roomId": aRoom.id
                                        ]
                                        aScheduleComponentDictArray.append(aScheduleComponentDict)
                                    }
                                }
                            }
                        }
                        if let aSensorArray = aRoom.sensors {
                            for aSensor in aSensorArray {
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
                                
                                let aScheduleComponentDict :[String:Any?] = [
                                    "controllerId": aSensor.id
                                    , "command": aSensor.scheduleCommands
                                    , "roomId": aRoom.id
                                    , "lightActivated": anIsMotionLightActivated
                                    , "lightActivatedSelected": anIsMotionLightActivatedSelected
                                    , "relay1Activated": false
                                    , "relay2Activated": false
                                    , "sensorActivated": anIsSensorActivated
                                    , "sensorActivatedSelected": anIsSensorActivatedSelected
                                    , "sensorProperty": true
                                    , "sensorRelayProperty": false
                                    , "sirenActivated": anIsSirenActivated
                                    , "sirenActivatedSelected": anIsSirenActivatedSelected
                                ]
                                aScheduleComponentDictArray.append(aScheduleComponentDict)
                            }
                        }
                    }
                }
                
                let aScheduleComponentDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("schedulerDeviceDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .child(aKey)
                    .setValue(aScheduleComponentDictArray, withCompletionBlock: { (pError, pDatabaseReference) in
                        anError = pError
                        pSchedule.id = aKey
                        aScheduleComponentDispatchSemaphore.signal()
                    })
                _ = aScheduleComponentDispatchSemaphore.wait(timeout: .distantFuture)
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, pSchedule)
            }
        }
        
    }
    
    
    func deleteSchedule(completion pCompletion: @escaping (Error?, Schedule?) -> Void, schedule pSchedule :Schedule) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                if (pSchedule.id?.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Schedule id is not available."])
                }
                
                // Delete schedule from schedulerDetails node
                let aScheduleDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("schedulerDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .child(pSchedule.id!)
                    .removeValue(completionBlock: { (pError, pDatabaseReference) in
                        anError = pError
                        aScheduleDispatchSemaphore.signal()
                    })
                _ = aScheduleDispatchSemaphore.wait(timeout: .distantFuture)
                
                // Delete schedule from schedulerDeviceDetails
                let aScheduleDeviceDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("schedulerDeviceDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .child(pSchedule.id!)
                    .removeValue(completionBlock: { (pError, pDatabaseReference) in
                        anError = pError
                        aScheduleDeviceDispatchSemaphore.signal()
                    })
                _ = aScheduleDeviceDispatchSemaphore.wait(timeout: .distantFuture)
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, pSchedule)
            }
        }
        
    }

}
