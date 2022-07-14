//
//  DataFetchManagerFireBase.swift
//  DEFT
//
//  Created by Rupendra on 10/12/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import Firebase


class DataFetchManagerFireBase: NSObject {
    var requestCount :Int = 0
    
    
    override init() {
        if ((FirebaseApp.allApps?.count ?? 0) <= 0) {
            FirebaseApp.configure()
        }
        self.database = Database.database().reference()
        
        super.init()
    }
    
    let database :DatabaseReference
    
    
    var databaseValueChangedNotificationTimer :Timer?
    
    private func postDatabaseValueChangedNotificationName() {
        self.databaseValueChangedNotificationTimer?.invalidate()
        self.databaseValueChangedNotificationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: {_ in
            DispatchQueue.main.async {
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: DataFetchManager.databaseValueChangedNotificationName)))
            }
        })
    }
    
    func observeChangeEvents() {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            if let aDeviceIdArray = self.deviceIdsForLoggedInUser(roomId: nil) {
                for aDeviceId in aDeviceIdArray {
                    self.database
                        .child("applianceDetails")
                        .child(aDeviceId)
                        .observe(DataEventType.childAdded) {(pDataSnapshot) in
                            self.postDatabaseValueChangedNotificationName()
                        }
                    self.database
                        .child("applianceDetails")
                        .child(aDeviceId)
                        .observe(DataEventType.childChanged) {(pDataSnapshot) in
                            self.postDatabaseValueChangedNotificationName()
                        }
                    self.database
                        .child("applianceDetails")
                        .child(aDeviceId)
                        .observe(DataEventType.childRemoved) {(pDataSnapshot) in
                            self.postDatabaseValueChangedNotificationName()
                        }
                }
            }
            
            if let aUserId = Auth.auth().currentUser?.uid {
                self.database
                    .child("rooms")
                    .child(aUserId)
                    .observe(DataEventType.childAdded) {(pDataSnapshot) in
                        self.postDatabaseValueChangedNotificationName()
                    }
                
                self.database
                    .child("rooms")
                    .child(aUserId)
                    .observe(DataEventType.childChanged) {(pDataSnapshot) in
                        self.postDatabaseValueChangedNotificationName()
                    }
                
                self.database
                    .child("rooms")
                    .child(aUserId)
                    .observe(DataEventType.childRemoved) {(pDataSnapshot) in
                        self.postDatabaseValueChangedNotificationName()
                    }
            }
            
            if let aDeviceIdArray = self.deviceIdsForLoggedInUser(roomId: nil) {
                for aDeviceId in aDeviceIdArray {
                    self.database
                        .child("devices")
                        .child(aDeviceId)
                        .observe(DataEventType.childAdded) {(pDataSnapshot) in
                            self.postDatabaseValueChangedNotificationName()
                        }
                    self.database
                        .child("devices")
                        .child(aDeviceId)
                        .observe(DataEventType.childChanged) {(pDataSnapshot) in
                            self.postDatabaseValueChangedNotificationName()
                        }
                    self.database
                        .child("devices")
                        .child(aDeviceId)
                        .observe(DataEventType.childRemoved) {(pDataSnapshot) in
                            self.postDatabaseValueChangedNotificationName()
                        }
                }
            }
            
            if let aSensorIdArray = self.sensorIdsForLoggedInUser(roomId: nil) {
                for aSensorId in aSensorIdArray {
                    self.database
                        .child("devices")
                        .child(aSensorId)
                        .observe(DataEventType.childAdded) {(pDataSnapshot) in
                            self.postDatabaseValueChangedNotificationName()
                        }
                    self.database
                        .child("devices")
                        .child(aSensorId)
                        .observe(DataEventType.childChanged) {(pDataSnapshot) in
                            self.postDatabaseValueChangedNotificationName()
                        }
                    self.database
                        .child("devices")
                        .child(aSensorId)
                        .observe(DataEventType.childRemoved) {(pDataSnapshot) in
                            self.postDatabaseValueChangedNotificationName()
                        }
                    
                    self.database
                        .child("sensorSetting")
                        .child(aSensorId)
                        .observe(DataEventType.childAdded) {(pDataSnapshot) in
                            self.postDatabaseValueChangedNotificationName()
                        }
                    
                    self.database
                        .child("sensorSetting")
                        .child(aSensorId)
                        .observe(DataEventType.childChanged) {(pDataSnapshot) in
                            self.postDatabaseValueChangedNotificationName()
                        }
                    
                    self.database
                        .child("sensorSetting")
                        .child(aSensorId)
                        .observe(DataEventType.childRemoved) {(pDataSnapshot) in
                            self.postDatabaseValueChangedNotificationName()
                        }
                }
            }
            
            // Listen to remote updates
            if let aRemoteHardwareIdArray = self.remoteHardwareIdsForLoggedInUser(roomId: nil) {
                for aRemoteHardwareId in aRemoteHardwareIdArray {
                    self.database
                        .child("remoteDetails1")
                        .child(aRemoteHardwareId)
                        .observe(DataEventType.childAdded) {(pDataSnapshot) in
                            self.postDatabaseValueChangedNotificationName()
                        }
                    
                    self.database
                        .child("remoteDetails1")
                        .child(aRemoteHardwareId)
                        .observe(DataEventType.childChanged) {(pDataSnapshot) in
                            self.postDatabaseValueChangedNotificationName()
                        }
                    
                    self.database
                        .child("remoteDetails1")
                        .child(aRemoteHardwareId)
                        .observe(DataEventType.childRemoved) {(pDataSnapshot) in
                            self.postDatabaseValueChangedNotificationName()
                        }
                    
                    self.database
                        .child("remoteKey1")
                        .child(aRemoteHardwareId)
                        .observe(DataEventType.childAdded) {(pDataSnapshot) in
                            self.postDatabaseValueChangedNotificationName()
                        }
                    
                    self.database
                        .child("remoteKey1")
                        .child(aRemoteHardwareId)
                        .observe(DataEventType.childChanged) {(pDataSnapshot) in
                            self.postDatabaseValueChangedNotificationName()
                        }
                    
                    self.database
                        .child("remoteKey1")
                        .child(aRemoteHardwareId)
                        .observe(DataEventType.childRemoved) {(pDataSnapshot) in
                            self.postDatabaseValueChangedNotificationName()
                        }
                }
            }
            
            // Listen to schedule updates
            if let aUserId = Auth.auth().currentUser?.uid {
                self.database
                    .child("schedulerDetails")
                    .child(aUserId)
                    .observe(DataEventType.childAdded) {(pDataSnapshot) in
                        self.postDatabaseValueChangedNotificationName()
                    }
                
                self.database
                    .child("schedulerDetails")
                    .child(aUserId)
                    .observe(DataEventType.childChanged) {(pDataSnapshot) in
                        self.postDatabaseValueChangedNotificationName()
                    }
                
                self.database
                    .child("schedulerDetails")
                    .child(aUserId)
                    .observe(DataEventType.childRemoved) {(pDataSnapshot) in
                        self.postDatabaseValueChangedNotificationName()
                    }
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
            }
        }
    }
    
    
    func removeAllObservers() {
        self.database.removeAllObservers()
    }
    
    
    func getNextKey(dataBasePath pDataBasePath :String, length pLength :Int = 1) -> String {
        var aReturnVal :String = ""
        
        var aNextId = 0
        var aKeyLength = pLength
        let aDispatchSemaphore = DispatchSemaphore(value: 0)
        self.database
            .child(pDataBasePath)
            .queryOrderedByKey()
            .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                if let anArray = (pDataSnapshot.value as? Array<Any>) {
                    var anAvailableIndex :Int? = nil
                    for (anIndex, aDict) in anArray.enumerated() {
                        if aDict is NSNull {
                            anAvailableIndex = anIndex
                            break
                        }
                    }
                    if anAvailableIndex != nil {
                        aNextId = anAvailableIndex!
                    } else {
                        aNextId = anArray.count
                    }
                    aKeyLength = String(format: "%d", aNextId).count
                } else if let aKeyArray = (pDataSnapshot.value as? Dictionary<AnyHashable,Any>)?.keys {
                    var aLastKey :Int = -1
                    var aMaxKeyLength :Int = 1
                    for aKey in aKeyArray {
                        if let aKeyInt = aKey as? Int, aLastKey < aKeyInt {
                            aLastKey = aKeyInt
                            let aKeyLength = String(format: "%d", aLastKey).count
                            if aMaxKeyLength < aKeyLength {
                                aMaxKeyLength = aKeyLength
                            }
                        } else if let aKeyString = aKey as? String, let aKeyInt = Int(aKeyString), aLastKey < aKeyInt {
                            aLastKey = aKeyInt
                            if aMaxKeyLength < aKeyString.count {
                                aMaxKeyLength = aKeyString.count
                            }
                        }
                    }
                    aNextId = aLastKey + 1
                    aKeyLength = aMaxKeyLength
                }
                aDispatchSemaphore.signal()
            }
        _ = aDispatchSemaphore.wait(timeout: .distantFuture)
        
        let aNumberFormatter = NumberFormatter()
        aNumberFormatter.minimumIntegerDigits = aKeyLength
        if let aNextIdString = aNumberFormatter.string(from: NSNumber(value: aNextId)) {
            aReturnVal = aNextIdString
        }
        
        return aReturnVal
    }
    
    
    func checkInternetConnection(completion pCompletion: @escaping (Error?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aReturnValError :Error?
            
            do {
                // Check Internet Connection
                guard let aUrlComponents = URLComponents(string: ConfigurationManager.shared.rechabilityServerUrlString) else {
                    throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Invalid rechability server URL."])
                }
                
                guard let aUrl = aUrlComponents.url else {
                    throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Invalid rechability server URL."])
                }
                
                var aUrlRequest = URLRequest(url: aUrl)
                aUrlRequest.httpMethod = "GET"
                
                var aDataTaskError :Error? = nil
                let aDispatchSemaphore = DispatchSemaphore(value: 0)
                let aDataTask = URLSession.shared.dataTask(with: aUrlRequest) { (pData, pResponse, pError) in
                    aDataTaskError = pError
                    aDispatchSemaphore.signal()
                }
                aDataTask.resume()
                _ = aDispatchSemaphore.wait(timeout: .distantFuture)
                
                if aDataTaskError != nil {
                    throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Rechability server connection error. " + aDataTaskError!.localizedDescription])
                }
            } catch {
                aReturnValError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(aReturnValError)
            }
        }
        
    }
    
}



