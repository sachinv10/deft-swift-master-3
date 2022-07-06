//
//  FrequentlyOperatedCollectionCellView.swift
//  DEFT
//
//  Created by Rupendra on 21/08/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class FrequentlyOperatedCollectionCellView: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var roomTitleLabel: UILabel!
    @IBOutlet weak var onOffSwitch: AppSwitch!
    
    weak var delegate :FrequentlyOperatedCollectionCellViewDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor(named: "PrimaryLightestColor")
        
        self.titleLabel.textColor = UIColor.darkGray
        self.roomTitleLabel.textColor = UIColor.darkGray
    }
    
    
    func load(appliance pAppliance :Appliance) {
        self.titleLabel.text = pAppliance.title
        self.roomTitleLabel.text = pAppliance.roomTitle
        self.onOffSwitch.isOn = pAppliance.isOn
    }
    
    
    @IBAction func onOffSwitchDidChangeValue(_ pSender: AppSwitch) {
        self.delegate?.cellView(self, didChangePowerState: pSender.isOn)
    }
    
}



protocol FrequentlyOperatedCollectionCellViewDelegate :AnyObject {
    func cellView(_ pSender: FrequentlyOperatedCollectionCellView, didChangePowerState pPowerState :Bool)
}
