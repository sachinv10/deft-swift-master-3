//
//  SearchMoodTableCellView.swift
//  DEFT
//
//  Created by Rupendra on 15/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SearchMoodTableCellView: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var applianceCountLabel: UILabel!
    @IBOutlet weak var curtainCountLabel: UILabel!
    @IBOutlet weak var remoteCountLabel: UILabel!
    
    @IBOutlet weak var onOffSwitch: AppSwitch!
    
    var mood :Mood?
    
    weak var delegate :SearchMoodTableCellViewDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func load(mood pMood :Mood) {
        self.mood = pMood
        
        self.titleLabel.text = pMood.title
        
        self.onOffSwitch.isOn = pMood.isOn
        
        let anApplianceCount = NSMutableAttributedString(string: String(format: "Lights: %02d", pMood.applianceCount ?? 0), attributes: nil)
        anApplianceCount.setAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: self.applianceCountLabel.font.pointSize)], range: NSRange(location: 0, length: 8))
        self.applianceCountLabel.attributedText = anApplianceCount
        
        let aCurtainCount = NSMutableAttributedString(string: String(format: "Curtains: %02d", pMood.curtainCount ?? 0), attributes: nil)
        aCurtainCount.setAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: self.curtainCountLabel.font.pointSize)], range: NSRange(location: 0, length: 10))
        self.curtainCountLabel.attributedText = aCurtainCount
        
        let aRemoteCount = NSMutableAttributedString(string: String(format: "Remotes: %02d", pMood.remoteCount ?? 0), attributes: nil)
        aRemoteCount.setAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: self.remoteCountLabel.font.pointSize)], range: NSRange(location: 0, length: 9))
        self.remoteCountLabel.attributedText = aRemoteCount
    }
    
    
    static func cellHeight() -> CGFloat {
        let aReturnVal :CGFloat = 70.0
        return aReturnVal
    }
    
}



extension SearchMoodTableCellView {
    @IBAction func onOffSwitchDidChangeValue(_ pSender: AppSwitch) {
        self.delegate?.cellView(self, didChangePowerState: self.onOffSwitch.isOn)
    }
}


protocol SearchMoodTableCellViewDelegate :AnyObject {
    func cellView(_ pSender: SearchMoodTableCellView, didChangePowerState pPowerState :Bool)
}
