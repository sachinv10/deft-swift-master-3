//
//  SelectRemoteKeyTableCellView.swift
//  DEFT
//
//  Created by Rupendra on 17/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SelectRemoteKeyTableCellView: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkboxImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func load(remoteKey pRemoteKey :RemoteKey, isChecked pIsChecked :Bool) {
        self.titleLabel.text = pRemoteKey.title
        
        self.titleLabel.text = pRemoteKey.title ?? pRemoteKey.tag?.rawValue ?? pRemoteKey.id
        self.checkboxImageView.isHidden = !pIsChecked
    }
    
    
    static func cellHeight() -> CGFloat {
        return UITableView.automaticDimension
    }

}
