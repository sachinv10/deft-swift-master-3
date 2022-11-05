//
//  DataFetchManagerFireBaseCurtain.swift
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
    
    func searchCurtain(completion pCompletion: @escaping (Error?, Array<Curtain>?) -> Void, room pRoom :Room?) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aCurtainArray :Array<Curtain>?
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                if (pRoom?.id?.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No room id available."])
                }
                
                // Fetch curtain IDs
                let aFilter = Auth.auth().currentUser!.uid + "_" + (pRoom?.id ?? "") + "_curtain"
                
                let aCurtainDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("devices")
                    .queryOrdered(byChild: "filter")
                    .queryEqual(toValue: aFilter)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Dictionary<String,Any>> {
                            aCurtainArray = DataContractManagerFireBase.curtains(dict: aDict)
                        }
                        aCurtainDispatchSemaphore.signal()
                    }
                _ = aCurtainDispatchSemaphore.wait(timeout: .distantFuture)
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, aCurtainArray)
            }
        }
        
    }
    
    
    func updateCurtainMotionState(completion pCompletion: @escaping (Error?) -> Void, curtain pCurtain :Curtain, motionState pMotionState :Curtain.MotionState) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Send message and reset it
                var aMessageValue = ""
                aMessageValue += "M012"
                aMessageValue += String(format: "%02d", pMotionState.rawValue)
                aMessageValue += "0F"
                anError = self.sendMessage(aMessageValue, entity: pCurtain)
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
    
    
    func updateCurtainDimmableValue(completion pCompletion: @escaping (Error?) -> Void, curtain pCurtain :Curtain, dimValue pDimValue :Int) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aReturnValError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Send message and reset it
                var aMessageValue = ""
                aMessageValue += "M012"
                aMessageValue += String(format: "%02d", pDimValue)
                aMessageValue += "0F"
                let anError = self.sendMessage(aMessageValue, entity: pCurtain)
                if anError != nil {
                    throw anError!
                }
            } catch {
                aReturnValError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(aReturnValError)
            }
        }
        
    }
    
}
