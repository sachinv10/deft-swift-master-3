//
//  DataFetchManagerFireBaseTankRegulator.swift
//  DEFT
//
//  Created by Rupendra on 09/10/21.
//  Copyright © 2021 Example. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase


extension DataFetchManagerFireBase {
    
    func searchTankRegulator(completion pCompletion: @escaping (Error?, Array<TankRegulator>?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aTankRegulatorArray :Array<TankRegulator>? = Array<TankRegulator>()
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Fetch Wifinity water level controllers
                let aFilter = Auth.auth().currentUser!.uid + "_WaterLevelController"
                let aWifinityDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("wifinityDevices")
                    .child(Auth.auth().currentUser!.uid)
                    .queryOrdered(byChild: "filter")
                    .queryEqual(toValue: aFilter)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        self.log(dataSnapshot: pDataSnapshot)
                        // Fetch objects
                        var aWifinityArray :Array<TankRegulator>?
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Dictionary<String,Any>> {
                            aWifinityArray = DataContractManagerFireBase.tankRegulators(dict: aDict)
                        }
                        // Add to total array
                        if let aValue = aWifinityArray {
                            aTankRegulatorArray?.append(contentsOf: aValue)
                        }
                        aWifinityDispatchSemaphore.signal()
                    }
                _ = aWifinityDispatchSemaphore.wait(timeout: .distantFuture)
                
                // Sort sensors
                aTankRegulatorArray?.sort { (pLhs, pRhs) -> Bool in
                    return (pLhs.title?.lowercased() ?? "") < (pRhs.title?.lowercased() ?? "")
                }
                if (aTankRegulatorArray?.count ?? 0) <= 0 {
                    aTankRegulatorArray = nil
                }
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, aTankRegulatorArray)
            }
        }
    }
    
    
    func updateTankRegulatorAutoMode(completion pCompletion: @escaping (Error?) -> Void, tankRegulator pTankRegulator :TankRegulator, autoMode pAutoMode :Bool) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Send message and reset it
                var aMessageValue = ""
                aMessageValue += "$a"
                aMessageValue += String(format: "%@", DataContractManagerFireBase.isOnCommandValue(pAutoMode))
                aMessageValue += "#"
                anError = self.sendMessage(aMessageValue, entity: pTankRegulator)
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
    
    
    func updateTankRegulatorMotorPowerState(completion pCompletion: @escaping (Error?) -> Void, tankRegulator pTankRegulator :TankRegulator, motorPowerState pMotorPowerState :Bool) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Send message and reset it
                var aMessageValue = ""
                aMessageValue += "$R"
                aMessageValue += String(format: "%@", DataContractManagerFireBase.tankRegulatorMotorPowerStateCommandValue(pMotorPowerState
                ))
                aMessageValue += "#"
                anError = self.sendMessage(aMessageValue, entity: pTankRegulator)
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
    
    
    func updateTankRegulatorSync(completion pCompletion: @escaping (Error?) -> Void, tankRegulator pTankRegulator :TankRegulator) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Send message and reset it
                var aMessageValue = ""
                aMessageValue += "$sync"
                anError = self.sendMessage(aMessageValue, entity: pTankRegulator)
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
