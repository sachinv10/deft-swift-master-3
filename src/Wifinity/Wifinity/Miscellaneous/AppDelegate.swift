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
import PushKit
import BackgroundTasks
import SocketIO
@main
class AppDelegate: UIResponder, UIApplicationDelegate, CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        print("provider delegate")
    }
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        print("call answered")
    }
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        print("call ended")
    }
    var window: UIWindow?
    var gcmMessageIDKey = "gcm_msg_key"
    var aUser :User?
    let manager = SocketManager(socketURL: URL(string: "https://vdp1.homeonetechnologies.in/")!, config: [.log(false), .compress])
    static var socket: SocketIOClient!
    var delegate: webrtcDelegate?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.error)
        aUser = User()
        aUser!.firebaseUserId = UserDefaults.standard.value(forKey: "userId") as? String
        
        if let aUserId =  aUser!.firebaseUserId{
            if let aRootController = UIApplication.shared.keyWindow?.rootViewController {
                if let aNavController = aRootController as? UINavigationController {
                    if let aLoginController = aNavController.viewControllers.first as? LoginController {
                        aLoginController.gotochecken()
                        aNavController.popToViewController(aLoginController, animated: true)
                    }
                }
            }
        }
        
        registerpushkit()
        self.registerForPushNotification()
        if UIApplication.shared.applicationState == .background {
            // App was launched due to Background Fetch event. No need for UI.
            return true
        }
        return true
    }
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Msg Background")
    }
    func registerpushkit(){
        if #available(iOS 12.0, *) {
            //   UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        }else{
            UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        }
    }
    var whiteOverlay :UIView?
    var orientationLock = UIInterfaceOrientationMask.portrait
    var myOrientation: UIInterfaceOrientationMask = .portrait
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return myOrientation
    }
}


