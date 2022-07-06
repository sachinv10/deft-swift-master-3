//
//  SelectApplianceTypeTableCellView.swift
//  Wifinity
//
//  Created by Rupendra on 17/01/21.
//

import UIKit

class SelectApplianceTypeTableCellView: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func load(applianceTypeGroup pApplianceTypeGroup :SelectApplianceTypeController.ApplianceTypeGroup) {
        self.titleLabel.text = pApplianceTypeGroup.title
    }
    
    
    static func cellHeight() -> CGFloat {
        return 48.0
    }
    
}