// MARK:- Commands

extension DataFetchManagerFireBase {
    
    func sendMessage(_ pMessage :String, entity pEntity :Any ) -> Error? {
        var aReturnVal :Error? = nil
        
        do {
            var flagmode: Bool = false
            var aNodeId :String? = nil
            var statusflag: Bool = false
            
            if let anAppliance = pEntity as? Appliance {
                aNodeId = anAppliance.hardwareId
            } else if let aCurtain = pEntity as? Curtain {
                aNodeId = aCurtain.id
            } else if let aRemote = pEntity as? Remote {
                aNodeId = aRemote.hardwareId
            } else if let aSensor = pEntity as? Sensor {
                aNodeId = aSensor.id
            } else if let aSchedule = pEntity as? Schedule {
                aNodeId = aSchedule.id
            } else if let aMood = pEntity as? Mood {
                aNodeId = aMood.id
                flagmode = true
             //   statusflag = pPowerState
                    
              
            } else if let aLock = pEntity as? Lock {
                aNodeId = aLock.id
            } else if let deviceID = pEntity as? String {
                aNodeId = deviceID
            }
            
            if (aNodeId?.count ?? 0) <= 0 {
                throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Command node ID is not available."])
            }
            
            var aMessageField :DatabaseReference? = nil
            aMessageField = self.database
                .child("messages")
                .child(aNodeId!)
                .child("applianceData")
                .child("message")
            
            if flagmode == true{
              
             var xyy = self.database
                    .child("mood")
                    .child(Auth.auth().currentUser!.uid)
                    .child(aNodeId!).child("toggle") //.setValue(populatedDictionary)
              
                var aResetMessageError :Error? = nil
                let aResetMessageDispatchSemaphore = DispatchSemaphore(value: 0)
                xyy.setValue(1, withCompletionBlock: { (pError, pDatabaseReference) in
                    aResetMessageError = pError
                    aResetMessageDispatchSemaphore.signal()
                })
            }
            
            // Send message
            var aSetMessageError :Error? = nil
            let aMessageDispatchSemaphore = DispatchSemaphore(value: 0)
            aMessageField?.setValue(pMessage, withCompletionBlock: { (pError, pDatabaseReference) in
                aSetMessageError = pError
                aMessageDispatchSemaphore.signal()
            })
            _ = aMessageDispatchSemaphore.wait(timeout: .distantFuture)
            if let anError = aSetMessageError {
                throw anError
            }
            
            // Reset message
            var aResetMessageError :Error? = nil
            let aResetMessageDispatchSemaphore = DispatchSemaphore(value: 0)
            aMessageField?.setValue("aa", withCompletionBlock: { (pError, pDatabaseReference) in
                aResetMessageError = pError
                aResetMessageDispatchSemaphore.signal()
            })
            _ = aResetMessageDispatchSemaphore.wait(timeout: .distantFuture)
            if let anError = aResetMessageError {
                throw anError
            }
        } catch {
            aReturnVal = error
        }
        
        return aReturnVal
    }
    
