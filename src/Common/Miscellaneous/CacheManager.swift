//
//  CacheManager.swift
//  Wifinity
//
//  Created by Rupendra on 06/03/21.
//

import Foundation

class CacheManager {
    static let shared = CacheManager()
    
    var fcmToken :String?
    
    
    
    func appNotificationSettings(userId pUserId :String) -> AppNotificationSettings? {
        var aReturnVal :AppNotificationSettings?
        
        if let aUserDict = UserDefaults.standard.dictionary(forKey: pUserId)
           , let aNotificationSettingsDict = aUserDict["notificationSettings"] as? Dictionary<String,Any> {
            let anAppNotificationSettings = AppNotificationSettings()
            anAppNotificationSettings.fcmToken = self.fcmToken
            anAppNotificationSettings.isEnergyNotificationSubscribed = aNotificationSettingsDict["isEnergyNotificationSubscribed"] as? Bool ?? false
            anAppNotificationSettings.isInformationNotificationSubscribed = aNotificationSettingsDict["isInformationNotificationSubscribed"] as? Bool ?? false
            anAppNotificationSettings.isGlobalOffNotificationSubscribed = aNotificationSettingsDict["isGlobalOffNotificationSubscribed"] as? Bool ?? false
            anAppNotificationSettings.isLockNotificationSubscribed = aNotificationSettingsDict["isLockNotificationSubscribed"] as? Bool ?? false
            anAppNotificationSettings.isSchedularNotificationSubscribed = aNotificationSettingsDict["isSchedularNotificationSubscribed"] as? Bool ?? false
            
            aReturnVal = anAppNotificationSettings
        }
        
        return aReturnVal
    }
    
    func cacheAppNotificationSettings(completion pCompletion :@escaping(() -> ()), userId pUserId :String) {
        if let aNotificationToken = self.fcmToken {
            DataFetchManager.shared.appNotificationSettingsDetails(completion: { (pError, pAppNotificationSettings) in
                if let anAppNotificationSettings = pAppNotificationSettings {
                    var aUserDict = UserDefaults.standard.dictionary(forKey: pUserId) ?? Dictionary<String,Any>()
                    
                    var aNotificationSettingsDict = Dictionary<String,Any?>()
                    aNotificationSettingsDict["notificationToken"] = anAppNotificationSettings.fcmToken
                    aNotificationSettingsDict["isEnergyNotificationSubscribed"] = anAppNotificationSettings.isEnergyNotificationSubscribed
                    aNotificationSettingsDict["isInformationNotificationSubscribed"] = anAppNotificationSettings.isInformationNotificationSubscribed
                    aNotificationSettingsDict["isGlobalOffNotificationSubscribed"] = anAppNotificationSettings.isGlobalOffNotificationSubscribed
                    aNotificationSettingsDict["isLockNotificationSubscribed"] = anAppNotificationSettings.isLockNotificationSubscribed
                    aNotificationSettingsDict["isSchedularNotificationSubscribed"] = anAppNotificationSettings.isSchedularNotificationSubscribed
                    
                    aUserDict["notificationSettings"] = aNotificationSettingsDict
                    UserDefaults.standard.setValue(aUserDict, forKey: pUserId)
                }
                
                pCompletion()
            }, notificationToken: aNotificationToken)
        } else {
            pCompletion()
        }
    }
}
