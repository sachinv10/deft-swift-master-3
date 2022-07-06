//
//  SearchTankRegulatorTableCellView.swift
//  DEFT
//
//  Created by Rupendra on 15/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SearchTankRegulatorTableCellView: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var onlineIndicatorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lowerTankContainerView: UIView!
    @IBOutlet weak var lowerTankImageView: UIImageView!
    @IBOutlet weak var upperTankContainerView: UIView!
    @IBOutlet weak var upperTankImageView: UIImageView!
    @IBOutlet weak var autoModeSwitch: AppSwitch!
    @IBOutlet weak var motorStateSwitch: AppSwitch!
    @IBOutlet weak var syncButton: UIButton!
    
    var tankRegulator :TankRegulator?
    
    weak var delegate :SearchTankRegulatorTableCellViewDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.iconImageView.tintColor = UIColor.darkGray
        self.iconImageView.layer.borderWidth = 1.0
        self.iconImageView.layer.borderColor = self.iconImageView.tintColor.cgColor
        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.size.height / 2.0
        self.onlineIndicatorView.layer.cornerRadius = self.onlineIndicatorView.frame.size.height / 2
        
        self.syncButton.backgroundColor = UIColor(named: "SecondaryLightestColor")
        self.syncButton.tintColor = UIColor(named: "ControlNormalColor")
        self.syncButton.layer.borderWidth = 1.0
        self.syncButton.layer.borderColor = UIColor(named: "ControlNormalColor")?.cgColor
        self.syncButton.layer.cornerRadius = 4.0
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    func load(tankRegulator pTankRegulator :TankRegulator) {
        self.tankRegulator = pTankRegulator
        
        self.onlineIndicatorView.backgroundColor = pTankRegulator.isOnline ? UIColor.green : UIColor.red
        
        self.titleLabel.text = pTankRegulator.title
        
        self.lowerTankImageView.image = TankRegulator.waterLevelImage(waterLevel: pTankRegulator.lowerTankFillPercent)
        
        self.upperTankContainerView.isHidden = (pTankRegulator.tankCount ?? 0) < 2
        self.upperTankImageView.image = TankRegulator.waterLevelImage(waterLevel: pTankRegulator.upperTankFillPercent)
        
        self.autoModeSwitch.isOn = pTankRegulator.isAutoModeActivated
        
        self.motorStateSwitch.isEnabled = !pTankRegulator.isAutoModeActivated
        self.motorStateSwitch.isOn = pTankRegulator.isMotorOn
        
        self.setNeedsLayout()
    }
    
    
    static func cellHeight() -> CGFloat {
        let aReturnVal :CGFloat = UITableView.automaticDimension
        return aReturnVal
    }
    
    
    @IBAction func didSelectSyncButton(_ pSender: UIButton) {
        self.delegate?.cellViewDidSelectSync(self)
    }
}


extension SearchTankRegulatorTableCellView {
    
    @IBAction func autoModeSwitchDidChangeValue(_ pSender: AppSwitch) {
        self.delegate?.cellView(self, didChangeAutoMode: self.autoModeSwitch.isOn)
    }
    
    @IBAction func motorSwitchDidChangeValue(_ pSender: AppSwitch) {
        self.delegate?.cellView(self, didChangeMotorState: self.motorStateSwitch.isOn)
    }
    
}


protocol SearchTankRegulatorTableCellViewDelegate :AnyObject {
    func cellView(_ pSender: SearchTankRegulatorTableCellView, didChangeAutoMode pAutoMode :Bool)
    func cellView(_ pSender: SearchTankRegulatorTableCellView, didChangeMotorState pMotorState :Bool)
    func cellViewDidSelectSync(_ pSender: SearchTankRegulatorTableCellView)
}
