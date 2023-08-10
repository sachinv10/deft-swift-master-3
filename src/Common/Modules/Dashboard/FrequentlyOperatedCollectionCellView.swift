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
    
    @IBOutlet weak var frequntlyOpIconView: UIImageView!
    @IBOutlet weak var lblonOffswitchbtn: UIButton!
    @IBOutlet weak var frequantlyOperatedView: UIView!
    let messageLabel = UILabel()
       
       override init(frame: CGRect) {
           super.init(frame: frame)
           messageLabel.text = "No data found"
           messageLabel.textAlignment = .center
           messageLabel.translatesAutoresizingMaskIntoConstraints = false
           contentView.addSubview(messageLabel)
           NSLayoutConstraint.activate([
               messageLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
               messageLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
           ])
       }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Your initialization code goes here
    }
 
    weak var delegate :FrequentlyOperatedCollectionCellViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor(named: "PrimaryLightestColor")
        
        self.titleLabel.textColor = UIColor.darkGray
        self.roomTitleLabel.textColor = UIColor.darkGray
        self.layer.cornerRadius = 25
//        self.layer.borderColor = UIColor.gray.cgColor
//        self.layer.borderWidth = 0.5
        self.layer.masksToBounds = true
        onOffSwitch.isHidden = true
        lblonOffswitchbtn.setTitle("", for: .normal)
    }
    var pAppliances: Appliance?
    func load(appliance pAppliance :Appliance) {
        pAppliances = pAppliance
        self.frequntlyOpIconView.image = pAppliance.icon?.resizableImage(withCapInsets: UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0), resizingMode: UIImage.ResizingMode.stretch)
        self.titleLabel.text = pAppliance.title
        self.roomTitleLabel.text = pAppliance.roomTitle
        self.onOffSwitch.isOn = pAppliance.isOn
        self.layer.backgroundColor = pAppliance.isOn == true ? UIColor(hex: "#F8E8BE").cgColor : UIColor(named: "PrimaryLightestColor")?.cgColor
      
     }
    
    @IBAction func onOffSwitchDidChangeValue(_ pSender: AppSwitch) {
        self.delegate?.cellView(self, didChangePowerState: pSender.isOn)
    }
    
    @IBAction func didtappedOnOffSwitch(_ sender: Any) {
        self.delegate?.cellView(self, didChangePowerState: !pAppliances!.isOn )
    }
}



protocol FrequentlyOperatedCollectionCellViewDelegate :AnyObject {
    func cellView(_ pSender: FrequentlyOperatedCollectionCellView, didChangePowerState pPowerState :Bool)
}
