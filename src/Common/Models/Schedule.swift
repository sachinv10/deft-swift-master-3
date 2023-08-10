//
//  Schedule.swift
//  DEFT
//
//  Created by Rupendra on 08/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class Schedule: NSObject {
    var id :String?
    var uuid :String?
    var title :String?
    var repeatOnce :Bool?
    var isOn :Bool = false
    var time :String?
    var repetitions :Array<Day>?
    
    var repetitionsDisplayText :String? {
        var aReturnVal :String? = nil
        if let aRepetitionArray = self.repetitions {
            var aDisplayText = ""
            for aRepetition in aRepetitionArray {
                aDisplayText += aRepetition.shortTitle + ", "
            }
            aDisplayText = aDisplayText.trimmingCharacters(in: CharacterSet(charactersIn: ", "))
            aReturnVal = aDisplayText
        }
        return aReturnVal
    }
    
    var rooms :Array<Room>?
    
    var applianceCount :Int?
    
    var calculatedApplianceCount :Int {
        var aReturnVal = 0
        if let aRoomArray = self.rooms {
            for aRoom in aRoomArray {
                aReturnVal += aRoom.appliances?.count ?? 0
            }
        }
        return aReturnVal
    }
    
    var curtainCount :Int?
    
    var calculatedCurtainCount :Int {
        var aReturnVal = 0
        if let aRoomArray = self.rooms {
            for aRoom in aRoomArray {
                aReturnVal += aRoom.curtains?.count ?? 0
            }
        }
        return aReturnVal
    }
    
    var remoteCount :Int?
    
    var calculatedRemoteCount :Int {
        var aReturnVal = 0
        if let aRoomArray = self.rooms {
            for aRoom in aRoomArray {
                if let aRemoteArray = aRoom.remotes {
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
        }
        return aReturnVal
    }
    
    var sensorCount :Int?
    
    var calculatedSensorCount :Int {
        var aReturnVal = 0
        if let aRoomArray = self.rooms {
            for aRoom in aRoomArray {
                aReturnVal += aRoom.sensors?.count ?? 0
            }
        }
        return aReturnVal
    }
    
    
    enum Day :String {
        case sunday = "Sunday"
        case monday = "Monday"
        case tuesday = "Tuesday"
        case wednesday = "Wednesday"
        case thursday = "Thursday"
        case friday = "Friday"
        case saturday = "Saturday"
        
        var shortTitle :String {
            var aReturnVal :String = "Sun"
            switch self {
            case .sunday:
                aReturnVal = "Sun"
            case .monday:
                aReturnVal = "Mon"
            case .tuesday:
                aReturnVal = "Tue"
            case .wednesday:
                aReturnVal = "Wed"
            case .thursday:
                aReturnVal = "Thu"
            case .friday:
                aReturnVal = "Fri"
            case .saturday:
                aReturnVal = "Sat"
            }
            return aReturnVal
        }
    }
    
    
    enum ComponentType :String {
        case appliance = "APPLIANCE"
        case curtain = "CURTAIN"
        case remoteKey = "REMOTE_KEY"
        case sensor = "SENSOR"
    }
    
    func clone() -> Schedule {
        let aReturnVal = Schedule()
        
        aReturnVal.id = self.id
        aReturnVal.uuid = self.uuid
        aReturnVal.title = self.title
        aReturnVal.repeatOnce = self.repeatOnce
        aReturnVal.time = self.time
        aReturnVal.repetitions = self.repetitions
        
        aReturnVal.rooms = self.rooms
        
        aReturnVal.applianceCount = self.applianceCount
        aReturnVal.curtainCount = self.curtainCount
        aReturnVal.remoteCount = self.remoteCount
        
        return aReturnVal
    }
}
