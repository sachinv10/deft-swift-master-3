//
//  RoomCollectionCellView.swift
//  DEFT
//
//  Created by Rupendra on 21/08/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class RoomCollectionCellView: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var applianceButton: RoomCollectionCellButton!
    @IBOutlet weak var curtainButton: RoomCollectionCellButton!
    @IBOutlet weak var remoteButton: RoomCollectionCellButton!
    @IBOutlet weak var moodButton: RoomCollectionCellButton!
    @IBOutlet weak var sensorButton: RoomCollectionCellButton!
    @IBOutlet weak var energyButton: RoomCollectionCellButton!
    
    weak var delegate :RoomCollectionCellViewDelegate?
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor =  UIColor(hex: "#FEFEFE")
        self.titleLabel.textColor = UIColor.darkGray
        self.dateLabel.textColor = UIColor.gray
    }
    
    
    func load(room pRoom :Room) {
        self.titleLabel.text = pRoom.title
       // self.dateLabel.text = "Last Active On " + (pRoom.lastActiveDateText ?? "")
        self.dateLabel.text = "Last Active On " + (pRoom.lastActivityRoom ?? "")
    }
    
    @IBAction func didSelectApplianceButton(_ pSender: UIButton?) {
        self.delegate?.didSelectApplianceButton(self)
    }
    
    @IBAction func didSelectCurtainButton(_ pSender: UIButton?) {
        self.delegate?.didSelectCurtainButton(self)
    }
    
    @IBAction func didSelectRemoteButton(_ pSender: UIButton?) {
        self.delegate?.didSelectRemoteButton(self)
    }
    
    
    @IBAction func didSelectMoodButton(_ pSender: UIButton?) {
        self.delegate?.didSelectMoodButton(self)
    }
    
    
    @IBAction func didSelectSensorButton(_ pSender: UIButton?) {
        self.delegate?.didSelectSensorButton(self)
    }
    
    
    @IBAction func didSelectEnergyButton(_ pSender: UIButton?) {
        self.delegate?.didSelectEnergyButton(self)
    }
    
}



protocol RoomCollectionCellViewDelegate :AnyObject {
    func didSelectApplianceButton(_ pSender :RoomCollectionCellView)
    func didSelectCurtainButton(_ pSender :RoomCollectionCellView)
    func didSelectRemoteButton(_ pSender :RoomCollectionCellView)
    func didSelectMoodButton(_ pSender :RoomCollectionCellView)
    func didSelectSensorButton(_ pSender :RoomCollectionCellView)
    func didSelectEnergyButton(_ pSender :RoomCollectionCellView)
}


class RoomCollectionCellButton :UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor(named: "SecondaryLightestColor")
        self.tintColor = UIColor(named: "ControlNormalColor")
        self.layer.borderWidth = 1.0
        self.layer.borderColor = self.tintColor.cgColor
        self.layer.cornerRadius = self.frame.size.height / 2.0
        if UtilityManager.shared.screenSizeType == UtilityManager.ScreenSizeType.small {
            self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            self.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = self.frame.size.height / 2.0
    }
}
