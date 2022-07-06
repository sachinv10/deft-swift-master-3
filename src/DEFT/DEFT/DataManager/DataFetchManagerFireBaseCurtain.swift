//
//  DataFetchManagerFireBaseCurtain.swift
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
    
    func curtain(withId pId :String) -> Curtain? {
        var aReturnVal :Curtain? = nil
        
        // Fetch curtain details
        if pId.hasPrefix("I") == true || pId.hasPrefix("M") == true {
            let aDispatchSemaphore = DispatchSemaphore(value: 0)
            self.database
                .child("wifinityDevices")
                .child(Auth.auth().currentUser!.uid)
                .child(pId)
                .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                    if let aResult = pDataSnapshot.value as? Dictionary<String, Dictionary<String, Any>>
                    , let aCurtain = DataContractManagerFireBase.curtain(dict: aResult) {
                        aReturnVal = aCurtain
                    } else if let aResult = pDataSnapshot.value as? Dictionary<String, Any>
                    , let aCurtain = DataContractManagerFireBase.curtain(dict: aResult) {
                        aReturnVal = aCurtain
                    }
                    aDispatchSemaphore.signal()
                }
            _ = aDispatchSemaphore.wait(timeout: .distantFuture)
        } else {
            let aDispatchSemaphore = DispatchSemaphore(value: 0)
            self.database
                .child("MqttCurtain")
                .child(Auth.auth().currentUser!.uid)
                .child("curtainDetails")
                .child(pId)
                .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                    if let aResult = pDataSnapshot.value as? Dictionary<String, Any>
                       , let aCurtain = DataContractManagerFireBase.curtain(dict: aResult) {
                        aReturnVal = aCurtain
                    }
                    aDispatchSemaphore.signal()
                }
            _ = aDispatchSemaphore.wait(timeout: .distantFuture)
        }
        
        return aReturnVal
    }
    
    func searchCurtain(completion pCompletion: @escaping (Error?, Array<Curtain>?) -> Void, room pRoom :Room?) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aCurtainArray :Array<Curtain>? = Array<Curtain>()
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Fetch frequently operated curtains - DeftDevices
                let aCurtainDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("MqttCurtain")
                    .child(Auth.auth().currentUser!.uid)
                    .child("curtainDetails")
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        self.log(dataSnapshot: pDataSnapshot)
                        // Fetch objects
                        var aDeftCurtainArray :Array<Curtain>?
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Dictionary<String,Any>> {
                            aDeftCurtainArray = DataContractManagerFireBase.curtains(dict: aDict)
                        } else if let anArray = pDataSnapshot.value as? Array<Dictionary<String,Any>> {
                            aDeftCurtainArray = DataContractManagerFireBase.curtains(array: anArray)
                        }
                        // Filter based on room
                        if pRoom != nil {
                            aDeftCurtainArray = aDeftCurtainArray?.filter({ (pCurtain) -> Bool in
                                return pCurtain.roomId == pRoom?.id
                            })
                        }
                        // Assign hardware generation manually
                        aDeftCurtainArray?.forEach({ (pCurtain) in
                            pCurtain.hardwareGeneration = Device.HardwareGeneration.deft
                        })
                        // Add to total array
                        if let aValue = aDeftCurtainArray {
                            aCurtainArray?.append(contentsOf: aValue)
                        }
                        aCurtainDispatchSemaphore.signal()
                    }
                _ = aCurtainDispatchSemaphore.wait(timeout: .distantFuture)
                
                // Fetch frequently operated curtains - WifinityDevices
                if let aRoomId = pRoom?.id {
                    let aCurtainFilter = Auth.auth().currentUser!.uid + "_" + aRoomId + "_curtain"
                    
                    let aCurtainDispatchSemaphore = DispatchSemaphore(value: 0)
                    self.database
                        .child("wifinityDevices")
                        .child(Auth.auth().currentUser!.uid)
                        .queryOrdered(byChild: "filter")
                        .queryEqual(toValue: aCurtainFilter)
                        .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                            self.log(dataSnapshot: pDataSnapshot)
                            // Fetch objects
                            var aWifinityCurtainArray :Array<Curtain>?
                            if let aDict = pDataSnapshot.value as? Dictionary<String,Dictionary<String,Any>> {
                                aWifinityCurtainArray = DataContractManagerFireBase.curtains(dict: aDict)
                            } else if let anArray = pDataSnapshot.value as? Array<Dictionary<String,Any>> {
                                aWifinityCurtainArray = DataContractManagerFireBase.curtains(array: anArray)
                            }
                            // Filter based on room
                            if pRoom != nil {
                                aWifinityCurtainArray = aWifinityCurtainArray?.filter({ (pCurtain) -> Bool in
                                    return pCurtain.roomId == pRoom?.id
                                })
                            }
                            // Assign hardware generation manually
                            aWifinityCurtainArray?.forEach({ (pCurtain) in
                                pCurtain.hardwareGeneration = Device.HardwareGeneration.wifinity
                            })
                            // Add to total array
                            if let aValue = aWifinityCurtainArray {
                                aCurtainArray?.append(contentsOf: aValue)
                            }
                            aCurtainDispatchSemaphore.signal()
                        }
                    _ = aCurtainDispatchSemaphore.wait(timeout: .distantFuture)
                }
                
                // Sort curtains
                aCurtainArray?.sort { (pLhs, pRhs) -> Bool in
                    return (pLhs.title?.lowercased() ?? "") < (pRhs.title?.lowercased() ?? "")
                }
                if (aCurtainArray?.count ?? 0) <= 0 {
                    aCurtainArray = nil
                }
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, aCurtainArray)
            }
        }
        
    }
    
    
    func updateCurtainMotionState(completion pCompletion: @escaping (Error?) -> Void, curtain pCurtain :Curtain, motionState pMotionState :Curtain.MotionState) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Send message and reset it
                var aMessageValue = ""
                if pCurtain.hardwareGeneration == Device.HardwareGeneration.deft {
                    aMessageValue += "M012"
                    aMessageValue += String(format: "%@", pCurtain.id!)
                    aMessageValue += String(format: "%d", pMotionState.rawValue)
                    aMessageValue += "0F"
                } else {
                    aMessageValue += "M012"
                    aMessageValue += String(format: "%02d", pMotionState.rawValue)
                    aMessageValue += "0F"
                }
                anError = self.sendMessage(aMessageValue, entity: pCurtain)
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
    
    
    func updateCurtainDimmableValue(completion pCompletion: @escaping (Error?) -> Void, curtain pCurtain :Curtain, dimValue pDimValue :Int) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Send message and reset it
                var aMessageValue = ""
                aMessageValue += "M012"
                aMessageValue += String(format: "%@", pCurtain.id!)
                aMessageValue += String(format: "%d", pDimValue)
                aMessageValue += "0F"
                anError = self.sendMessage(aMessageValue, entity: pCurtain)
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
