//
//  SearchDeviceTableCellView.swift
//  DEFT
//
//  Created by Rupendra on 15/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SearchDeviceTableCellView: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var onlineIndicatorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hardwareIdLabel: UILabel!
    @IBOutlet weak var roomTitleLabel: UILabel!
    
    var device :Device?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.iconImageView.tintColor = UIColor.darkGray
        self.iconImageView.layer.borderWidth = 1.0
        self.iconImageView.layer.borderColor = self.iconImageView.tintColor.cgColor
        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.size.height / 2.0
        self.onlineIndicatorView.layer.cornerRadius = self.onlineIndicatorView.frame.size.height / 2
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    func load(device pDevice :Device) {
        self.device = pDevice
        
        if let anIsOnline = pDevice.isOnline {
            self.onlineIndicatorView.isHidden = false
            self.onlineIndicatorView.backgroundColor = anIsOnline ? UIColor.green : UIColor.red
        } else {
            self.onlineIndicatorView.isHidden = true
        }
        self.titleLabel.text = pDevice.title?.capitalized
        self.hardwareIdLabel.text = pDevice.id
        self.roomTitleLabel.text = pDevice.room?.title?.capitalized
        self.setNeedsLayout()
    }
    
    
    static func cellHeight() -> CGFloat {
        let aReturnVal :CGFloat = UITableView.automaticDimension
        return aReturnVal
    }
}
