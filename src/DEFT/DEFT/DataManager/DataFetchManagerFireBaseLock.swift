//
//  DataFetchManagerFireBaseLock.swift
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
    
    func searchLock(completion pCompletion: @escaping (Error?, Array<Lock>?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aLockArray :Array<Lock>? = Array<Lock>()
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Fetch DEFT locks
                let aLockDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("Locks")
                    .child(Auth.auth().currentUser!.uid)
                    .child("lockDetails")
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        self.log(dataSnapshot: pDataSnapshot)
                        
                        var aDeftLockArray :Array<Lock>?
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Dictionary<String,Any>> {
                            aDeftLockArray = DataContractManagerFireBase.locks(dict: aDict)
                        }
                        
                        // Sort frequently operated appliances
                        aDeftLockArray?.sort { (pLhs, pRhs) -> Bool in
                            return (pLhs.title?.lowercased() ?? "") < (pRhs.title?.lowercased() ?? "")
                        }
                        
                        if aDeftLockArray != nil {
                            aLockArray?.append(contentsOf: aDeftLockArray!)
                        }
                        
                        aLockDispatchSemaphore.signal()
                    }
                _ = aLockDispatchSemaphore.wait(timeout: .distantFuture)
                
                if (aLockArray?.count ?? 0) <= 0 {
                    aLockArray = nil
                }
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, aLockArray)
            }
        }
        
    }
    
    
    func updateLockState(completion pCompletion: @escaping (Error?) -> Void, lock pLock :Lock) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Send message and reset it
                var aMessageValue = ""
                if pLock.hardwareType == Device.HardwareType.gateLock {
                    aMessageValue += "C012"
                    aMessageValue += pLock.id!
                    aMessageValue += "0245"
                    aMessageValue += "00000F"
                } else {
                    aMessageValue += "L012"
                    aMessageValue += pLock.id!
                    aMessageValue += "20F"
                }
                anError = self.sendMessage(aMessageValue, entity: pLock)
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
