//
//  AppDelegate.swift
//  Wifinity
//
//  Created by Rupendra on 10/12/20.
//

import UIKit
import UserNotifications
import FirebaseCore
import Firebase
import FirebaseMessaging



@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    var aUser :User?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      //  ProgressOverlay.shared.activityIndicatorViewStyle = UIActivityIndicatorView.Style.whiteLarge
        
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.error)
        
         aUser = User()
      
//        aUser!.emailAddress = UserDefaults.standard.value(forKey: "emailAddress") as? String
//        aUser!.password =  UserDefaults.standard.value(forKey: "password") as? String
        aUser!.firebaseUserId = UserDefaults.standard.value(forKey: "userId") as? String
    
        if let aUserId =  aUser!.firebaseUserId{
            if let aRootController = UIApplication.shared.keyWindow?.rootViewController {
                if let aNavController = aRootController as? UINavigationController {
                    if let aLoginController = aNavController.viewControllers.first as? LoginController {
                        aLoginController.gotochecken()
                       // aNavController.popToViewController(aLoginController, animated: true)
                    }
                }
            }
        }
        
//
//
//        if let aUserId =  aUser!.firebaseUserId{
//            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
//            let homeViewController = mainStoryboard.instantiateViewController(withIdentifier: "DashboardControllerId") as!
//            DashboardController
//                    window!.rootViewController = homeViewController
//            print("app del uid=\(aUserId)")
//        }
        
       
        self.registerForPushNotification()
        return true
    }
    var whiteOverlay :UIView?

}


extension AppDelegate :UNUserNotificationCenterDelegate {
    
    func registerForPushNotification() {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
       //	 Messaging.messaging().isAutoInitEnabled = true
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