    func sendMessagereset(_ pMessage :String, entity pEntity :Any ) -> Error? {
        var aReturnVal :Error? = nil
        
        do {
            var flagmode: Bool = false
            var aNodeId :String? = nil
            var statusflag: Bool = false
            
            if let anAppliance = pEntity as? Appliance {
                aNodeId = anAppliance.hardwareId
            } else if let aCurtain = pEntity as? Curtain {
                aNodeId = aCurtain.id
            } else if let aRemote = pEntity as? Remote {
                aNodeId = aRemote.hardwareId
            } else if let aSensor = pEntity as? Sensor {
                aNodeId = aSensor.id
            } else if let aSchedule = pEntity as? Schedule {
                aNodeId = aSchedule.id
            } else if let aMood = pEntity as? Mood {
                aNodeId = aMood.id
                flagmode = true
  
            } else if let aLock = pEntity as? Lock {
                aNodeId = aLock.id
            } else if let deviceID = pEntity as? String {
                aNodeId = deviceID
            }else if let anAppliance = pEntity as? ControllerAppliance {
                aNodeId = anAppliance.id
            }
            
            if (aNodeId?.count ?? 0) <= 0 {
                throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Command node ID is not available."])
            }
            
            var aMessageField :DatabaseReference? = nil
            aMessageField = self.database
                .child("messages")
                .child(aNodeId!)
                .child("applianceData")
                .child("message")
            
           
            
            // Send message
            var aSetMessageError :Error? = nil
            let aMessageDispatchSemaphore = DispatchSemaphore(value: 0)
            aMessageField?.setValue(pMessage, withCompletionBlock: { (pError, pDatabaseReference) in
                aSetMessageError = pError
                aMessageDispatchSemaphore.signal()
            })
            _ = aMessageDispatchSemaphore.wait(timeout: .distantFuture)
            if let anError = aSetMessageError {
                throw anError
            }
            
            // Reset message
            var aResetMessageError :Error? = nil
            let aResetMessageDispatchSemaphore = DispatchSemaphore(value: 0)
            aMessageField?.setValue("aa", withCompletionBlock: { (pError, pDatabaseReference) in
                aResetMessageError = pError
                aResetMessageDispatchSemaphore.signal()
            })
            _ = aResetMessageDispatchSemaphore.wait(timeout: .distantFuture)
            if let anError = aResetMessageError {
                throw anError
            }
        } catch {
            aReturnVal = error
        }
        
        return aReturnVal
    }
}
