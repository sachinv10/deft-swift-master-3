//
//  SelectDeviceTableCellView.swift
//  Wifinity
//
//  Created by Rupendra on 17/01/21.
//

import UIKit

class SelectDeviceTableCellView: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    var shouldCheckForAddedApplianceCount :Bool = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func load(device pDevice :Device) {
        self.titleLabel.text = (pDevice.title ?? "") + " (" + (pDevice.id ?? "") + ")"
        
        if self.shouldCheckForAddedApplianceCount {
            if let anApplianceArray = pDevice.addedAppliances, anApplianceArray.count > 0 {
                self.descriptionLabel.isHidden = false
                var anApplianceString = "Appliances:"
                for anAppliance in anApplianceArray {
                    if let aTitle = anAppliance.title {
                        anApplianceString += "\n✦ " + aTitle
                    } else if let anId = anAppliance.id {
                        anApplianceString += "\n✦ " + anId
                    }
                }
                self.descriptionLabel.text = anApplianceString
            } else {
                self.descriptionLabel.isHidden = true
                self.descriptionLabel.text = nil
            }
            
            if (pDevice.addedAppliances?.count ?? 0) >= (pDevice.switchCount ?? 0) {
                self.messageLabel.isHidden = false
                self.messageLabel.text = "This device is full"
            } else {
                self.messageLabel.isHidden = true
                self.messageLabel.text = nil
            }
        } else {
            self.descriptionLabel.isHidden = true
            self.messageLabel.isHidden = true
        }
    }
    
    
    static func cellHeight() -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
