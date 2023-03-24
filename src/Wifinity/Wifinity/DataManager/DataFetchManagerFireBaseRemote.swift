//
//  DataFetchManagerFireBaseRemote.swift
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
    
    func searchRemote(completion pCompletion: @escaping (Error?, Array<Remote>?) -> Void, room pRoom :Room?) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aRemoteArray :Array<Remote>?
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                if (pRoom?.id?.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No room id available."])
                }
                
                // Fetch remote IDs
                if let aRemoteHardwareIdArray = self.remoteHardwareIdsForLoggedInUser(roomId: pRoom!.id!) {
                    var aFetchedRemoteArray = Array<Remote>()
                    for aRemoteHardwareId in aRemoteHardwareIdArray {
                        let aRemoteDispatchSemaphore = DispatchSemaphore(value: 0)
                        self.database
                            .child("remoteDetails1")
                            .child(aRemoteHardwareId)
                            .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                                if let aDict = pDataSnapshot.value as? Dictionary<String,Dictionary<String,Any>>
                                   , let anArray = DataContractManagerFireBase.remotes(dict: aDict) {
                                    aFetchedRemoteArray.append(contentsOf: anArray)
                                    // Sort the array
                                    aRemoteArray = aFetchedRemoteArray.sorted { (pLhs, pRhs) -> Bool in
                                        return (pLhs.title?.lowercased() ?? "") < (pRhs.title?.lowercased() ?? "")
                                    }
                                }
                                aRemoteDispatchSemaphore.signal()
                            }
                        _ = aRemoteDispatchSemaphore.wait(timeout: .distantFuture)
                    }
                }
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, aRemoteArray)
            }
        }
        
    }
    
    
    func remoteDetails(completion pCompletion: @escaping (Error?, Remote?) -> Void, remote pRemote :Remote) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aRemote :Remote?
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                if (pRemote.id?.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Remote ID can not be empty."])
                }
                
                // Fetch frequently operated remotes
                let aRemoteDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("remoteKey1")
                    .child(pRemote.hardwareId!)
                    .child(pRemote.id!)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Dictionary<String,Any>> {
                            aRemote = pRemote
                            aRemote?.keys = DataContractManagerFireBase.remoteKeys(dict: aDict)
                        }
                        aRemoteDispatchSemaphore.signal()
                    }
                _ = aRemoteDispatchSemaphore.wait(timeout: .distantFuture)
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, aRemote)
            }
        }
        
    }
    
    
    func updateRemoteKey(completion pCompletion: @escaping (Error?) -> Void, remote pRemote :Remote, remoteKey pRemoteKey :RemoteKey) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Update remote key in database
                let aField :DatabaseReference = self.database
                    .child("remoteKey1")
                    .child(pRemote.hardwareId!)
                    .child(pRemote.id!)
                    .child(pRemoteKey.id!)
                    .child("newKeyName")
                let anApplianceDispatchSemaphore = DispatchSemaphore(value: 0)
                aField.setValue(pRemoteKey.title, withCompletionBlock: { (pError, pDatabaseReference) in
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
    
    
    func clickRemoteKey(completion pCompletion: @escaping (Error?) -> Void, remote pRemote :Remote, remoteKey pRemoteKey :RemoteKey) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                if (pRemoteKey.command?.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Command can not be empty."])
                }
                
                // Send message and reset it
                anError = self.sendMessage(pRemoteKey.command!, entity: pRemote)
                if anError != nil {
                    throw anError!
                }
                
                // Update remote key in database
                let aCurrentTimestamp = Int(Date().timeIntervalSince1970 * 1000)
                let aField :DatabaseReference = self.database
                    .child("remoteKey1")
                    .child(pRemote.hardwareId!)
                    .child(pRemote.id!)
                    .child(pRemoteKey.id!)
                    .child("timestamp")
                let anApplianceDispatchSemaphore = DispatchSemaphore(value: 0)
                aField.setValue(aCurrentTimestamp, withCompletionBlock: { (pError, pDatabaseReference) in
                    anError = pError
                    pRemoteKey.timestamp = aCurrentTimestamp
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
    
    func resetController(completion pCompletion: @escaping (Error?, Array<Appliance>?) -> Void, room uRoom :String?, room pRoom :String?, Applinces pcontroller :ControllerAppliance?, includeOnOnly pIncludeOnOnly :Bool) {
   
         DispatchQueue.global(qos: .background).async {
             self.requestCount += 1
 
             var anApplianceArray :Array<Appliance>?
             var anError :Error?
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                var datadictionary: [String: AnyHashable] = [String: AnyHashable]()
                datadictionary.updateValue(false, forKey: "wCommand")
                datadictionary.updateValue(false, forKey: "xCommand")
                datadictionary.updateValue(false, forKey: "yCommand")
                
                var dataidpass: [String: AnyHashable] = [String: AnyHashable]()
                dataidpass.updateValue(pRoom, forKey: "password")
                dataidpass.updateValue(uRoom, forKey: "ssid")
                
                // Fetch frequently operated appliances
                let anApplianceDispatchSemaphore = DispatchSemaphore(value: 0)
                var databaseref : DatabaseReference?
                databaseref =  self.database
                    .child("routerDetails")
                    .child((pcontroller?.id) ?? "")
                    print((pcontroller?.id) ?? "")
                 databaseref?.updateChildValues(datadictionary)
                //
                var databaserefnc : DatabaseReference?
                databaserefnc =  self.database.child("messages").child((pcontroller?.id) ?? "").child("applianceData").child("message")
               
                //  databaserefnc?.setValue("Y0120F")"
                self.sendmsg(pMessage: "Y0120F", pApplinces: pcontroller!)
            
               //  databaserefnc?.setValue("W012" + (uRoom ?? "") + "0F1")
                self.sendmsg(pMessage: "W" + (uRoom ?? "") + "0F1", pApplinces: pcontroller!)
               
             //   databaserefnc?.setValue("X012" + (pRoom ?? "") + "0F1")
                self.sendmsg(pMessage: "X" + (pRoom ?? "") + "0F1", pApplinces: pcontroller!)
           
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                self.database
                    .child("routerDetails")
                    .child((pcontroller?.id) ?? "")
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        print(pDataSnapshot.value)
                        print("router get ditail")
                   //      self.log(dataSnapshot: pDataSnapshot)
                     
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Any> {
                             if (aDict["wCommand"] as! Bool != false), (aDict["xCommand"] as! Bool != false){
                                print("true")
                             //    update database id and  passwd
                                 self.database.child("temp").updateChildValues(dataidpass)
                                 self.database.child("devices").child((pcontroller?.id) ?? "").updateChildValues(dataidpass)
                                 PopupManager.shared.displaySuccess(message: "Reset successfully", description: "")

                            }
                         }
                        anApplianceDispatchSemaphore.signal()
                    }
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
    
    func sendmsg(pMessage: String, pApplinces: ControllerAppliance)  {
        // Send message
       
        do{
        var aReturnVal :Error? = nil
        var aMessageField: DatabaseReference?
            aMessageField =  self.database.child("messages").child(pApplinces.id ?? "").child("applianceData").child("message")
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
        }catch{
            
        }
        
    }
    
    func recordRemoteKey(completion pCompletion: @escaping (Error?) -> Void, remote pRemote :Remote, remoteKey pRemoteKey :RemoteKey) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                if (pRemoteKey.recordCommand?.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Key is not recorded."])
                }
                
                // Send message and reset it
                anError = self.sendMessage(pRemoteKey.recordCommand!, entity: pRemote)
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
    
    
    func remoteHardwareIdsForLoggedInUser(roomId pRoomId :String?) -> Array<String>? {
        var aReturnVal :Array<String>?
        
        if let aRoomId = pRoomId {
            let aDispatchSemaphore = DispatchSemaphore(value: 0)
            self.database
                .child("rooms")
                .child(Auth.auth().currentUser!.uid)
                .child(aRoomId)
                .child("remotes")
                .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                    aReturnVal = pDataSnapshot.value as? Array<String>
                    aDispatchSemaphore.signal()
                }
            _ = aDispatchSemaphore.wait(timeout: .distantFuture)
        } else {
            if let aRoomIdArray = self.roomIdsForLoggedInUser() {
                var aFetchedRemoteIdArray = Array<String>()
                for aRoomId in aRoomIdArray {
                    let aDispatchSemaphore = DispatchSemaphore(value: 0)
                    self.database
                        .child("rooms")
                        .child(Auth.auth().currentUser!.uid)
                        .child(aRoomId)
                        .child("remotes")
                        .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                            if let aRemoteIdArray = pDataSnapshot.value as? Array<String> {
                                aFetchedRemoteIdArray.append(contentsOf: aRemoteIdArray)
                            }
                            aDispatchSemaphore.signal()
                        }
                    _ = aDispatchSemaphore.wait(timeout: .distantFuture)
                }
                if aFetchedRemoteIdArray.count > 0 {
                    aReturnVal = aFetchedRemoteIdArray
                }
            }
        }
        
        return aReturnVal
    }
    
}
