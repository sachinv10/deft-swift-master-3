//
//  DataFetchManagerFireBaseAppliance.swift
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
    
    func saveAppliance(completion pCompletion: @escaping (Error?, Appliance?) -> Void, appliance pAppliance :Appliance) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                if (pAppliance.hardwareId?.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Hardware id is not available."])
                }
                
                let anApplianceId = pAppliance.id ?? self.getAvailableApplianceId(deviceId: pAppliance.hardwareId!)
                if (anApplianceId?.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Appliance id is not available."])
                }
                
                let aStatus = self.deviceKeepAliveValueSync(deviceId: pAppliance.hardwareId!)
                
                var anApplianceDict :Dictionary<String,Any?> = Dictionary<String,Any?>()
                anApplianceDict.updateValue(pAppliance.title, forKey: "applianceName")
                anApplianceDict.updateValue(pAppliance.type?.title, forKey: "applianceType")
                anApplianceDict.updateValue(pAppliance.type?.rawValue, forKey: "applianceTypeId")
                anApplianceDict.updateValue(pAppliance.stripType?.title, forKey: "stripType")
                anApplianceDict.updateValue(pAppliance.brandTitle, forKey: "brand")
                anApplianceDict.updateValue(pAppliance.dimmableValue, forKey: "dimableValue")
                anApplianceDict.updateValue(pAppliance.isDimmable, forKey: "dimmable")
                anApplianceDict.updateValue(pAppliance.dimType?.rawValue, forKey: "dimType")
                anApplianceDict.updateValue(0, forKey: "triacDimValue")
                anApplianceDict.updateValue(pAppliance.dimmableValueMin, forKey: "minDimming")
                anApplianceDict.updateValue(pAppliance.dimmableValueMax, forKey: "maxDimming")
                anApplianceDict.updateValue(nil, forKey: "energy")
                anApplianceDict.updateValue(pAppliance.hardwareId, forKey: "hardwareId")
                anApplianceDict.updateValue(anApplianceId, forKey: "id")
                anApplianceDict.updateValue(0, forKey: "lastOperated")
                anApplianceDict.updateValue(false, forKey: "lock")
                anApplianceDict.updateValue(0, forKey: "lockToggle")
                anApplianceDict.updateValue(0, forKey: "onTime")
                anApplianceDict.updateValue(false, forKey: "processing")
                anApplianceDict.updateValue(pAppliance.roomId, forKey: "roomId")
                anApplianceDict.updateValue(pAppliance.roomTitle, forKey: "roomName")
                anApplianceDict.updateValue(false, forKey: "state")
                anApplianceDict.updateValue(aStatus, forKey: "status")
                anApplianceDict.updateValue(pAppliance.operatedCount, forKey: "applianceOperatedCount")
                anApplianceDict.updateValue(Auth.auth().currentUser?.uid, forKey: "uid")
                
                let anApplianceDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("applianceDetails")
                    .child(pAppliance.hardwareId!)
                    .child(anApplianceId!)
                    .setValue(anApplianceDict, withCompletionBlock: { (pError, pDatabaseReference) in
                        anError = pError
                        pAppliance.id = anApplianceId
                        anApplianceDispatchSemaphore.signal()
                    })
                _ = anApplianceDispatchSemaphore.wait(timeout: .distantFuture)
                
                // Save appliance switch-type in device node
                let aSwitchTypeDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("devices")
                    .child(pAppliance.hardwareId!)
                    .child("switchType")
                    .child(pAppliance.id!)
                    .setValue(pAppliance.type!.title, withCompletionBlock: { (pError, pDatabaseReference) in
                        anError = pError
                        pAppliance.id = anApplianceId
                        aSwitchTypeDispatchSemaphore.signal()
                    })
                _ = aSwitchTypeDispatchSemaphore.wait(timeout: .distantFuture)
                
                // Save appliance switch-name in device node
                let aSwitchNameDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("devices")
                    .child(pAppliance.hardwareId!)
                    .child("switchName")
                    .child(pAppliance.id!)
                    .setValue(pAppliance.title!, withCompletionBlock: { (pError, pDatabaseReference) in
                        anError = pError
                        pAppliance.id = anApplianceId
                        aSwitchNameDispatchSemaphore.signal()
                    })
                _ = aSwitchNameDispatchSemaphore.wait(timeout: .distantFuture)
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, pAppliance)
            }
        }
        
    }
    
    
    func searchAppliance(completion pCompletion: @escaping (Error?, Array<Appliance>?,Array<String>?) -> Void, room pRoom :Room?, includeOnOnly pIncludeOnOnly :Bool) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anApplianceArray: Array<Appliance>?
            var deviceIdArray: Array<String>?
            var anError: Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                if let aDeviceIdArray = self.deviceIdsForLoggedInUser(roomId: pRoom?.id) {
                    deviceIdArray = aDeviceIdArray
                    SearchApplianceController.applinceId = aDeviceIdArray
                    var aFetchedApplianceArray = Array<Appliance>()
                    for aDeviceId in aDeviceIdArray {
                        let aDispatchSemaphore = DispatchSemaphore(value: 0)
                        self.database
                            .child("applianceDetails")
                            .child(aDeviceId)
                            .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                                if let anArray = DataContractManagerFireBase.appliances(any: pDataSnapshot.value) {
                                    aFetchedApplianceArray.append(contentsOf: anArray)
                                }
                                aDispatchSemaphore.signal()
                            }
                        _ = aDispatchSemaphore.wait(timeout: .distantFuture)
                    }
                    if aFetchedApplianceArray.count > 0 {
                        if pIncludeOnOnly {
                            anApplianceArray = aFetchedApplianceArray.filter({ (pAppliance) -> Bool in
                                return pAppliance.isOn
                            })
                        } else {
                            anApplianceArray = aFetchedApplianceArray
                        }
                        anApplianceArray?.sort { (pLhs, pRhs) -> Bool in
                            return (pLhs.title?.lowercased() ?? "") < (pRhs.title?.lowercased() ?? "")
                        }
                    }
                }
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, anApplianceArray,deviceIdArray)
            }
        }
        
    }
    
    
    func updateAppliancePowerState(completion pCompletion: @escaping (Error?) -> Void, appliance pAppliance :Appliance, powerState pPowerState :Bool) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                if (pAppliance.id?.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Appliance ID is not available."])
                }
                
                // NO NEED TO update state in database
                
                // Send message and reset it
                var aDimValue = 0
                if pAppliance.dimType == Appliance.DimType.rc {
                    aDimValue = pAppliance.dimmableValue ?? 5
                } else if pAppliance.dimType == Appliance.DimType.triac {
                    aDimValue = pAppliance.dimmableValueTriac ?? 99
                }
                let aMessageValue = Appliance.command(appliance: pAppliance, powerState: pPowerState, dimValue: aDimValue)
                anError = self.sendMessage(aMessageValue, entity: pAppliance)
                if anError != nil {
                    throw anError!
                }
                
                // Update frequent usage count
                if let aCount = self.fetchApplianceProperty(pAppliance, propertyName: "applianceOperatedCount") as? Int {
                    anError = self.updateApplianceProperty(pAppliance, propertyName: "applianceOperatedCount", propertyValue: aCount + 1)
                }
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
    
    
    func updateApplianceDimmableValue(completion pCompletion: @escaping (Error?) -> Void, appliance pAppliance :Appliance, dimValue pDimValue :Int) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // NO NEED TO update state in database
                
                // Send message and reset it
                let aMessageValue = Appliance.command(appliance: pAppliance, powerState: pAppliance.isOn, dimValue: pDimValue)
                anError = self.sendMessage(aMessageValue, entity: pAppliance)
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
    
    
    func updateAppliance(completion pCompletion: @escaping (Error?) -> Void, appliance pAppliance :Appliance, property1 pProperty1 :Int, property2 pProperty2 :Int, property3 pProperty3 :Int, glowPatternValue pGlowPatternValue :Int) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // NO NEED TO update state in database
                
                // Send message and reset it
                var aMessageValue = ""
                if pAppliance.slaveId != nil {
                    // Not available in DEFT
                } else if pAppliance.hardwareId != nil {
                    aMessageValue += "#l0230"
                    aMessageValue += ":"
                    aMessageValue += String(format: "%02d", pGlowPatternValue)
                    aMessageValue += ":"
                    aMessageValue += String(format: "%03d", pProperty1)
                    aMessageValue += ":"
                    aMessageValue += String(format: "%03d", pProperty2)
                    aMessageValue += ":"
                    aMessageValue += String(format: "%03d", pProperty3)
                    aMessageValue += ":"
                    aMessageValue += "0F"
                }
                anError = self.sendMessage(aMessageValue, entity: pAppliance)
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
    
    func updateDevice(completion pCompletion: @escaping (Error?) -> Void, deviceId: String) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // NO NEED TO update state in database
                
                // Send message and reset it
                anError = self.sendMessage("B2F", entity: deviceId)
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

    func updateDeviceDimabble(completion pCompletion: @escaping (Error?) -> Void, deviceId: String, dimValue: Int) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // NO NEED TO update state in database
                
                // Send message and reset it
                anError = self.sendMessage("Bb2\(dimValue)F", entity: deviceId)
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

    
    private func updateApplianceProperty(_ pAppliance :Appliance, propertyName pPropertyName :String, propertyValue pPropertyValue :Any) -> Error? {
        var aReturnVal :Error? = nil
        
        
        return aReturnVal
    }
    
    
    private func fetchApplianceProperty(_ pAppliance :Appliance, propertyName pPropertyName :String) -> Any? {
        var aReturnVal :Any? = nil
        
        
        return aReturnVal
    }
    
    
    func deleteAppliance(completion pCompletion: @escaping (Error?, Appliance?) -> Void, appliance pAppliance :Appliance) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                if (pAppliance.hardwareId?.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Hardware id is not available."])
                }
                
                if (pAppliance.id?.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Appliance id is not available."])
                }
                
                // Delete appliance from applianceDetails node
                let anApplianceDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("applianceDetails")
                    .child(pAppliance.hardwareId!)
                    .child(pAppliance.id!)
                    .removeValue(completionBlock: { (pError, pDatabaseReference) in
                        anError = pError
                        anApplianceDispatchSemaphore.signal()
                    })
                _ = anApplianceDispatchSemaphore.wait(timeout: .distantFuture)
                
                // Delete appliance switch-type from device node
                let aSwitchTypeDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("devices")
                    .child(pAppliance.hardwareId!)
                    .child("switchType")
                    .child(pAppliance.id!)
                    .removeValue(completionBlock: { (pError, pDatabaseReference) in
                        anError = pError
                        aSwitchTypeDispatchSemaphore.signal()
                    })
                _ = aSwitchTypeDispatchSemaphore.wait(timeout: .distantFuture)
                
                // Delete appliance switch-name from device node
                let aSwitchNameDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("devices")
                    .child(pAppliance.hardwareId!)
                    .child("switchName")
                    .child(pAppliance.id!)
                    .removeValue(completionBlock: { (pError, pDatabaseReference) in
                        anError = pError
                        aSwitchNameDispatchSemaphore.signal()
                    })
                _ = aSwitchNameDispatchSemaphore.wait(timeout: .distantFuture)
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, pAppliance)
            }
        }
        
    }
    
    
    func getAvailableApplianceId(deviceId pDeviceId :String) -> String? {
        var aReturnVal :String? = nil
        
        var aSwitchCount = 0
        if let aHardwareType = Device.getHardwareType(id: pDeviceId)
        , let aCount = Device.getSwitchCount(hardwareType: aHardwareType) {
            aSwitchCount = aCount
        }
        
        var anOccupiedIdArray = Array<Int>()
        let aDispatchSemaphore = DispatchSemaphore(value: 0)
        self.database
            .child("applianceDetails")
            .child(pDeviceId)
            .queryOrderedByKey()
            .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                if let anArray = (pDataSnapshot.value as? Array<Dictionary<String,Any>?>) {
                    for aDict in anArray {
                        if let anIdString = aDict?["id"] as? String, let anId = Int(anIdString) {
                            anOccupiedIdArray.append(anId)
                        }
                    }
                }
                aDispatchSemaphore.signal()
            }
        _ = aDispatchSemaphore.wait(timeout: .distantFuture)
        
        anOccupiedIdArray = anOccupiedIdArray.sorted()
        
        for anIndex in stride(from: 0, to: aSwitchCount, by: 1) {
            if anIndex < anOccupiedIdArray.count && anOccupiedIdArray[anIndex] != anIndex {
                aReturnVal = String(format: "%d", anIndex)
                break
            } else if anOccupiedIdArray.count == anIndex {
                aReturnVal = String(format: "%d", anIndex)
                break
            }
        }
        
        return aReturnVal
    }
    
    func checkToShowApplianceDimmable(completion pCompletion: @escaping (Bool?) -> Void, room : Room?) {
       
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            var returnValue : Bool? = false

            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                let aDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("rooms")
                    .child(Auth.auth().currentUser!.uid)
                    .child(room!.id!)
                    .child("dimmable")
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        if let aReturnVal = pDataSnapshot.value as? Bool {
                            returnValue = aReturnVal
                        }
                        aDispatchSemaphore.signal()
                    }
                _ = aDispatchSemaphore.wait(timeout: .distantFuture)
            } catch {
                //anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(returnValue)
            }
        }
        
        
        
        
    }
}
