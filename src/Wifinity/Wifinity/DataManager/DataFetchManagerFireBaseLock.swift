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
            
            var aLockArray :Array<Lock>?
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Fetch locks
                let aFilter = Auth.auth().currentUser!.uid + "_lock"
                
                let aLockDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("devices")
                    .queryOrdered(byChild: "filter")
                    .queryEqual(toValue: aFilter)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Dictionary<String,Any>> {
                            aLockArray = DataContractManagerFireBase.locks(dict: aDict)
                        }
                        // Sort the array
                        aLockArray?.sort { (pLhs, pRhs) -> Bool in
                            return pLhs.title?.lowercased() ?? "" < pRhs.title?.lowercased() ?? ""
                        }
                        aLockDispatchSemaphore.signal()
                    }
                _ = aLockDispatchSemaphore.wait(timeout: .distantFuture)
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
                    aMessageValue += "C0230200F"
                } else {
                    aMessageValue += "L012020F"
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
