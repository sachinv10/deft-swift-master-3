//
//  SelectRoomTableCellView.swift
//  DEFT
//
//  Created by Rupendra on 17/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SelectRoomTableCellView: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var disclosureIndicatorImageView: UIImageView!
    
    var shouldHideDisclosureIndicator = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.disclosureIndicatorImageView.isHidden = self.shouldHideDisclosureIndicator
    }
    
    
    func load(room pRoom :Room, selectedComponentCount pSelectedComponentCount :Int) {
        self.titleLabel.text = pRoom.title
        
        if pSelectedComponentCount > 0 {
            self.subtitleLabel.text = String(format: "(%d)", pSelectedComponentCount)
        } else {
            self.subtitleLabel.text = nil
        }
    }
    
    
    static func cellHeight() -> CGFloat {
        return 48.0
    }

}
