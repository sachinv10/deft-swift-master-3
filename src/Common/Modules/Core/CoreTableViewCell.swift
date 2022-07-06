//
//  CoreTableViewCell.swift
//  Wifinity
//
//  Created by Vivek V. Unhale on 26/05/22.
//

import UIKit

class CoreTableViewCell: UITableViewCell {

    @IBOutlet weak var coreIcon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var coreToggleSwitch: AppSwitch!
    
    weak var delegate :CoreTableViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

   
    func configureCell(coreData: Core) {
        if let ruleName = coreData.ruleName {
            nameLabel.text = ruleName
        }
        
        if let state = coreData.state {
            coreToggleSwitch.isOn = state
        }
    }
    
    @IBAction func toggleClicked(_ sender: AppSwitch) {
        self.delegate?.cellView(self, didChangePowerState: self.coreToggleSwitch.isOn)
    }
    
}

protocol CoreTableViewDelegate :AnyObject {
    func cellView(_ pSender: CoreTableViewCell, didChangePowerState pState :Bool)
}
