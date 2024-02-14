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
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging
import Messages
import CallKit
import PushKit
import BackgroundTasks
import SocketIO
import CoreData
import CoreLocation
@main
class AppDelegate: UIResponder, UIApplicationDelegate, CXProviderDelegate {
    static var locationManager: CLLocationManager!
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
    var notificationCenter: UNUserNotificationCenter?

    
    lazy var persistentContainer: NSPersistentContainer = {
           let container = NSPersistentContainer(name: "CartDataModel")
           container.loadPersistentStores { (storeDescription, error) in
               if let error = error as NSError? {
                   fatalError("Unresolved error \(error), \(error.userInfo)")
               }
           }
           return container
       }()
    
    func saveContext(){
        let context = persistentContainer.viewContext
        if context.hasChanges{
            do{
               try context.save()
            }catch{
               let error = error as? NSError
                fatalError("Unresolve error=\(String(describing: error))")
            }
        }
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last ?? "Not found!!")

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
     //   configLocation()
        registerpushkit()
        self.registerForPushNotification()
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)

        if UIApplication.shared.applicationState == .background {
            // App was launched due to Background Fetch event. No need for UI.
            return true
        }
        return true
    }
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Msg Background")
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Start location updates
      //  AppDelegate.locationManager.startUpdatingLocation()
        print("Msg Did Enter Background")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Stop location updates when the app is in the foreground
     //   locationManager.stopUpdatingLocation()
        print("Msg Will Enter Foreground")
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
                    UNUserNotificationCenter.current().delegate = self
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
         let categorys = UNNotificationCategory(identifier: "newNotificationRequest", actions: [answerAction, rejectAction], intentIdentifiers: [], options: [])
            center.setNotificationCategories([categorys])
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
    func handleNotification(_ userInfo: [String: Any]) {
           if let aps = userInfo["aps"] as? [String: Any],
              let alert = aps["alert"] as? [String: Any] {
               let title = alert["title"] as? String
               let body = alert["body"] as? String
               let imageUrl = alert["imageUrl"] as? String
               let category = alert["category"] as? String
               if category == "Wifinity Notification"{
                   let content = UNMutableNotificationContent()
                   content.title = title ?? ""
                   content.body = body ?? ""
                   content.categoryIdentifier = "myNotificationCategory"
                   //      let fileURL: URL = URL(string: imageUrl ?? "")!
                   
                       if let url = URL(string: "https://picsum.photos/200/300") {
                           do {
                               let attachement = try? UNNotificationAttachment(identifier: "attachment", url: url, options: nil)
                               content.attachments = [attachement!]

                               let request = UNNotificationRequest.init(identifier: "newNotificationRequest", content: content, trigger: nil)

                               let center = UNUserNotificationCenter.current()
                               center.add(request)
                               
                           } catch {
                               // Handle any errors that occur when creating the attachment
                               print("Error creating notification attachment: \(error)")
                           }
                       } else {
                           // Handle the case where the URL string is not valid
                       }
                       
                       let request = UNNotificationRequest.init(identifier: "myNotificationCategory", content: content, trigger: nil)
                       
                       let center = UNUserNotificationCenter.current()
                       center.add(request)
                       
                   }
             
           }
       }
    func handleNotifications(_ userInfo: [AnyHashable: Any]) {
        if let aps = userInfo["aps"] as? [String: Any],
           let alert = aps["alert"] as? [String: Any],
           let title = alert["title"] as? String,
           let body = alert["body"] as? String,
           let imageUrl = userInfo["imageUrl"] as? String,
           let imageUrlURL = URL(string: imageUrl) {

            // Create the notification content with attachment
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = "Wifinity Notification"
            
            if let attachment = try? UNNotificationAttachment(identifier: "imageAttachment", url: imageUrlURL, options: nil) {
                content.attachments = [attachment]
            }
            // Create a notification request and add it to the notification center
            let request = UNNotificationRequest(identifier: "Wifinity Notification", content: content, trigger: nil)
//                UNUserNotificationCenter.current().add(request) { error in
//                if let error = error {
//                    print("Error scheduling notification: \(error.localizedDescription)")
//                }
//            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler pCompletionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        if let userInfo = notification.request.content.userInfo as? [AnyHashable: Any] {
            handleNotifications(userInfo)
            }
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
                }else if response.actionIdentifier == "reject" {
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
        if response.notification.request.content.categoryIdentifier == "Wifinity Notification" {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "OfferZone", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "OfferZoneViewController") as! OfferZoneViewController
                
                let navigationController = self.window?.rootViewController as? UINavigationController
                navigationController?.pushViewController(vc, animated: true)
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

// MARK: - Location manager

extension AppDelegate: CLLocationManagerDelegate {

   func configLocation() {
       self.notificationCenter = UNUserNotificationCenter.current()
           notificationCenter?.delegate = self
       
       AppDelegate.locationManager = CLLocationManager()
       AppDelegate.locationManager.delegate = self
       AppDelegate.locationManager.requestAlwaysAuthorization()
       AppDelegate.locationManager.desiredAccuracy = kCLLocationAccuracyBest
       AppDelegate.locationManager.allowsBackgroundLocationUpdates = true
       AppDelegate.locationManager.startUpdatingLocation()
       
        let region = CLCircularRegion(
            center: CLLocationCoordinate2D(latitude: 18.55683898925781, longitude: 73.91633605957028),
            radius: 1000.0,
            identifier: "pune"
        )
        region.notifyOnExit = true
        region.notifyOnEntry = true
       // 18.562232,73.912947
      //  AppDelegate.locationManager.startMonitoring(for: region)
       AppDelegate.locationManager.startMonitoring(for: region)

       let options: UNAuthorizationOptions = [.alert, .sound]
       notificationCenter?.requestAuthorization(options: options) { (granted, error) in
                  if !granted {
                      print("Permission not granted")
                  }
            }
    }
    func updateLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
         updateLocationManually(latitude: latitude, longitude: longitude)
    }

    func updateLocationManually(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
           let location = CLLocation(latitude: latitude, longitude: longitude)
        AppDelegate.locationManager.delegate?.locationManager?(AppDelegate.locationManager, didUpdateLocations: [location])
       }
    
    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered region: \(region.identifier)")
        if region is CLCircularRegion {
            fetchDataFromAPI(forRegion: region)
            self.localNotification(forRegion: region, mode: "Entered region")
        //    YourLocationManager.Shared.updateVale(id: region, action: "Entered region")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let currentLatitude = location.coordinate.latitude
        let currentLongitude = location.coordinate.longitude
        print("Current Location: \(currentLatitude), \(currentLongitude)")
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited region: \(region.identifier)")
        if region is CLCircularRegion {
            // Do what you want if this information
            if let uid = Auth.auth().currentUser?.uid{
                Database.database().reference().child("geoFencingDeviceDetails").child(uid).child("008").child("Exited region").setValue(["id":region.identifier], withCompletionBlock: {(error, DataSnapshot) in
                    
                })
            }
            self.localNotification(forRegion: region, mode: "Exited region")
        //    YourLocationManager.Shared.updateVale(id: region, action: "Exited region")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
        AppDelegate.locationManager.startUpdatingLocation()
    }
    
    func fetchDataFromAPI(forRegion region: CLRegion!) {
        // Replace "https://jsonplaceholder.typicode.com/posts/1" with the actual API URL
        if let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1") {
            URLSession.shared.dataTask(with: url) { [self] data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    return
                }

                guard let data = data else {
                    print("No data received")
                    return
                }

                // Parse JSON data
             do {
                    let post = try JSONDecoder().decode(Post.self, from: data)
                    print("Post Title: \(post.title)")
                    localNotification(forRegion: region, mode: post.title)
                    // Handle other properties as needed
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }.resume()
        }
    }
    func localNotification(forRegion region: CLRegion!, mode: String){
        
        let content = UNMutableNotificationContent()
        content.title = mode
        content.body = region.identifier
        content.sound = UNNotificationSound.default
        let timeInSeconds: TimeInterval = (2) // 60s * 15 = 15min
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInSeconds,
                                                        repeats: false)
        let identifier = region.identifier
        // the notification request object
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)
        notificationCenter?.add(request, withCompletionHandler: { (error) in
            if error != nil {
                print("Error adding notification with identifier: \(identifier)")
            }
        })

    }
    
}

