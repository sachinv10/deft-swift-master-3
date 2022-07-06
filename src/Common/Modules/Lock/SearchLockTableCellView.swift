//
//  SearchLockTableCellView.swift
//  DEFT
//
//  Created by Rupendra on 15/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SearchLockTableCellView: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lockStatusButton: UIButton!
    
    var lock :Lock?
    var isLockOpened :Bool = false
    
    weak var delegate :SearchLockTableCellViewDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.isLockOpened {
            self.lockStatusButton.setImage(UIImage(named: "LockOpen"), for: UIControl.State.normal)
        } else {
            self.lockStatusButton.setImage(UIImage(named: "LockClose"), for: UIControl.State.normal)
        }
    }
    
    
    func load(lock pLock :Lock) {
        self.lock = pLock
        
        self.titleLabel.text = pLock.title
        self.isLockOpened = pLock.isOpen
        self.setNeedsLayout()
    }
    
    
    static func cellHeight() -> CGFloat {
        let aReturnVal :CGFloat = 70.0
        return aReturnVal
    }
}


extension SearchLockTableCellView {
    
    @IBAction func didSelectLockButton(_ pSender: UIButton?) {
        self.isLockOpened = !self.isLockOpened
        self.setNeedsLayout()
        self.delegate?.cellView(self, didChangeLockState: self.isLockOpened)
    }
    
}


protocol SearchLockTableCellViewDelegate :AnyObject {
    func cellView(_ pSender: SearchLockTableCellView, didChangeLockState pLockState :Bool)
}
