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
    
    
    func observeChangeEvents() {
        self.database
            .child("ApplianceDetails")
            .child(Auth.auth().currentUser!.uid)
            .observe(DataEventType.childChanged) {(pDataSnapshot) in
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: DataFetchManager.databaseValueChangedNotificationName)))
            }
        
        self.database
            .child("rooms")
            .child(Auth.auth().currentUser!.uid)
            .observe(DataEventType.childChanged) {(pDataSnapshot) in
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: DataFetchManager.databaseValueChangedNotificationName)))
            }
        
        self.database
            .child("MqttCurtain")
            .child(Auth.auth().currentUser!.uid)
            .observe(DataEventType.childChanged) {(pDataSnapshot) in
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: DataFetchManager.databaseValueChangedNotificationName)))
            }
        
        self.database
            .child("sensorDetails")
            .child(Auth.auth().currentUser!.uid)
            .observe(DataEventType.childChanged) {(pDataSnapshot) in
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: DataFetchManager.databaseValueChangedNotificationName)))
            }
        
        self.database
            .child("wifinitySensorSetting")
            .observe(DataEventType.childChanged) {(pDataSnapshot) in
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: DataFetchManager.databaseValueChangedNotificationName)))
            }
        
        self.database
            .child("wifinityDevices")
            .child(Auth.auth().currentUser!.uid)
            .observe(DataEventType.childChanged) {(pDataSnapshot) in
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: DataFetchManager.databaseValueChangedNotificationName)))
            }
        
        self.database
            .child("remoteKey1")
            .child(Auth.auth().currentUser!.uid)
            .observe(DataEventType.childChanged) {(pDataSnapshot) in
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: DataFetchManager.databaseValueChangedNotificationName)))
            }
        
        self.database
            .child("schedulerDetails")
            .child(Auth.auth().currentUser!.uid)
            .observe(DataEventType.childAdded) {(pDataSnapshot) in
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: DataFetchManager.databaseValueChangedNotificationName)))
            }
        
        self.database
            .child("schedulerDetails")
            .child(Auth.auth().currentUser!.uid)
            .observe(DataEventType.childChanged) {(pDataSnapshot) in
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: DataFetchManager.databaseValueChangedNotificationName)))
            }
        
        self.database
            .child("schedulerDetails")
            .child(Auth.auth().currentUser!.uid)
            .observe(DataEventType.childRemoved) {(pDataSnapshot) in
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: DataFetchManager.databaseValueChangedNotificationName)))
            }
        
        self.database
            .child("moodDetails")
            .child(Auth.auth().currentUser!.uid)
            .observe(DataEventType.childChanged) {(pDataSnapshot) in
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: DataFetchManager.databaseValueChangedNotificationName)))
            }
        
        self.database
            .child("mqttIFTT")
            .child(Auth.auth().currentUser!.uid)
            .observe(DataEventType.childChanged) {(pDataSnapshot) in
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: DataFetchManager.databaseValueChangedNotificationName)))
            }
    }
    
    
    func removeAllObservers() {
        self.database.removeAllObservers()
    }
    
    
    func log(dataSnapshot pDataSnapshot :DataSnapshot) {
        if ConfigurationManager.shared.isDebugMode {
            var aLog = "--------------------------------------------------"
            aLog += String(format: "\n# Path: %@", pDataSnapshot.ref.url)
            aLog += String(format: "\n# Body: %@", pDataSnapshot.children.allObjects.description)
            Swift.print(aLog)
        }
    }
    
    func log(databaseReference pDatabaseReference :DatabaseReference) {
        if ConfigurationManager.shared.isDebugMode {
            var aLog = "--------------------------------------------------"
            aLog += String(format: "\n# Path: %@", pDatabaseReference.url)
            Swift.print(aLog)
        }
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
            
            var anError :Error?
            
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
                
                let aDispatchSemaphore = DispatchSemaphore(value: 0)
                let aDataTask = URLSession.shared.dataTask(with: aUrlRequest) { (pData, pResponse, pError) in
                    anError = pError
                    aDispatchSemaphore.signal()
                }
                aDataTask.resume()
                _ = aDispatchSemaphore.wait(timeout: .distantFuture)
                
                if anError != nil {
                    throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Rechability server connection error. " + anError!.localizedDescription])
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


// MARK:- Commands

extension DataFetchManagerFireBase {
    
    func sendMessage(_ pMessage :String, entity pEntity :Any) -> Error? {
        var aReturnVal :Error? = nil
        
        do {
            
            var aMessageField :DatabaseReference? = nil
            if let anAppliance = pEntity as? Appliance {
                if anAppliance.slaveId != nil {
                    aMessageField = self.database
                        .child("mqtt")
                        .child(Auth.auth().currentUser!.uid)
                        .child("applianceData")
                        .child("message")
                } else if anAppliance.hardwareId != nil {
                    aMessageField = self.database
                        .child("wifinityMessage")
                        .child(String(format: "%@_%@", Auth.auth().currentUser!.uid, anAppliance.hardwareId!))
                        .child("message")
                }
            } else if let aCurtain = pEntity as? Curtain {
                if aCurtain.hardwareGeneration == Device.HardwareGeneration.deft {
                    aMessageField = self.database
                        .child("mqtt")
                        .child(Auth.auth().currentUser!.uid)
                        .child("applianceData")
                        .child("message")
                } else {
                    aMessageField = self.database
                        .child("wifinityMessage")
                        .child(Auth.auth().currentUser!.uid  + "_" + (aCurtain.id ?? ""))
                        .child("message")
                }
            } else if let aRemote = pEntity as? Remote {
                if aRemote.hardwareGeneration == Device.HardwareGeneration.deft {
                    aMessageField = self.database
                        .child("mqtt")
                        .child(Auth.auth().currentUser!.uid)
                        .child("applianceData")
                        .child("message")
                } else {
                    aMessageField = self.database
                        .child("wifinityMessage")
                        .child(Auth.auth().currentUser!.uid  + "_" + (aRemote.irId ?? ""))
                        .child("message")
                }
            } else if let aSensor = pEntity as? Sensor {
                if aSensor.hardwareGeneration == Device.HardwareGeneration.deft {
                    aMessageField = self.database
                        .child("mqtt")
                        .child(Auth.auth().currentUser!.uid)
                        .child("applianceData")
                        .child("message")
                } else {
                    aMessageField = self.database
                        .child("wifinityMessage")
                        .child(Auth.auth().currentUser!.uid  + "_" + (aSensor.id ?? ""))
                        .child("message")
                }
            } else if let _ = pEntity as? Schedule {
                aMessageField = self.database
                    .child("mqtt")
                    .child(Auth.auth().currentUser!.uid)
                    .child("applianceData")
                    .child("message")
            } else if let _ = pEntity as? Mood {
                aMessageField = self.database
                    .child("mqtt")
                    .child(Auth.auth().currentUser!.uid)
                    .child("applianceData")
                    .child("message")
            } else if let _ = pEntity as? Lock {
                aMessageField = self.database
                    .child("mqtt")
                    .child(Auth.auth().currentUser!.uid)
                    .child("applianceData")
                    .child("message")
            } else if let aTankRegulator = pEntity as? TankRegulator {
                aMessageField = self.database
                    .child("wifinityMessage")
                    .child(Auth.auth().currentUser!.uid  + "_" + (aTankRegulator.id ?? ""))
                    .child("message")
            }
            
            if aMessageField == nil {
                throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Command node is not available."])
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
    
}
