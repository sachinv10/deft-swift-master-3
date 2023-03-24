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
    func registerpushkit(){
 
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
        
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        	 Messaging.messaging().isAutoInitEnabled = true
        let callObserver = CXCallObserver()
        callObserver.setDelegate(self, queue: nil)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (pGranted, pError) in
            DispatchQueue.main.async {
                if pGranted {
                    UIApplication.shared.registerForRemoteNotifications()
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
        }
      
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
//                       var alert: UIAlertView!
//                       alert = UIAlertView(title: "Incoming Call", message: alertMsg, delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "Answer")
//                       alert.show()
            if #available(iOS 14.0, *) {
            let callManager = CallManager()
                if notification.request.content.categoryIdentifier == "incomingCall" {
                    // callManager.showNotification()
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
                    
                    let storyboard = UIStoryboard(name: "VDP", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "CallingViewController") as! CallingViewController
                    vc.id = h_id as! String // "V001641534575660"
                    let navigationController = window?.rootViewController as? UINavigationController
                    navigationController?.pushViewController(vc, animated: true)
                } else if response.actionIdentifier == "reject" {
                    
                }else if response.actionIdentifier == "com.apple.UNNotificationDefaultActionIdentifier"{
                    let storyboard = UIStoryboard(name: "VDP", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "CallingViewController") as! CallingViewController
                    vc.id = h_id as! String
                    let navigationController = window?.rootViewController as? UINavigationController
                    navigationController?.pushViewController(vc, animated: true)
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
                  
                //  callManager.reportIncommingCall(id: uuid, handel: "VDP Calling", window: window!, vdpid: messageID["hardwareId"] as! String)
                  callManager.displayIncomingCallAlert(userInfo: messageID)
                
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

 

extension AppDelegate: MessagingDelegate {
    func messaging(_ pMessaging: Messaging,didReceiveRegistrationToken pFcmToken: String?) {
        let aTokenDict = ["token": pFcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: aTokenDict)
        CacheManager.shared.fcmToken = pFcmToken
    }
}

 

class CustomView: UIView {

    let firstButton = UIButton(type: .system)
    let secondButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

      func setupViews() {
        addSubview(firstButton)
        addSubview(secondButton)

        firstButton.translatesAutoresizingMaskIntoConstraints = false
        secondButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            firstButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            firstButton.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            firstButton.widthAnchor.constraint(equalToConstant: 100),
            firstButton.heightAnchor.constraint(equalToConstant: 50),

            secondButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            secondButton.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            secondButton.widthAnchor.constraint(equalToConstant: 100),
            secondButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        firstButton.setTitle("Button 1", for: .normal)
        secondButton.setTitle("Button 2", for: .normal)
    }
}
