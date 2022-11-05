//
//  DataFetchManagerFireBaseSensor.swift
//  DEFT
//
//  Created by Rupendra on 08/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import Firebase


extension DataFetchManagerFireBase {
    
    func searchSensor(completion pCompletion: @escaping (Error?, Array<Sensor>?) -> Void, room pRoom :Room?) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aSensorArray :Array<Sensor>? = Array<Sensor>()
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                if (pRoom?.id?.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No room id available."])
                }
                
                // Fetch sensor IDs
                let aFilter = Auth.auth().currentUser!.uid + "_" + (pRoom?.id ?? "") + "_smartsensor"
                SearchSensorController.sensorId = aFilter
                let aSensorDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("devices")
                    .queryOrdered(byChild: "filter")
                    .queryEqual(toValue: aFilter)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Dictionary<String,Any>> {
                            aSensorArray = DataContractManagerFireBase.sensors(dict: aDict)
                            // Sort the array
                            aSensorArray?.sort { (pLhs, pRhs) -> Bool in
                                return (pLhs.title?.lowercased() ?? "") < (pRhs.title?.lowercased() ?? "")
                            }
                        }
                        aSensorDispatchSemaphore.signal()
                    }
                _ = aSensorDispatchSemaphore.wait(timeout: .distantFuture)
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, aSensorArray)
            }
        }
        
    }
    
    
    func sensorDetails(completion pCompletion: @escaping (Error?, Sensor?) -> Void, sensor pSensor :Sensor) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aSensor :Sensor?
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                if (pSensor.id?.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Sensor ID can not be empty."])
                }
                
                // Fetch sensor details
                let aSensorDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("devices")
                    .child(pSensor.id!)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Any> {
                            aSensor = DataContractManagerFireBase.sensor(dict: aDict)
                        }
                        aSensorDispatchSemaphore.signal()
                    }
                _ = aSensorDispatchSemaphore.wait(timeout: .distantFuture)
                
                // Fetch sensor settings
                let aSensorSettingsDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("sensorSetting")
                    .child(pSensor.id!)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Any>
                        , let aSensorSettings = DataContractManagerFireBase.sensor(dict: aDict){
                            aSensor?.update(sensor: aSensorSettings)
                        }
                        aSensorSettingsDispatchSemaphore.signal()
                    }
                _ = aSensorSettingsDispatchSemaphore.wait(timeout: .distantFuture)
                
                
                let aToken :String? = CacheManager.shared.fcmToken
                
                let aHardwareId :String = pSensor.id ?? ""
                if aHardwareId.count <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Sensor hardware id not available."])
                }
                
                let aPath = "sensorDeviceToken" + "/" + aHardwareId + "/" + "token"
                
                // Check if token is already saved
                var anExistingTokenKey :String?
                let aTokenKeyDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child(aPath)
                    .observe( .value) { (pDataSnapshot) in
                        let anEnumerator = pDataSnapshot.children
                        while let anObject = anEnumerator.nextObject() as? DataSnapshot {
                            if (anObject.value as? String) == aToken {
                                anExistingTokenKey = anObject.key
                                break
                            }
                        }
                        aTokenKeyDispatchSemaphore.signal()
                    }
                _ = aTokenKeyDispatchSemaphore.wait(timeout: .distantFuture)
                
                if anExistingTokenKey != nil {
                    aSensor?.notificationSettingsState = true
                }
                
                
                // Fetch sensor notification-sound-state
                if let aKey = anExistingTokenKey {
                    let aSensorNotificationSoundDispatchSemaphore = DispatchSemaphore(value: 0)
                    self.database
                        .child("sensorDeviceToken")
                        .child(aHardwareId)
                        .child("notificationSoundStatus")
                        .child(aKey)
                        .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                            if let aValue = pDataSnapshot.value as? Bool {
                                aSensor?.notificationSoundState = aValue
                            }
                            aSensorNotificationSoundDispatchSemaphore.signal()
                        }
                    _ = aSensorNotificationSoundDispatchSemaphore.wait(timeout: .distantFuture)
                }
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, aSensor)
            }
        }
        
    }
    
    
    func updateSensorMotionState(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor, motionState pMotionState :Sensor.MotionState) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Send message and reset it
                var aMessageValue = ""
                aMessageValue += "$M"
                aMessageValue += "0"
                aMessageValue += "0"
                aMessageValue += String(format: "%d", pMotionState.rawValue)
                aMessageValue += "0"
                aMessageValue += "#"
                anError = self.sendMessage(aMessageValue, entity: pSensor)
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
    
    
    func updateSensorOccupancyState(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor, occupancyState pOccupancyState :Sensor.OccupancyState) {
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.global(qos: .background).async {
                self.requestCount += 1
                
                var anError :Error?
                
                do {
                    if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                        throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                    }
                    
                    // Send message and reset it
                    var aMessageValue = ""
                    aMessageValue += "$M"
                    aMessageValue += String(format: "%d", pOccupancyState.rawValue)
                    aMessageValue += "002#"
                    anError = self.sendMessage(aMessageValue, entity: pSensor)
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
    
    func updateSensorBtnResetCounter(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor) {
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.global(qos: .background).async {
                self.requestCount += 1
               
                
                var anError :Error?
                
                do {
                    if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                        throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                    }
                    // Send message and reset it
                    var aMessageValue = ""
                    aMessageValue += ""
                    var aNodeId :String?
                    if let aSensor = pSensor as? Sensor {
                        aNodeId = aSensor.roomId
                    }
                    
                    var aMessageField :DatabaseReference? = nil
                    aMessageField = self.database
                        .child("rooms").child((Auth.auth().currentUser?.uid)!)
                        .child(aNodeId!).child("peopleCount")
//                        .child("applianceData")
//                        .child("message")
                    
                    
                    var aSetMessageError :Error? = nil
                    let aMessageDispatchSemaphore = DispatchSemaphore(value: 0)
                    aMessageField?.setValue(0, withCompletionBlock: { (pError, pDatabaseReference) in
                        aSetMessageError = pError
                        aMessageDispatchSemaphore.signal()
                    })
                    _ = aMessageDispatchSemaphore.wait(timeout: .distantFuture)
                    if let anError = aSetMessageError {
                        throw anError
                    }
                    
                   
                    
                //   anError = self.sendMessage(aMessageValue, entity: pSensor)
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
    func updateSensorCalibrate(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor) {
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.global(qos: .background).async {
                self.requestCount += 1
                let  dictionary:[String: Any] = ["config":"calibrate"]
                
                
                var strings = ""
                
             //   let dictionary = ["aKey": "aValue", "anotherKey": "anotherValue"]
                if let theJSONData = try? JSONSerialization.data(
                    withJSONObject: dictionary,
                    options: []) {
                    let theJSONText = String(data: theJSONData,
                                               encoding: .ascii)
                    print("JSON string = \(theJSONText!)")
                    strings = theJSONText!
                }
                
                
                var anError :Error?
                
                do {
                    if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                        throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                    }
                    
                    // Send message and reset it
                    var aMessageValue = ""
                    aMessageValue += strings
              
                    anError = self.sendMessage(aMessageValue, entity: pSensor)
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
    func updateSensorBrnFixNow(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor) {
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.global(qos: .background).async {
                self.requestCount += 1
                let  dictionary:[String: Any] = ["uid":"\(Auth.auth().currentUser?.uid ?? "")","roomId": "\(pSensor.roomId!)"]
                
                
                var strings = ""
                
             //   let dictionary = ["aKey": "aValue", "anotherKey": "anotherValue"]
                if let theJSONData = try? JSONSerialization.data(
                    withJSONObject: dictionary,
                    options: []) {
                    let theJSONText = String(data: theJSONData,
                                               encoding: .ascii)
                    print("JSON string = \(theJSONText!)")
                    strings = theJSONText!
                }
                
                
                var anError :Error?
                
                do {
                    if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                        throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                    }
                    
                    // Send message and reset it
                    var aMessageValue = ""
                    aMessageValue += strings
              
                    anError = self.sendMessage(aMessageValue, entity: pSensor)
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
    
    func updateSensorSync(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Send message and reset it
                var aMessageValue = ""
                if pSensor.hardwareType == Device.HardwareType.smokeDetector {
                    aMessageValue += "$G2#"
                } else {
                    aMessageValue += "$L2#"
                }
                anError = self.sendMessage(aMessageValue, entity: pSensor)
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
    
    
    func updateSensorThreshold(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor, smokeThreshold pSmokeThreshold :Int, coThreshold pCoThreshold :Int, lpgThreshold pLpgThreshold :Int) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Send message and reset it
                var aMessageValue = ""
                aMessageValue += "$g"
                aMessageValue += ":"
                aMessageValue += String(format: "%04d", pSmokeThreshold)
                aMessageValue += ":"
                aMessageValue += String(format: "%04d", pCoThreshold)
                aMessageValue += ":"
                aMessageValue += String(format: "%04d", pLpgThreshold)
                aMessageValue += ":"
                aMessageValue += "0100#"
                anError = self.sendMessage(aMessageValue, entity: pSensor)
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
    
    
    func updateSensorMotionLightState(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor, lightState pLightState :Sensor.LightState, isSettings pIsSettings :Bool) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Send message and reset it
                var aMessageValue = ""
                if pIsSettings == true {
                    aMessageValue += "$M"
                    aMessageValue += "0"
                    aMessageValue += "0"
                    aMessageValue += String(format: "%d", pLightState.rawValue)
                    aMessageValue += "0"
                    aMessageValue += "#"
                } else {
                    aMessageValue += "$R"
                    aMessageValue += String(format: "%d", pLightState.rawValue)
                    aMessageValue += "#"
                }
                anError = self.sendMessage(aMessageValue, entity: pSensor)
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
    
    
    func updateSensorMotionLightTimeout(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor, motionLightTimeout pMotionLightTimeout :Int) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Send message and reset it
                var aMessageValue = ""
                aMessageValue += "$B"
                aMessageValue += String(format: "%02d", pMotionLightTimeout)
                aMessageValue += "#"
                anError = self.sendMessage(aMessageValue, entity: pSensor)
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
    
    
    func updateSensorMotionLightIntensity(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor, motionLightIntensity pMotionLightIntensity :Int) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                let aMotionLightIntensity = UtilityManager.motionLightIntensityServerValue(sliderValue: Int(pMotionLightIntensity))
                
                // Send message and reset it
                var aMessageValue = ""
                aMessageValue += "$H"
                aMessageValue += String(format: "%04d", aMotionLightIntensity)
                aMessageValue += "#"
                anError = self.sendMessage(aMessageValue, entity: pSensor)
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
    
    
    func updateSensorSirenState(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor, sirenState pSirenState :Sensor.SirenState) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Send message and reset it
                var aMessageValue = ""
                aMessageValue += "$R"
                aMessageValue += String(format: "%d", pSirenState.rawValue)
                aMessageValue += "#"
                anError = self.sendMessage(aMessageValue, entity: pSensor)
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
    
    
    func updateSensorSirenSettingsState(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor, sirenState pSirenState :Sensor.SirenState) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Send message and reset it
                var aMessageValue = ""
                aMessageValue += "$M"
                aMessageValue += "0"
                if pSirenState == Sensor.SirenState.on {
                    aMessageValue += "2"
                } else {
                    aMessageValue += "1"
                }
                aMessageValue += "0"
                aMessageValue += "0"
                aMessageValue += "#"
                anError = self.sendMessage(aMessageValue, entity: pSensor)
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
    
    
    func updateSensorSirenTimeout(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor, sirenTimeout pSirenTimeout :Int) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Send message and reset it
                var aMessageValue = ""
                aMessageValue += "$S"
                aMessageValue += String(format: "%02d", pSirenTimeout)
                aMessageValue += "#"
                anError = self.sendMessage(aMessageValue, entity: pSensor)
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
    
    
    func updateSensorNotificationSettings(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor, fcmToken pFcmToken :String?, notificationSubscriptionState pNotificationSubscriptionState :Bool, notificationSoundState pNotificationSoundState :Bool) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                let aHardwareId :String = pSensor.id ?? ""
                if aHardwareId.count <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Sensor hardware id not available."])
                }
                
                let aToken :String? = pFcmToken
                
                let anIsNotificationSubscribed :Bool = pNotificationSubscriptionState
                
                let aPath = "sensorDeviceToken" + "/" + aHardwareId + "/" + "token"
                
                // Check if token is already saved
                var anExistingTokenKey :String?
                let aTokenKeyDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child(aPath)
                    .observe(.value) { (pDataSnapshot) in
                        let anEnumerator = pDataSnapshot.children
                        while let anObject = anEnumerator.nextObject() as? DataSnapshot {
                            if (anObject.value as? String) == aToken {
                                anExistingTokenKey = anObject.key
                                break
                            }
                        }
                        aTokenKeyDispatchSemaphore.signal()
                    }
                _ = aTokenKeyDispatchSemaphore.wait(timeout: .distantFuture)
                
                
                if anIsNotificationSubscribed == true && anExistingTokenKey == nil {
                    let aKey = self.getNextKey(dataBasePath: aPath)
                    
                    let aDispatchSemaphore = DispatchSemaphore(value: 0)
                    self.database
                        .child(aPath)
                        .child(aKey)
                        .setValue(aToken, withCompletionBlock: { (pError, pDatabaseReference) in
                            anError = pError
                            aDispatchSemaphore.signal()
                        })
                    _ = aDispatchSemaphore.wait(timeout: .distantFuture)
                } else if anIsNotificationSubscribed == false && anExistingTokenKey != nil {
                    let aDispatchSemaphore = DispatchSemaphore(value: 0)
                    self.database
                        .child(aPath)
                        .child(anExistingTokenKey!)
                        .removeValue(completionBlock: { (pError, pDatabaseReference) in
                            anError = pError
                            aDispatchSemaphore.signal()
                        })
                    _ = aDispatchSemaphore.wait(timeout: .distantFuture)
                }
                
                if let aKey = anExistingTokenKey {
                    if anIsNotificationSubscribed {
                        let aDispatchSemaphore = DispatchSemaphore(value: 0)
                        self.database
                            .child("sensorDeviceToken")
                            .child(aHardwareId)
                            .child("notificationSoundStatus")
                            .child(aKey)
                            .setValue(pNotificationSoundState, withCompletionBlock: { (pError, pDatabaseReference) in
                                anError = pError
                                aDispatchSemaphore.signal()
                            })
                        _ = aDispatchSemaphore.wait(timeout: .distantFuture)
                    } else {
                        let aDispatchSemaphore = DispatchSemaphore(value: 0)
                        self.database
                            .child("sensorDeviceToken")
                            .child(aHardwareId)
                            .child("notificationSoundStatus")
                            .child(anExistingTokenKey!)
                            .removeValue(completionBlock: { (pError, pDatabaseReference) in
                                anError = pError
                                aDispatchSemaphore.signal()
                            })
                        _ = aDispatchSemaphore.wait(timeout: .distantFuture)
                    }
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
    
    
    func sensorIdsForLoggedInUser(roomId pRoomId :String?) -> Array<String>? {
        var aReturnVal :Array<String>?
        
        if let aRoomId = pRoomId {
            let aDispatchSemaphore = DispatchSemaphore(value: 0)
            self.database
                .child("rooms")
                .child(Auth.auth().currentUser!.uid)
                .child(aRoomId)
                .child("sensors")
                .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                    aReturnVal = pDataSnapshot.value as? Array<String>
                    aDispatchSemaphore.signal()
                }
            _ = aDispatchSemaphore.wait(timeout: .distantFuture)
        } else {
            if let aRoomIdArray = self.roomIdsForLoggedInUser() {
                var aFetchedSensorIdArray = Array<String>()
                for aRoomId in aRoomIdArray {
                    let aDispatchSemaphore = DispatchSemaphore(value: 0)
                    self.database
                        .child("rooms")
                        .child(Auth.auth().currentUser!.uid)
                        .child(aRoomId)
                        .child("sensors")
                        .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                            if let aDeviceIdArray = pDataSnapshot.value as? Array<String> {
                                aFetchedSensorIdArray.append(contentsOf: aDeviceIdArray)
                            }
                            aDispatchSemaphore.signal()
                        }
                    _ = aDispatchSemaphore.wait(timeout: .distantFuture)
                }
                if aFetchedSensorIdArray.count > 0 {
                    aReturnVal = aFetchedSensorIdArray
                }
            }
        }
        
        return aReturnVal
    }
    
}

