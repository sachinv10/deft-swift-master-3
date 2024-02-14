//
//  NotificationViewController.swift
//  ImageNotifications
//
//  Created by Apple on 26/10/23.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet weak var lableTitle: UILabel!
    @IBOutlet weak var imageViewNotification: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {

        if let userInfo = notification.request.content.userInfo as? [AnyHashable: Any]{
            if let aps = userInfo["aps"] as? [String: Any],
               let alert = aps["alert"] as? [String: Any],
               let title = alert["title"] as? String,
               let body = alert["body"] as? String,
               let imageUrl = userInfo["imageUrl"] as? String,
               let imageUrlURL = URL(string: imageUrl) {
                URLSession.shared.dataTask(with: imageUrlURL, completionHandler: {(Data, respounce, error) in
                    if Data != nil && error == nil{
                        DispatchQueue.main.async {
                             self.imageViewNotification.image = UIImage(data: Data!)
                        }
                    }
                }).resume()
            }
          }
        }
}
