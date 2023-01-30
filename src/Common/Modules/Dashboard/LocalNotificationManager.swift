//
//  LocalNotificationManager.swift
//  Wifinity
//
//  Created by Apple on 17/01/23.
//

import Foundation
import UserNotifications

class LocalNotificationManager {

    static let shared = LocalNotificationManager()

    private init() {}

    func scheduleLocalNotification(title: String, body: String, timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "LocalNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error scheduling local notification: \(error.localizedDescription)")
            }
        }
    }

}
