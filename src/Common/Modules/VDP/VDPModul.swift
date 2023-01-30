//
//  VDPModul.swift
//  Wifinity
//
//  Created by Apple on 30/12/22.
//

import Foundation
import UIKit


class VDPModul: NSObject {
    var available :Bool = false
    var id :String?
    var callStatus :String?
    var ip_address :String?
    var name :String?
    var ssid :String?
    var uid :String?
    var nightVision :Bool = false
    var online :Bool = false
    var vdpFilter :Bool = false
    
    func clone() -> VDPModul {
        let aReturnVal = VDPModul()
        aReturnVal.available = self.available
        aReturnVal.id = self.id
        aReturnVal.callStatus = self.callStatus
        aReturnVal.ip_address = self.ip_address
        aReturnVal.name = self.name
        aReturnVal.ssid = self.ssid
        aReturnVal.uid = self.uid
        aReturnVal.nightVision = self.nightVision
        aReturnVal.online = self.online
        aReturnVal.vdpFilter = self.vdpFilter
        return aReturnVal
    }
    
     
}
