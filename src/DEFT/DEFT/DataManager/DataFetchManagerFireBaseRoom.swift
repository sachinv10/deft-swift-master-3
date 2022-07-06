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
    
    func saveRoom(completion pCompletion: @escaping (Error?, Room?) -> Void, room pRoom :Room) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                let aKey = pRoom.id ?? self.getNextKey(dataBasePath: "rooms/" + Auth.auth().currentUser!.uid, length: 2)
                
                let aRoomDict = [
                    "roomId": aKey
                    , "roomName": pRoom.title
                ]
                
                let aRoomDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("rooms")
                    .child(Auth.auth().currentUser!.uid)
                    .child(aKey)
                    .setValue(aRoomDict, withCompletionBlock: { (pError, pDatabaseReference) in
                        self.log(databaseReference: pDatabaseReference)
                        anError = pError
                        pRoom.id = aKey
                        aRoomDispatchSemaphore.signal()
                    })
                _ = aRoomDispatchSemaphore.wait(timeout: .distantFuture)
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, pRoom)
            }
        }
        
    }
    
    
    func searchRoom(completion pCompletion: @escaping (Error?, Array<Room>?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aRoomArray :Array<Room>? = Array<Room>()
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Fetch rooms
                let aRoomDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("roomDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        self.log(dataSnapshot: pDataSnapshot)
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Dictionary<String,Any>> {
                            aRoomArray = DataContractManagerFireBase.rooms(dict: aDict)
                        }
                        // Sort rooms
                        aRoomArray?.sort { (pLhs, pRhs) -> Bool in
                            return pLhs.title?.lowercased() ?? "" < pRhs.title?.lowercased() ?? ""
                        }
                        aRoomDispatchSemaphore.signal()
                    }
                _ = aRoomDispatchSemaphore.wait(timeout: .distantFuture)
                
                if (aRoomArray?.count ?? 0) <= 0 {
                    aRoomArray = nil
                }
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, aRoomArray)
            }
        }
        
    }

}
