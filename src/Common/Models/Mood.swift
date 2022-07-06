//
//  Mood.swift
//  DEFT
//
//  Created by Rupendra on 15/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import Foundation


class Mood: NSObject {
    var id :String?
    var uuid :String?
    var title :String?
    
    var isOn :Bool = false
    
    var room :Room?
    
    var applianceCount :Int?
    
    var calculatedApplianceCount :Int {
        var aReturnVal = 0
        if let aRoom = self.room {
            aReturnVal += aRoom.appliances?.count ?? 0
        }
        return aReturnVal
    }
    
    var curtainCount :Int?
    
    var calculatedCurtainCount :Int {
        var aReturnVal = 0
        if let aRoom = self.room {
            aReturnVal += aRoom.curtains?.count ?? 0
        }
        return aReturnVal
    }
    
    var remoteCount :Int?
    
    var calculatedRemoteCount :Int {
        var aReturnVal = 0
        if let aRoom = self.room {
            if let aRemoteArray = aRoom.moodOnRemotes {
                var aFilteredRemoteArray = Array<Remote>()
                for aRemote in aRemoteArray {
                    if !aFilteredRemoteArray.contains(where: { (pRemote) -> Bool in
                        return pRemote.id == aRemote.id
                    }) {
                        aFilteredRemoteArray.append(aRemote)
                    }
                }
                for aRemote in aFilteredRemoteArray {
                    aReturnVal += (aRemote.selectedRemoteKeys?.count ?? 0)
                }
            }
            if let aRemoteArray = aRoom.moodOffRemotes {
                var aFilteredRemoteArray = Array<Remote>()
                for aRemote in aRemoteArray {
                    if !aFilteredRemoteArray.contains(where: { (pRemote) -> Bool in
                        return pRemote.id == aRemote.id
                    }) {
                        aFilteredRemoteArray.append(aRemote)
                    }
                }
                for aRemote in aFilteredRemoteArray {
                    aReturnVal += (aRemote.selectedRemoteKeys?.count ?? 0)
                }
            }
        }
        return aReturnVal
    }
    
    
    enum ComponentType :String {
        case appliance = "APPLIANCE"
        case curtain = "CURTAIN"
        case remoteKey = "REMOTE_KEY"
    }
    
    
    func clone() -> Mood {
        let aReturnVal = Mood()
        
        aReturnVal.id = self.id
        aReturnVal.uuid = self.uuid
        aReturnVal.title = self.title
        
        aReturnVal.isOn = self.isOn
        
        aReturnVal.room = self.room?.clone()
        
        aReturnVal.applianceCount = self.applianceCount
        aReturnVal.remoteCount = self.remoteCount
        aReturnVal.curtainCount = self.curtainCount
        
        return aReturnVal
    }
}
