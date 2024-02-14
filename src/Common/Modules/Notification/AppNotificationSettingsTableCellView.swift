//
//  AppNotificationSettingsTableCellView.swift
//  Wifinity
//
//  Created by Rupendra on 06/03/21.
//

import UIKit


class AppNotificationSettingsTableCellView: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueSwitch: AppSwitch!
    
    weak var delegate :AppNotificationSettingsTableCellViewDelegate?
    
    
    func load(title pTitle :String, value pValue :Bool) {
        self.titleLabel.text = pTitle
        self.valueSwitch.isOn = pValue
    }
    
    static func cellHeight() -> CGFloat {
        return 52.0
    }
    
    @IBAction func onOffSwitchDidChangeValue(_ pSender: AppSwitch) {
        self.delegate?.appNotificationSettingsTableCellView(self, didChangeValue: self.valueSwitch.isOn)
    }
}

protocol AppNotificationSettingsTableCellViewDelegate :AnyObject {
    func appNotificationSettingsTableCellView(_ pSender :AppNotificationSettingsTableCellView, didChangeValue pValue :Bool)
}
