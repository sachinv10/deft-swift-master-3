//
//  SearchRemoteTableCellView.swift
//  DEFT
//
//  Created by Rupendra on 20/09/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SearchRemoteTableCellView: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var remote :Remote?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.iconImageView.tintColor = UIColor.darkGray
        self.titleLabel.textColor = UIColor.darkGray
    }
    
    
    func load(remote pRemote :Remote) {
        self.remote = pRemote
        
        self.iconImageView.image = pRemote.icon
        self.titleLabel.text = pRemote.title
    }
    
    
    static func cellHeight() -> CGFloat {
        let aReturnVal :CGFloat = 70.0
        return aReturnVal
    }
    
}
