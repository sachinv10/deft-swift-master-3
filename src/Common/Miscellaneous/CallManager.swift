//
//  CallManager.swift
//  Wifinity
//
//  Created by Apple on 30/01/23.
//

import UIKit
import CallKit
import Foundation
import PushKit
@available(iOS 14.0, *)
class CallManager: NSObject,CXProviderDelegate, CXCallObserverDelegate {
    func providerDidReset(_ provider: CXProvider) {
        
    }
    
    
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasEnded == true {
            // The call has ended
            print("The call has ended")
            
        } else if call.isOutgoing == true {
            // The call is outgoing
                print("The call is outgoing")
        }else if call.hasConnected == true{
            print("call connected")
        } else {
            // The call is incoming
            let incomingCallIdentifier = call.uuid.uuidString
            print("Incoming call identifier: \(incomingCallIdentifier)")
        }
    }
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        print("call answere")
        DispatchQueue.global(qos: .background).async {
            self.gotoCallingvc()
           // self.declineCall()
            
        }
      
         provider.invalidate()
    }
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        print("call end")
      
    }
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        print("call started in proveder")
    }
    
    func displayIncomingCallAlert(userInfo: [AnyHashable: Any]) {
        let center = UNUserNotificationCenter.current()
        var vdx = DashboardController()
            vdx.loadVdp()
            let answerAction = UNNotificationAction(identifier: "answer", title: "Answer", options: [.foreground])
            let rejectAction = UNNotificationAction(identifier: "reject", title: "Reject", options: [.destructive])

            let category = UNNotificationCategory(identifier: "incomingCall", actions: [answerAction, rejectAction], intentIdentifiers: [], options: [])
            center.setNotificationCategories([category])
            let content = UNMutableNotificationContent()
            content.title = "VDP Incoming Call"
            content.body = "Please long press to answer the call"
            content.categoryIdentifier = "incomingCall"
            content.userInfo = ["hardwareId":"\(userInfo["hardwareId"]!)"]
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "iphone_marimba_sound.wav"))
        do{
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "incomingCall", content: content, trigger: trigger)
            center.add(request)
        }catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
 

       }
   
let provider = CXProvider(configuration: CXProviderConfiguration())
    let callController = CXCallController()
    let callObserver = CXCallObserver()
    override init() {
        super.init()
        provider.setDelegate(self, queue: nil)
      //  callObserver.setDelegate(self, queue: nil)
        callController.callObserver.setDelegate(self, queue: nil)
    }
    
    public func reportIncommingCall(id: UUID, handel: String, window: UIWindow, vdpid: String){
        self.vdpId = vdpid
        windows = window
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: handel)
        update.hasVideo = true
        provider.reportNewIncomingCall(with: id, update: update, completion: {error in
            if let error = error{
                print(String(describing: error))
            }else{
                print("call reported")
                self.callController.callObserver.setDelegate(self, queue: nil)
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 45) { [self] in
                    guard let call = callController.callObserver.calls.first else { return }
                    provider.reportCall(with: call.uuid, endedAt: nil, reason: .unanswered)
                                 }
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 10) {
                  self.startCall(id: id, handel: handel)
                }
            }
        })
     }
    
    
    public func startCall(id: UUID, handel: String){
        let handel = CXHandle(type: .generic, value: handel)
        let action = CXStartCallAction(call: id, handle: handel)
        let transaction = CXTransaction(action: action)
        callController.request(transaction){error in
            if let error = error{
                print(String(describing: error))
            }else{
                print("call started")
              //  self.declineCall()
                self.provider.invalidate()
            }
            
        }
    }
    var windows: UIWindow?
    var vdpId = String()
    func gotoCallingvc(){
        DispatchQueue.main.async { [self] in
            let storyboard = UIStoryboard(name: "VDP", bundle: nil)
           let vc = storyboard.instantiateViewController(withIdentifier: "CallingViewController") as! CallingViewController
               vc.id = vdpId
                    let navigationController = windows?.rootViewController as? UINavigationController
                     navigationController?.pushViewController(vc, animated: true)
        }
    }
    func declineCall() {
        DispatchQueue.global(qos: .background).async { [self] in
        guard let call = callController.callObserver.calls.first else { return }
        provider.reportCall(with: call.uuid, endedAt: nil, reason: .remoteEnded)
          //  UIApplication.shared.open(NSURL(string: "whatsapp://send?phone=+919689374439")! as URL)

        }
     }
}
