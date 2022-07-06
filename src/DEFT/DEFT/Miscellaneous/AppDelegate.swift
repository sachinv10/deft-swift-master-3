//
//  AppDelegate.swift
//  DEFT
//
//  Created by Rupendra on 21/08/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit
import UserNotifications
import FirebaseCore
import FirebaseMessaging


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ProgressOverlay.shared.activityIndicatorViewStyle = UIActivityIndicatorView.Style.whiteLarge
        
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.error)
        
        self.registerForPushNotification()
        return true
    }
    
}


extension AppDelegate :UNUserNotificationCenterDelegate {
    
    func registerForPushNotification() {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (pGranted, pError) in
            DispatchQueue.main.async {
                if pGranted {
                    UIApplication.shared.registerForRemoteNotifications()
                } else {
                    var aMessage = "Failed to get authorization for user notification."
                    if let anErrorMessage = pError?.localizedDescription {
                        aMessage += "" + anErrorMessage
                    }
                    Swift.print(aMessage)
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken pDeviceToken: Data) {
        Messaging.messaging().apnsToken = pDeviceToken
    }
    
    func application(_ pApplication: UIApplication, didFailToRegisterForRemoteNotificationsWithError pError: Error) {
        let aMessage = "Failed to register for user notification. " + pError.localizedDescription
        Swift.print(aMessage)
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler pCompletionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        pCompletionHandler([[.alert, .sound]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}


extension AppDelegate: MessagingDelegate {
    func messaging(_ pMessaging: Messaging,didReceiveRegistrationToken pFcmToken: String?) {
        let aTokenDict = ["token": pFcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: aTokenDict)
        CacheManager.shared.fcmToken = pFcmToken
    }
}
