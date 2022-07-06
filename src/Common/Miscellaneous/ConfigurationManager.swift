//
//  ConfigurationManager.swift
//  DEFT
//
//  Created by Rupendra on 21/08/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class ConfigurationManager: NSObject {

    static var shared :ConfigurationManager = {
        return ConfigurationManager()
    }()
    
    
    var appType :ConfigurationManager.AppType {
        var aReturnVal = ConfigurationManager.AppType.deft
        #if APP_WIFINITY
        aReturnVal = ConfigurationManager.AppType.wifinity
        #endif
        return aReturnVal
    }
    
    #if DEBUG
    let isDebugMode :Bool = true
    #else
    let isDebugMode :Bool = false
    #endif
    
    var newDeviceConfigureNetworkUrlString :String {
        return "http://192.168.4.1/"
    }
    
    var moodActivateUrlString :String {
        return "http://35.238.195.189:3012/deft/moodActivate"
    }
    
    var rechabilityServerUrlString :String {
        return "https://google.com/"
    }
    
    var supportPhoneNumber :String {
        return "+919007900709"
    }
    
    
    enum AppType :String {
        case deft
        case wifinity
    }
    
}
