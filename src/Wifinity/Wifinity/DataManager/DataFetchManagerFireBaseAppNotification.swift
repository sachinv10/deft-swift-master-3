//
//  DataFetchManagerFireBaseAppNotification.swift
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
    
    func searchAppNotification(completion pCompletion: @escaping (Error?, Array<AppNotification>?) -> Void, appNotificationType pAppNotificationType :AppNotification.AppNotificationType, hardwareId pHardwareId :String?, pageNumber pPageNumber :Int) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anAppNotificationArray :Array<AppNotification>? = Array<AppNotification>()
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                var anAppNotificationType = "energy"
                switch pAppNotificationType {
                case AppNotification.AppNotificationType.energyNotification:
                    anAppNotificationType = "energy"
                case AppNotification.AppNotificationType.deviceOfflineNotification:
                    anAppNotificationType = "deviceOffLine"
                case AppNotification.AppNotificationType.schedularNotification:
                    anAppNotificationType = "schedular"
                case AppNotification.AppNotificationType.sensorNotification:
                    anAppNotificationType = "sensorMotion"
                default:
                    break
                }
                
                // Fetch DEFT app url
                var aNotificationUrl :URL?
                let anAppServerDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("restfulApi")
                    .child("notification")
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Any> {
                            if let anIpAddress = aDict["ip"] as? String
                               , let aPort = aDict["port"] as? Int
                               , var aUrlComponents = URLComponents(string: String(format: "http://%@:%d", anIpAddress, aPort)) {
                                aUrlComponents.path = "/standAlonelog/getNotification"
                                var aQueryItemArray = Array<URLQueryItem>()
                                aQueryItemArray.append(URLQueryItem(name: "uid", value: Auth.auth().currentUser!.uid))
                                aQueryItemArray.append(URLQueryItem(name: "notificationType", value: anAppNotificationType))
                                aQueryItemArray.append(URLQueryItem(name: "hardwareId", value: pHardwareId))
                                aQueryItemArray.append(URLQueryItem(name: "count", value: String(format: "%d", pPageNumber)))
                                aUrlComponents.queryItems = aQueryItemArray
                                aNotificationUrl = aUrlComponents.url
                            }
                        }
                        
                        anAppServerDispatchSemaphore.signal()
                    }
                _ = anAppServerDispatchSemaphore.wait(timeout: .distantFuture)
                if aNotificationUrl == nil {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Invalid app notification url."])
                }
                
                // Fetch DEFT app notifications
                var aUrlRequest = URLRequest(url: aNotificationUrl!)
                aUrlRequest.httpMethod = "GET"
                
                let anAppNotificationDispatchSemaphore = DispatchSemaphore(value: 0)
                let aDataTask = URLSession.shared.dataTask(with: aUrlRequest, completionHandler: { (pData, pUrlResponse, pError) in
                    if let aResponseBody = pData
                       , let anArray = try? JSONSerialization.jsonObject(with: aResponseBody, options: []) as? Array<Dictionary<String,Any>> {
                        anAppNotificationArray = DataContractManagerFireBase.appNotifications(array: anArray)
                    }
                    
                    anAppNotificationDispatchSemaphore.signal()
                })
                aDataTask.resume()
                _ = anAppNotificationDispatchSemaphore.wait(timeout: .distantFuture)
                
                if (anAppNotificationArray?.count ?? 0) <= 0 {
                    anAppNotificationArray = nil
                }
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, anAppNotificationArray)
            }
        }
        
    }

    
    func saveAppNotificationSettings(completion pCompletion: @escaping (Error?, AppNotificationSettings?) -> Void, appNotificationSettings pAppNotificationSettings :AppNotificationSettings) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            var anAppNotificationSettings :AppNotificationSettings?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                if (pAppNotificationSettings.fcmToken?.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Push notification permission is not available."])
                }
                
                var aPathTokenDict = Dictionary<String, String>()
                let aNotificationToken = pAppNotificationSettings.fcmToken!
                let aBasePath = "notificationDeviceToken" + "/" + Auth.auth().currentUser!.uid
                
                aPathTokenDict.updateValue(aNotificationToken, forKey: aBasePath + "/criticalNotificationDeviceToken")
                aPathTokenDict.updateValue(aNotificationToken, forKey: aBasePath + "/energyActivatedDevice")
                aPathTokenDict.updateValue(aNotificationToken, forKey: aBasePath + "/informationToken")
                aPathTokenDict.updateValue(aNotificationToken, forKey: aBasePath + "/globalOffActivatedDevice")
                aPathTokenDict.updateValue(aNotificationToken, forKey: aBasePath + "/lockActivatedDevice")
                aPathTokenDict.updateValue(aNotificationToken, forKey: aBasePath + "/schedularActivatedDevice")
                
                for aPath in aPathTokenDict.keys {
                    let aToken = aPathTokenDict[aPath]
                    
                    // Check if notification is subscribed
                    var anIsNotificationSubscribed :Bool = false
                    if aPath.hasSuffix("energyActivatedDevice")
                    && pAppNotificationSettings.isEnergyNotificationSubscribed == true {
                        anIsNotificationSubscribed = true
                    } else if aPath.hasSuffix("informationToken")
                    && pAppNotificationSettings.isInformationNotificationSubscribed == true {
                        anIsNotificationSubscribed = true
                    } else if aPath.hasSuffix("globalOffActivatedDevice")
                    && pAppNotificationSettings.isGlobalOffNotificationSubscribed == true {
                        anIsNotificationSubscribed = true
                    } else if aPath.hasSuffix("lockActivatedDevice")
                    && pAppNotificationSettings.isLockNotificationSubscribed == true {
                        anIsNotificationSubscribed = true
                    } else if aPath.hasSuffix("schedularActivatedDevice")
                    && pAppNotificationSettings.isSchedularNotificationSubscribed == true {
                        anIsNotificationSubscribed = true
                    }
                    
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
                }
                
                anAppNotificationSettings = pAppNotificationSettings
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, anAppNotificationSettings)
            }
        }
        
    }
    
    
    func appNotificationSettingsDetails(completion pCompletion: @escaping (Error?, AppNotificationSettings?) -> Void, notificationToken pNotificationToken :String) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            var anAppNotificationSettings :AppNotificationSettings?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                var aPathTokenDict = Dictionary<String, String>()
                let aBasePath = "notificationDeviceToken" + "/" + Auth.auth().currentUser!.uid
                
                aPathTokenDict.updateValue(pNotificationToken, forKey: aBasePath + "/criticalNotificationDeviceToken")
                aPathTokenDict.updateValue(pNotificationToken, forKey: aBasePath + "/energyActivatedDevice")
                aPathTokenDict.updateValue(pNotificationToken, forKey: aBasePath + "/informationToken")
                aPathTokenDict.updateValue(pNotificationToken, forKey: aBasePath + "/globalOffActivatedDevice")
                aPathTokenDict.updateValue(pNotificationToken, forKey: aBasePath + "/lockActivatedDevice")
                aPathTokenDict.updateValue(pNotificationToken, forKey: aBasePath + "/schedularActivatedDevice")
                
                let aSettings = AppNotificationSettings()
                
                for aPath in aPathTokenDict.keys {
                    let aToken = aPathTokenDict[aPath]
                    
                    var aDoesTokenExist :Bool = false
                    
                    let aTokenKeyDispatchSemaphore = DispatchSemaphore(value: 0)
                    self.database
                        .child(aPath)
                        .observe(.value) { (pDataSnapshot) in
                            let anEnumerator = pDataSnapshot.children
                            while let anObject = anEnumerator.nextObject() as? DataSnapshot {
                                if (anObject.value as? String) == aToken {
                                    aDoesTokenExist = true
                                    break
                                }
                            }
                            aTokenKeyDispatchSemaphore.signal()
                        }
                    _ = aTokenKeyDispatchSemaphore.wait(timeout: .distantFuture)
                    
                    if aDoesTokenExist == true {
                        if aPath.hasSuffix("energyActivatedDevice") {
                            aSettings.isEnergyNotificationSubscribed = true
                        } else if aPath.hasSuffix("informationToken") {
                            aSettings.isInformationNotificationSubscribed = true
                        } else if aPath.hasSuffix("globalOffActivatedDevice") {
                            aSettings.isGlobalOffNotificationSubscribed = true
                        } else if aPath.hasSuffix("lockActivatedDevice") {
                            aSettings.isLockNotificationSubscribed = true
                        } else if aPath.hasSuffix("schedularActivatedDevice") {
                            aSettings.isSchedularNotificationSubscribed = true
                        }
                    }
                }
                
                anAppNotificationSettings = aSettings
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, anAppNotificationSettings)
            }
        }
        
    }
}
