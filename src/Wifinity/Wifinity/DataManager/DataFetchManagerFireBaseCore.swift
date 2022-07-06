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


extension DataFetchManagerFireBase {
    
    
    func coreList(completion pCompletion: @escaping (Error?, [Core]?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var coreArray :Array<Core>? = Array<Core>()
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Fetch DEFT schedules
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
