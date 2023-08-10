//
//  DataFetchManagerFireBaseCore.swift
//  Wifinity
//
//  Created by Vivek V. Unhale on 26/05/22.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import CoreMedia
import Firebase


extension DataFetchManagerFireBase {
    
    func saveCore(completion pCompletion: @escaping (Error?, Core?) -> Void, core pCore :Core) {
         DispatchQueue.global(qos: .background).async {
             self.requestCount += 1
 
             var anError :Error?
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                var devicesId: Dictionary<String, Any> = Dictionary<String, Any>()
              if let devices = pCore.deviceId{
                  for i in 0..<devices.count{
                    let id = String(i)
                      devicesId.updateValue(devices[i], forKey: id)
                   }
                }

              // Save schedule
                var aScheduleDict: Dictionary<String, Any> = Dictionary<String, Any>()
                var aCoreDataDict: Dictionary<String, Any> = Dictionary<String, Any>()
                var aWhenListDict: Dictionary<String, Any> = Dictionary<String, Any>()
                var aThenListDict: Dictionary<String, Any> = Dictionary<String, Any>()

                aScheduleDict.updateValue( pCore.createdBy!, forKey: "createdBy")
                aScheduleDict.updateValue( pCore.ifStatement!, forKey: "ifStatement")
                aScheduleDict.updateValue( pCore.isCreatedBySensor ?? false, forKey: "isCreatedBySensor")
                aScheduleDict.updateValue( pCore.ruleId!, forKey: "ruleId")
                aScheduleDict.updateValue( pCore.Operator, forKey: "operator")
                aScheduleDict.updateValue( pCore.ruleName!, forKey: "ruleName")
                aScheduleDict.updateValue( pCore.state!, forKey: "state")
                aScheduleDict.updateValue( pCore.thenStatement!, forKey: "thenStatement")
                aScheduleDict.updateValue( devicesId, forKey: "deviceId")
                print(aScheduleDict)
                if let coredata = pCore.coreEditData{
                    if (pCore.duration != nil){
                        aCoreDataDict.updateValue(pCore.duration!, forKey: "duration")
                    }
                    if (pCore.from != nil){
                        aCoreDataDict.updateValue(pCore.from!, forKey: "from")
                    }
                    if (pCore.to != nil){
                        aCoreDataDict.updateValue(pCore.to!, forKey: "to")
                    }
                    aCoreDataDict.updateValue(pCore.Operator, forKey: "operation")
                    aCoreDataDict.updateValue(pCore.ruleId!, forKey: "ruleId")
                    aCoreDataDict.updateValue(pCore.ruleName!, forKey: "ruleName")

                    //When
                    for item in 0..<coredata.whenSelectionList!.count{
                        var aWhenListDictt: Dictionary<String, Any> = Dictionary<String, Any>()

                        let iflist = coredata.whenSelectionList![item]
                        aWhenListDictt.updateValue(iflist.roomId!, forKey: "roomId")
                        aWhenListDictt.updateValue(iflist.roomName!, forKey: "roomName")
                        aWhenListDictt.updateValue(iflist.checked ?? true, forKey: "checked")
                        aWhenListDictt.updateValue(iflist.currentState, forKey: "currentState")
                        if iflist.routineType == "temperature" || iflist.routineType == "motion" || iflist.routineType == "light" {
                            aWhenListDictt.updateValue(iflist.routineType!, forKey: "routineType")
                            aWhenListDictt.updateValue(iflist.sensorTypeId!, forKey: "sensorTypeId")
                            aWhenListDictt.updateValue("\(iflist.appName!)(\(String(describing: iflist.routineType!)))", forKey: "sensorName")
                            aWhenListDictt.updateValue(iflist.hardwareId!, forKey: "id")
                            aWhenListDictt.updateValue(iflist.hardwareId!, forKey: "index")
                            aWhenListDictt.updateValue((iflist.state! != 1) ? true : false, forKey: "state")
                            aWhenListDictt.updateValue("\(iflist.uniqueKey!)\(iflist.sensorTypeId!)", forKey: "uniqueKey")
                            aWhenListDictt.updateValue(iflist.operators!, forKey: "operator")
                            aWhenListDictt.updateValue(iflist.intensity!, forKey: "intensity")
                        }else if iflist.routineType == "Curtain"{
                            aWhenListDictt.updateValue(0, forKey: "currentState")
                            aWhenListDictt.updateValue(iflist.hardwareId!, forKey: "curtainId")
                            aWhenListDictt.updateValue(iflist.currentLevel!, forKey: "currentLevel")

                        }else{
                          aWhenListDictt.updateValue(Core.gethardwareType(pid: iflist.hardwareId!, list: iflist)!, forKey: "routineType")
                            aWhenListDictt.updateValue(iflist.currentLevel!, forKey: "currentLevel")
                            aWhenListDictt.updateValue(iflist.appId!, forKey: "appId")
                            aWhenListDictt.updateValue(iflist.appName!, forKey: "appName")
                            aWhenListDictt.updateValue(iflist.dimValue!, forKey: "dimValue")
                            aWhenListDictt.updateValue(iflist.dimmable!, forKey: "dimmable")
                            aWhenListDictt.updateValue(iflist.hardwareId!, forKey: "hardwareId")
                            aWhenListDictt.updateValue(iflist.maxDimming, forKey: "maxDimming")
                            aWhenListDictt.updateValue(iflist.minDimming, forKey: "minDimming")
                            aWhenListDictt.updateValue(iflist.state!, forKey: "state")
                            aWhenListDictt.updateValue(iflist.uniqueKey!, forKey: "uniqueKey")
                        }
                        aWhenListDict.updateValue(aWhenListDictt, forKey: String(item))
                    }
                    if aWhenListDict.count > 0{
                        aCoreDataDict.updateValue(aWhenListDict, forKey: "whenSelectionList")
                    }
                    
                    //Then
                    for item in 0..<coredata.actionSelectionList!.count{
                        var aWhenListDictt: Dictionary<String, Any> = Dictionary<String, Any>()

                        let iflist = coredata.actionSelectionList![item]
                        aWhenListDictt.updateValue(iflist.checked ?? true, forKey: "checked")
                        aWhenListDictt.updateValue(iflist.roomId!, forKey: "roomId")
                        aWhenListDictt.updateValue(iflist.roomName ?? "", forKey: "roomName")
                      
                         if iflist.routineType == "curtain"{
                            aWhenListDictt.updateValue(0, forKey: "currentState")
                            aWhenListDictt.updateValue(iflist.hardwareId!, forKey: "curtainId")
                            aWhenListDictt.updateValue(iflist.currentLevel!, forKey: "currentLevel")
                            aWhenListDictt.updateValue(iflist.appName!, forKey: "curtainName")
                            aWhenListDictt.updateValue(iflist.currentType!, forKey: "curtainType")
                            aWhenListDictt.updateValue(iflist.routineType!, forKey: "routineType")
                            aWhenListDictt.updateValue(iflist.uniqueKey!, forKey: "uniqueKey")
                         }else if iflist.routineType == "remote"{
                             aWhenListDictt.updateValue(iflist.appName!, forKey: "appName")
                             aWhenListDictt.updateValue(iflist.uniqueKey!, forKey: "uniqueKey")
                             aWhenListDictt.updateValue(iflist.currentLevel!, forKey: "currentLevel")
                           //  aWhenListDictt.updateValue(iflist.hardwareId!, forKey: "hardwareId")
                             aWhenListDictt.updateValue(iflist.currentState, forKey: "currentState")
                             aWhenListDictt.updateValue(iflist.routineType!, forKey: "routineType")
                             aWhenListDictt.updateValue(iflist.dimValue!, forKey: "dimValue")
                             aWhenListDictt.updateValue(iflist.dimmable!, forKey: "dimmable")
                             aWhenListDictt.updateValue(iflist.maxDimming, forKey: "maxDimming")
                             aWhenListDictt.updateValue(iflist.minDimming, forKey: "minDimming")
                             aWhenListDictt.updateValue(iflist.state!, forKey: "state")
                         }else{
                             aWhenListDictt.updateValue(iflist.appId!, forKey: "appId")
                             aWhenListDictt.updateValue(iflist.appName!, forKey: "appName")
                             aWhenListDictt.updateValue(iflist.uniqueKey!, forKey: "uniqueKey")
                             aWhenListDictt.updateValue(iflist.currentLevel!, forKey: "currentLevel")
                             aWhenListDictt.updateValue(iflist.hardwareId!, forKey: "hardwareId")
                             aWhenListDictt.updateValue(iflist.currentState, forKey: "currentState")
                             aWhenListDictt.updateValue(Core.gethardwareType(pid: iflist.hardwareId!, list: iflist)!, forKey: "routineType")
                             aWhenListDictt.updateValue(iflist.dimValue!, forKey: "dimValue")
                             aWhenListDictt.updateValue(iflist.dimmable!, forKey: "dimmable")
                             aWhenListDictt.updateValue(iflist.maxDimming, forKey: "maxDimming")
                             aWhenListDictt.updateValue(iflist.minDimming, forKey: "minDimming")
                             aWhenListDictt.updateValue(iflist.state!, forKey: "state")
                            if iflist.stripType == Appliance.StripType.rgb{
                                aWhenListDictt.updateValue(String(format: "%03d", iflist.ledStripProperty1!)
                        , forKey: "property1")
                                aWhenListDictt.updateValue(String(format: "%03d",iflist.ledStripProperty2!), forKey: "property2")
                                aWhenListDictt.updateValue(String(format: "%03d",iflist.ledStripProperty3!), forKey: "property3")
                                aWhenListDictt.updateValue("rgb", forKey: "routineType")
                                aWhenListDictt.updateValue((iflist.stripType?.title ?? "RGB") as String, forKey: "stripType")
                                aWhenListDictt.updateValue(iflist.stripLightEvent!, forKey: "stripState")
                                aWhenListDictt.updateValue("Strip Light", forKey: "applianceType")
                         //       thank you everyone for the wonderfull birthaday wishesh
                             }
                         }
                        aThenListDict.updateValue(aWhenListDictt, forKey: String(item))
                    }
                    if aThenListDict.count > 0{
                        aCoreDataDict.updateValue(aThenListDict, forKey: "actionSelectionList")
                    }
                    aScheduleDict.updateValue( aCoreDataDict, forKey: "coreEditData")
                }
 
                let aScheduleDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("coreUI")
                    .child(Auth.auth().currentUser!.uid)
                    .child(pCore.ruleId!)
                    .setValue(aScheduleDict, withCompletionBlock: { (pError, pDatabaseReference) in
                        anError = pError
                        pCore.ruleId = pCore.ruleId
                        aScheduleDispatchSemaphore.signal()
                        pCompletion(anError, pCore)
                    })
                _ = aScheduleDispatchSemaphore.wait(timeout: .distantFuture)
             } catch {
                 anError = error
                 pCompletion(anError, pCore)
             }

            DispatchQueue.main.async {
                self.requestCount -= 1
               // pCompletion(anError, pCore)
            }
         }
 
     }
    func saveCoreForBackend(completion pCompletion: @escaping (Error?, Core?) -> Void, core pCore :Core) {
         DispatchQueue.global(qos: .background).async {
             self.requestCount += 1
 
             var anError :Error?
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
              var devicesId: Dictionary<String, Any> = Dictionary<String, Any>()
              if let devices = pCore.deviceId{
                  for i in 0..<devices.count{
                    let id = String(i)
                      devicesId.updateValue(devices[i], forKey: id)
                   }
                }

              // Save schedule
                var aScheduleDict: Dictionary<String, Any> = Dictionary<String, Any>()
                var coreDevices: Dictionary<String, Any> = Dictionary<String, Any>()
                var command: Dictionary<String, Any> = Dictionary<String, Any>()
                var ifDeviceId: Dictionary<String, Any> = Dictionary<String, Any>()
                var ifDeviceType: Dictionary<String, Any> = Dictionary<String, Any>()
                var ifState: Dictionary<String, Any> = Dictionary<String, Any>()
                var ifTempState: Dictionary<String, Any> = Dictionary<String, Any>()
                var operators: Dictionary<String, Any> = Dictionary<String, Any>()
                var offCommand: Dictionary<String, Any> = Dictionary<String, Any>()
                
                aScheduleDict.updateValue( pCore.ruleId!, forKey: "id")
                aScheduleDict.updateValue( pCore.Operator, forKey: "operation")
                aScheduleDict.updateValue( pCore.state!, forKey: "state")
                aScheduleDict.updateValue( Auth.auth().currentUser?.uid ?? "", forKey: "uid")
          
                if let coredata = pCore.coreEditData{
                 
                    //When ifDeviceId & ifDeviceType
                    for item in 0..<coredata.whenSelectionList!.count{
                        var aWhenListDictt: Dictionary<String, Any> = Dictionary<String, Any>()

                         let iflist = coredata.whenSelectionList![item]
                        let aIfDevice = DataContractManagerFireBase.coreIfDevicesId(dict: iflist)
                        ifDeviceId.updateValue(aIfDevice, forKey: String(item))
                        if iflist.routineType == "temperature"||iflist.routineType == "motion"||iflist.routineType == "light"{
                            ifDeviceType.updateValue("sensor", forKey: String(item))
                         let intenSity = iflist.intensity
                            ifState.updateValue(String(intenSity ?? 0), forKey: String(item))
                            ifTempState.updateValue("30", forKey: String(item))
                            operators.updateValue(iflist.operators ?? "", forKey: String(item))
                            let str = iflist.routineType
                            if let firstvalue = str?.first{
                                aWhenListDictt.updateValue("\(coredata.ruleId!):\(String(item)):\(String(describing: firstvalue))", forKey: "expression")
                            }
                            aWhenListDictt.updateValue("Sensor", forKey: "coreComponentType")
                        }else if iflist.routineType == "Curtain"{
                            let intenSity = iflist.state
                            ifState.updateValue(String(intenSity! ), forKey: String(item))
                            ifTempState.updateValue("2", forKey: String(item))
                            ifDeviceType.updateValue(iflist.routineType!.lowercased(), forKey: String(item))
                            operators.updateValue("=", forKey: String(item))
                            aWhenListDictt.updateValue("Curtain", forKey: "coreComponentType")
                            aWhenListDictt.updateValue("\(coredata.ruleId!):\(String(item)):C", forKey: "expression")
                        }else{
                            ifDeviceType.updateValue(iflist.routineType!, forKey: String(item))
                            if iflist.dimmable ?? false{
                                ifState.updateValue(iflist.state! == 2 ? "true:\(String(iflist.dimValue!))" : "false", forKey: String(item))
                            }else{  ifState.updateValue(iflist.state! == 2 ? "true" : "false", forKey: String(item))}
                            ifTempState.updateValue(iflist.currentState ? "true":"false", forKey: String(item))
                            aWhenListDictt.updateValue("\(coredata.ruleId!):\(String(item)):\(iflist.dimmable! == true ? "b":"a")", forKey: "expression")
                            aWhenListDictt.updateValue(iflist.appId!, forKey: "applianceId")
                        }
                        if iflist.routineType == "appliance"{
                            operators.updateValue("=", forKey: String(item))
                            aWhenListDictt.updateValue("Appliance", forKey: "coreComponentType")
                        }
                        aWhenListDictt.updateValue(iflist.hardwareId!, forKey: "controllerId")
                     
                        coreDevices.updateValue(aWhenListDictt, forKey: String(item))
                     }
                  
                    //command
                    for item in 0..<coredata.actionSelectionList!.count{
                      var aWhenListDictt: Dictionary<String, Any> = Dictionary<String, Any>()
                      let aCommand = DataContractManagerFireBase.coreCommand(dict: coredata.actionSelectionList![item])
                        command.updateValue(aCommand, forKey: String(item))
                        let aOffcomd = DataContractManagerFireBase.coreCommandoff(dict: coredata.actionSelectionList![item])
                        offCommand.updateValue(aOffcomd, forKey: String(item))
                    }
                    
                    if command.count > 0{
                        aScheduleDict.updateValue( command, forKey: "command")
                    }
                    if offCommand.count > 0{
                        aScheduleDict.updateValue( offCommand, forKey: "offCommand")
                    }
                    if ifDeviceId.count > 0{
                        aScheduleDict.updateValue( ifDeviceId, forKey: "ifDeviceId")
                        aScheduleDict.updateValue( ifDeviceType, forKey: "ifDeviceType")
                        aScheduleDict.updateValue( ifState, forKey: "ifState")
                        aScheduleDict.updateValue(ifTempState, forKey: "ifTempState")
                        aScheduleDict.updateValue(operators, forKey: "operator")
                        aScheduleDict.updateValue(coreDevices, forKey: "coreDevices")
                    }
                    // duration
                    if let ds = coredata.duration{
                         aScheduleDict.updateValue(ds, forKey: "duration")
                     }
                    if let ds = coredata.from{
                         aScheduleDict.updateValue(ds, forKey: "from")
                     }
                    if let ds = coredata.to{
                         aScheduleDict.updateValue(ds, forKey: "to")
                     }
                }
 
                let aScheduleDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("core")
                    .child(Auth.auth().currentUser!.uid)
                    .child(pCore.ruleId!)
                    .setValue(aScheduleDict, withCompletionBlock: { (pError, pDatabaseReference) in
                        anError = pError
                        pCore.ruleId = pCore.ruleId
                        aScheduleDispatchSemaphore.signal()
                    })
                _ = aScheduleDispatchSemaphore.wait(timeout: .distantFuture)
             } catch {
                 anError = error
             }

            DispatchQueue.main.async {
                self.requestCount -= 1
              //  pCompletion(anError, pCore)
            }
         }
 
     }
    // delete core
    func deleteCore(completion pCompletion: @escaping (Error?) -> Void, core pCore :Core) {
         DispatchQueue.global(qos: .background).async {
             self.requestCount += 1
 
             var anError :Error?
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }

                let aScheduleDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("core")
                    .child(Auth.auth().currentUser!.uid)
                    .child(pCore.ruleId!).removeValue(completionBlock: {(pError, databaseref) in
                        anError = pError
                        // pCompletion(anError)
                         aScheduleDispatchSemaphore.signal()
                    })
                _ = aScheduleDispatchSemaphore.wait(timeout: .distantFuture)
                self.database
                    .child("coreUI")
                    .child(Auth.auth().currentUser!.uid)
                    .child(pCore.ruleId!).removeValue(completionBlock: {(pError, databaseref) in
                         anError = pError
                         pCompletion(anError)
                         aScheduleDispatchSemaphore.signal()
                    })
                _ = aScheduleDispatchSemaphore.wait(timeout: .distantFuture)
             } catch {
                 anError = error
                 pCompletion(anError)

             }

            DispatchQueue.main.async {
                self.requestCount -= 1
              //  pCompletion(anError, pCore)
            }
         }
 
     }
    func coreList(completion pCompletion: @escaping (Error?, [Core]?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var coreArray :Array<Core>? = Array<Core>()
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Fetch coreUI
                let aScheduleDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("coreUI")
                    .child(Auth.auth().currentUser!.uid)
                    .observe(DataEventType.value) { (pDataSnapshot) in
                        coreArray?.removeAll()
                        var aDeftScheduleArray :Array<Core>?
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Dictionary<String,Any>> {
                            aDeftScheduleArray = DataContractManagerFireBase.core(dict: aDict)
                        }
                        
                        // Sort frequently operated appliances
                        aDeftScheduleArray?.sort { (pLhs, pRhs) -> Bool in
                            return (pLhs.ruleName?.lowercased() ?? "") < (pRhs.ruleName?.lowercased() ?? "")
                        }

                        if aDeftScheduleArray != nil {
                            coreArray?.append(contentsOf: aDeftScheduleArray!)
                        }
                        pCompletion(anError, coreArray)
                        aScheduleDispatchSemaphore.signal()
                        
                    }
                _ = aScheduleDispatchSemaphore.wait(timeout: .distantFuture)
                
                if (coreArray?.count ?? 0) <= 0 {
                    coreArray = nil
                }
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, coreArray)
            }
        }
        
    }
    
    
    func updateCoreState(completion pCompletion: @escaping (Error?) -> Void, pcore core :Core) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Update state in database
                let aField :DatabaseReference =  self.database
                    .child("coreUI")
                    .child(Auth.auth().currentUser!.uid)
                    .child(core.ruleId!)
                    .child("state")
                let anApplianceDispatchSemaphore = DispatchSemaphore(value: 0)
                aField.setValue(core.state, withCompletionBlock: { (pError, pDatabaseReference) in
                    anError = pError
                    anApplianceDispatchSemaphore.signal()
                })
                _ = anApplianceDispatchSemaphore.wait(timeout: .distantFuture)
                
          
                let bField :DatabaseReference =  self.database
                    .child("core")
                    .child(Auth.auth().currentUser!.uid)
                    .child(core.ruleId!)
                    .child("state")
             //   let anApplianceDispatchSemaphore = DispatchSemaphore(value: 0)
                bField.setValue(core.state, withCompletionBlock: { (pError, pDatabaseReference) in
                    anError = pError
                    anApplianceDispatchSemaphore.signal()
                })
                _ = anApplianceDispatchSemaphore.wait(timeout: .distantFuture)
                
                
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
    
    
    func updateCoreData(completion pCompletion: @escaping (Error?) -> Void, pcore core :Core) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                    self.database
                        .child("core")
                        .child(Auth.auth().currentUser!.uid)
                        .child(core.ruleId!)
                        .child("coreDevices")
                        .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                            
                            if let aDict = pDataSnapshot.value as? [[String : Any]]{
                                var acoredeviesDataArray :Array<CoreDevicesData>?
                                acoredeviesDataArray = DataContractManagerFireBase.coreDeviesData(dict: aDict)
                                if let array = acoredeviesDataArray {
                                    for device in array {
                                        if device.coreComponentType == "Appliance" {
                                            self.updateCoreExpression(completion: { cError in
                                                    pCompletion(cError)
                                            }, pcore: device, coreState: core.state ?? false)
                                            print("YESSSSS")
                                        } else {
                                            self.updateCoreExpressionInDevices(completion: { cError in
                                                pCompletion(cError)
                                        }, pcore: device, coreState: core.state ?? false)
                                        }
                                    }
                                }
                                // print(device)
                            }
                        }
                    let anApplianceDispatchSemaphore1 = DispatchSemaphore(value: 0)
                    
                    _ = anApplianceDispatchSemaphore1.wait(timeout: .distantFuture)
                
                
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
    
    
    func updateCoreExpression(completion pCompletion: @escaping (Error?) -> Void, pcore coreDevice :CoreDevicesData, coreState: Bool) {
            DispatchQueue.global(qos: .background).async {
                self.requestCount += 1
                
                var anError :Error?
                
                do {
                    if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                        throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                    }
                    
                    
                    let path = self.database
                        .child("applianceDetails")
                        .child(coreDevice.controllerId!)
                        .child(coreDevice.applianceId!)
                        .child("core")
                    
                    if coreState {
                        path.observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                            if let dict = pDataSnapshot.value as? [String : String] {
                                //  count = countt.count
                                // Update state in database
                                var array = [String]()
                                for (_,value) in dict {
                                    array.append(value)
                                }
                                
                                if array.contains(coreDevice.expression ?? "") {
                                    
                                } else {
                                    array.append(coreDevice.expression ?? "")
                                    
                                    //  let dict = ["\(count)": coreDevice.expression]
                                    var vdict = [String:String]()
                                    
                                    for i in 0..<array.count {
                                        vdict["\(i)"] = array[i]
                                    }
                                    
                                    let aField :DatabaseReference = self.database
                                        .child("applianceDetails")
                                        .child(coreDevice.controllerId!)
                                        .child(coreDevice.applianceId!)
                                        .child("core")
                               //     let anApplianceDispatchSemaphore = DispatchSemaphore(value: 0)
                                    
                                    aField.setValue(vdict, withCompletionBlock: { (pError, pDatabaseReference) in
                                        anError = pError
                                //        anApplianceDispatchSemaphore.signal()
                                    })
                                //    _ = anApplianceDispatchSemaphore.wait(timeout: .distantFuture)
                                }
                            } else if var array = pDataSnapshot.value as? [String]  {
                                if array.contains(coreDevice.expression ?? "") {
                                    
                                } else {
                                    array.append(coreDevice.expression ?? "")
                                    
                                    //  let dict = ["\(count)": coreDevice.expression]
                                    var vdict = [String:String]()
                                    
                                    for i in 0..<array.count {
                                        vdict["\(i)"] = array[i]
                                    }
                                    
                                    let aField :DatabaseReference = self.database
                                        .child("applianceDetails")
                                        .child(coreDevice.controllerId!)
                                        .child(coreDevice.applianceId!)
                                        .child("core")
                                   // let anApplianceDispatchSemaphore = DispatchSemaphore(value: 0)
                                    
                                    aField.setValue(vdict, withCompletionBlock: { (pError, pDatabaseReference) in
                                        anError = pError
                                    //    anApplianceDispatchSemaphore.signal()
                                    })
                                   // _ = anApplianceDispatchSemaphore.wait(timeout: .distantFuture)
                                }
                            } else {
                                let aField :DatabaseReference = self.database
                                    .child("applianceDetails")
                                    .child(coreDevice.controllerId!)
                                    .child(coreDevice.applianceId!)
                                    .child("core")
                                
                              //  let anApplianceDispatchSemaphore = DispatchSemaphore(value: 0)
                                var vdict = [String:String]()
                                vdict = ["0": coreDevice.expression ?? ""]
                                aField.setValue(vdict, withCompletionBlock: { (pError, pDatabaseReference) in
                                    anError = pError
                                //    anApplianceDispatchSemaphore.signal()
                                })
                                //_ = anApplianceDispatchSemaphore.wait(timeout: .distantFuture)
                            }
                            
                        }
                    } else {
                        path.observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                            
                            if let dict = pDataSnapshot.value as? [String : String] {
                                //  count = countt.count
                                // Update state in database
                                
                                var array = [String]()
                                for (_,value) in dict {
                                    array.append(value)
                                }
                                
                                if array.contains(coreDevice.expression ?? "") {
                                    
                                    let arr = array
                                    
                                    for i in 0..<arr.count {
                                        if arr[i] == coreDevice.expression {
                                            array.remove(at: i)
                                            continue
                                        }
                                    }
                                    
                                    var vdict = [String:String]()
                                    
                                    for i in 0..<array.count {
                                        vdict["\(i)"] = array[i]
                                    }
                                    
                                    let aField :DatabaseReference = self.database
                                        .child("applianceDetails")
                                        .child(coreDevice.controllerId!)
                                        .child(coreDevice.applianceId!)
                                        .child("core")
                                 //   let anApplianceDispatchSemaphore = DispatchSemaphore(value: 0)
                                    
                                    aField.setValue(vdict, withCompletionBlock: { (pError, pDatabaseReference) in
                                        anError = pError
                                    //    anApplianceDispatchSemaphore.signal()
                                    })
                                  //  _ = anApplianceDispatchSemaphore.wait(timeout: .distantFuture)
                                }
                            }
                            else if var array = pDataSnapshot.value as? [String] {
                                //  count = countt.count
                                // Update state in database
                                if array.contains(coreDevice.expression ?? "") {
                                    
                                    let arr = array
                                    
                                    for i in 0..<arr.count {
                                        if arr[i] == coreDevice.expression {
                                            array.remove(at: i)
                                            continue
                                        }
                                    }
                                    
                                    var vdict = [String:String]()
                                    
                                    for i in 0..<array.count {
                                        vdict["\(i)"] = array[i]
                                    }
                                    
                                    let aField :DatabaseReference = self.database
                                        .child("applianceDetails")
                                        .child(coreDevice.controllerId!)
                                        .child(coreDevice.applianceId!)
                                        .child("core")
                                  //  let anApplianceDispatchSemaphore = DispatchSemaphore(value: 0)
                                    
                                    aField.setValue(vdict, withCompletionBlock: { (pError, pDatabaseReference) in
                                        anError = pError
                                   //     anApplianceDispatchSemaphore.signal()
                                    })
                                  //  _ = anApplianceDispatchSemaphore.wait(timeout: .distantFuture)
                                }
                            }
                            
                        }
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
    
    func updateCoreExpressionInDevices(completion pCompletion: @escaping (Error?) -> Void, pcore coreDevice :CoreDevicesData, coreState: Bool) {
            DispatchQueue.global(qos: .background).async {
                self.requestCount += 1
                
                var anError :Error?
                
                do {
                    if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                        throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                    }
                    
                    let path = self.database
                        .child("devices")
                        .child(coreDevice.controllerId!)
                        .child("core")
                    
                    if coreState {
                        path.observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                            if let dict = pDataSnapshot.value as? [String : String] {
                                //  count = countt.count
                                // Update state in database
                                var array = [String]()
                                for (_,value) in dict {
                                    array.append(value)
                                }
                                
                                if array.contains(coreDevice.expression ?? "") {
                                    
                                } else {
                                    array.append(coreDevice.expression ?? "")
                                    
                                    //  let dict = ["\(count)": coreDevice.expression]
                                    var vdict = [String:String]()
                                    
                                    for i in 0..<array.count {
                                        vdict["\(i)"] = array[i]
                                    }
                                    
                                    let aField :DatabaseReference = self.database
                                        .child("devices")
                                        .child(coreDevice.controllerId!)
                                        .child("core")
                               //     let anApplianceDispatchSemaphore = DispatchSemaphore(value: 0)
                                    
                                    aField.setValue(vdict, withCompletionBlock: { (pError, pDatabaseReference) in
                                        anError = pError
                                //        anApplianceDispatchSemaphore.signal()
                                    })
                                //    _ = anApplianceDispatchSemaphore.wait(timeout: .distantFuture)
                                }
                            } else if var array = pDataSnapshot.value as? [String]  {
                                if array.contains(coreDevice.expression ?? "") {
                                    
                                } else {
                                    array.append(coreDevice.expression ?? "")
                                    
                                    //  let dict = ["\(count)": coreDevice.expression]
                                    var vdict = [String:String]()
                                    
                                    for i in 0..<array.count {
                                        vdict["\(i)"] = array[i]
                                    }
                                    
                                    let aField :DatabaseReference = self.database
                                        .child("devices")
                                        .child(coreDevice.controllerId!)
                                        .child("core")
                                   // let anApplianceDispatchSemaphore = DispatchSemaphore(value: 0)
                                    
                                    aField.setValue(vdict, withCompletionBlock: { (pError, pDatabaseReference) in
                                        anError = pError
                                    //    anApplianceDispatchSemaphore.signal()
                                    })
                                   // _ = anApplianceDispatchSemaphore.wait(timeout: .distantFuture)
                                }
                            } else {
                                let aField :DatabaseReference = self.database
                                    .child("devices")
                                    .child(coreDevice.controllerId!)
                                    .child("core")
                                
                              //  let anApplianceDispatchSemaphore = DispatchSemaphore(value: 0)
                                var vdict = [String:String]()
                                vdict = ["0": coreDevice.expression ?? ""]
                                aField.setValue(vdict, withCompletionBlock: { (pError, pDatabaseReference) in
                                    anError = pError
                                //    anApplianceDispatchSemaphore.signal()
                                })
                                //_ = anApplianceDispatchSemaphore.wait(timeout: .distantFuture)
                            }
                            
                        }
                    } else {
                        path.observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                            
                            if let dict = pDataSnapshot.value as? [String : String] {
                                //  count = countt.count
                                // Update state in database
                                
                                var array = [String]()
                                for (_,value) in dict {
                                    array.append(value)
                                }
                                
                                if array.contains(coreDevice.expression ?? "") {
                                    
                                    let arr = array
                                    
                                    for i in 0..<arr.count {
                                        if arr[i] == coreDevice.expression {
                                            array.remove(at: i)
                                            continue
                                        }
                                    }
                                    
                                    var vdict = [String:String]()
                                    
                                    for i in 0..<array.count {
                                        vdict["\(i)"] = array[i]
                                    }
                                    
                                    let aField :DatabaseReference = self.database
                                        .child("devices")
                                        .child(coreDevice.controllerId!)
                                        .child("core")
                                 //   let anApplianceDispatchSemaphore = DispatchSemaphore(value: 0)
                                    
                                    aField.setValue(vdict, withCompletionBlock: { (pError, pDatabaseReference) in
                                        anError = pError
                                    //    anApplianceDispatchSemaphore.signal()
                                    })
                                  //  _ = anApplianceDispatchSemaphore.wait(timeout: .distantFuture)
                                }
                            }
                            else if var array = pDataSnapshot.value as? [String] {
                                //  count = countt.count
                                // Update state in database
                                if array.contains(coreDevice.expression ?? "") {
                                    
                                    let arr = array
                                    
                                    for i in 0..<arr.count {
                                        if arr[i] == coreDevice.expression {
                                            array.remove(at: i)
                                            continue
                                        }
                                    }
                                    
                                    var vdict = [String:String]()
                                    
                                    for i in 0..<array.count {
                                        vdict["\(i)"] = array[i]
                                    }
                                    
                                    let aField :DatabaseReference = self.database
                                        .child("devices")
                                        .child(coreDevice.controllerId!)
                                        .child("core")
                                  //  let anApplianceDispatchSemaphore = DispatchSemaphore(value: 0)
                                    
                                    aField.setValue(vdict, withCompletionBlock: { (pError, pDatabaseReference) in
                                        anError = pError
                                   //     anApplianceDispatchSemaphore.signal()
                                    })
                                  //  _ = anApplianceDispatchSemaphore.wait(timeout: .distantFuture)
                                }
                            }
                            
                        }
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
    
}



extension DataContractManagerFireBase {
    
    static func core(dict pDict :Dictionary<String,Dictionary<String,Any>>) -> Array<Core>? {
        var aReturnVal :Array<Core>? = Array<Core>()
        
        for aScheduleDict in pDict.values {
            let aSchedule = DataContractManagerFireBase.core(dict: aScheduleDict)
            aReturnVal!.append(aSchedule)
        }
        if aReturnVal!.count <= 0 {
            aReturnVal = nil
        }
        
        return aReturnVal
    }
    
    static func core(dict pDict :Dictionary<String,Any>) -> Core {
        let aReturnVal :Core = Core()
        
        if let aTitle = pDict["ruleName"] as? String {
            aReturnVal.ruleName = aTitle.capitalized
        }
        
        if let aPowerState = pDict["state"] as? Bool {
            aReturnVal.state = aPowerState
        }
        
        if let ruleId = pDict["ruleId"] as? String {
            aReturnVal.ruleId = ruleId
        }
        
        if let createdBy = pDict["createdBy"] as? String {
            aReturnVal.createdBy = createdBy
        }
        
        if let ifStatement = pDict["ifStatement"] as? String {
            aReturnVal.ifStatement = ifStatement
        }

        if let isCreatedBySensor = pDict["isCreatedBySensor"] as? Bool {
            aReturnVal.isCreatedBySensor = isCreatedBySensor
        }
        
        if let operators = pDict["operator"] as? String {
            aReturnVal.Operator = operators
        }
        if let operators = pDict["deviceId"] as? Array<String>{
            aReturnVal.deviceId = operators
        }
    
        if let operators = pDict["thenStatement"] as? String {
            aReturnVal.thenStatement = operators
        }
        
        if let coreEditData = pDict["coreEditData"] as? Dictionary<String,Any>{
            let coredata: coreEditdata = coreEditdata()
 
            var whenactionSelectionList: Array<actionSelectionList> = Array<actionSelectionList>()
            var thenactionSelectionList: Array<actionSelectionList> = Array<actionSelectionList>()
            if let operators = coreEditData["duration"] as? String {
                coredata.duration = operators
            }
            if let from = coreEditData["from"] as? String {
                coredata.from = from
            }
            if let to = coreEditData["to"] as? String {
                coredata.to = to
            }
            if let whenlist = coreEditData["whenSelectionList"] as? Array<Dictionary<String,Any>> {
                whenactionSelectionList = DataContractManagerFireBase.coreSortCondition(whenlist: whenlist)
                 //   coredata.whenSelectionList = whenlistdata
            }
            if let thenlist = coreEditData["actionSelectionList"] as? Array<Dictionary<String,Any>> {
                thenactionSelectionList = DataContractManagerFireBase.coreSortCondition(whenlist: thenlist)
                 //   coredata.whenSelectionList = whenlistdata
            }
            coredata.operation = aReturnVal.Operator
            coredata.ruleId = aReturnVal.ruleId
            coredata.ruleName = aReturnVal.ruleName
            coredata.whenSelectionList = whenactionSelectionList
            coredata.actionSelectionList = thenactionSelectionList
            aReturnVal.coreEditData = coredata
        }
        return aReturnVal
    }
    
    static func coreSortCondition(whenlist: Array<Dictionary<String,Any>>)-> Array<actionSelectionList>{
        var whenactionSelectionList: Array<actionSelectionList> = Array<actionSelectionList>()

        for item in whenlist{
            let pactionSelectionList = actionSelectionList()
             if let state = item["appId"] as? String{
                pactionSelectionList.appId = state
             }
            if let state = item["appName"] as? String{
               pactionSelectionList.appName = state
            }
            if let state = item["curtainName"] as? String{
                pactionSelectionList.appName = state
             }
            if let state = item["sensorName"] as? String{
                pactionSelectionList.appName = state
             }
            if let state = item["curtainType"] as? String{
                pactionSelectionList.currentType = state
             }
            if let checked = item["checked"] as? Bool{
               pactionSelectionList.checked = checked
            }
            if let currentLevel = item["currentLevel"] as? Int{
               pactionSelectionList.currentLevel = currentLevel
            }
            if let currentState = item["currentState"] as? Bool{
               pactionSelectionList.currentState = currentState
            }
            if let dimValue = item["dimValue"] as? Int{
               pactionSelectionList.dimValue = dimValue
            }
            if let dimValue = item["sensorTypeId"] as? Int{
               pactionSelectionList.sensorTypeId = dimValue
            }
            if let dimmable = item["dimmable"] as? Bool{
               pactionSelectionList.dimmable = dimmable
            }
            if let hardwareId = item["curtainId"] as? String{
               pactionSelectionList.hardwareId = hardwareId
            }
            if let hardwareId = item["hardwareId"] as? String{
               pactionSelectionList.hardwareId = hardwareId
            }
            if let hardwareId = item["id"] as? String{
               pactionSelectionList.hardwareId = hardwareId
            }
            if let maxDimming = item["maxDimming"] as? Int{
               pactionSelectionList.maxDimming = maxDimming
            }
            if let minDimming = item["minDimming"] as? Int{
               pactionSelectionList.minDimming = minDimming
            }
            if let roomId = item["roomId"] as? String{
               pactionSelectionList.roomId = roomId
            }
            if let roomName = item["roomName"] as? String{
               pactionSelectionList.roomName = roomName
            }
            if let routineType = item["routineType"] as? String{
               pactionSelectionList.routineType = routineType
            }
            if let state = item["state"] as? Int{
               pactionSelectionList.state = state
            }
            if let state = item["intensity"] as? Int{
               pactionSelectionList.intensity = state
            }
            if let uniqueKey = item["operator"] as? String{
                pactionSelectionList.operators = uniqueKey
            }
            if let uniqueKey = item["uniqueKey"] as? String{
                pactionSelectionList.uniqueKey = uniqueKey
            }
            whenactionSelectionList.append(pactionSelectionList)
            
        }
        return whenactionSelectionList
    }
    static func coreIfDevicesId(dict pDict :actionSelectionList) -> String {
        var aReturnVal :String = String()
        if pDict.routineType == "appliance"{
            let x = "\(String(describing: pDict.hardwareId!)):\(String(describing: pDict.appId!))"
            aReturnVal = x
         }
        if pDict.routineType == "temperature" || pDict.routineType == "motion" || pDict.routineType == "light"{
            let x = "\(String(describing: pDict.hardwareId!))"
            aReturnVal = x
         }
        return aReturnVal
    }
    
    static func coreCommand(dict pDict :actionSelectionList) -> String {
        var aReturnVal :String = String()
        if pDict.routineType == "appliance"{
            let x = "\(String(describing: pDict.hardwareId!)):C023\(String(describing: pDict.appId!))\(String(describing: pDict.state!))00F"
            aReturnVal = x
            if pDict.dimmable!{
                let x = "\(String(describing: pDict.hardwareId!)):C023\(String(describing: pDict.appId!))\(String(describing: pDict.state!))1\(String(describing: pDict.dimValue ?? 5))F"
                aReturnVal = x
            }
            if pDict.stripType == Appliance.StripType.rgb{
                let y = Int(pDict.stripLightEvent ?? "0")
                let formattedValue = String(format: "%02d", y!)
                let x = "\(String(describing: pDict.hardwareId!)):#l0230:\( formattedValue):\(String(describing: pDict.ledStripProperty1!)):\(String(describing: pDict.ledStripProperty2!)):\(String(describing: pDict.ledStripProperty3!)):0F"
                aReturnVal = x
            }
          
         }else if pDict.routineType == "curtain"{
             let x = "\(String(describing: pDict.hardwareId!)):M0120\(String(describing: pDict.state!))0F"
             aReturnVal = x
          }else if pDict.routineType == "remote"{
              let x = "\(String(describing: pDict.hardwareId ?? "")):\(String(describing: pDict.appId ?? ""))"
              aReturnVal = x
           }
         
        return aReturnVal
    }
    static func coreCommandoff(dict pDict :actionSelectionList) -> String {
        var aReturnVal :String = String()
        if pDict.routineType == "appliance"{
            let x = "\(String(describing: pDict.hardwareId!)):C023\(String(describing: pDict.appId!))\(String(describing: pDict.state! == 1 ? 2 : 1))15F"
            aReturnVal = x
         }
         
        return aReturnVal
    }
    static func coreDeviesData(dict pDict : [[String:Any]]) -> Array<CoreDevicesData>? {
        var aReturnVal :Array<CoreDevicesData>? = Array<CoreDevicesData>()
        
        for aScheduleDict in pDict {
            let aSchedule = DataContractManagerFireBase.coreDeviesData(dict: aScheduleDict)
            aReturnVal!.append(aSchedule)
        }
        if aReturnVal!.count <= 0 {
            aReturnVal = nil
        }
        
        return aReturnVal
    }
    
    static func coreDeviesData(dict pDict :[String:Any]) -> CoreDevicesData {
        let aReturnVal :CoreDevicesData = CoreDevicesData()
        
        if let controllerId = pDict["controllerId"] as? String {
            aReturnVal.controllerId = controllerId
        }
        
        if let expression = pDict["expression"] as? String {
            aReturnVal.expression = expression
        }
        
        if let applianceId = pDict["applianceId"] as? String {
            aReturnVal.applianceId = applianceId
        }
        if let coreComponentType = pDict["coreComponentType"] as? String {
            aReturnVal.coreComponentType = coreComponentType
        }

        return aReturnVal
    }
}