extension AppDelegate :UNUserNotificationCenterDelegate, CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        print("call changed status: \(call)")
        print("Call state changed: \(call.hasEnded)")
    }
    
    func registerForPushNotification() {
        
     //   UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        let callObserver = CXCallObserver()
        callObserver.setDelegate(self, queue: nil)
        UNUserNotificationCenter.current().delegate = self

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (pGranted, pError) in
                if pGranted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                    print("Notification access granted")
                    let content = UNMutableNotificationContent()
                    content.sound = UNNotificationSound.default
                } else {
                    print("Notification access denied")
                    var aMessage = "Failed to get authorization for user notification."
                    if let anErrorMessage = pError?.localizedDescription {
                        aMessage += "" + anErrorMessage
                    }
                    Swift.print(aMessage)
                }
          }
        let center = UNUserNotificationCenter.current()
            let answerAction = UNNotificationAction(identifier: "answer", title: "Answer", options: [.foreground])
            let rejectAction = UNNotificationAction(identifier: "reject", title: "Reject", options: [.destructive])

            let category = UNNotificationCategory(identifier: "incomingCall", actions: [answerAction, rejectAction], intentIdentifiers: [], options: [])
                center.setNotificationCategories([category])
        }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken pDeviceToken: Data) {
        Messaging.messaging().apnsToken = pDeviceToken
        let token = pDeviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ pApplication: UIApplication, didFailToRegisterForRemoteNotificationsWithError pError: Error) {
        let aMessage = "Failed to register for user notification. " + pError.localizedDescription
        Swift.print(aMessage)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler pCompletionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        var alertMsg = "Incoming Call"
       
        if #available(iOS 14.0, *) {
             if notification.request.content.categoryIdentifier == "incomingCall" {
            }
        } else {
            // Fallback on earlier versions
        }
        pCompletionHandler([[.alert, .sound, .badge]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("didreceive call notification")

        if response.notification.request.content.categoryIdentifier == "incomingCall" {
            let id = response.notification.request.content.userInfo
            
            if let h_id = id["hardwareId"]{
                if response.actionIdentifier == "answer" {
                    print("answer")
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "VDP", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "CallingViewController") as! CallingViewController
                        vc.id = h_id as! String // "V001641534575660" V001681462936392
                        let navigationController = self.window?.rootViewController as? UINavigationController
                        navigationController?.pushViewController(vc, animated: true)
                     }
                } else if response.actionIdentifier == "reject" {
                    print("reject")
                }else if response.actionIdentifier == "com.apple.UNNotificationDefaultActionIdentifier"{
                    DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "VDP", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "CallingViewController") as! CallingViewController
                    vc.id = h_id as! String
                        let navigationController = self.window?.rootViewController as? UINavigationController
                     navigationController?.pushViewController(vc, animated: true)
                  }
               }
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
        Messaging.messaging().appDidReceiveMessage(userInfo!)
        
        // Print message ID.
        if let messageID = userInfo {
            print("Message ID: \(messageID)")
            // let CustomView = CustomView()
            //   CustomView.setupViews()
            if #available(iOS 14.0, *) {
                let callManager = CallManager()
                let uuid = UUID()
                
                //   callManager.reportIncommingCall(id: uuid, handel: "VDP Calling", window: window!, vdpid: messageID["hardwareId"] as! String)
                
                // local notification
                //callManager.displayIncomingCallAlert(userInfo: messageID)
              //  displayIncomingCallAlert(userInfo: messageID)
              
                   
//                    let center = UNUserNotificationCenter.current()
//                        let content = UNMutableNotificationContent()
//                        content.title = "VDP Incoming Call"
//                        content.body = "Please long press to answer the call"
//                        content.categoryIdentifier = "incomingCall"
//                        content.userInfo = ["hardwareId":"\(messageID["hardwareId"]!)"]
//                        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "iphone_marimba_sound.wav"))
//                    do{
//                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//                        let request = UNNotificationRequest(identifier: "incomingCall", content: content, trigger: trigger)
////                        try await center.add(request)
//                        UNUserNotificationCenter.current().add(request) { (error) in
//                               if let error = error {
//                                   print(error.localizedDescription)
//                                   // Handle any error occurred while scheduling the notification
//                               }
//                           }
//                    }catch let error as NSError {
//                        print("Error: \(error.localizedDescription)")
//                    }
            } else {
                // Fallback on earlier versions
                
            }
        }
        // Print full message.
        print(userInfo)
        print("background process=\(UIBackgroundFetchResult.newData)")
        
        return UIBackgroundFetchResult.newData
        
    }
    
    
    func callController(_ callController: CXCallController, didFailWithError error: Error) {
        print("Error initiating call: \(error)")
    }
    
    func callController(_ callController: CXCallController, didChange call: CXCall) {
        print("Call state changed: \(call.hasEnded)")
    }
}
//  Call notification
extension AppDelegate{
    func displayIncomingCallAlert(userInfo: [AnyHashable: Any]) {
       
        let center = UNUserNotificationCenter.current()
            let answerAction = UNNotificationAction(identifier: "answer", title: "Answer", options: [.foreground])
            let rejectAction = UNNotificationAction(identifier: "reject", title: "Reject", options: [.destructive])

            let category = UNNotificationCategory(identifier: "incomingCall", actions: [answerAction, rejectAction], intentIdentifiers: [], options: [])
            center.setNotificationCategories([category])
            let content = UNMutableNotificationContent()
            content.title = "VDP Incoming Call"
            content.body = "Please long press to answer the call"
            content.categoryIdentifier = "incomingCall"
         //   content.userInfo = ["hardwareId":"\(userInfo["hardwareId"]!)"]
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "iphone_marimba_sound.wav"))
        do{
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "incomingCall", content: content, trigger: trigger)
            center.add(request)
        }catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ pMessaging: Messaging,didReceiveRegistrationToken pFcmToken: String?) {
        let aTokenDict = ["token": pFcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: aTokenDict)
        CacheManager.shared.fcmToken = pFcmToken
    }
}



