//
//  DataFetchManagerFireBaseRule.swift
//  DEFT
//
//  Created by Rupendra on 24/10/21.
//  Copyright © 2021 Example. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase


extension DataFetchManagerFireBase {
    
    func searchRule(completion pCompletion: @escaping (Error?, Array<Rule>?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aRuleArray :Array<Rule>? = Array<Rule>()
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Fetch DEFT rules
                let aRuleDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("mqttIFTT")
                    .child(Auth.auth().currentUser!.uid)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        self.log(dataSnapshot: pDataSnapshot)
                        
                        var aDeftRuleArray :Array<Rule>?
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Dictionary<String,Any>> {
                            aDeftRuleArray = DataContractManagerFireBase.rules(dict: aDict)
                        }
                        
                        // Sort frequently operated appliances
                        aDeftRuleArray?.sort { (pLhs, pRhs) -> Bool in
                            return (pLhs.title?.lowercased() ?? "") < (pRhs.title?.lowercased() ?? "")
                        }
                        
                        if aDeftRuleArray != nil {
                            aRuleArray?.append(contentsOf: aDeftRuleArray!)
                        }
                        
                        aRuleDispatchSemaphore.signal()
                    }
                _ = aRuleDispatchSemaphore.wait(timeout: .distantFuture)
                
                if (aRuleArray?.count ?? 0) <= 0 {
                    aRuleArray = nil
                }
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, aRuleArray)
            }
        }
        
    }
    
    
    func updateRuleState(completion pCompletion: @escaping (Error?) -> Void, rule pRule :Rule, state pState :Bool) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Save rule state
                let aRuleStateDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("mqttIFTT")
                    .child(Auth.auth().currentUser!.uid)
                    .child(pRule.id!)
                    .child("state")
                    .setValue(pState, withCompletionBlock: { (pError, pDatabaseReference) in
                        anError = pError
                        aRuleStateDispatchSemaphore.signal()
                    })
                _ = aRuleStateDispatchSemaphore.wait(timeout: .distantFuture)
                
                // Save iftt rule state
                let anIfttRuleStateDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("ifttt")
                    .child(Auth.auth().currentUser!.uid)
                    .child(pRule.id!)
                    .child("state")
                    .setValue(pState, withCompletionBlock: { (pError, pDatabaseReference) in
                        anError = pError
                        anIfttRuleStateDispatchSemaphore.signal()
                    })
                _ = anIfttRuleStateDispatchSemaphore.wait(timeout: .distantFuture)
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

