//
//  DataFetchManagerFireBaseUser.swift
//  DEFT
//
//  Created by Rupendra on 03/01/21.
//  Copyright © 2021 Example. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase


extension DataFetchManagerFireBase {
    
    func login(completion pCompletion: @escaping (Error?, User?) -> Void, user pUser :User) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aUser :User?
            var anError :Error?
            
            do {
                // Login
                let aDispatchSemaphore = DispatchSemaphore(value: 0)
                Auth.auth().signIn(withEmail: pUser.emailAddress!, password: pUser.password!) { (pAuthDataResult, pError) in
                    if let aFirebaseUser = pAuthDataResult?.user {
                        self.observeChangeEvents()
                        
                        aUser = User()
                        aUser!.emailAddress = pUser.emailAddress
                        aUser!.password = pUser.password
                        aUser!.firebaseUserId = aFirebaseUser.uid
                    } else {
                        anError = pError ?? NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Unknown error."])
                    }
                    aDispatchSemaphore.signal()
                }
                _ = aDispatchSemaphore.wait(timeout: .distantFuture)
                
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Invalid credentials."])
                }
                
                // Fetch Profile Details
                let aProfileDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("mqttUserDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        self.log(dataSnapshot: pDataSnapshot)
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Any> {
                            let aUserProfile = DataContractManagerFireBase.user(dict: aDict)
                            aUser?.lockPassword = aUserProfile.lockPassword
                        } else {
                            anError = NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Profile error."])
                        }
                        aProfileDispatchSemaphore.signal()
                    }
                _ = aProfileDispatchSemaphore.wait(timeout: .distantFuture)
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, aUser)
            }
        }
        
    }
    
    
    func logout(completion pCompletion: @escaping (Error?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                try Auth.auth().signOut()
                self.removeAllObservers()
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError)
            }
        }
    }
    
    
    func resetPassword(completion pCompletion: @escaping (Error?, User?) -> Void, user pUser :User) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aUser :User?
            var anError :Error?
            
            // Reset password
            let aDispatchSemaphore = DispatchSemaphore(value: 0)
            Auth.auth().sendPasswordReset(withEmail: pUser.emailAddress!, completion: {pError in
                if let aValue = pError {
                    aUser = nil
                    anError = aValue
                } else {
                    aUser = pUser
                    anError = nil
                }
                aDispatchSemaphore.signal()
            })
            _ = aDispatchSemaphore.wait(timeout: .distantFuture)
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, aUser)
            }
        }
        
    }
    
    
    func dashboardDetails(completion pCompletion: @escaping (Error?, Array<Appliance>?, Array<Room>?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anApplianceArray :Array<Appliance>?
            var aRoomArray :Array<Room>?
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Fetch frequently operated appliances
                let anApplianceDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("ApplianceDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .queryOrdered(byChild: "applianceOperatedCount")
                    .queryLimited(toLast: 6)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        self.log(dataSnapshot: pDataSnapshot)
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Dictionary<String,Any>> {
                            anApplianceArray = DataContractManagerFireBase.appliances(dict: aDict)
                            // Sort frequently operated appliances
                            anApplianceArray?.sort { (pLhs, pRhs) -> Bool in
                                return pLhs.operatedCount ?? 0 > pRhs.operatedCount ?? 0
                            }
                        }
                        anApplianceDispatchSemaphore.signal()
                    }
                _ = anApplianceDispatchSemaphore.wait(timeout: .distantFuture)
                
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
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, anApplianceArray, aRoomArray)
            }
        }
        
    }
    
}
