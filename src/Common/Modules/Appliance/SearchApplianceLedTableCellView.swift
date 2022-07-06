//
//  SearchApplianceLedTableCellView.swift
//  DEFT
//
//  Created by Rupendra on 25/08/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SearchApplianceLedTableCellView: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var onlineIndicatorView: UIView!
    @IBOutlet weak var disclosureIndicatorImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var roomTitleLabel: UILabel!
    @IBOutlet weak var onOffSwitch: AppSwitch!
    @IBOutlet weak var glowPatternButtonContainerView: UIView!
    
    @IBOutlet weak var containerViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sliderContainerView: UIView!
    @IBOutlet weak var warmnessSlider: AppSlider!
    @IBOutlet weak var brightnessSlider: AppSlider!
    var sliderTimer: Timer?
    
    @IBOutlet weak var colorPickerControl: ColorPickerControl!
    var colorPickerTimer: Timer?
    
    var appliance: Appliance?
    weak var delegate :SearchApplianceLedTableCellViewDelegate?
    
    var showDisclosureIndicator :Bool = false {
        didSet {
            if self.showDisclosureIndicator {
                self.disclosureIndicatorImageView.isHidden = false
                self.selectionStyle = UITableViewCell.SelectionStyle.default
                self.containerViewTrailingConstraint.constant = 30
            } else {
                self.disclosureIndicatorImageView.isHidden = true
                self.selectionStyle = UITableViewCell.SelectionStyle.none
                self.containerViewTrailingConstraint.constant = 15
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.iconImageView.tintColor = UIColor.darkGray
        self.iconImageView.layer.borderWidth = 1.0
        self.iconImageView.layer.borderColor = self.iconImageView.tintColor.cgColor
        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.size.height / 2.0
        self.onlineIndicatorView.layer.cornerRadius = self.onlineIndicatorView.frame.size.height / 2
        self.titleLabel.textColor = UIColor.darkGray
        self.roomTitleLabel.textColor = UIColor.gray
        
        self.warmnessSlider.minimumTrackTintColor = UIColor(named: "ControlCheckedColor")
        self.warmnessSlider.maximumTrackTintColor = UIColor(named: "ControlNormalColor")
        
        self.brightnessSlider.minimumTrackTintColor = UIColor(named: "ControlCheckedColor")
        self.brightnessSlider.maximumTrackTintColor = UIColor(named: "ControlNormalColor")
        
        self.colorPickerControl.isExclusiveTouch = true
        self.colorPickerControl.addTarget(self, action: #selector(self.colorPickerDidChangeValue(_:)), for: UIControl.Event.valueChanged)
        
        for anIndex in 0..<self.glowPatternButtonContainerView.subviews.count {
            if let aButton = self.glowPatternButtonContainerView.subviews[anIndex] as? UIButton {
                aButton.layer.borderWidth = 1.0
                aButton.layer.borderColor = UIColor(named: "ControlNormalColor")?.cgColor
                aButton.layer.cornerRadius = 4.0
                aButton.tintColor = UIColor(named: "ControlNormalColor")
                aButton.backgroundColor = UIColor(named: "SecondaryLightestColor")
                if UtilityManager.shared.screenSizeType == UtilityManager.ScreenSizeType.small {
                    aButton.titleLabel?.font = UIFont.systemFont(ofSize: 10.0)
                } else {
                    aButton.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
                }
            }
        }
        for anIndex in 0..<self.glowPatternButtonContainerView.subviews.count {
            if let aButton = self.glowPatternButtonContainerView.subviews[anIndex] as? UIButton {
                aButton.tag = 2100 + anIndex
                aButton.addTarget(self, action: #selector(self.didSelectGlowPatternButton(_:)), for: UIControl.Event.touchUpInside)
            }
        }
    }
    
    
    func load(appliance pAppliance :Appliance, shouldShowRoomTitle pShouldShowRoomTitle :Bool) {
        self.appliance = pAppliance
        
        self.iconImageView.image = pAppliance.icon?.resizableImage(withCapInsets: UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0), resizingMode: UIImage.ResizingMode.stretch)
        if let anIsOnline = pAppliance.isOnline {
            self.onlineIndicatorView.isHidden = false
            self.onlineIndicatorView.backgroundColor = anIsOnline ? UIColor.green : UIColor.red
        } else {
            self.onlineIndicatorView.isHidden = true
        }
        self.titleLabel.text = pAppliance.title
        self.roomTitleLabel.isHidden = !pShouldShowRoomTitle
        self.roomTitleLabel.text = pAppliance.roomTitle
        
        self.onOffSwitch.isOn = pAppliance.isOn
        
        self.glowPatternButtonContainerView.isHidden = true
        if pAppliance.type == Appliance.ApplianceType.ledStrip && pAppliance.isOn {
            self.glowPatternButtonContainerView.isHidden = false
        }
        
        self.sliderContainerView.isHidden = true
        self.colorPickerControl.isHidden = true
        if pAppliance.type == Appliance.ApplianceType.ledStrip && pAppliance.isOn {
            if pAppliance.stripType == Appliance.StripType.rgb {
                self.colorPickerControl.isHidden = false
                if let aProperty1 = pAppliance.ledStripProperty1, let aProperty2 = pAppliance.ledStripProperty2, let aProperty3 = pAppliance.ledStripProperty3 {
                    self.colorPickerControl.color = UtilityManager.color(property1: aProperty1, property2: aProperty2, property3: aProperty3)
                }
            } else {
                self.sliderContainerView.isHidden = false
                self.warmnessSlider.minimumValue = 0
                self.warmnessSlider.maximumValue = 100
                if let aProperty1 = pAppliance.ledStripProperty1, let aProperty2 = pAppliance.ledStripProperty2, let aProperty3 = pAppliance.ledStripProperty3 {
                    self.warmnessSlider.value = Float(UtilityManager.warmnessSliderValue(property1: aProperty1, property2: aProperty2, property3: aProperty3))
                }
                
                self.brightnessSlider.minimumValue = 1
                self.brightnessSlider.maximumValue = 255
                if let aProperty1 = pAppliance.ledStripProperty1, let aProperty2 = pAppliance.ledStripProperty2, let aProperty3 = pAppliance.ledStripProperty3 {
                    self.brightnessSlider.value = Float(UtilityManager.brightnessSliderValue(property1: aProperty1, property2: aProperty2, property3: aProperty3))
                }
            }
        }
    }
    
    
    static func cellHeight(appliance pAppliance :Appliance) -> CGFloat {
        var aReturnVal :CGFloat = 80.0
        
        if pAppliance.type == Appliance.ApplianceType.ledStrip && pAppliance.isOn {
            if pAppliance.stripType == Appliance.StripType.rgb {
                aReturnVal = 380.0
            } else {
                aReturnVal = 300.0
            }
        }
        
        return aReturnVal
    }
    
    
    @IBAction func onOffSwitchDidChangeValue(_ pSender: AppSwitch) {
        let aGlowPattern = pSender.isOn ? Appliance.GlowPatternType.on : Appliance.GlowPatternType.off
        self.delegate?.cellView(self, didChangeProperty1: self.appliance?.ledStripProperty1 ?? 255, property2: self.appliance?.ledStripProperty2 ?? 255, property3: self.appliance?.ledStripProperty3 ?? 255, glowPattern: aGlowPattern)
    }
    
    
    @IBAction func sliderDidChangeValue(_ pSender: UISlider) {
        let aRoundedValue = round(pSender.value / 1) * 1
        pSender.value = aRoundedValue
        
        self.sliderTimer?.invalidate()
        self.sliderTimer = nil
        self.sliderTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block: { (pTimer) in
            let aProperty1 = UtilityManager.property1(warmness: Int(self.warmnessSlider.value), brightness: Int(self.brightnessSlider.value))
            let aProperty2 = UtilityManager.property2(warmness: Int(self.warmnessSlider.value), brightness: Int(self.brightnessSlider.value))
            self.delegate?.cellView(self, didChangeProperty1: aProperty1, property2: aProperty2, property3: 255, glowPattern: Appliance.GlowPatternType.on)
        })
    }
    
    
    @objc func colorPickerDidChangeValue(_ pSender: ColorPickerControl) {
        self.colorPickerTimer?.invalidate()
        self.colorPickerTimer = nil
        self.colorPickerTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block: { (pTimer) in
            let aProperty1 = UtilityManager.property1(color: self.colorPickerControl.color)
            let aProperty2 = UtilityManager.property2(color: self.colorPickerControl.color)
            let aProperty3 = UtilityManager.property3(color: self.colorPickerControl.color)
            self.delegate?.cellView(self, didChangeProperty1: aProperty1, property2: aProperty2, property3: aProperty3, glowPattern: Appliance.GlowPatternType.on)
        })
    }
    
    
    @objc func didSelectGlowPatternButton(_ pSender :UIButton) {
        let aButtonIndex = pSender.tag - 2100
        var aGlowPattern = Appliance.GlowPatternType.auto
        switch aButtonIndex {
        case 0:
            aGlowPattern = Appliance.GlowPatternType.shock
        case 1:
            aGlowPattern = Appliance.GlowPatternType.dimBlink
        case 2:
            aGlowPattern = Appliance.GlowPatternType.colourJump
        case 3:
            aGlowPattern = Appliance.GlowPatternType.flicker
        case 4:
            aGlowPattern = Appliance.GlowPatternType.colourFlash
        case 5:
            aGlowPattern = Appliance.GlowPatternType.strobe
        case 6:
            aGlowPattern = Appliance.GlowPatternType.alternate
        case 7:
            aGlowPattern = Appliance.GlowPatternType.singleFade
        case 8:
            aGlowPattern = Appliance.GlowPatternType.mountain
        case 9:
            aGlowPattern = Appliance.GlowPatternType.flash
        case 10:
            aGlowPattern = Appliance.GlowPatternType.auto
        default:
            aGlowPattern = Appliance.GlowPatternType.auto
        }
        if let aProperty1 = self.appliance?.ledStripProperty1, let aProperty2 = self.appliance?.ledStripProperty2, let aProperty3 = self.appliance?.ledStripProperty3 {
            self.delegate?.cellView(self, didChangeProperty1: aProperty1, property2: aProperty2, property3: aProperty3, glowPattern: aGlowPattern)
        }
    }
    
}


protocol SearchApplianceLedTableCellViewDelegate :AnyObject {
    func cellView(_ pSender :SearchApplianceLedTableCellView, didChangeProperty1 pProperty1 :Int, property2 pProperty2 :Int, property3 pProperty3 :Int, glowPattern pGlowPatternValue :Appliance.GlowPatternType)
}
