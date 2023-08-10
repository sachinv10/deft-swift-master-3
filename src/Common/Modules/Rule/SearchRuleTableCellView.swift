//
//  SearchRuleTableCellView.swift
//  DEFT
//
//  Created by Rupendra on 24/10/21.
//  Copyright © 2021 Example. All rights reserved.
//

import UIKit

class SearchRuleTableCellView: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var onOffSwitch: AppSwitch!
    
    var rule :Rule?
    
    weak var delegate :SearchRuleTableCellViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func load(rule pRule :Rule) {
        self.rule = pRule
        
        self.titleLabel.text = pRule.title
        
        self.onOffSwitch.isOn = pRule.isOn
    }
    
    
    static func cellHeight() -> CGFloat {
        let aReturnVal :CGFloat = UITableView.automaticDimension
        return aReturnVal
    }
}


extension SearchRuleTableCellView {
    @IBAction func onOffSwitchDidChangeValue(_ pSender: AppSwitch) {
        self.delegate?.cellView(self, didChangeState: self.onOffSwitch.isOn)
    }
}


protocol SearchRuleTableCellViewDelegate :AnyObject {
    func cellView(_ pSender: SearchRuleTableCellView, didChangeState pState :Bool)
}
