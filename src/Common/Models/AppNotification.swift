//
//  Notification.swift
//  DEFT
//
//  Created by Rupendra on 15/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import Foundation


class AppNotification: NSObject {
    var id :String?
    var message :String?
    var date :Date?
    var timeStamp: String?
    
    
    enum AppNotificationType :String {
        case energyNotification = "Energy Notification"
        case motionNotification = "Motion Notification"
        case globalOffNotification = "Global Off Notification"
        case lockNotification = "Lock Notification"
        case schedularNotification = "Schedular Notification"
        case informationNotification = "Information Notification"
        case deviceOfflineNotification = "Device Offline Notification"
        case sensorNotification = "Sensor Notification"
        case tempratureNotification = "Temperature Notification"
    }
}


class AppNotificationSettings: NSObject {
    var fcmToken :String?
    
    var isEnergyNotificationSubscribed :Bool = false
    var isInformationNotificationSubscribed :Bool = false
    var isGlobalOffNotificationSubscribed :Bool = false
    var isLockNotificationSubscribed :Bool = false
    var isSchedularNotificationSubscribed :Bool = false
    var isTemperatureNotificationSubscribed: Bool = false
    var isVDPNotificationSubscribed: Bool = false
    var isCriticalNotificationDeviceToken: Bool = true
    var isSmartSensorNotificationSubscribed: Bool = false
    var isSmokeSensorNotificationSubscribed: Bool = false
    func clone() -> AppNotificationSettings {
        let aReturnVal = AppNotificationSettings()
        
        aReturnVal.fcmToken = self.fcmToken
        
        aReturnVal.isEnergyNotificationSubscribed = self.isEnergyNotificationSubscribed
        aReturnVal.isInformationNotificationSubscribed = self.isInformationNotificationSubscribed
        aReturnVal.isGlobalOffNotificationSubscribed = self.isGlobalOffNotificationSubscribed
        aReturnVal.isLockNotificationSubscribed = self.isLockNotificationSubscribed
        aReturnVal.isSchedularNotificationSubscribed = self.isSchedularNotificationSubscribed
        aReturnVal.isTemperatureNotificationSubscribed = self.isTemperatureNotificationSubscribed
        aReturnVal.isVDPNotificationSubscribed = self.isVDPNotificationSubscribed
        aReturnVal.isCriticalNotificationDeviceToken = self.isCriticalNotificationDeviceToken
        aReturnVal.isSmartSensorNotificationSubscribed = self.isSmartSensorNotificationSubscribed
        aReturnVal.isSmokeSensorNotificationSubscribed = self.isSmokeSensorNotificationSubscribed
        return aReturnVal
    }
}
