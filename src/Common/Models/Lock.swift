//
//  Lock.swift
//  DEFT
//
//  Created by Rupendra on 15/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import Foundation


class Lock: NSObject {
    var id :String?
    var title :String?
    var isOpen :Bool = false
    var password :String?
    
    var deftLockType :String?
    
    var hardwareType :Device.HardwareType? {
        var aReturnVal :Device.HardwareType? = nil
        if let anId = self.id {
            aReturnVal = Device.getHardwareType(id: anId)
        }
        if aReturnVal == nil {
            if self.deftLockType == "Gate Controller" {
                aReturnVal = Device.HardwareType.gateLock
            }
        }
        return aReturnVal
    }
    
    func clone() -> Lock {
        let aReturnVal = Lock()
        
        aReturnVal.id = self.id
        aReturnVal.title = self.title
        aReturnVal.isOpen = self.isOpen
        aReturnVal.password = self.password
        aReturnVal.deftLockType = self.deftLockType
        
        return aReturnVal
    }
    
}
