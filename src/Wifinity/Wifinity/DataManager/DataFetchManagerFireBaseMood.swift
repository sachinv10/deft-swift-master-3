//
//  DataFetchManagerFireBaseMood.swift
//  DEFT
//
//  Created by sachin on 08/11/20.
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
    //MARK: - Fetch remote key
    func selectRemoteKeys(completion pCompletion: @escaping (Error?, Array<RemoteKey>?) -> Void, room pRoom :Room?, applianeslist papplianeslist: applianeslist?) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
           // var aMoodArray :Array<MoodAppliances>? = Array<MoodAppliances>()
            var aMoodArray :Array<RemoteKey>? = Array<RemoteKey>()

            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Fetch remote key
                
                let aDispatchSemaphore = DispatchSemaphore(value: 0)
                if  let aDeviceId = papplianeslist?.remoteId, let aDeviceSubId = papplianeslist?.id{
                    var databs = self.database
                        .child("remoteKey1")
                        .child(aDeviceId).child(aDeviceSubId)
                     databs.observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                         if let anArray = DataContractManagerFireBase.remoteKeys(dict: pDataSnapshot.value as! Dictionary<String, Dictionary<String, Any>>){
                            print(anArray)
                             aMoodArray?.append(contentsOf: anArray)
 
                            aDispatchSemaphore.signal()
                        }
                    }
                    _ = aDispatchSemaphore.wait(timeout: .distantFuture)
                }
             
 
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
    func createNewMood(completion pCompletion: @escaping (Error?,  MoodAppliances?) -> Void, mood pMood :Mood?) {
         DispatchQueue.global(qos: .background).async {
             self.requestCount += 1

            var aMoodArray :MoodAppliances? = MoodAppliances()

            var anError :Error?

            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                var jsonDictinary: Dictionary<String,AnyHashable> = Dictionary<String,AnyHashable>()
                var selectedappliances:Dictionary<String,String> = Dictionary<String,String>()
                var moodOnStaticCommand:Dictionary<String,String> = Dictionary<String,String>()
                
                for i in 0..<(pMood?.moodOnStaticCommand.count)!{
                    moodOnStaticCommand.updateValue((pMood?.moodOnStaticCommand[i])!, forKey: "\(i)")
                }
                
                for i in 0..<(pMood?.applianceSelected.count)!{
                    selectedappliances.updateValue((pMood?.applianceSelected[i])!, forKey: "\(i)")
                }
                jsonDictinary.updateValue(pMood?.applianceDetails, forKey: "applianceDetails")
                jsonDictinary.updateValue(selectedappliances, forKey: "applianceSelected")
                jsonDictinary.updateValue(pMood?.curtainCount, forKey: "curtainCount")
                jsonDictinary.updateValue("", forKey: "curtainSelected")
                jsonDictinary.updateValue(pMood?.lightCount, forKey: "lightCount")
                jsonDictinary.updateValue(pMood?.id, forKey: "modeId")
                jsonDictinary.updateValue(pMood?.title, forKey: "moodName")
              //  jsonDictinary.updateValue(pMood?.title, forKey: "moodOFFIRCommand")
                jsonDictinary.updateValue(moodOnStaticCommand, forKey: "moodOnStaticCommand")
                jsonDictinary.updateValue(pMood?.remoteCount, forKey: "remoteCount")
                jsonDictinary.updateValue(pMood?.room?.id, forKey: "roomId")
                jsonDictinary.updateValue(pMood?.room?.title, forKey: "roomName")
                jsonDictinary.updateValue(pMood?.room?.id, forKey: "roomId")
                jsonDictinary.updateValue(false, forKey: "state")
                jsonDictinary.updateValue(0, forKey: "toggle")
                
                let data = self.database.child("mood").child(Auth.auth().currentUser!.uid).child(pMood?.id ?? "").setValue(jsonDictinary, withCompletionBlock: {(erro , databasere )in
                    if let error = erro{
                        print(error)
                        anError = erro
                    }else{
                        print(databasere)
                    }
                })
                
            } catch {
                anError = error
            }

            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, aMoodArray)
            }
        }
        
    }
    
    func selectAppliances(completion pCompletion: @escaping (Error?, Array<MoodAppliances>?) -> Void, room pRoom :Room?) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aMoodArray :Array<MoodAppliances>? = Array<MoodAppliances>()
        
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Fetch moods
             //   applianceDetails
                if let aDeviceIdArray = pRoom?.devices{
                    var aFetchedApplianceArray = Array<Appliance>()
                    for aDeviceId in aDeviceIdArray {
                        let aDispatchSemaphore = DispatchSemaphore(value: 0)
                        var databs = self.database
                            .child("applianceDetails")
                            .child(aDeviceId)
                        databs.keepSynced(true)
                        databs.observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                            if let anArray = DataContractManagerFireBase.appliances(any: pDataSnapshot.value) {
                                var moodappliances = MoodAppliances()

                                for data in anArray{
                                    var applianceslist = applianeslist()
                                    moodappliances.hederType = "Appliances"
                                    applianceslist.name = data.title
                                    applianceslist.id = data.id
                                    applianceslist.hardwareId = data.hardwareId
                                    moodappliances.list.append(applianceslist)
                                }
                                aMoodArray?.append(moodappliances)

                                aFetchedApplianceArray.append(contentsOf: anArray)
                            }
                            aDispatchSemaphore.signal()
                        }
                        _ = aDispatchSemaphore.wait(timeout: .distantFuture)
                    }
                    
                }
                     
                        
              //  curtan
                if let aDeviceIdArray = pRoom?.curtainId{
                    var aFetchedApplianceArray = Array<Appliance>()
                    for aDeviceId in aDeviceIdArray {
                        let aDispatchSemaphore = DispatchSemaphore(value: 0)
                        var databs = self.database
                            .child("devices")
                            .child(aDeviceId)
                        databs.keepSynced(true)
                        databs.observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                            if let anArray = DataContractManagerFireBase.curtain(dict: pDataSnapshot.value as! Dictionary<String, Any>   ) {
                                print(anArray.title)
                                 
                                    var moodappliances = MoodAppliances()
                                    var applianceslist = applianeslist()
                                    moodappliances.hederType = "Curtain"
                                applianceslist.name = anArray.title
                                applianceslist.id = anArray.id
                              //  applianceslist.hardwareId =
                                    moodappliances.list.append(applianceslist)
                                    aMoodArray?.append(moodappliances)
                                
                             }
                            aDispatchSemaphore.signal()
                        }
                        _ = aDispatchSemaphore.wait(timeout: .distantFuture)
                    }
                    
                }
            
                // remote
                if let aDeviceIdArray = pRoom?.remoteId{
                    var aFetchedApplianceArray = Array<Appliance>()
                    for aDeviceId in aDeviceIdArray {
                        let aDispatchSemaphore = DispatchSemaphore(value: 0)
                        var databs = self.database
                            .child("devices")
                            .child(aDeviceId)
                        databs.keepSynced(true)
                        databs.observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                            if let anArray = DataContractManagerFireBase.remoteforMood(dict: pDataSnapshot.value as!  Dictionary<String, Any>){
                                print(anArray)
                                var moodappliances = MoodAppliances()
                                for i in stride(from: 0, to: anArray.name?.count ?? 0, by: 1){
                                    var applianceslist = applianeslist()
                                    moodappliances.hederType = "Remote"
                                    applianceslist.name = anArray.name?[i]
                                    applianceslist.id = anArray.id?[i]
                                    applianceslist.remoteId = anArray.remoteId
                                    applianceslist.remoteType = anArray.remoteType?[i].uppercased()
                                    moodappliances.list.append(applianceslist)
                                }
                                
                                aMoodArray?.append(moodappliances)
                                
                                aDispatchSemaphore.signal()
                            }
                        }
                        _ = aDispatchSemaphore.wait(timeout: .distantFuture)
                    }
                    
                }
                
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
    
    func searchMood(completion pCompletion: @escaping (Error?, String?, Array<Mood>?) -> Void, room pRoom :Room?) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aMoodArray :Array<Mood>? = Array<Mood>()
            var anError :Error?
            var mood_id:String? = String()
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
                     
                            for moodkey in aDict.keys{
                               if mood_id != nil{
                                   if  mood_id! < moodkey{
                                       mood_id = moodkey
                                   }
                               }else{
                                   mood_id = moodkey
                               }
                            }
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
                pCompletion(anError, mood_id, aMoodArray)
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
    func deleteMoods(pmood: Mood, complition:@escaping(Error?) -> Void) {
        if let moodid = pmood.id{
            self.database
                .child("mood")
                .child(Auth.auth().currentUser!.uid).child(moodid).removeValue(completionBlock: {error, datarefrances in
                    if let err = error{
                        complition(err)
                    }else{
                        complition(nil)
                    }
                    
                })
            
          
        }
    }

}
