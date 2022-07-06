//
//  SearchScheduleTableCellView.swift
//  DEFT
//
//  Created by Rupendra on 08/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SearchScheduleTableCellView: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var repetitionLabel: UILabel!
    @IBOutlet weak var applianceCountLabel: UILabel!
    @IBOutlet weak var curtainCountLabel: UILabel!
    @IBOutlet weak var remoteCountLabel: UILabel!
    @IBOutlet weak var sensorCountLabel: UILabel!
    
    @IBOutlet weak var onOffSwitch: AppSwitch!
    
    var schedule :Schedule?
    
    weak var delegate :SearchScheduleTableCellViewDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func load(schedule pSchedule :Schedule) {
        self.schedule = pSchedule
        
        self.titleLabel.text = pSchedule.title
        
        self.onOffSwitch.isOn = self.schedule?.isOn ?? false
        
        let aTime = NSMutableAttributedString(string: String(format: "Scheduled At: %@", pSchedule.time ?? 0), attributes: nil)
        aTime.setAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: self.repetitionLabel.font.pointSize)], range: NSRange(location: 0, length: 14))
        self.timeLabel.attributedText = aTime
        
        
        let aRepetition = NSMutableAttributedString(string: String(format: "Scheduled For: %@", pSchedule.repetitionsDisplayText ?? "(No Repetition)"), attributes: nil)
        aRepetition.setAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: self.repetitionLabel.font.pointSize)], range: NSRange(location: 0, length: 15))
        self.repetitionLabel.attributedText = aRepetition
        
        let anApplianceCount = NSMutableAttributedString(string: String(format: "Appliances: %02d", pSchedule.applianceCount ?? 0), attributes: nil)
        anApplianceCount.setAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: self.applianceCountLabel.font.pointSize)], range: NSRange(location: 0, length: 12))
        self.applianceCountLabel.attributedText = anApplianceCount
        
        let aCurtainCount = NSMutableAttributedString(string: String(format: "Curtains: %02d", pSchedule.curtainCount ?? 0), attributes: nil)
        aCurtainCount.setAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: self.curtainCountLabel.font.pointSize)], range: NSRange(location: 0, length: 10))
        self.curtainCountLabel.attributedText = aCurtainCount
        
        let aRemoteCount = NSMutableAttributedString(string: String(format: "Remotes: %02d", pSchedule.remoteCount ?? 0), attributes: nil)
        aRemoteCount.setAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: self.remoteCountLabel.font.pointSize)], range: NSRange(location: 0, length: 9))
        self.remoteCountLabel.attributedText = aRemoteCount
        
        let aSensorCount = NSMutableAttributedString(string: String(format: "Sensors: %02d", pSchedule.sensorCount ?? 0), attributes: nil)
        aSensorCount.setAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: self.sensorCountLabel.font.pointSize)], range: NSRange(location: 0, length: 9))
        self.sensorCountLabel.attributedText = aSensorCount
    }
    
    
    static func cellHeight() -> CGFloat {
        let aReturnVal :CGFloat = 70.0
        return aReturnVal
    }
    
}


extension SearchScheduleTableCellView {
    @IBAction func onOffSwitchDidChangeValue(_ pSender: AppSwitch) {
        self.delegate?.cellView(self, didChangePowerState: self.onOffSwitch.isOn)
    }
}


protocol SearchScheduleTableCellViewDelegate :AnyObject {
    func cellView(_ pSender: SearchScheduleTableCellView, didChangePowerState pPowerState :Bool)
}
