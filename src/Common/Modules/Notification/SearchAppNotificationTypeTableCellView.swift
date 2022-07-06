//
//  SearchAppNotificationTypeTableCellView.swift
//  DEFT
//
//  Created by Rupendra on 15/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit


class SearchAppNotificationTypeTableCellView: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    var appNotificationType :AppNotification.AppNotificationType?
    
    
    func load(appNotificationType pAppNotificationType :AppNotification.AppNotificationType) {
        self.appNotificationType = pAppNotificationType
        
        self.titleLabel.text = pAppNotificationType.rawValue
    }
    
    
    static func cellHeight() -> CGFloat {
        let aReturnVal :CGFloat = 60.0
        return aReturnVal
    }
}
