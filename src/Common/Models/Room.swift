//
//  Room.swift
//  DEFT
//
//  Created by Rupendra on 21/08/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class Room: NSObject {
    var id :String?
    var title :String?
    var lastActiveDate :Date?
    
    var appliances :Array<Appliance>?
    var curtains :Array<Curtain>?
    var remotes :Array<Remote>?
    var moodOnRemotes :Array<Remote>?
    var moodOffRemotes :Array<Remote>?
    var sensors :Array<Sensor>?
    
    override init() {
        
    }
    
    init(title pTitle :String, lastActiveDate pLastActiveDate :Date) {
        self.title = pTitle
        self.lastActiveDate = pLastActiveDate
    }
    
    
    func clone() -> Room {
        let aReturnVal :Room = Room()
        
        aReturnVal.id = self.id
        aReturnVal.title = self.title
        
        aReturnVal.lastActiveDate = self.lastActiveDate
        
        aReturnVal.appliances = self.appliances
        aReturnVal.curtains = self.curtains
        aReturnVal.remotes = self.remotes
        aReturnVal.moodOnRemotes = self.moodOnRemotes
        aReturnVal.moodOffRemotes = self.moodOffRemotes
        aReturnVal.sensors = self.sensors
        
        return aReturnVal
    }
    
    
    var lastActiveDateText :String? {
        var aReturnVal :String? = nil
        if let aDate = self.lastActiveDate {
            let aDateFormatter = DateFormatter()
            aDateFormatter.dateFormat = "dd MMM 'at' hh:mm a"
            aReturnVal = aDateFormatter.string(from: aDate)
        }
        return aReturnVal
    }
}
