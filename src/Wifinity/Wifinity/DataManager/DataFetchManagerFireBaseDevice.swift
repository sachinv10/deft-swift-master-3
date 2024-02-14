//
//  DataFetchManagerFireBaseDevice.swift
//  Wifinity
//
//  Created by Sachin on 16/12/22.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import Firebase


extension DataFetchManagerFireBase {
    
    func configureDevice(completion pCompletion: @escaping (Error?, Device?) -> Void, device pDevice :Device) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            var compflag = false
        do {
             if (pDevice.id?.prefix(3) == "V00") {
                 var updatemsg = [String]()
                 let uid = Auth.auth().currentUser?.uid
                 let ref = Database.database().reference().child("routerDetails").child(pDevice.id ?? "")
                 ref.updateChildValues(["wCommand": false, "xCommand": false, "yCommand": false])
                 let msg1 = "Y0120F"
               
                 updatemsg.append(msg1)
                 let msg2 = "W" + pDevice.networkSsid! + "0F1"
                 updatemsg.append(msg2)
                 let msg3 = "X" + pDevice.networkPassword! + "0F1"
                 updatemsg.append(msg3)
                 for item in updatemsg{
                     let error = self.sendMessage(item, entity: pDevice)
                     if error != nil{
                         print(error?.localizedDescription)
                     }
                 }
                 ref.observe(.childChanged, with: { error in
                     ref.child("temp").setValue(["password":pDevice.networkPassword, "ssid": pDevice.networkSsid])
                     if compflag == false{
                         pCompletion(anError, pDevice)
                     }
                     compflag = true
                 })
                 DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                     if compflag == false{
                         pCompletion(anError, pDevice)
                     }
                 }
                 
             }else{
                // Configure device
                let aQueryItemArray = [
                    URLQueryItem(name: "ssid", value: pDevice.networkSsid)
                    , URLQueryItem(name: "pass", value: pDevice.networkPassword)
                ]
                guard var aUrlComponents = URLComponents(string: ConfigurationManager.shared.newDeviceConfigureNetworkUrlString) else {
                    throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Invalid device configuraion URL."])
                }
                
                aUrlComponents.queryItems = aQueryItemArray
                
                guard let aUrl = aUrlComponents.url else {
                    throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Invalid device configuraion URL."])
                }
                
                var aUrlRequest = URLRequest(url: aUrl)
                aUrlRequest.httpMethod = "GET"
                
                let aDispatchSemaphore = DispatchSemaphore(value: 0)
                let aDataTask = URLSession.shared.dataTask(with: aUrlRequest) { (pData, pResponse, pError) in
                    anError = pError
                    DispatchQueue.main.async {
                        pCompletion(anError, pDevice)
                    }
                    aDispatchSemaphore.signal()
                }
                aDataTask.resume()
                _ = aDispatchSemaphore.wait(timeout: .distantFuture)
                
                if anError != nil {
                    throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Device configuration request error. " + anError!.localizedDescription])
                }
            }
            } catch {
                anError = error
                pCompletion(anError, pDevice)
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
              //  pCompletion(anError, pDevice)
            }
        }
        
    }
    
    
    func saveDevice(completion pCompletion: @escaping (Error?, Device?) -> Void, device pDevice :Device) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                if pDevice.id == nil {
                    throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Invalid device ID."])
                }
                if pDevice.room?.id == nil
                && pDevice.hardwareType != Device.HardwareType.lock
                    && pDevice.hardwareType != Device.HardwareType.gateLock && pDevice.hardwareType != Device.HardwareType.VDP{
                    throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Invalid room ID."])
                }
                
                // Save device
                var aDeviceDict :Dictionary<String,Any?> = Dictionary<String,Any?>()
                var aDeviceVdp :Dictionary<String,Any?> = Dictionary<String,Any?>()
                // save sensor setting
                var aSensorDict :Dictionary<String,Any?> = Dictionary<String,Any?>()
                if let aHardwareType = pDevice.hardwareType {
                    aDeviceDict.updateValue(DataContractManagerFireBase.hardwareTypeDatabaseValue(aHardwareType), forKey: "controllerType")
                //     aDeviceDict.updateValue(DataContractManagerFireBase.hardwareTypeForAndroidDatabaseValue(aHardwareType), forKey: "type")
                }
                if pDevice.hardwareType == Device.HardwareType.rollingCurtain || pDevice.hardwareType == Device.HardwareType.slidingCurtain {
                    aDeviceDict.updateValue(Auth.auth().currentUser!.uid + "_" + (pDevice.room?.id ?? "") + "_curtain", forKey: "filter")
                } else if pDevice.hardwareType == Device.HardwareType.smartSensor
                || pDevice.hardwareType == Device.HardwareType.smokeDetector
                || pDevice.hardwareType == Device.HardwareType.smartSensorBattery
                || pDevice.hardwareType == Device.HardwareType.smokeDetectorBattery
                || pDevice.hardwareType == Device.HardwareType.thermalSensor
                || pDevice.hardwareType == Device.HardwareType.uvSensor
                || pDevice.hardwareType == Device.HardwareType.smartSecuritySensor {
                    aDeviceDict.updateValue(Auth.auth().currentUser!.uid + "_" + (pDevice.room?.id ?? "") + "_smartsensor", forKey: "filter")
                } else if pDevice.hardwareType == Device.HardwareType.ir {
                    aDeviceDict.updateValue(Auth.auth().currentUser!.uid + "_" + (pDevice.room?.id ?? "") + "_IR", forKey: "filter")
                } else if pDevice.hardwareType == Device.HardwareType.lock
                || pDevice.hardwareType == Device.HardwareType.gateLock {
                    aDeviceDict.updateValue(Auth.auth().currentUser!.uid + "_lock", forKey: "filter")
                } else if pDevice.hardwareType == Device.HardwareType.waterTank {
                    aDeviceDict.updateValue(Auth.auth().currentUser!.uid + "_WaterLevelController", forKey: "filter")
                } else if pDevice.hardwareType == Device.HardwareType.waterTank2 {
                    aDeviceDict.updateValue(Auth.auth().currentUser!.uid + "_WaterLevelController", forKey: "filter")
                }else if pDevice.hardwareType == Device.HardwareType.Occupy {
                    aDeviceDict.updateValue(Auth.auth().currentUser!.uid + "_" + (pDevice.room?.id ?? "") + "_smartsensor", forKey: "filter")
                }else {
                    aDeviceDict.updateValue(Auth.auth().currentUser!.uid + "_" + (pDevice.room?.id ?? ""), forKey: "filter")
                }
                aDeviceDict.updateValue(pDevice.id, forKey: "id")
                aDeviceDict.updateValue(pDevice.title, forKey: "name")
                aDeviceDict.updateValue(false, forKey: "online")
                aDeviceDict.updateValue(pDevice.room?.id, forKey: "roomId")
                aDeviceDict.updateValue(pDevice.room?.title, forKey: "roomName")
                aDeviceDict.updateValue("", forKey: "switchName")
                aDeviceDict.updateValue("", forKey: "switchType")
                aDeviceDict.updateValue(pDevice.switchCount, forKey: "switches")
                aDeviceDict.updateValue(Auth.auth().currentUser!.uid, forKey: "uid")
                
                if let aHardwareType = pDevice.hardwareType {
                    switch aHardwareType {
                    case Device.HardwareType.oneSwitch
                    , Device.HardwareType.twoSwitch
                    , Device.HardwareType.threeSwitch
                    , Device.HardwareType.fourSwitch
                    , Device.HardwareType.fiveSwitch
                    , Device.HardwareType.sixSwitch
                    , Device.HardwareType.sevenSwitch
                    , Device.HardwareType.eightSwitch
                    , Device.HardwareType.nineSwitch
                    , Device.HardwareType.tenSwitch:
                        aDeviceDict.updateValue("", forKey: "workingAppliances")
                    case Device.HardwareType.clOneSwitch:
                        break
                    case Device.HardwareType.ctOneSwitch
                         , Device.HardwareType.ctTwoSwitch
                         , Device.HardwareType.ctThreeSwitch
                         , Device.HardwareType.ctFourSwitch
                         , Device.HardwareType.ctFiveSwitch
                         , Device.HardwareType.ctSixSwitch
                         , Device.HardwareType.ctSevenSwitch
                         , Device.HardwareType.ctEightSwitch
                         , Device.HardwareType.ctNineSwitch
                         , Device.HardwareType.ctTenSwitch:
                        break
                    case  Device.HardwareType.smartSensorBattery:
                        aDeviceDict.updateValue("NA", forKey: "currentTemp")
                        aDeviceDict.updateValue("NA", forKey: "lastMotion")
                        aDeviceDict.updateValue("NA", forKey: "lightIntensity")
                        aDeviceDict.updateValue(false, forKey: "state")
                        aDeviceDict.updateValue(0, forKey: "syncToggle")
                        aDeviceDict.updateValue("1", forKey: "batterySaverMode")
                        aDeviceDict.updateValue("90", forKey: "batteryPercentage")
                        let timestamp = NSDate().timeIntervalSince1970 * 100
                        aDeviceDict.updateValue(Int(timestamp), forKey: "lastMotionTimeStamp")
                        
                        aSensorDict.updateValue("3", forKey: "batterySaverMode")
                        aSensorDict.updateValue("0010", forKey: "motionTimeOutExtreme")
                        aSensorDict.updateValue("0030", forKey: "motionTimeOutLow")
                        aSensorDict.updateValue("0020", forKey: "motionTimeOutMedium")
                        aSensorDict.updateValue("1200", forKey: "wakeUpTimeExtreme")
                        aSensorDict.updateValue("2", forKey: "sensorState")
                        aSensorDict.updateValue("2700", forKey: "wakeUpTime")
                        aSensorDict.updateValue("4500", forKey: "wakeUpTimeExtreme")
                        aSensorDict.updateValue("2700", forKey: "wakeUpTimeLow")
                        aSensorDict.updateValue("3600", forKey: "wakeUpTimeMedium")
                    case Device.HardwareType.smartSensor:
                        aDeviceDict.updateValue("NA", forKey: "currentTemp")
                        aDeviceDict.updateValue("NA", forKey: "lastMotion")
                        aDeviceDict.updateValue("NA", forKey: "lightIntensity")
                        aDeviceDict.updateValue(false, forKey: "state")
                        aDeviceDict.updateValue(0, forKey: "syncToggle")
                    case Device.HardwareType.smokeDetector:
                        aDeviceDict.updateValue(200, forKey: "adcThreshold")
                        aDeviceDict.updateValue(0, forKey: "co2Threshold")
                        aDeviceDict.updateValue(0, forKey: "lpgThreshold")
                        aDeviceDict.updateValue(0, forKey: "smokeThreshold")
                        aDeviceDict.updateValue("NA", forKey: "lightIntensity")
                        aDeviceDict.updateValue(false, forKey: "state")
                        aDeviceDict.updateValue(0, forKey: "syncToggle")
                    case Device.HardwareType.smokeDetectorBattery:
                        aDeviceDict.updateValue(200, forKey: "adcThreshold")
                        aDeviceDict.updateValue(0, forKey: "co2Threshold")
                        aDeviceDict.updateValue(0, forKey: "lpgThreshold")
                        aDeviceDict.updateValue(0, forKey: "smokeThreshold")
                        aDeviceDict.updateValue("NA", forKey: "lightIntensity")
                        aDeviceDict.updateValue(false, forKey: "state")
                        aDeviceDict.updateValue(0, forKey: "syncToggle")
                        aDeviceDict.updateValue("3", forKey: "batterySaverMode")
                        aDeviceDict.updateValue("90", forKey: "batteryPercentage")
                        aDeviceDict.updateValue("3", forKey: "sensorSensitivity")
                        let timestamp = NSDate().timeIntervalSince1970 * 100
                        aDeviceDict.updateValue(Int(timestamp), forKey: "lastMotionTimeStamp")
                    case .Occupy:
                        if let aHardwareType = pDevice.hardwareType {
                            aDeviceDict.updateValue(DataContractManagerFireBase.hardwareTypeForAndroidDatabaseValue(aHardwareType), forKey: "controllerSubType")
                        }
                        aDeviceDict.updateValue("-62", forKey: "wifiSignalStrength")
                        aDeviceDict.updateValue("NA", forKey: "lastOperation")
                        aDeviceDict.updateValue(0, forKey: "lastOperationTime")
                        aDeviceDict.updateValue(0, forKey: "peopleCount")
                        aDeviceDict.updateValue(false, forKey: "state")
                        let timestamp = NSDate().timeIntervalSince1970
                        aDeviceDict.updateValue(Int(timestamp * 100), forKey: "timeStamp")
                        aDeviceDict.updateValue(false, forKey: "uidAssign")
                        aDeviceDict.updateValue( NewDeviceConfigureDeviceController.networkPssword, forKey: "wifiPassword")
                        aDeviceDict.updateValue( NewDeviceConfigureDeviceController.networkSsid, forKey: "wifiSsid")
                        break
                    case Device.HardwareType.thermalSensor:
                        break
                    case Device.HardwareType.uvSensor:
                        break
                    case Device.HardwareType.smartSecuritySensor:
                        break
                    case Device.HardwareType.rollingCurtain:
                        aDeviceDict.updateValue(Auth.auth().currentUser!.uid + "_curtain", forKey: "voice_filter")
                    case Device.HardwareType.slidingCurtain:
                        aDeviceDict.updateValue(Auth.auth().currentUser!.uid + "_curtain", forKey: "voice_filter")
                        aDeviceDict.updateValue(0, forKey: "level")
                    case Device.HardwareType.ir:
                        break
                    case Device.HardwareType.lock
                         , Device.HardwareType.gateLock:
                        aDeviceDict.updateValue(pDevice.id, forKey: "hardwareId")
                        aDeviceDict.updateValue(pDevice.lockPassword, forKey: "lockPassword")
                        aDeviceDict.updateValue(false, forKey: "state")
                        aDeviceDict.updateValue(0, forKey: "toggle")
                        aDeviceDict.updateValue(Auth.auth().currentUser!.uid + "_lock", forKey: "voice_filter")
                        aDeviceDict.removeValue(forKey: "switchName")
                        aDeviceDict.removeValue(forKey: "switchType")
                        aDeviceDict.removeValue(forKey: "switches")
                        break
                    case .waterTank:
                        if let aHardwareType = pDevice.hardwareType {
                            aDeviceDict.updateValue(DataContractManagerFireBase.hardwareTypeDatabaseValue(aHardwareType), forKey: "type")
                        }
                        aDeviceDict.updateValue(false, forKey: "autoModeActivated")
                        aDeviceDict.updateValue(pDevice.id, forKey: "hardwareId")
                        aDeviceDict.updateValue(false, forKey: "motorState")
                        aDeviceDict.updateValue(false, forKey: "state")
                        aDeviceDict.updateValue(1, forKey: "tankCount")
                        aDeviceDict.updateValue(10, forKey: "tankFillPercentage")
                        aDeviceDict.updateValue(2, forKey: "tankWaterLevel")
                        aDeviceDict.updateValue("WaterLevelController", forKey: "controllerType")
                        aDeviceDict.updateValue(Auth.auth().currentUser!.uid + "_WaterLevelController", forKey: "voice_filter")
                        break
                    case .waterTank2:
                        if let aHardwareType = pDevice.hardwareType {
                            aDeviceDict.updateValue(DataContractManagerFireBase.hardwareTypeDatabaseValue(aHardwareType), forKey: "type")
                        }
                        aDeviceDict.updateValue(false, forKey: "autoModeActivated")
                        aDeviceDict.updateValue(pDevice.id, forKey: "hardwareId")
                        aDeviceDict.updateValue(false, forKey: "motorState")
                        aDeviceDict.updateValue(false, forKey: "state")
                        aDeviceDict.updateValue(1, forKey: "tankCount")
                        aDeviceDict.updateValue(10, forKey: "tankFillPercentage")
                        aDeviceDict.updateValue(2, forKey: "tankWaterLevel")
                        aDeviceDict.updateValue("WaterLevelController", forKey: "controllerType")
                        aDeviceDict.updateValue(Auth.auth().currentUser!.uid + "_WaterLevelController", forKey: "voice_filter")
                        break
                    case .CSoneSwitch,
                            .CStwoSwitch,
                            .CSthreeSwitch,
                            .CSfourSwitch,
                            .CSfiveSwitch,
                            .CSsixSwitch,
                            .CSsevenSwitch,
                            .CSeightSwitch,
                            .CSnineSwitch,
                            .CStenSwitch:
                        if let aHardwareType = pDevice.hardwareType {
                            aDeviceDict.updateValue(DataContractManagerFireBase.hardwareTypeForAndroidDatabaseValue(aHardwareType), forKey: "type")
                            
                            aDeviceDict.updateValue(Device.getSwitchCount(hardwareType: aHardwareType), forKey: "switches")
                        }
                        let timestamp = NSDate().timeIntervalSince1970
                        aDeviceDict.updateValue(Int(timestamp * 100), forKey: "timeStamp")
                        aDeviceDict.updateValue( NewDeviceConfigureDeviceController.networkPssword, forKey: "wifiPassword")
                        aDeviceDict.updateValue( NewDeviceConfigureDeviceController.networkSsid, forKey: "wifiSsid")
                                break
                    case .VDP:
                     // setup  vdp
                        aDeviceDict.removeValue(forKey: "roomId")
                        aDeviceDict.removeValue(forKey: "roomName")
                        aDeviceDict.removeValue(forKey: "switchName")
                        aDeviceDict.removeValue(forKey: "switchType")
                        aDeviceDict.removeValue(forKey: "switches")
                        
                        aDeviceDict.updateValue(false, forKey: "available")
                        aDeviceDict.updateValue("NA", forKey: "callStatus")
                        aDeviceDict.updateValue(false, forKey: "camera")
                        aDeviceDict.updateValue("192.168.1.182", forKey: "ip_address")
                        aDeviceDict.updateValue(false, forKey: "nightVision")
                        aDeviceDict.updateValue(pDevice.networkSsid, forKey: "wifiSsid")
                        aDeviceDict.updateValue(pDevice.networkPassword, forKey: "wifiPassword")
                        aDeviceDict.updateValue(pDevice.id, forKey: "hardwareId")
                        aDeviceDict.updateValue(false, forKey: "state")
                        aDeviceDict.updateValue(false, forKey: "vdpFilter")
                        aDeviceDict.updateValue(Auth.auth().currentUser!.uid + "_VDP", forKey: "filter")

                        break
                    }
                }
                
               
                if pDevice.hardwareType != Device.HardwareType.VDP{
                    let aSaveDeviceDispatchSemaphore = DispatchSemaphore(value: 0)
                    self.database
                        .child("devices")
                        .child(pDevice.id!)
                        .setValue(aDeviceDict, withCompletionBlock: { (pError, pDatabaseReference) in
                            anError = pError
                            aSaveDeviceDispatchSemaphore.signal()
                        })
                    _ = aSaveDeviceDispatchSemaphore.wait(timeout: .distantFuture)
                }
                
                // Add device ID to room
                if let _ = pDevice.room?.id {
                    var aDeviceIdArray :Array<String> = Array<String>()
                    
                    // Decide the node in rooms
                    var aNode = "devices"
                    if let aHardwareType = Device.getHardwareType(id: pDevice.id!) {
                        switch aHardwareType {
                        case Device.HardwareType.rollingCurtain
                             , Device.HardwareType.slidingCurtain:
                            aNode = "curtains"
                        case Device.HardwareType.smartSensor
                             , Device.HardwareType.smokeDetector
                             , Device.HardwareType.thermalSensor
                             , Device.HardwareType.uvSensor
                             , Device.HardwareType.smartSecuritySensor,
                              .smartSensorBattery,
                              .smokeDetectorBattery
                            , Device.HardwareType.Occupy:
                            aNode = "sensors"
                        case Device.HardwareType.ir:
                            aNode = "remotes"
                        case Device.HardwareType.oneSwitch
                             , Device.HardwareType.twoSwitch
                             , Device.HardwareType.threeSwitch
                             , Device.HardwareType.fourSwitch
                             , Device.HardwareType.fiveSwitch
                             , Device.HardwareType.sixSwitch
                             , Device.HardwareType.sevenSwitch
                             , Device.HardwareType.eightSwitch
                             , Device.HardwareType.nineSwitch
                             , Device.HardwareType.tenSwitch
                             
                             , Device.HardwareType.clOneSwitch
                             
                             , Device.HardwareType.ctOneSwitch
                             , Device.HardwareType.ctTwoSwitch
                             , Device.HardwareType.ctThreeSwitch
                             , Device.HardwareType.ctFourSwitch
                             , Device.HardwareType.ctFiveSwitch
                             , Device.HardwareType.ctSixSwitch
                             , Device.HardwareType.ctSevenSwitch
                             , Device.HardwareType.ctEightSwitch
                             , Device.HardwareType.ctNineSwitch
                             , Device.HardwareType.ctTenSwitch,
                               Device.HardwareType.waterTank
                              ,Device.HardwareType.waterTank2:
                            aNode = "devices"
                        case Device.HardwareType.lock
                             , Device.HardwareType.gateLock:
                            aNode = "locks"
                        
                        case .CSoneSwitch,
                                .CStwoSwitch,
                                .CSthreeSwitch,
                                .CSfourSwitch,
                                .CSfiveSwitch,
                                .CSsixSwitch,
                                .CSsevenSwitch,
                                .CSeightSwitch,
                                .CSnineSwitch,
                                .CStenSwitch:
                                break
                        case .VDP:
                              break
                        }
                    }
                    
                    // Get current ids
                    let aDispatchSemaphore = DispatchSemaphore(value: 0)
                    self.database
                        .child("rooms")
                        .child(Auth.auth().currentUser!.uid)
                        .child(pDevice.room!.id!)
                        .child(aNode)
                        .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                            if let anIdArray = pDataSnapshot.value as? Array<String> {
                                aDeviceIdArray.append(contentsOf: anIdArray)
                            }
                            aDispatchSemaphore.signal()
                        }
                    _ = aDispatchSemaphore.wait(timeout: .distantFuture)
                    
                    if aDeviceIdArray.contains(pDevice.id!) == false {
                        aDeviceIdArray.append(pDevice.id!)
                    }
                    
                    // Save new array of ids
                    let aSaveDeviceIdDispatchSemaphore = DispatchSemaphore(value: 0)
                    self.database
                        .child("rooms")
                        .child(Auth.auth().currentUser!.uid)
                        .child(pDevice.room!.id!)
                        .child(aNode)
                        .setValue(aDeviceIdArray, withCompletionBlock: { (pError, pDatabaseReference) in
                            anError = pError
                            aSaveDeviceIdDispatchSemaphore.signal()
                        })
                    _ = aSaveDeviceIdDispatchSemaphore.wait(timeout: .distantFuture)
                }
                
                // Save sensor details
                if pDevice.hardwareType == Device.HardwareType.smartSensor
                || pDevice.hardwareType == Device.HardwareType.smokeDetector
                || pDevice.hardwareType == Device.HardwareType.thermalSensor
                || pDevice.hardwareType == Device.HardwareType.uvSensor
                || pDevice.hardwareType == Device.HardwareType.smartSecuritySensor{
                    var aSensorSettingsDict :Dictionary<String,Any?> = Dictionary<String,Any?>()
                    aSensorSettingsDict.updateValue(434, forKey: "lightIntensityLimit")
                    aSensorSettingsDict.updateValue(1, forKey: "motionLightState")
                    aSensorSettingsDict.updateValue(1, forKey: "motionLightTimeout")
                    aSensorSettingsDict.updateValue(2, forKey: "motionNotificateState")
                    aSensorSettingsDict.updateValue(1, forKey: "sirenState")
                    aSensorSettingsDict.updateValue(1, forKey: "sirenTimeout")

                    let aSaveSensorDispatchSemaphore = DispatchSemaphore(value: 0)
                    self.database
                        .child("sensorSetting")
                        .child(pDevice.id!)
                        .setValue(aSensorSettingsDict, withCompletionBlock: { (pError, pDatabaseReference) in
                            anError = pError
                            aSaveSensorDispatchSemaphore.signal()
                        })
                    _ = aSaveSensorDispatchSemaphore.wait(timeout: .distantFuture)
                }
                if pDevice.hardwareType == Device.HardwareType.smartSensorBattery {
                    var aSensorSettingsDict :Dictionary<String,Any?> = Dictionary<String,Any?>()
                    aSensorSettingsDict.updateValue("4500", forKey: "wakeUpTimeExtreme")
                    aSensorSettingsDict.updateValue("2500", forKey: "wakeUpTimeLow")
                    aSensorSettingsDict.updateValue("3600", forKey: "wakeUpTimeMedium")
                    aSensorSettingsDict.updateValue("1", forKey: "sensorState")
                    aSensorSettingsDict.updateValue("3", forKey: "batterySaverMode")
                    aSensorSettingsDict.updateValue("0010", forKey: "motionTimeOutExtreme")
                    aSensorSettingsDict.updateValue("0030", forKey: "motionTimeOutLow")
                    aSensorSettingsDict.updateValue("0020", forKey: "motionTimeOutMedium")
                    self.database
                        .child("sensorSetting")
                        .child(pDevice.id!)
                        .setValue(aSensorSettingsDict, withCompletionBlock: { (pError, pDatabaseReference) in
                            anError = pError
                        })
                }else if pDevice.hardwareType == Device.HardwareType.smokeDetectorBattery{
                    var aSensorSettingsDict :Dictionary<String,Any?> = Dictionary<String,Any?>()
                    aSensorSettingsDict.updateValue("3", forKey: "batterySaverMode")
                    aSensorSettingsDict.updateValue("3", forKey: "sensorSensitivity")
                    aSensorSettingsDict.updateValue("1", forKey: "sensorState")
                    aSensorSettingsDict.updateValue("0600", forKey: "wakeUpTime")
                    aSensorSettingsDict.updateValue("1200", forKey: "wakeUpTimeExtreme")
                    aSensorSettingsDict.updateValue("0600", forKey: "wakeUpTimeLow")
                    aSensorSettingsDict.updateValue("0900", forKey: "wakeUpTimeMedium")
                    aSensorSettingsDict.updateValue("1500", forKey: "sensorSensitivityLow")
                    aSensorSettingsDict.updateValue("1900", forKey: "sensorSensitivityHigh")
                    self.database
                        .child("sensorSetting")
                        .child(pDevice.id!)
                        .setValue(aSensorSettingsDict, withCompletionBlock: { (pError, pDatabaseReference) in
                            anError = pError
                        })
                }else if pDevice.hardwareType == Device.HardwareType.VDP{
                    self.database
                        .child("vdpDevices")
                        .child(pDevice.id!)
                        .setValue(aDeviceDict, withCompletionBlock: { (pError, pDatabaseReference) in
                            anError = pError
                        })
                    aDeviceVdp.updateValue("", forKey: "msgContent")
                    aDeviceVdp.updateValue("", forKey: "msgType")
                    for i in 0..<2{
                        var refs = self.database
                            .child("vdpCustomMessages")
                            .child(pDevice.id!).childByAutoId().key
                        aDeviceVdp.updateValue(refs, forKey: "msgId")
                        if i == 0{
                            aDeviceVdp.updateValue("hello", forKey: "msgContent")
                            aDeviceVdp.updateValue("welcomeMessage", forKey: "msgType")
                        }else{
                            aDeviceVdp.updateValue("You can try after some time", forKey: "msgContent")
                            aDeviceVdp.updateValue("timeoutMessage", forKey: "msgType")
                        }
                        self.database
                            .child("vdpCustomMessages")
                            .child(pDevice.id!).child(refs ?? "")
                            .setValue(aDeviceVdp, withCompletionBlock: { (pError, pDatabaseReference) in
                                anError = pError
                            })
                    }
                }
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, pDevice)
            }
        }
        
    }
    
    
    func deviceIdsForLoggedInUser(roomId pRoomId :String?) -> Array<String>? {
        var aReturnVal :Array<String>?
        
        if let aRoomId = pRoomId {
            let aDispatchSemaphore = DispatchSemaphore(value: 0)
            self.database
                .child("rooms")
                .child(Auth.auth().currentUser!.uid)
                .child(aRoomId)
                .child("devices")
                .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot, str) in
                 //    aReturnVal = pDataSnapshot.value as? Array<String>
                    if let arrayOfOptionals = pDataSnapshot.value as? Array<String>{
                           let x = self.nullArrayRemove(pdata: arrayOfOptionals as! Array<String?>)
                          aReturnVal = x
                    }
                     aDispatchSemaphore.signal()
                }
            _ = aDispatchSemaphore.wait(timeout: .distantFuture)
        } else {
            if let aRoomIdArray = self.roomIdsForLoggedInUser() {
                var aFetchedRoomIdArray = Array<String>()
               // SearchApplianceController.applinceId = aRoomIdArray
                for aRoomId in aRoomIdArray {
                    let aDispatchSemaphore = DispatchSemaphore(value: 0)
                    self.database
                        .child("rooms")
                        .child(Auth.auth().currentUser!.uid)
                        .child(aRoomId)
                        .child("devices")
                        .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                            if let aDeviceIdArray = pDataSnapshot.value as? Array<String> {
                                aFetchedRoomIdArray.append(contentsOf: aDeviceIdArray)
                            }
                            
                            aDispatchSemaphore.signal()
                        }
                    _ = aDispatchSemaphore.wait(timeout: .distantFuture)
                }
                if aFetchedRoomIdArray.count > 0 {
                    aReturnVal = aFetchedRoomIdArray
                }
            }
        }
        
        /*
        // Fetch devices
        let aDispatchSemaphore = DispatchSemaphore(value: 0)
        self.database
            .child("devices")
            .queryOrdered(byChild: "uid")
            .queryEqual(toValue: Auth.auth().currentUser!.uid)
            .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                if let aDict = pDataSnapshot.value as? Dictionary<String,Dictionary<String,Any>> {
                    aDeviceArray = DataContractManagerFireBase.devices(dict: aDict)
                }
                if pRoom != nil {
                    aDeviceArray = aDeviceArray?.filter({ (pDevice) -> Bool in
                        return pDevice.room?.id == pRoom?.id
                    })
                }
                
                if pHardwareTypeArray != nil {
                    aDeviceArray = aDeviceArray?.filter({ (pDevice) -> Bool in
                        var aReturnVal = false
                        if let aHardwareType = pDevice.hardwareType {
                            aReturnVal = pHardwareTypeArray!.contains(aHardwareType)
                        }
                        return aReturnVal
                    })
                }
                
                // Sort devices
                aDeviceArray?.sort { (pLhs, pRhs) -> Bool in
                    return (pLhs.title?.lowercased() ?? "") < (pRhs.title?.lowercased() ?? "")
                }
                aDispatchSemaphore.signal()
            }
        _ = aDispatchSemaphore.wait(timeout: .distantFuture)
         */
        
        return aReturnVal
    }
    func nullArrayRemove(pdata: Array<String?>) -> Array<String> {
        let filteredArray = pdata.compactMap { $0 }
        return filteredArray
    }
    
    func searchDevice(completion pCompletion: @escaping (Error?, Array<Device>?) -> Void, room pRoom :Room?, hardwareTypes pHardwareTypeArray :Array<Device.HardwareType>?) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aDeviceArray :Array<Device>? = Array<Device>()
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Fetch devices
                if let aDeviceIdArray = self.deviceIdsForLoggedInUser(roomId: pRoom?.id) {
                    var aFetchedDeviceArray = Array<Device>()
                    for aDeviceId in aDeviceIdArray {
                        let anApplianceDispatchSemaphore = DispatchSemaphore(value: 0)
                        self.database
                            .child("devices")
                            .child(aDeviceId)
                            .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                                if let aDict = pDataSnapshot.value as? Dictionary<String,Any>
                                   , let aDevice = DataContractManagerFireBase.device(dict: aDict) {
                                    aFetchedDeviceArray.append(aDevice)
                                }
                                anApplianceDispatchSemaphore.signal()
                            }
                        _ = anApplianceDispatchSemaphore.wait(timeout: .distantFuture)
                    }
                    
                    // Filter devices with hardware types
                    if pHardwareTypeArray != nil {
                        aFetchedDeviceArray = aFetchedDeviceArray.filter({ (pDevice) -> Bool in
                            var aReturnVal = false
                            if let aHardwareType = pDevice.hardwareType {
                                aReturnVal = pHardwareTypeArray!.contains(aHardwareType)
                            }
                            return aReturnVal
                        })
                    }
                    
                    // Fetch added appliances devices
                    for aDevice in aFetchedDeviceArray {
                        var aFetchedApplianceArray = Array<Appliance>()
                        
                        let aDispatchSemaphore = DispatchSemaphore(value: 0)
                        self.database
                            .child("applianceDetails")
                            .child(aDevice.id!)
                            .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                                if let anArray = DataContractManagerFireBase.appliances(any: pDataSnapshot.value) {
                                    aFetchedApplianceArray.append(contentsOf: anArray)
                                }
                                aDispatchSemaphore.signal()
                            }
                        _ = aDispatchSemaphore.wait(timeout: .distantFuture)
                        
                        aFetchedApplianceArray.sort { (pLhs, pRhs) -> Bool in
                            return (pLhs.title?.lowercased() ?? "") < (pRhs.title?.lowercased() ?? "")
                        }
                        
                        if aFetchedApplianceArray.count > 0 {
                            aDevice.addedAppliances = aFetchedApplianceArray
                        }
                    }
                    
                    // Sort devices
                    aFetchedDeviceArray.sort { (pLhs, pRhs) -> Bool in
                        return (pLhs.title?.lowercased() ?? "") < (pRhs.title?.lowercased() ?? "")
                    }
                    
                    if aFetchedDeviceArray.count > 0 {
                        aDeviceArray = aFetchedDeviceArray
                    }
                }
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, aDeviceArray)
            }
        }
        
    }
    
    
    func deviceDetails(completion pCompletion: @escaping (Error?, Device?) -> Void, device pDevice :Device) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aDevice :Device?
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                if (pDevice.id?.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Device ID can not be empty."])
                }
                
                // Fetch device details
                let aRemoteDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("devices")
                    .child(pDevice.id!)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Any> {
                            aDevice = DataContractManagerFireBase.device(dict: aDict)
                        }
                        aRemoteDispatchSemaphore.signal()
                    }
                _ = aRemoteDispatchSemaphore.wait(timeout: .distantFuture)
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, aDevice)
            }
        }
        
    }
    
    
    func deviceKeepAliveValueSync(deviceId pDeviceId :String) -> Bool {
        var aReturnVal = false
        
        let aDispatchSemaphore = DispatchSemaphore(value: 0)
        self.database
            .child("keepAlive")
            .child(pDeviceId)
            .child("online")
            .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                aReturnVal = (pDataSnapshot.value as? Bool) ?? false
                aDispatchSemaphore.signal()
            }
        _ = aDispatchSemaphore.wait(timeout: .distantFuture)
        
        return aReturnVal
    }
}
