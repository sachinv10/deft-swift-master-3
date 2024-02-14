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
    var deviceToken :String?
    
    
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
            anAppNotificationSettings.isCriticalNotificationDeviceToken = aNotificationSettingsDict["isCriticalNotificationDeviceToken"] as? Bool ?? false
            anAppNotificationSettings.isTemperatureNotificationSubscribed = aNotificationSettingsDict["isTemperatureNotificationSubscribed"] as? Bool ?? false
            anAppNotificationSettings.isVDPNotificationSubscribed = aNotificationSettingsDict["isVDPNotificationSubscribed"] as? Bool ?? false
            anAppNotificationSettings.isSmartSensorNotificationSubscribed = aNotificationSettingsDict["isSmartSensorNotificationSubscribed"] as? Bool ?? false
            anAppNotificationSettings.isSmokeSensorNotificationSubscribed = aNotificationSettingsDict["isSmokeSensorNotificationSubscribed"] as? Bool ?? false
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
                    aNotificationSettingsDict["isCriticalNotificationDeviceToken"] = anAppNotificationSettings.isCriticalNotificationDeviceToken
                    aNotificationSettingsDict["isTemperatureNotificationSubscribed"] = anAppNotificationSettings.isTemperatureNotificationSubscribed
                    aNotificationSettingsDict["isVDPNotificationSubscribed"] = anAppNotificationSettings.isVDPNotificationSubscribed
                    aNotificationSettingsDict["isSmartSensorNotificationSubscribed"] = anAppNotificationSettings.isSmartSensorNotificationSubscribed
                    aNotificationSettingsDict["isSmokeSensorNotificationSubscribed"] = anAppNotificationSettings.isSmokeSensorNotificationSubscribed
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
