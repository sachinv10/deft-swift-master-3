//
//  SearchCurtainTableCellView.swift
//  DEFT
//
//  Created by Rupendra on 20/09/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SearchCurtainTableCellView: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var onlineIndicatorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var buttonContainerView: UIView!
    
    @IBOutlet weak var slider: AppSlider!
    var sliderTimer: Timer?
    
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var lblOpen: UILabel!
    @IBOutlet weak var lblClose: UILabel!
    @IBOutlet weak var lblPause: UILabel!
    var curtain :Curtain?
    weak var delegate :SearchCurtainTableCellViewDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.iconImageView.tintColor = UIColor.darkGray
        self.iconImageView.layer.borderWidth = 1.0
        self.iconImageView.layer.borderColor = self.iconImageView.tintColor.cgColor
        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.size.height / 2.0
        self.onlineIndicatorView.layer.cornerRadius = self.onlineIndicatorView.frame.size.height / 2
        self.titleLabel.textColor = UIColor.darkGray
        
        self.slider.minimumTrackTintColor = UIColor(named: "ControlCheckedColor")
        self.slider.maximumTrackTintColor = UIColor(named: "ControlNormalColor")
        
        self.openButton.tintColor = UIColor(named: "ControlNormalColor")
        self.openButton.layer.borderWidth = 1.0
        self.openButton.layer.borderColor = UIColor(named: "ControlNormalColor")?.cgColor
        self.openButton.layer.cornerRadius = self.openButton.frame.size.height / 2
        
        self.stopButton.tintColor = UIColor(named: "ControlNormalColor")
        self.stopButton.layer.borderWidth = 1.0
        self.stopButton.layer.borderColor = UIColor(named: "ControlNormalColor")?.cgColor
        self.stopButton.layer.cornerRadius = self.stopButton.frame.size.height / 2
        
        self.closeButton.tintColor = UIColor(named: "ControlNormalColor")
        self.closeButton.layer.borderWidth = 1.0
        self.closeButton.layer.borderColor = UIColor(named: "ControlNormalColor")?.cgColor
        self.closeButton.layer.cornerRadius = self.closeButton.frame.size.height / 2
    }
    
    
    func load(curtain pCurtain :Curtain) {
        self.curtain = pCurtain
        
        self.iconImageView.image = pCurtain.icon
        if let anIsOnline = pCurtain.isOnline {
            self.onlineIndicatorView.isHidden = false
            self.onlineIndicatorView.backgroundColor = anIsOnline == true ? UIColor.green : UIColor.red
        } else {
            self.onlineIndicatorView.isHidden = true
        }
        self.titleLabel.text = pCurtain.title
        if self.curtain?.type == Curtain.CurtainType.rolling {
            self.buttonContainerView.isHidden = true
            self.slider.isHidden = false
            self.lblOpen.isHidden = true
            self.lblClose.isHidden = true
            self.lblPause.isHidden = true
        } else {
            self.buttonContainerView.isHidden = false
            self.slider.isHidden = true
            self.lblOpen.isHidden = false
            self.lblPause.isHidden = false
            self.lblClose.isHidden = false
        }
        self.slider.value = Float(self.curtain?.level ?? 0)
    }
    
    
    static func cellHeight(curtain pCurtain :Curtain) -> CGFloat {
        let aReturnVal :CGFloat = 145.0
        return aReturnVal
    }
    
    
    @IBAction func didSelectOpenButton(_ pSender: UIButton) {
        self.delegate?.cellViewDidSelectOpenCurtain(self)
    }
    
    
    @IBAction func didSelectStopButton(_ pSender: UIButton) {
        self.delegate?.cellViewDidSelectStopCurtain(self)
    }
    
    
    @IBAction func didSelectCloseButton(_ pSender: UIButton) {
        self.delegate?.cellViewDidSelectCloseCurtain(self)
    }
    
    
    @IBAction func sliderDidChangeValue(_ pSender: UISlider) {
        let aRoundedValue = round(pSender.value / 1) * 1
        pSender.value = aRoundedValue
        
        self.sliderTimer?.invalidate()
        self.sliderTimer = nil
        self.sliderTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block: { (pTimer) in
            self.delegate?.cellView(self, didChangeDimmableValue: Int(pSender.value))
        })
    }
    
}



protocol SearchCurtainTableCellViewDelegate :AnyObject {
    func cellViewDidSelectOpenCurtain(_ pSender: SearchCurtainTableCellView)
    func cellViewDidSelectStopCurtain(_ pSender: SearchCurtainTableCellView)
    func cellViewDidSelectCloseCurtain(_ pSender: SearchCurtainTableCellView)
    func cellView(_ pSender: SearchCurtainTableCellView, didChangeDimmableValue pDimmableValue :Int)
}
