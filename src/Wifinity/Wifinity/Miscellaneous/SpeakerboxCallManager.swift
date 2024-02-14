//
//  SpeakerboxCallManager.swift
//  Wifinity
//
//  Created by Apple on 03/02/23.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseAuth
import FirebaseDatabase
class YourLocationManager: NSObject {
    static let Shared = YourLocationManager()
  
    override init() {
        if ((FirebaseApp.allApps?.count ?? 0) <= 0) {
            FirebaseApp.configure()
        }
        self.database = Database.database().reference()
        
        super.init()
    }
    
    let database :DatabaseReference
    
    func updateVale(id: CLRegion!, action: String){
        if let uid = Auth.auth().currentUser?.uid{
            database.child("geoFencingDeviceDetails").child(uid).child("008").child(action).setValue(["id":id.identifier], withCompletionBlock: {(error, DataSnapshot) in
                
            })
        }
    }
    

}
