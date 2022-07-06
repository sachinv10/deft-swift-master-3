//
//  DataFetchManagerFireBaseMood.swift
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
    
    func saveMood(completion pCompletion: @escaping (Error?, Mood?) -> Void, mood pMood :Mood) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                
                // Perform prerequisits
                if (pMood.uuid?.count ?? 0) <= 0 {
                    pMood.uuid = UtilityManager.randomUuid()
                }
                if let aRoom = pMood.room {
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
                                let aMoodDispatchSemaphore = DispatchSemaphore(value: 0)
                                self.database
                                    .child("ApplianceDetails")
                                    .child(Auth.auth().currentUser!.uid)
                                    .child(anApplianceKey)
                                    .child("uuid")
                                    .setValue(aUuid, withCompletionBlock: { (pError, pDatabaseReference) in
                                        anAppliance.uuid = aUuid
                                        aMoodDispatchSemaphore.signal()
                                    })
                                _ = aMoodDispatchSemaphore.wait(timeout: .distantFuture)
                            }
                            // END -- Crete and save UUID if not exist.
                        }
                    }
                }
                
                // Create mood dict
                let aMoodDict = DataContractManagerFireBase.moodDict(mood: pMood)
                
                // Save mood
                let aMoodDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("moodDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .child(pMood.uuid!)
                    .setValue(aMoodDict, withCompletionBlock: { (pError, pDatabaseReference) in
                        anError = pError
                        aMoodDispatchSemaphore.signal()
                    })
                _ = aMoodDispatchSemaphore.wait(timeout: .distantFuture)
                
                // Create mood device dict
                if let aRoom = pMood.room {
                    let aMoodComponentDict = DataContractManagerFireBase.moodComponentDict(room: aRoom)
                    
                    // Save mood devices
                    let aMoodDeviceDispatchSemaphore = DispatchSemaphore(value: 0)
                    self.database
                        .child("moodDeviceDetails")
                        .child(Auth.auth().currentUser!.uid)
                        .child(pMood.uuid!)
                        .setValue(aMoodComponentDict, withCompletionBlock: { (pError, pDatabaseReference) in
                            anError = pError
                            aMoodDeviceDispatchSemaphore.signal()
                        })
                    _ = aMoodDeviceDispatchSemaphore.wait(timeout: .distantFuture)
                }
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, pMood)
            }
        }
        
    }
    
    
    func searchMood(completion pCompletion: @escaping (Error?, Array<Mood>?) -> Void, room pRoom :Room?) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aMoodArray :Array<Mood>? = Array<Mood>()
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Fetch DEFT moods
                let aMoodDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("moodDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        self.log(dataSnapshot: pDataSnapshot)
                        
                        var aDeftMoodArray :Array<Mood>?
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Dictionary<String,Any>> {
                            aDeftMoodArray = DataContractManagerFireBase.moods(dict: aDict)
                        }
                        if pRoom != nil {
                            aDeftMoodArray = aDeftMoodArray?.filter({ (pMood) -> Bool in
                                return pMood.room?.id == pRoom?.id
                            })
                        }
                        
                        // Sort moods
                        aDeftMoodArray?.sort { (pLhs, pRhs) -> Bool in
                            return (pLhs.title?.lowercased() ?? "") < (pRhs.title?.lowercased() ?? "")
                        }
                        
                        if aDeftMoodArray != nil {
                            aMoodArray?.append(contentsOf: aDeftMoodArray!)
                        }
                        
                        aMoodDispatchSemaphore.signal()
                    }
                _ = aMoodDispatchSemaphore.wait(timeout: .distantFuture)
                
                if (aMoodArray?.count ?? 0) <= 0 {
                    aMoodArray = nil
                }
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, aMoodArray)
            }
        }
        
    }
    
    
    func moodDetails(completion pCompletion: @escaping (Error?, Mood?) -> Void, mood pMood :Mood) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aMood :Mood?
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                if (pMood.uuid?.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Mood UUID can not be empty."])
                }
                
                // Fetch mood details
                let aRemoteDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("moodDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .child(pMood.uuid!)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        self.log(dataSnapshot: pDataSnapshot)
                        
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Any> {
                            aMood = DataContractManagerFireBase.mood(dict: aDict)
                        }
                        aRemoteDispatchSemaphore.signal()
                    }
                _ = aRemoteDispatchSemaphore.wait(timeout: .distantFuture)
                
                // Fetch mood device details
                let aMoodDeviceDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("moodDeviceDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .child(pMood.uuid!)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        self.log(dataSnapshot: pDataSnapshot)
                        
                        if let aValue = pDataSnapshot.value as? Dictionary<String,Any> {
                            aMood?.room = DataContractManagerFireBase.moodRoom(dict: aValue)
                        }
                        aMoodDeviceDispatchSemaphore.signal()
                    }
                _ = aMoodDeviceDispatchSemaphore.wait(timeout: .distantFuture)
                
                if let aRoom = aMood?.room {
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
                    var aRemoteArray = Array<Remote>()
                    if let aValue = aRoom.remotes {
                        aRemoteArray.append(contentsOf: aValue)
                    }
                    if let aValue = aRoom.moodOnRemotes {
                        aRemoteArray.append(contentsOf: aValue)
                    }
                    if let aValue = aRoom.moodOffRemotes {
                        aRemoteArray.append(contentsOf: aValue)
                    }
                    for aRemote in aRemoteArray {
                        if let aFetchedRemote = self.remote(withId: aRemote.id!) {
                            aRemote.title = aFetchedRemote.title
                            aRemote.irId = aFetchedRemote.irId
                            
                            if let aFetchedRemoteKeyArray = aFetchedRemote.keys
                               , let aMoodRemoteKeyArray = aRemote.selectedRemoteKeys {
                                for aFetchedRemoteKey in aFetchedRemoteKeyArray {
                                    for aMoodRemoteKey in aMoodRemoteKeyArray {
                                        if aMoodRemoteKey.id == aFetchedRemoteKey.id {
                                            aMoodRemoteKey.title = aFetchedRemoteKey.title
                                            aMoodRemoteKey.tag = aFetchedRemoteKey.tag
                                        }
                                    }
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
                pCompletion(anError, aMood)
            }
        }
        
    }
    
    
    func updateMoodPowerState(completion pCompletion: @escaping (Error?) -> Void, mood pMood :Mood, powerState pPowerState :Bool) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                // Activate mood
                let aParameterDict :[String: Any?] = [
                    "uid" : Auth.auth().currentUser!.uid
                    , "roomId" : pMood.room?.id
                    , "moodId" : pMood.uuid
                    , "state" : pPowerState
                ]
                
                guard let aUrl = URL(string: ConfigurationManager.shared.moodActivateUrlString) else {
                    throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Invalid activate mood URL."])
                }
                
                var aUrlRequest = URLRequest(url: aUrl)
                aUrlRequest.httpMethod = "POST"
                aUrlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                aUrlRequest.httpBody = try JSONSerialization.data(withJSONObject: aParameterDict, options: [])
                
                let aDispatchSemaphore = DispatchSemaphore(value: 0)
                let aDataTask = URLSession.shared.dataTask(with: aUrlRequest) { (pData, pResponse, pError) in
                    if let aData = pData
                    , let aDict = try? JSONSerialization.jsonObject(with: aData, options: []) as? Dictionary<String,Any> {
                        if (pPowerState == true && aDict["status"] as? String == "Activate")
                        || (pPowerState == false && aDict["status"] as? String == "Deactivate") {
                            anError = nil
                        } else {
                            anError = NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Mood activation not updated by server."])
                        }
                    } else {
                        anError = pError ?? NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Server error."])
                    }
                    aDispatchSemaphore.signal()
                }
                aDataTask.resume()
                _ = aDispatchSemaphore.wait(timeout: .distantFuture)
                
                if anError != nil {
                    throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Mood activation request error. " + anError!.localizedDescription])
                }
                
                // Save mood state
                let aMoodStateDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("moodDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .child(pMood.uuid!)
                    .child("state")
                    .setValue(pPowerState, withCompletionBlock: { (pError, pDatabaseReference) in
                        anError = pError
                        aMoodStateDispatchSemaphore.signal()
                    })
                _ = aMoodStateDispatchSemaphore.wait(timeout: .distantFuture)
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError)
            }
        }
        
    }
    
    
    func deleteMood(completion pCompletion: @escaping (Error?, Mood?) -> Void, mood pMood :Mood) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                if (pMood.uuid?.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Mood uuid is not available."])
                }
                
                // Delete mood from moodDetails node
                let aMoodDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("moodDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .child(pMood.uuid!)
                    .removeValue(completionBlock: { (pError, pDatabaseReference) in
                        anError = pError
                        aMoodDispatchSemaphore.signal()
                    })
                _ = aMoodDispatchSemaphore.wait(timeout: .distantFuture)
                
                // Delete mood from moodDeviceDetails
                let aMoodDeviceDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("moodDeviceDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .child(pMood.uuid!)
                    .removeValue(completionBlock: { (pError, pDatabaseReference) in
                        anError = pError
                        aMoodDeviceDispatchSemaphore.signal()
                    })
                _ = aMoodDeviceDispatchSemaphore.wait(timeout: .distantFuture)
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, pMood)
            }
        }
        
    }

}
