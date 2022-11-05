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
                let aRoomDispatchSemaphore = DispatchSemaphore(value: 0)
                for itemId in (0 ..< ControllerListViewController.contollerDeviceId.count) {
                    print(itemId)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                        let sd = ControllerListViewController.contollerDeviceId[itemId]
                        //                    self.getDetailontime(id: sd, completion: {(pCompletion) in
                        //                        aRoomArray?.append(pCompletion!)
                        //                    } )
                        self.database
                            .child("devices")
                            .child(sd)
                            .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                                print(pDataSnapshot)
                                if let aDict = pDataSnapshot.value as? Dictionary<String,Any> {
                                    if  let controllerapp =  DataContractManagerFireBase.devicecontroller(dict: aDict){
                                        aRoomArray?.append(controllerapp)
                                        print(sd)
                                    }
                                }
                                aRoomDispatchSemaphore.signal()
                            }
                        self.database
                            .child("keepAliveTimeStamp")
                            .child(sd)
                            .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                                print(pDataSnapshot)
                                if let aDict = pDataSnapshot.value as? Dictionary<String,Any> {
                                    DeviceSettingViewController.timestamp.append(aDict)
                                }
                                aRoomDispatchSemaphore.signal()
                            }
                    }
                }
                _ = aRoomDispatchSemaphore.wait(timeout: .distantFuture)
                
            } catch {
                anError = error
                pCompletion(anError, aRoomArray)
            }
            if aRoomArray?.count != nil{
                
            }
            //    pCompletion(anError, aRoomArray)
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
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
                    .child(Auth.auth().currentUser!.uid)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
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
            ControllerListViewController.contollerDeviceId = self.devidedetail(array: aReturnVal!)!
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
        var viewController = storyboard.instantiateViewController(withIdentifier: "ControllerListViewController") as! ControllerListViewController
        return viewController
    }
}

