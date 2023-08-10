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
    var applianceDetails :String?
    var applianceSelected = Array<String?>()
    var offAppliances = Array<String?>()
    var moodOnStaticCommand = Array<String?>()

    var returnCommand : String?
    
    var curtainSelected: String?
    var lightCount: Int?
    var isOn :Bool = false
    var CurtanStatus: CurtanStatus? = .On
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
    
    enum CurtanStatus: String{
        case On = "2"
        case Off = "1"
    }
    func clone() -> Mood {
        let aReturnVal = Mood()
        
        aReturnVal.id = self.id
        aReturnVal.uuid = self.uuid
        aReturnVal.title = self.title
        aReturnVal.applianceDetails = self.applianceDetails
        aReturnVal.applianceSelected = self.applianceSelected
        aReturnVal.lightCount = self.lightCount
        aReturnVal.isOn = self.isOn
        
        aReturnVal.room = self.room?.clone()
        
        aReturnVal.applianceCount = self.applianceCount
        aReturnVal.remoteCount = self.remoteCount
        aReturnVal.curtainCount = self.curtainCount
        
        return aReturnVal
    }
    func remove() {
        self.applianceDetails = nil
        self.applianceSelected.removeAll()
        self.offAppliances.removeAll()
        self.moodOnStaticCommand.removeAll()
        self.returnCommand = nil
        self.curtainSelected = nil
        self.lightCount = nil
        self.applianceCount = nil
        self.curtainCount = nil
        self.remoteCount = nil
    }
}
