//
//  DataFetchManagerFireBaseRoom.swift
//  DEFT
//
//  Created by Rupendra on 08/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import Firebase
import UIKit

extension DataFetchManagerFireBase {
    func editRoomName(coplition pComplition: @escaping(Error?)-> Void,room pRoom: Room?){
        DispatchQueue.global(qos: .background).async { [self] in
            var anError: Error? = nil
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                let updatedData = ["roomName": pRoom?.title]
                var hardwareId: [String] = [String]()
                if let hId = pRoom?.devices{
                    hardwareId.append(contentsOf: hId)
                    for item in hId{
                        if let h_type = Device.getHardwareType(id: item){
                            if let count = Device.getSwitchCount(hardwareType: h_type){
                                for i in 0..<count{
                                    database.child("applianceDetails").child(item).child(String(i)).updateChildValues(updatedData, withCompletionBlock: {(error, DatabaseReference) in
                                        print("room Name Updated")
                                    })
                                }
                            }
                        }
                    }
                }
                if let hId = pRoom?.curtainId{
                    hardwareId.append(contentsOf: hId)
                }
                if let hId = pRoom?.remoteId{
                    hardwareId.append(contentsOf: hId)
                }
                if let hId = pRoom?.sensorId{
                    hardwareId.append(contentsOf: hId)
                }
                let aDispatchSemaphore = DispatchSemaphore(value: 0)
                
                if let roomid = pRoom?.id{
                    database.child("rooms").child(Auth.auth().currentUser!.uid).child(roomid).updateChildValues(updatedData, withCompletionBlock: {(error, DatabaseReference) in
                        pComplition(error)
                        aDispatchSemaphore.signal()
                    })
                    aDispatchSemaphore.wait(timeout: .distantFuture)
                }
                for items in hardwareId{
                    database.child("devices").child(items).updateChildValues(updatedData, withCompletionBlock: {(error, DatabaseReference) in
                        // pComplition(error)
                        aDispatchSemaphore.signal()
                    })
                    aDispatchSemaphore.wait(timeout: .distantFuture)
                }
                
                
            }catch{
                pComplition(anError)
            }
        }
    }
    func deleteRoom(coplition pComplition: @escaping(Error?)-> Void,room pRoom: Room?){
        var anError: Error? = nil
        do {
            if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
            }
            //    let aDispatchSemaphore = DispatchSemaphore(value: 0)
            if let roomid = pRoom?.id{
                database.child("rooms").child(Auth.auth().currentUser!.uid).child(roomid).removeValue(completionBlock: {(error, DatabaseReference) in
                    if error != nil{
                    }
                    pComplition(error)
                })
            }
        }catch{
            pComplition(anError)
        }
    }
    func saveRoom(completion pCompletion: @escaping (Error?, Room?) -> Void, room pRoom :Room) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                let aKey = pRoom.id ?? self.getNextKey(dataBasePath: "rooms/" + Auth.auth().currentUser!.uid, length: 2)
                
                var aRoomDict = Dictionary<String,Any?>()
                aRoomDict.updateValue(aKey, forKey: "roomId")
                aRoomDict.updateValue(pRoom.title, forKey: "roomName")
                
                let aDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("rooms")
                    .child(Auth.auth().currentUser!.uid)
                    .child(aKey)
                    .setValue(aRoomDict, withCompletionBlock: { (pError, pDatabaseReference) in
                        anError = pError
                        pRoom.id = aKey
                        aDispatchSemaphore.signal()
                    })
                _ = aDispatchSemaphore.wait(timeout: .distantFuture)
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, pRoom)
            }
        }
    }
    
    func searchdevice(completion pCompletion: @escaping (Error?, Array<ControllerAppliance>?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aRoomArray :Array<ControllerAppliance>? = Array<ControllerAppliance>()
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Fetch rooms
                var aRoomDispatchSemaphore = DispatchSemaphore(value: 0)
                //for itemId in (0 ..< ControllerListViewController.contollerDeviceId.count) {
                // print(itemId)
                DispatchQueue.main.asyncAfter(deadline: .now()){
                    //    let sd = ControllerListViewController.contollerDeviceId[itemId]
                    //                    self.getDetailontime(id: sd, completion: {(pCompletion) in
                    //                        aRoomArray?.append(pCompletion!)
                    //                    } )
                    self.database
                        .child("devices")
                        .queryOrdered(byChild: "uid").queryEqual(toValue: Auth.auth().currentUser?.uid ?? "").keepSynced(true)
                    self.database
                        .child("devices")
                        .queryOrdered(byChild: "uid").queryEqual(toValue: Auth.auth().currentUser?.uid ?? "")
                        .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                            if let aDict = pDataSnapshot.value as? [String:Any] {
                                for items in aDict{
                                    if let controllerapp =  DataContractManagerFireBase.devicecontroller(dict: items.value as! Dictionary<String,Any>){
                                        aRoomArray?.append(controllerapp)
                                    }
                                }
                            }
                            aRoomDispatchSemaphore.signal()
                        }
                    
                    
                    //                        self.database
                    //                            .child("keepAliveTimeStamp")
                    //                            .child(sd)
                    //                            .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                    //                                print(pDataSnapshot)
                    //                                if let aDict = pDataSnapshot.value as? Dictionary<String,Any> {
                    //                                    DeviceSettingViewController.timestamp.append(aDict)
                    //                                }
                    //                                aRoomDispatchSemaphore.signal()
                    //                            }
                }
                //}
                _ = aRoomDispatchSemaphore.wait(timeout: .distantFuture)
                aRoomDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("vdpDevices")
                    .queryOrdered(byChild: "uid").queryEqual(toValue: Auth.auth().currentUser?.uid ?? "")
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        if let aDict = pDataSnapshot.value as? [String:Any] {
                            for items in aDict{
                                if let controllerapp =  DataContractManagerFireBase.devicecontroller(dict: items.value as! Dictionary<String,Any>){
                                    aRoomArray?.append(controllerapp)
                                }
                            }
                        }
                        pCompletion(anError, aRoomArray)
                        aRoomDispatchSemaphore.signal()
                    }
                _ = aRoomDispatchSemaphore.wait(timeout: .distantFuture)
            } catch {
                anError = error
                pCompletion(anError, aRoomArray)
            }
            if aRoomArray?.count != nil{
            }
            //    pCompletion(anError, aRoomArray)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.requestCount -= 1
                print("reran.......")
                pCompletion(anError, aRoomArray)
            }
            pCompletion(anError, aRoomArray)
        }
        
    }
    func getDetailontime(id: String, completion pCompletion: @escaping (ControllerAppliance?) -> Void) {
        
        let aRoomDispatchSemaphore = DispatchSemaphore(value: 0)
        self.database
            .child("devices")
            .child(id)
            .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                print(pDataSnapshot)
                if let aDict = pDataSnapshot.value as? Dictionary<String,Any> {
                    if  let controllerapp =  DataContractManagerFireBase.devicecontroller(dict: aDict){
                        pCompletion(controllerapp)
                        //  aRoomDispatchSemaphore.signal()
                    }
                }
                aRoomDispatchSemaphore.signal()
            }
        // _ = aRoomDispatchSemaphore.wait(timeout: .distantFuture)
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
                    .child("rooms")
                    .child(Auth.auth().currentUser!.uid).keepSynced(true)
                self.database
                    .child("rooms")
                    .child(Auth.auth().currentUser!.uid)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Dictionary<String,Any>> {
                            aRoomArray = DataContractManagerFireBase.rooms(dict: aDict)
                        }
                        // Sort rooms
                        aRoomArray?.sort { (pLhs, pRhs) -> Bool in
                            return pLhs.title?.lowercased() ?? "" < pRhs.title?.lowercased() ?? ""
                        }
                        aRoomArray?.sort { (Plhs, pRhs) -> Bool in
                            return Plhs.position?.lowercased() ?? "" < pRhs.position?.lowercased() ?? ""
                        }
                        aRoomDispatchSemaphore.signal()
                    }
                _ = aRoomDispatchSemaphore.wait(timeout: .distantFuture)
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, aRoomArray)
            }
        }
        
    }
    
    
    func roomIdsForLoggedInUser() -> Array<String>? {
        var aReturnVal :Array<String>?
        
        let aDispatchSemaphore = DispatchSemaphore(value: 0)
        self.database
            .child("rooms")
            .child(Auth.auth().currentUser!.uid)
            .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                print(pDataSnapshot)
                
                aReturnVal = (pDataSnapshot.value as? Dictionary<String,Any>)?.keys.map { String($0) }
                var aReturnValx = (pDataSnapshot.value as? Dictionary<String,Dictionary<String,Any>>)
                print(aReturnValx as Any)
                aDispatchSemaphore.signal()
            }
        _ = aDispatchSemaphore.wait(timeout: .distantFuture)
        if (aReturnVal != nil){
            //   ControllerListViewController.contollerDeviceId = self.devidedetail(array: aReturnVal!)!
        }
        return aReturnVal
    }
    
    func devidedetail(array: Array<String>) -> Array<String>?{
        var aaaDeviceIdArray = [String: String]()
        var aFetchedRoomIdArray = Array<String>()
        for aRoomId in array {
            let aDispatchSemaphore = DispatchSemaphore(value: 0)
            self.database
                .child("rooms")
                .child(Auth.auth().currentUser!.uid)
                .child(aRoomId)
                .child("devices")
                .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                    if let aDeviceIdArray = pDataSnapshot.value as? Array<String> {
                        aFetchedRoomIdArray.append(contentsOf: aDeviceIdArray)
                        let sdx = self.deviceApplinceDetail(array: aDeviceIdArray)
                    }
                    aDispatchSemaphore.signal()
                }
            self.database
                .child("rooms")
                .child(Auth.auth().currentUser!.uid)
                .child(aRoomId)
                .child("curtains")
                .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                    if let aDeviceIdArray = pDataSnapshot.value as? Array<String> {
                        aFetchedRoomIdArray.append(contentsOf: aDeviceIdArray)
                    }
                    aDispatchSemaphore.signal()
                }
            
            self.database
                .child("rooms")
                .child(Auth.auth().currentUser!.uid)
                .child(aRoomId)
                .child("remotes")
                .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                    if let aDeviceIdArray = pDataSnapshot.value as? Array<String> {
                        aFetchedRoomIdArray.append(contentsOf: aDeviceIdArray)
                    }
                    aDispatchSemaphore.signal()
                }
            self.database
                .child("rooms")
                .child(Auth.auth().currentUser!.uid)
                .child(aRoomId)
                .child("sensors")
                .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                    if let aDeviceIdArray = pDataSnapshot.value as? Array<String> {
                        aFetchedRoomIdArray.append(contentsOf: aDeviceIdArray)
                    }
                    aDispatchSemaphore.signal()
                }
            _ = aDispatchSemaphore.wait(timeout: .distantFuture)
        }
        //  print(aFetchedRoomIdArray)
        return aFetchedRoomIdArray
    }
    func deviceApplinceDetail(array: Array<String>) -> Array<String>?{
        var aFetchedRoomIdArray = Array<String>()
        var aRoomArray :Array<ControllerAppliance>? = Array<ControllerAppliance>()
        let aDispatchSemaphore = DispatchSemaphore(value: 0)
        
        for aRoomId in array {
            self.database.child("devices").child(aRoomId).observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                print(pDataSnapshot)
                if let aDict = pDataSnapshot.value as? Dictionary<String,Any> {
                    if  let controllerapp =  DataContractManagerFireBase.devicecontroller(dict: aDict){
                        print(controllerapp)
                        aRoomArray?.append(controllerapp)
                        let viewobj = self.myfunc()
                        viewobj.controllerApplince.append(controllerapp)
                    }
                }
                aDispatchSemaphore.signal()
            }
        }
        return aFetchedRoomIdArray
    }
    func myfunc()-> ControllerListViewController{
        let storyboard = UIStoryboard(name: "ContollerList", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ControllerListViewController") as! ControllerListViewController
        return viewController
    }
    func verifyMobileNumber(complition pcomplition: @escaping(Error?, UserVerify?)-> Void) {
        var userverifyy = UserVerify()
        var error: Error?
        
        if let uid = Auth.auth().currentUser?.uid{
            Database.database().reference().child("standaloneUserDetails").child(uid).observeSingleEvent(of: .value, with: {DataSnapshot in
                do{
                    let xd = try? DataSnapshot.value as? Dictionary<String,Any>
                    userverifyy.numberVerified = xd?["numberVerified"] as? String
                    userverifyy.phoneNumber = xd?["phoneNumber"] as? String
                    
                    userverifyy.dob = xd?["dob"] as? String
                    userverifyy.email = xd?["email"] as? String
                    
                    userverifyy.userName = xd?["userName"] as? String
                    userverifyy.flatNumber = xd?["flatNumber"] as? String
                    
                    userverifyy = userverifyy.clone()
                }catch let errors{
                    error = errors
                }
                pcomplition(error, userverifyy)
            })
        }
    }
}

