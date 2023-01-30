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
import Messages
import CallKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var gcmMessageIDKey = "gcm_msg_key"
    var aUser :User?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      //  ProgressOverlay.shared.activityIndicatorViewStyle = UIActivityIndicatorView.Style.whiteLarge
        
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.error)
        
         aUser = User()

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

        self.registerForPushNotification()
        if UIApplication.shared.applicationState == .background {
               // App was launched due to Background Fetch event. No need for UI.
               return true
           }
        return true
    }
    var whiteOverlay :UIView?
    var orientationLock = UIInterfaceOrientationMask.portrait
    var myOrientation: UIInterfaceOrientationMask = .portrait
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return myOrientation
    }
}


extension AppDelegate :UNUserNotificationCenterDelegate {
//    func applicationDidEnterBackground(_ application: UIApplication) {
//
//    }
//    func applicationDidEnterBackground(_ application: UIApplication) {
//      UserDefaults.standard.set(
//        Date().timeIntervalSince1970,
//        forKey: appEntereBGKey
//      )
//    }
    
    func registerForPushNotification() {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        	 Messaging.messaging().isAutoInitEnabled = true
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (pGranted, pError) in
            DispatchQueue.main.async {
                if pGranted {
                    UIApplication.shared.registerForRemoteNotifications()
                    print("Notification access granted")
                    
                } else {
                    print("Notification access denied")
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
        if notification.request.content.categoryIdentifier == "CALL_INCOMING" {
                   print("incoming call")
               }
        pCompletionHandler([[.alert, .sound]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("didreceive notification")
//        if response.notification.request.content.categoryIdentifier == "CALL_INCOMING" {
//                   // Perform actions for incoming call notifications
//               }
//        if response.actionIdentifier == "answerCall" {
//            // Navigate to the call screen
//            print("incoming answerCall")
//            let callViewController = VdpViewController()
//            let navigationController = window?.rootViewController as? UINavigationController
//          //  navigationController?.pushViewController(callViewController, animated: true)
//        } else if response.actionIdentifier == "declineCall" {
//            // Navigate to the call log screen
//            print("incoming declineCall")
//            let callLogViewController = VdpViewController()
//            let navigationController = window?.rootViewController as? UINavigationController
//           // navigationController?.pushViewController(callLogViewController, animated: true)
//        }
        if response.notification.request.content.categoryIdentifier == "CALL_INCOMING" {
                  if response.actionIdentifier == "answerCall" {
                      // Perform actions for answering the call
                      // You can use CallKit framework to answer the call
                      let callController = CXCallController()
                      let answerCallAction = CXAnswerCallAction(call: UUID(uuidString: response.notification.request.identifier)!)
                      let transaction = CXTransaction(action: answerCallAction)
                      callController.request(transaction) { error in
                          if let error = error {
                              print("Error answering call: \(error)")
                          } else {
                              print("Call answered successfully")
                          }
                      }
                  } else if response.actionIdentifier == "declineCall" {
                      // Perform actions for declining the call
                  }
              }
        completionHandler()
    }
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]?) async
      -> UIBackgroundFetchResult {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      //  Messaging.messaging().appDidReceiveMessage(userInfo)
        

      // Print message ID.
          
          if let messageID = userInfo {
        print("Message ID: \(messageID)")
              let callController = CXCallController()
              let uuid = UUID()
              let uuidString = uuid.uuidString
              let uuidd = UUID(uuidString: uuidString)
              let answerCallAction = CXAnswerCallAction(call: uuidd!)
              let transaction = CXTransaction(action: answerCallAction)
              callController.request(transaction) { error in
                  if let error = error {
                      print("Error answering call: \(error)")
                  } else {
                      print("Call answered successfully")
                  }
              }
      }

      // Print full message.
      print(userInfo)

      return UIBackgroundFetchResult.newData
    }

}

 

extension AppDelegate: MessagingDelegate {
    func messaging(_ pMessaging: Messaging,didReceiveRegistrationToken pFcmToken: String?) {
        let aTokenDict = ["token": pFcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: aTokenDict)
        CacheManager.shared.fcmToken = pFcmToken
    }
}
