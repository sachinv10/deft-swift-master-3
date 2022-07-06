//
//  DataFetchManagerFireBaseMood.swift
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
    
    func saveMood(completion pCompletion: @escaping (Error?, Mood?) -> Void, mood pMood :Mood) {
        pCompletion(nil, pMood)
    }
    
    
    func searchMood(completion pCompletion: @escaping (Error?, Array<Mood>?) -> Void, room pRoom :Room?) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aMoodArray :Array<Mood>? = Array<Mood>()
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Fetch moods
                let aMoodDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("mood")
                    .child(Auth.auth().currentUser!.uid)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        
                        var aDeftMoodArray :Array<Mood>?
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Dictionary<String,Any>> {
                            aDeftMoodArray = DataContractManagerFireBase.moods(dict: aDict)
                        }
                        if pRoom != nil {
                            aDeftMoodArray = aDeftMoodArray?.filter({ (pMood) -> Bool in
                                return pMood.room?.id == pRoom?.id
                            })
                        }
                        
                        // Sort moods
                        aDeftMoodArray?.sort { (pLhs, pRhs) -> Bool in
                            return (pLhs.title?.lowercased() ?? "") < (pRhs.title?.lowercased() ?? "")
                        }
                        
                        if aDeftMoodArray != nil {
                            aMoodArray?.append(contentsOf: aDeftMoodArray!)
                        }
                        
                        aMoodDispatchSemaphore.signal()
                    }
                _ = aMoodDispatchSemaphore.wait(timeout: .distantFuture)
                
                if (aMoodArray?.count ?? 0) <= 0 {
                    aMoodArray = nil
                }
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, aMoodArray)
            }
        }
        
    }
    
    
    func moodDetails(completion pCompletion: @escaping (Error?, Mood?) -> Void, mood pMood :Mood) {
        pCompletion(nil, pMood)
    }
    
    
    func updateMoodPowerState(completion pCompletion: @escaping (Error?) -> Void, mood pMood :Mood, powerState pPowerState :Bool) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Send message and reset it
                var aMessageValue = ""
                aMessageValue += "C012"
                aMessageValue += pMood.id!
                aMessageValue += "0245"
                aMessageValue += "00000F"
                anError = self.sendMessage(aMessageValue, entity: pMood)
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
    
    
    func deleteMood(completion pCompletion: @escaping (Error?, Mood?) -> Void, mood pMood :Mood) {
        pCompletion(NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Functionality not supported."]), nil)
    }

}
