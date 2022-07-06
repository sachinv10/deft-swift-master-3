//
//  SearchAppNotificationTableCellView.swift
//  DEFT
//
//  Created by Rupendra on 05/12/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SearchAppNotificationTableCellView: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    
    var appNotification :AppNotification?
    
    
    func load(appNotification pAppNotification :AppNotification) {
        self.appNotification = pAppNotification
        
        let aMessage = NSMutableAttributedString(string: pAppNotification.message ?? "", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: self.messageLabel.font.pointSize)])
        if let aDate = pAppNotification.date {
            let aDateFormatter = DateFormatter()
            aDateFormatter.dateFormat = "dd-MMM-yyyy 'at' hh:mm a"
            aMessage.append(NSAttributedString(string: "\n" + aDateFormatter.string(from: aDate), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: self.messageLabel.font.pointSize - 4)]))
        }
        let aParagraphStyle = NSMutableParagraphStyle()
        aParagraphStyle.paragraphSpacing = 8
        aMessage.addAttribute(.paragraphStyle, value: aParagraphStyle, range: NSRange(location: 0, length: aMessage.length))
        self.messageLabel.attributedText = aMessage
    }
    
}
