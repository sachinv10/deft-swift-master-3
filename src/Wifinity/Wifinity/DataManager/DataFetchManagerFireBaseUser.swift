//
//  DataFetchManagerFireBaseUser.swift
//  Wifinity
//
//  Created by Rupendra on 03/01/21.
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
            var aReturnValError :Error?
            
            do {
                // Login
                var aLoginError :Error? = nil
                let aLoginDispatchSemaphore = DispatchSemaphore(value: 0)
                Auth.auth().signIn(withEmail: pUser.emailAddress!, password: pUser.password!) { (pAuthDataResult, pError) in
                    if let aFirebaseUser = pAuthDataResult?.user {
                        aUser = User()
                        aUser!.emailAddress = pUser.emailAddress
                        aUser!.password = pUser.password
                        aUser!.firebaseUserId = aFirebaseUser.uid
                        UserDefaults.standard.set(pUser.emailAddress, forKey: "emailAddress")
                        UserDefaults.standard.set(pUser.password, forKey: "password")
                        UserDefaults.standard.set(aFirebaseUser.uid, forKey: "userId")
                    } else {
                        aLoginError = pError ?? NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Unknown error."])
                    }
                    aLoginDispatchSemaphore.signal()
                }
                _ = aLoginDispatchSemaphore.wait(timeout: .distantFuture)
                if let anError = aLoginError {
                    throw anError
                }
                
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Invalid credentials."])
                }
                
                // Fetch Profile Details
                var aProfileError :Error? = nil
                let aProfileDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("mqttUserDetails")
                    .child(Auth.auth().currentUser!.uid)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Any> {
                            let aUserProfile = DataContractManagerFireBase.user(dict: aDict)
                            aUser?.lockPassword = aUserProfile.lockPassword
                        } else {
                            aProfileError = NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Error in fetching profile details."])
                        }
                        aProfileDispatchSemaphore.signal()
                    }
                _ = aProfileDispatchSemaphore.wait(timeout: .distantFuture)
                if let anError = aProfileError {
                    // Do not handle this error because database does not always have mqttUserDetails/userId key,
                    // and throwing this error will avoid next steps.
                    // throw anError
                }
                
                // Observe change events
                self.observeChangeEvents()
            } catch {
                aReturnValError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(aReturnValError, aUser)
            }
        }
        
    }
    
    
    func logout(completion pCompletion: @escaping (Error?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aReturnValError :Error?
            
            do {
                try Auth.auth().signOut()
                self.removeAllObservers()
            } catch {
                aReturnValError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(aReturnValError)
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
   
    func devicesDetails(completion pCompletion: @escaping (Error?, Array<ControllerAppliance>?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anApplianceArray :Array<ControllerAppliance>?
             var aReturnValError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Fetch rooms
                var aFetchRoomError :Error?
                let aRoomDispatchSemaphore = DispatchSemaphore(value: 0)
                self.searchdevice { (pError, pRoomArray) in
                    aFetchRoomError = pError
                    anApplianceArray = pRoomArray
                    print("reEnter....")
                    if pError == nil{
                      pCompletion(aReturnValError, anApplianceArray)
                    }
                    aRoomDispatchSemaphore.signal()
                }
                _ = aRoomDispatchSemaphore.wait(timeout: .distantFuture)
                if let anError = aFetchRoomError {
                    throw anError
                }
            } catch {
                aReturnValError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                print("reEnter....")
             //   pCompletion(aReturnValError, anApplianceArray)
            }
        }
        
    }
    func devidedetail(pcontrollerApplince: ControllerAppliance) ->  String{
        
       let aRoomId = pcontrollerApplince.roomId!
        let controller_id = pcontrollerApplince.id
            let aDispatchSemaphore = DispatchSemaphore(value: 0)
            database.child("rooms").child(Auth.auth().currentUser!.uid).child(aRoomId).child("devices")
                .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                    if let aDeviceIdArray = pDataSnapshot.value as? Array<String> {
                        for i in 0..<aDeviceIdArray.count {
                            if controller_id == aRoomId{
                                pcontrollerApplince.hardwareId = String(i)
                            }
                        }
                       
                    }
                    aDispatchSemaphore.signal()
                }
            Database.database().reference()
                .child("rooms")
                .child(Auth.auth().currentUser!.uid)
                .child(aRoomId)
                .child("curtains")
                .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                    if let aDeviceIdArray = pDataSnapshot.value as? Array<String> {
                        for i in 0..<aDeviceIdArray.count {
                            if controller_id == aRoomId{
                                pcontrollerApplince.hardwareId = String(i)
                            }
                        }

                    }
                    aDispatchSemaphore.signal()
                }

            Database.database().reference()
                .child("rooms")
                .child(Auth.auth().currentUser!.uid)
                .child(aRoomId)
                .child("remotes")
                .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                    if let aDeviceIdArray = pDataSnapshot.value as? Array<String> {
                        for i in 0..<aDeviceIdArray.count {
                            if controller_id == aRoomId{
                                pcontrollerApplince.hardwareId = String(i)
                            }
                        }

                    }
                    aDispatchSemaphore.signal()
                }
            Database.database().reference()
                .child("rooms")
                .child(Auth.auth().currentUser!.uid)
                .child(aRoomId)
                .child("sensors")
                .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                    if let aDeviceIdArray = pDataSnapshot.value as? Array<String> {
                        for i in 0..<aDeviceIdArray.count {
                            if controller_id == aRoomId{
                                pcontrollerApplince.hardwareId = String(i)
                            }
                        }

                    }
                    aDispatchSemaphore.signal()
                }
            _ = aDispatchSemaphore.wait(timeout: .distantFuture)
       
        return ""
      //  return aFetchedRoomIdArray
    }
    
    func dashboardDetails(completion pCompletion: @escaping (Error?, Array<Appliance>?, Array<Room>?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anApplianceArray :Array<Appliance>?
            var aRoomArray :Array<Room>?
            var aReturnValError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Fetch frequently operated appliances
                if let aDeviceIdArray = self.deviceIdsForLoggedInUser(roomId: nil) {
                    SearchApplianceController.applinceId = aDeviceIdArray
                    var aFetchedApplianceArray = Array<Appliance>()
                    for aDeviceId in aDeviceIdArray {
                        let anApplianceDispatchSemaphore = DispatchSemaphore(value: 0)
                        self.database
                            .child("applianceDetails")
                            .child(aDeviceId)
                            .observe(DataEventType.value) { (pDataSnapshot) in
                                if let anArray = DataContractManagerFireBase.appliances(any: pDataSnapshot.value) {
                                    aFetchedApplianceArray.append(contentsOf: anArray)
                                }
                                anApplianceDispatchSemaphore.signal()
                            }
                        _ = anApplianceDispatchSemaphore.wait(timeout: .distantFuture)
                    }
                    if aFetchedApplianceArray.count > 0 {
                        // Sort frequently operated appliances and take top 6
                        aFetchedApplianceArray.sort { (pLhs, pRhs) -> Bool in
                            return pLhs.operatedCount ?? 0 > pRhs.operatedCount ?? 0
                        }
                        anApplianceArray = Array(aFetchedApplianceArray.prefix(6))
                    }
                }
                
                // Fetch rooms
                var aFetchRoomError :Error?
                let aRoomDispatchSemaphore = DispatchSemaphore(value: 0)
                self.searchRoom { (pError, pRoomArray) in
                    aFetchRoomError = pError
                    aRoomArray = pRoomArray
                    aRoomDispatchSemaphore.signal()
                }
                _ = aRoomDispatchSemaphore.wait(timeout: .distantFuture)
                if let anError = aFetchRoomError {
                    throw anError
                }
            } catch {
                aReturnValError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(aReturnValError, anApplianceArray, aRoomArray)
            }
        }
        
    }
    
}
