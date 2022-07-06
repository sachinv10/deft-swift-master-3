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
                        self.log(dataSnapshot: pDataSnapshot)
                        
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
                if (pSchedule.uuid?.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Schedule UUID can not be empty."])
                }
                
                // Fetch schedule details
                let aRemoteDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("schedulerDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .child(pSchedule.uuid!)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        self.log(dataSnapshot: pDataSnapshot)
                        
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Any> {
                            aSchedule = DataContractManagerFireBase.schedule(dict: aDict)
                        }
                        aRemoteDispatchSemaphore.signal()
                    }
                _ = aRemoteDispatchSemaphore.wait(timeout: .distantFuture)
                
                // Fetch schedule device details
                let aScheduleDeviceDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("schedulerDeviceDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .child(pSchedule.uuid!)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        self.log(dataSnapshot: pDataSnapshot)
                        
                        if let aValue = pDataSnapshot.value as? Array<Dictionary<String,Any>> {
                            aSchedule?.rooms = DataContractManagerFireBase.scheduleRooms(array: aValue)
                        } else if let aValue = pDataSnapshot.value as? Dictionary<String,Any> {
                            aSchedule?.rooms = DataContractManagerFireBase.scheduleRooms(dict: aValue)
                        }
                        aScheduleDeviceDispatchSemaphore.signal()
                    }
                _ = aScheduleDeviceDispatchSemaphore.wait(timeout: .distantFuture)
                
                if let aRoomArray = aSchedule?.rooms {
                    for aRoom in aRoomArray {
                        
                        // Fetch room details
                        let aDispatchSemaphore = DispatchSemaphore(value: 0)
                        self.database
                            .child("roomDetails")
                            .child(Auth.auth().currentUser!.uid)
                            .child(aRoom.id!)
                            .child("roomName")
                            .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                                if let aValue = pDataSnapshot.value as? String {
                                    aRoom.title = aValue.capitalized
                                }
                                aDispatchSemaphore.signal()
                            }
                        _ = aDispatchSemaphore.wait(timeout: .distantFuture)
                        
                        // Fetch appliance details
                        if let anApplianceArray = aRoom.appliances {
                            for anAppliance in anApplianceArray {
                                if let aFetchedAppliance = self.appliance(withUuid: anAppliance.uuid!) {
                                    anAppliance.id = aFetchedAppliance.id
                                    anAppliance.roomId = aFetchedAppliance.roomId
                                    anAppliance.slaveId = aFetchedAppliance.slaveId
                                    anAppliance.hardwareId = aFetchedAppliance.hardwareId
                                    anAppliance.title = aFetchedAppliance.title
                                }
                            }
                        }
                        
                        // Fetch curtain details
                        if let aCurtainArray = aRoom.curtains {
                            for aCurtain in aCurtainArray {
                                if let aFetchedCurtain = self.curtain(withId: aCurtain.id!) {
                                    aCurtain.title = aFetchedCurtain.title
                                }
                            }
                        }
                        
                        // Fetch remote details
                        if let aRemoteArray = aRoom.remotes {
                            for aRemote in aRemoteArray {
                                if let aFetchedRemote = self.remote(withId: aRemote.id!) {
                                    aRemote.title = aFetchedRemote.title
                                    aRemote.irId = aFetchedRemote.irId
                                    
                                    if let aFetchedRemoteKeyArray = aFetchedRemote.keys
                                       , let aScheduleRemoteKeyArray = aRemote.selectedRemoteKeys {
                                        for aFetchedRemoteKey in aFetchedRemoteKeyArray {
                                            for aScheduleRemoteKey in aScheduleRemoteKeyArray {
                                                if aScheduleRemoteKey.id == aFetchedRemoteKey.id {
                                                    aScheduleRemoteKey.title = aFetchedRemoteKey.title
                                                    aScheduleRemoteKey.tag = aFetchedRemoteKey.tag
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Fetch sensor details
                        if let aSensorArray = aRoom.sensors {
                            for aSensor in aSensorArray {
                                if let aFetchedSensor = self.sensor(withId: aSensor.id!) {
                                    aSensor.title = aFetchedSensor.title
                                }
                            }
                        }
                    }
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
    
    
    func saveSchedule(completion pCompletion: @escaping (Error?, Schedule?) -> Void, schedule pSchedule :Schedule) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                
                // Perform prerequisits
                if (pSchedule.uuid?.count ?? 0) <= 0 {
                    pSchedule.uuid = UtilityManager.randomUuid()
                }
                if let aRoomArray = pSchedule.rooms {
                    for aRoom in aRoomArray {
                        if let anApplianceArray = aRoom.appliances {
                            for anAppliance in anApplianceArray {
                                // BEGIN -- Crete and save UUID if not exist.
                                if anAppliance.uuid == nil {
                                    let aUuid = UtilityManager.randomUuid()
                                    var anApplianceKey = ""
                                    if let aKey = anAppliance.hardwareId {
                                        anApplianceKey = aKey + "_" + anAppliance.id!
                                    } else {
                                        anApplianceKey = String(format: "%@%@%@", anAppliance.roomId!, anAppliance.slaveId!, anAppliance.id!)
                                    }
                                    let aScheduleDispatchSemaphore = DispatchSemaphore(value: 0)
                                    self.database
                                        .child("ApplianceDetails")
                                        .child(Auth.auth().currentUser!.uid)
                                        .child(anApplianceKey)
                                        .child("uuid")
                                        .setValue(aUuid, withCompletionBlock: { (pError, pDatabaseReference) in
                                            anAppliance.uuid = aUuid
                                            aScheduleDispatchSemaphore.signal()
                                        })
                                    _ = aScheduleDispatchSemaphore.wait(timeout: .distantFuture)
                                }
                                // END -- Crete and save UUID if not exist.
                            }
                        }
                    }
                }
                
                // Create schedule dict
                let aScheduleDict = DataContractManagerFireBase.scheduleDict(schedule: pSchedule)
                
                // Save schedule
                let aScheduleDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("schedulerDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .child(pSchedule.uuid!)
                    .setValue(aScheduleDict, withCompletionBlock: { (pError, pDatabaseReference) in
                        anError = pError
                        aScheduleDispatchSemaphore.signal()
                    })
                _ = aScheduleDispatchSemaphore.wait(timeout: .distantFuture)
                
                // Create schedule device dict
                if let aRoomArray = pSchedule.rooms {
                    let aScheduleComponentDict = DataContractManagerFireBase.scheduleComponentDict(rooms: aRoomArray)
                    
                    // Save schedule devices
                    let aScheduleDeviceDispatchSemaphore = DispatchSemaphore(value: 0)
                    self.database
                        .child("schedulerDeviceDetails")
                        .child(Auth.auth().currentUser!.uid)
                        .child(pSchedule.uuid!)
                        .setValue(aScheduleComponentDict, withCompletionBlock: { (pError, pDatabaseReference) in
                            anError = pError
                            aScheduleDeviceDispatchSemaphore.signal()
                        })
                    _ = aScheduleDeviceDispatchSemaphore.wait(timeout: .distantFuture)
                }
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
                
                if (pSchedule.uuid?.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Schedule uuid is not available."])
                }
                
                // Delete schedule from scheduleDetails node
                let aScheduleDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("schedulerDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .child(pSchedule.uuid!)
                    .removeValue(completionBlock: { (pError, pDatabaseReference) in
                        anError = pError
                        aScheduleDispatchSemaphore.signal()
                    })
                _ = aScheduleDispatchSemaphore.wait(timeout: .distantFuture)
                
                // Delete schedule from scheduleDeviceDetails
                let aScheduleDeviceDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("schedulerDeviceDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .child(pSchedule.uuid!)
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
    
    
    func updateSchedulePowerState(completion pCompletion: @escaping (Error?) -> Void, schedule pSchedule :Schedule, powerState pPowerState :Bool) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Update schedule state
                let aScheduleDeviceDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("schedulerDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .child(pSchedule.uuid!)
                    .child("activated")
                    .setValue(pPowerState, withCompletionBlock: { (pError, pDatabaseReference) in
                        anError = pError
                        aScheduleDeviceDispatchSemaphore.signal()
                    })
                _ = aScheduleDeviceDispatchSemaphore.wait(timeout: .distantFuture)
                if anError != nil {
                    throw anError!
                }
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError)
            }
        }
        
    }

}
