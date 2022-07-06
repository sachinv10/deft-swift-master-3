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
    
    func appliance(withUuid pUuid :String) -> Appliance? {
        var aReturnVal :Appliance? = nil
        
        // Fetch appliance details
        let aDispatchSemaphore = DispatchSemaphore(value: 0)
        self.database
            .child("ApplianceDetails")
            .child(Auth.auth().currentUser!.uid)
            .queryOrdered(byChild: "uuid")
            .queryEqual(toValue: pUuid)
            .queryLimited(toFirst: 1)
            .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                if let aResult = pDataSnapshot.value as? Dictionary<String, Dictionary<String, Any>>
                   , let anAppliance = DataContractManagerFireBase.appliances(dict: aResult)?.first {
                    aReturnVal = anAppliance
                }
                aDispatchSemaphore.signal()
            }
        _ = aDispatchSemaphore.wait(timeout: .distantFuture)
        
        return aReturnVal
    }
    
    func saveAppliance(completion pCompletion: @escaping (Error?, Appliance?) -> Void, appliance pAppliance :Appliance) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Update title in database
                anError = self.updateApplianceProperty(pAppliance, propertyName: "applianceName", propertyValue: pAppliance.title)
                if anError != nil {
                    throw anError!
                }
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, pAppliance)
            }
        }
        
    }
    
    
    func searchAppliance(completion pCompletion: @escaping (Error?, Array<Appliance>?) -> Void, room pRoom :Room?, includeOnOnly pIncludeOnOnly :Bool) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anApplianceArray :Array<Appliance>?
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Fetch frequently operated appliances
                let anApplianceDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("ApplianceDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        self.log(dataSnapshot: pDataSnapshot)
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Dictionary<String,Any>> {
                            anApplianceArray = DataContractManagerFireBase.appliances(dict: aDict)
                        }
                        if pRoom != nil {
                            anApplianceArray = anApplianceArray?.filter({ (pAppliance) -> Bool in
                                return pAppliance.roomId == pRoom?.id
                            })
                        }
                        if pIncludeOnOnly {
                            anApplianceArray = anApplianceArray?.filter({ (pAppliance) -> Bool in
                                return pAppliance.isOn
                            })
                        }
                        
                        // Sort frequently operated appliances
                        anApplianceArray?.sort { (pLhs, pRhs) -> Bool in
                            return (pLhs.title?.lowercased() ?? "") < (pRhs.title?.lowercased() ?? "")
                        }
                        anApplianceDispatchSemaphore.signal()
                    }
                _ = anApplianceDispatchSemaphore.wait(timeout: .distantFuture)
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, anApplianceArray)
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
                
                // Update state in database
                anError = self.updateApplianceProperty(pAppliance, propertyName: "state", propertyValue: pPowerState)
                if anError != nil {
                    throw anError!
                }
                
                // Send message and reset it
                var aMessageValue = ""
                if pAppliance.slaveId != nil {
                    aMessageValue += "C012"
                    aMessageValue += pAppliance.roomId!
                    aMessageValue += pAppliance.slaveId!
                    aMessageValue += pAppliance.id!
                    aMessageValue += DataContractManagerFireBase.isOnCommandValue(pPowerState)
                    aMessageValue += DataContractManagerFireBase.isDimmableCommandValue(pAppliance.isDimmable)
                    aMessageValue += String(format: "%d", pAppliance.dimmableValue ?? 0)
                    aMessageValue += "00000F"
                } else if pAppliance.hardwareId != nil {
                    if pAppliance.hardwareId?.starts(with: "C0") == true {
                        aMessageValue += "C023"
                        aMessageValue += pAppliance.id!
                        aMessageValue += DataContractManagerFireBase.isOnCommandValue(pPowerState)
                        aMessageValue += DataContractManagerFireBase.isDimmableCommandValue(pAppliance.isDimmable)
                        aMessageValue += String(format: "%d", pAppliance.dimmableValue ?? 0)
                        aMessageValue += "F"
                    } else if pAppliance.hardwareId?.starts(with: "CT") == true {
                        aMessageValue += "C023"
                        aMessageValue += pAppliance.id!
                        aMessageValue += DataContractManagerFireBase.isOnCommandValue(pPowerState)
                        aMessageValue += DataContractManagerFireBase.isDimmableCommandValue(pAppliance.isDimmable)
                        aMessageValue += "5"
                        if pAppliance.dimType == Appliance.DimType.rc {
                            aMessageValue += String(format: "%d", pAppliance.dimmableValue ?? 0)
                            aMessageValue += "99F"
                        } else if pAppliance.dimType == Appliance.DimType.triac {
                            let aDimmableValue :Int = UtilityManager.dimmableValueFromSliderValue(appliance: pAppliance, sliderValue: pAppliance.dimmableValueTriac ?? 1)
                            aMessageValue += String(format: "%02d", aDimmableValue)
                            aMessageValue += "F"
                        }
                    } else if pAppliance.hardwareId?.starts(with: "CL") == true {
                        // This will be handled in updateAppliance:property1:property2:property3
                    }
                    
                }
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
                var aMessageValue = ""
                if pAppliance.slaveId != nil {
                    aMessageValue += "C012"
                    aMessageValue += pAppliance.roomId!
                    aMessageValue += pAppliance.slaveId!
                    aMessageValue += pAppliance.id!
                    aMessageValue += DataContractManagerFireBase.isOnCommandValue(pAppliance.isOn)
                    aMessageValue += DataContractManagerFireBase.isDimmableCommandValue(pAppliance.isDimmable)
                    if pAppliance.dimType == Appliance.DimType.rc {
                        aMessageValue += String(format: "%d", pDimValue)
                        aMessageValue += "99000F"
                    } else if pAppliance.dimType == Appliance.DimType.triac {
                        aMessageValue += "5"
                        aMessageValue += String(format: "%02d", pDimValue)
                        aMessageValue += "000F"
                    } else {
                        aMessageValue += String(format: "%d", pDimValue)
                        aMessageValue += "99000F"
                    }
                } else if pAppliance.hardwareId != nil {
                    if pAppliance.hardwareId?.starts(with: "C0") == true {
                        aMessageValue += "C023"
                        aMessageValue += pAppliance.id!
                        aMessageValue += DataContractManagerFireBase.isOnCommandValue(pAppliance.isOn)
                        aMessageValue += DataContractManagerFireBase.isDimmableCommandValue(pAppliance.isDimmable)
                        aMessageValue += String(format: "%d", pDimValue)
                        aMessageValue += "F"
                    } else if pAppliance.hardwareId?.starts(with: "CT") == true {
                        aMessageValue += "C023"
                        aMessageValue += pAppliance.id!
                        aMessageValue += DataContractManagerFireBase.isOnCommandValue(pAppliance.isOn)
                        aMessageValue += DataContractManagerFireBase.isDimmableCommandValue(pAppliance.isDimmable)
                        aMessageValue += "5"
                        if pAppliance.dimType == Appliance.DimType.rc {
                            aMessageValue += String(format: "%d", pDimValue)
                            aMessageValue += "99F"
                        } else if pAppliance.dimType == Appliance.DimType.triac {
                            aMessageValue += String(format: "%02d", pDimValue)
                            aMessageValue += "F"
                        }
                    } else if pAppliance.hardwareId?.starts(with: "CL") == true {
                        // This will be handled in updateAppliance:property1:property2:property3
                    }
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
    
    
    func updateAppliance(completion pCompletion: @escaping (Error?) -> Void, appliance pAppliance :Appliance, property1 pProperty1 :Int, property2 pProperty2 :Int, property3 pProperty3 :Int, glowPatternValue pGlowPatternValue :Int) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Update state in database
                if pGlowPatternValue == Appliance.GlowPatternType.on.rawValue {
                    anError = self.updateApplianceProperty(pAppliance, propertyName: "state", propertyValue: true)
                    if anError != nil {
                        throw anError!
                    }
                } else if pGlowPatternValue == Appliance.GlowPatternType.off.rawValue {
                    anError = self.updateApplianceProperty(pAppliance, propertyName: "state", propertyValue: false)
                    if anError != nil {
                        throw anError!
                    }
                }
                
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
    
    
    private func updateApplianceProperty(_ pAppliance :Appliance, propertyName pPropertyName :String, propertyValue pPropertyValue :Any) -> Error? {
        var aReturnVal :Error? = nil
        
        do {
            var anError :Error? = nil
            
            // Update property (old version)
            if pAppliance.slaveId != nil {
                let aField :DatabaseReference = self.database
                    .child("rooms")
                    .child(Auth.auth().currentUser!.uid)
                    .child(pAppliance.roomId!)
                    .child(pAppliance.slaveId!)
                    .child(pAppliance.id!)
                    .child(pPropertyName)
                let anApplianceDispatchSemaphore = DispatchSemaphore(value: 0)
                aField.setValue(pPropertyValue, withCompletionBlock: { (pError, pDatabaseReference) in
                    self.log(databaseReference: pDatabaseReference)
                    anError = pError
                    anApplianceDispatchSemaphore.signal()
                })
                _ = anApplianceDispatchSemaphore.wait(timeout: .distantFuture)
                if anError != nil {
                    throw anError!
                }
            }
            
            // Update on-off flag (new version)
            var aPowerStateField :DatabaseReference? = nil
            if pAppliance.slaveId != nil {
                aPowerStateField = self.database
                    .child("ApplianceDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .child(String(format: "%@%@%@", pAppliance.roomId!, pAppliance.slaveId!, pAppliance.id!))
                    .child(pPropertyName)
            } else if pAppliance.hardwareId != nil {
                aPowerStateField = self.database
                    .child("ApplianceDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .child(String(format: "%@_%@", pAppliance.hardwareId!, pAppliance.id!))
                    .child(pPropertyName)
            }
            let aNewVersionApplianceDispatchSemaphore = DispatchSemaphore(value: 0)
            aPowerStateField?.setValue(pPropertyValue, withCompletionBlock: { (pError, pDatabaseReference) in
                self.log(databaseReference: pDatabaseReference)
                anError = pError
                aNewVersionApplianceDispatchSemaphore.signal()
            })
            _ = aNewVersionApplianceDispatchSemaphore.wait(timeout: .distantFuture)
            if anError != nil {
                throw anError!
            }
        } catch {
            aReturnVal = error
        }
        
        return aReturnVal
    }
    
    
    private func fetchApplianceProperty(_ pAppliance :Appliance, propertyName pPropertyName :String) -> Any? {
        var aReturnVal :Any? = nil
        
        var anOperatedCountField :DatabaseReference? = nil
        if pAppliance.slaveId != nil {
            anOperatedCountField = self.database
                .child("ApplianceDetails")
                .child(Auth.auth().currentUser!.uid)
                .child(String(format: "%@%@%@", pAppliance.roomId!, pAppliance.slaveId!, pAppliance.id!))
                .child("applianceOperatedCount")
        } else if pAppliance.hardwareId != nil {
            anOperatedCountField = self.database
                .child("ApplianceDetails")
                .child(Auth.auth().currentUser!.uid)
                .child(String(format: "%@_%@", pAppliance.hardwareId!, pAppliance.id!))
                .child("applianceOperatedCount")
        }
        let anOperatedCountDispatchSemaphore = DispatchSemaphore(value: 0)
        anOperatedCountField?.observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
            self.log(dataSnapshot: pDataSnapshot)
            aReturnVal = pDataSnapshot.value
            anOperatedCountDispatchSemaphore.signal()
        }
        _ = anOperatedCountDispatchSemaphore.wait(timeout: .distantFuture)
        
        return aReturnVal
    }
    
    
    func deleteAppliance(completion pCompletion: @escaping (Error?, Appliance?) -> Void, appliance pAppliance :Appliance) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(nil, pAppliance)
            }
        }
    }
    
}
