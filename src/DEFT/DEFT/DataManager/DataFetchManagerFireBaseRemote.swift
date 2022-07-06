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


extension DataFetchManagerFireBase {
    
    func remote(withId pId :String) -> Remote? {
        var aReturnVal :Remote? = nil
        
        let aDispatchSemaphore = DispatchSemaphore(value: 0)
        self.database
            .child("remote")
            .child(Auth.auth().currentUser!.uid)
            .queryOrdered(byChild: "remoteId")
            .queryEqual(toValue: pId)
            .queryLimited(toFirst: 1)
            .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                if let aResult = pDataSnapshot.value as? Dictionary<String, Dictionary<String, Any>>
                , let aRemote = DataContractManagerFireBase.remotes(dict: aResult)?.first {
                    aReturnVal = aRemote
                }
                aDispatchSemaphore.signal()
            }
        _ = aDispatchSemaphore.wait(timeout: .distantFuture)
        
        if let aRemote = aReturnVal {
            let aRemoteKeyDispatchSemaphore = DispatchSemaphore(value: 0)
            self.remoteDetails(completion: { (pError, pRemote) in
                aRemote.keys = pRemote?.keys
                aRemoteKeyDispatchSemaphore.signal()
            }, remote: aRemote)
            _ = aRemoteKeyDispatchSemaphore.wait(timeout: .distantFuture)
        }
        
        return aReturnVal
    }
    
    
    func searchRemote(completion pCompletion: @escaping (Error?, Array<Remote>?) -> Void, room pRoom :Room?) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aRemoteArray :Array<Remote>? = Array<Remote>()
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Fetch DEFT remotes
                let aRemoteDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("remote")
                    .child(Auth.auth().currentUser!.uid)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        self.log(dataSnapshot: pDataSnapshot)
                        // Fetch objects
                        var aDeftRemoteArray :Array<Remote>?
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Dictionary<String,Any>> {
                            aDeftRemoteArray = DataContractManagerFireBase.remotes(dict: aDict)
                        }
                        // Filter based on room
                        if pRoom != nil {
                            aDeftRemoteArray = aDeftRemoteArray?.filter({ (pRemote) -> Bool in
                                return pRemote.roomId == pRoom?.id
                            })
                        }
                        // Add to total array
                        if let aValue = aDeftRemoteArray {
                            aRemoteArray?.append(contentsOf: aValue)
                        }
                        aRemoteDispatchSemaphore.signal()
                    }
                _ = aRemoteDispatchSemaphore.wait(timeout: .distantFuture)
                
                // Sort remotes
                aRemoteArray?.sort { (pLhs, pRhs) -> Bool in
                    return (pLhs.title?.lowercased() ?? "") < (pRhs.title?.lowercased() ?? "")
                }
                if (aRemoteArray?.count ?? 0) <= 0 {
                    aRemoteArray = nil
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
                if (pRemote.irId?.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Remote IRID can not be empty."])
                }
                
                // Fetch frequently operated remotes
                let aRemoteDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("remoteKey1")
                    .child(Auth.auth().currentUser!.uid)
                    .child(pRemote.irId!)
                    .child(pRemote.id!)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        self.log(dataSnapshot: pDataSnapshot)
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
                
                // Update timestamp in database
                let aField :DatabaseReference = self.database
                    .child("remoteKey1")
                    .child(Auth.auth().currentUser!.uid)
                    .child(pRemote.irId!)
                    .child(pRemote.id!)
                    .child(pRemoteKey.id!)
                    .child("newKeyName")
                let anApplianceDispatchSemaphore = DispatchSemaphore(value: 0)
                aField.setValue(pRemoteKey.title, withCompletionBlock: { (pError, pDatabaseReference) in
                    self.log(databaseReference: pDatabaseReference)
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
                
                // Update timestamp in database
                let aField :DatabaseReference = self.database
                    .child("remoteKey1")
                    .child(Auth.auth().currentUser!.uid)
                    .child(pRemote.irId!)
                    .child(pRemote.id!)
                    .child(pRemoteKey.id!)
                    .child("timestamp")
                let anApplianceDispatchSemaphore = DispatchSemaphore(value: 0)
                aField.setValue(pRemoteKey.timestamp, withCompletionBlock: { (pError, pDatabaseReference) in
                    self.log(databaseReference: pDatabaseReference)
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
    
    
    func recordRemoteKey(completion pCompletion: @escaping (Error?) -> Void, remote pRemote :Remote, remoteKey pRemoteKey :RemoteKey) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                if (pRemoteKey.recordCommand?.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Record command can not be empty."])
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
    
}
