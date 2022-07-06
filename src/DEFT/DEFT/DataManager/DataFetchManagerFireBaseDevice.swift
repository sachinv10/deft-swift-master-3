//
//  DataFetchManagerFireBaseDevice.swift
//  DEFT
//
//  Created by Rupendra on 03/01/21.
//  Copyright © 2021 Example. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase


extension DataFetchManagerFireBase {
    
    func searchDevice(completion pCompletion: @escaping (Error?, Array<Device>?) -> Void, room pRoom :Room?, hardwareTypes pHardwareTypeArray :Array<Device.HardwareType>?) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aDeviceArray :Array<Device>? = Array<Device>()
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Fetch devices
                let aDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("wifinityDevices")
                    .child(Auth.auth().currentUser!.uid)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Dictionary<String,Any>>
                           , let aFetchedDeviceArray = DataContractManagerFireBase.devices(dict: aDict) {
                            aDeviceArray = aFetchedDeviceArray
                        }
                        aDispatchSemaphore.signal()
                    }
                _ = aDispatchSemaphore.wait(timeout: .distantFuture)
                
                // Sort devices
                aDeviceArray?.sort { (pLhs, pRhs) -> Bool in
                    return (pLhs.title?.lowercased() ?? pLhs.id ?? "") < (pRhs.title?.lowercased() ?? pRhs.id ?? "")
                }
                if (aDeviceArray?.count ?? 0) <= 0 {
                    aDeviceArray = nil
                }
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, aDeviceArray)
            }
        }
        
    }
    
}
