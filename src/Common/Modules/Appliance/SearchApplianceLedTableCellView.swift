//
//  SearchApplianceLedTableCellView.swift
//  DEFT
//
//  Created by Rupendra on 25/08/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SearchApplianceLedTableCellView: UITableViewCell, ColorPickerControllerDelegate {
    func didtappedDonebtn() {
        print("tapped done")
        let aProperty1 = UtilityManager.property1(color: self.colorPickerControl.color)
        let aProperty2 = UtilityManager.property2(color: self.colorPickerControl.color)
        let aProperty3 = UtilityManager.property3(color: self.colorPickerControl.color)
        self.delegate?.cellView(self, didChangeProperty1: aProperty1, property2: aProperty2, property3: aProperty3, glowPattern: Appliance.GlowPatternType.on)
        appliance?.RGBMode = true
        self.delegate?.cellViewRefrash(self)
    }
    
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
    
    @IBOutlet weak var britnessImageView: UIImageView!
    var appliance: Appliance?
    weak var delegate :SearchApplianceLedTableCellViewDelegate?
    
    @IBOutlet weak var stackMailView: UIStackView!
    @IBOutlet weak var viewBritnessSlider: UIView!
    @IBOutlet weak var viewWC: UIView!
    @IBOutlet weak var sliderStackView: UIStackView!
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
    
    
    @IBOutlet weak var titleContaintView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        disclosureIndicatorImageView.isHidden = true
        stackMailView.spacing = 15
        sliderStackView.spacing = 10
        titleContaintView.layer.borderColor = UIColor(hex: "#7749A6").cgColor
        titleContaintView.layer.borderWidth = 2
        titleContaintView.layer.masksToBounds = true
        titleContaintView.layer.cornerRadius = 10
        
        self.lblledSetting.isHidden = true
        self.lblledSetting.setTitle("", for: .normal)
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
        self.colorPickerControl.delegate = self
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
        self.lblledSetting.isHidden = !pAppliance.isOn
        if pAppliance.type == Appliance.ApplianceType.ledStrip && pAppliance.isOn {
            self.glowPatternButtonContainerView.isHidden = pAppliance.ledMode
        }
        self.viewBritnessSlider.isHidden = false
//        self.britnessImageView.isHidden = false
//        self.brightnessSlider.isHidden = false
        self.sliderContainerView.isHidden = true
        self.colorPickerControl.isHidden = true
        if pAppliance.type == Appliance.ApplianceType.ledStrip && pAppliance.isOn {
            if pAppliance.stripType == Appliance.StripType.rgb {
                self.sliderContainerView.isHidden = false
                self.warmnessSlider.isHidden = false
                self.viewBritnessSlider.isHidden = true
                self.warmnessSlider.maximumValue = 99
                if let aProperty1 = pAppliance.ledStripProperty1, let aProperty2 = pAppliance.ledStripProperty2, let aProperty3 = pAppliance.ledStripProperty3 {
                    self.warmnessSlider.value = Float(UtilityManager.singleStripBritValue(property1: (Int(Float(aProperty1) / Float(2.53)))))
                }
                    self.colorPickerControl.isHidden = pAppliance.RGBMode
                    if let aProperty1 = pAppliance.ledStripProperty1, let aProperty2 = pAppliance.ledStripProperty2, let aProperty3 = pAppliance.ledStripProperty3 {
                        print("hex color code=\(colorPickerControl.rgbToHex(red: CGFloat(aProperty1), green: CGFloat(aProperty2), blue: CGFloat(aProperty3)))")
                    self.colorPickerControl.color = UtilityManager.color(property1: aProperty1, property2: aProperty2, property3: aProperty3)
                }
            } else if pAppliance.stripType == Appliance.StripType.wc && pAppliance.type == Appliance.ApplianceType.ledStrip && pAppliance.isOn{
                self.sliderContainerView.isHidden = false
                self.warmnessSlider.minimumValue = 0
                self.warmnessSlider.maximumValue = 100
                if let aProperty1 = pAppliance.ledStripProperty1, let aProperty2 = pAppliance.ledStripProperty2, let aProperty3 = pAppliance.ledStripProperty3 {
                    self.warmnessSlider.value = Float(UtilityManager.warmnessSliderValue(property1: aProperty1, property2: aProperty2, property3: aProperty3))
                }
                self.sliderContainerView.isHidden = false
                
                self.brightnessSlider.minimumValue = 1
                self.brightnessSlider.maximumValue = 255
                if let aProperty1 = pAppliance.ledStripProperty1, let aProperty2 = pAppliance.ledStripProperty2, let aProperty3 = pAppliance.ledStripProperty3 {
                    self.brightnessSlider.value = Float(UtilityManager.brightnessSliderValue(property1: aProperty1, property2: aProperty2, property3: aProperty3))
                }
            }else if pAppliance.stripType == Appliance.StripType.singleStrip && pAppliance.type == Appliance.ApplianceType.ledStrip && pAppliance.isOn{
                self.sliderContainerView.isHidden = false
                self.warmnessSlider.isHidden = false
                self.viewBritnessSlider.isHidden = true
                self.warmnessSlider.maximumValue = 99
                if let aProperty1 = pAppliance.ledStripProperty1, let aProperty2 = pAppliance.ledStripProperty2, let aProperty3 = pAppliance.ledStripProperty3 {
                    self.warmnessSlider.value = Float(UtilityManager.singleStripBritValue(property1: (Int(Float(aProperty1) / Float(2.53)))))
                }
            }else{
                self.sliderContainerView.isHidden = false
                self.warmnessSlider.isHidden = false
                self.viewBritnessSlider.isHidden = true
//                self.brightnessSlider.isHidden = true
//                self.britnessImageView.isHidden = true
                self.warmnessSlider.minimumValue = 1
                self.warmnessSlider.maximumValue = 255
                if let aProperty1 = pAppliance.ledStripProperty1, let aProperty2 = pAppliance.ledStripProperty2, let aProperty3 = pAppliance.ledStripProperty3 {
                    self.warmnessSlider.value = Float(UtilityManager.singleStripBritValue(property1: aProperty1))
                }
            }
        }
        self.showDisclosureIndicator = true
        configMenu()
    }
    func configMenu(){
       if appliance?.stripType == Appliance.StripType.rgb{
           menuItemsForAccepted =
                 [
                   UIAction(title: "Mode", image: nil, handler: { (_) in
                       self.selectMode()
                    }),
                   UIAction(title: "Color", image: nil, handler: { (_) in
                        self.didSelectColor()
                    })
                 ]
       }else{
       menuItemsForAccepted =
             [
               UIAction(title: "Mode", image: nil, handler: { (_) in
                   self.selectMode()
                })
           ]
       }
        if #available(iOS 14.0, *) {
            lblledSetting.menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItemsForAccepted!)
            lblledSetting.showsMenuAsPrimaryAction = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    static func cellHeight(appliance pAppliance :Appliance) -> CGFloat {
        var aReturnVal :CGFloat = 80.0
        
        if pAppliance.type == Appliance.ApplianceType.ledStrip && pAppliance.isOn {
            if pAppliance.stripType == Appliance.StripType.rgb {
                aReturnVal = 380.0
            } else  if pAppliance.stripType == Appliance.StripType.wc {
                aReturnVal = 300.0
            } else if pAppliance.stripType == Appliance.StripType.singleStrip {
                aReturnVal = 200.0
            }
        }
        
        return aReturnVal
    }
    
    @IBOutlet weak var lblledSetting: UIButton!
    
    var menuItemsForAccepted: [UIAction]?
    @objc func selectMode(){
        if appliance!.ledMode{
             appliance?.ledMode = false
             self.delegate?.cellViewRefrash(self)
        }else{
            appliance?.ledMode = true
        }
    }
    
    @objc func didSelectColor(){
        self.colorPickerControl.delegate = self
        if appliance!.RGBMode{
             appliance?.RGBMode = false
             self.delegate?.cellViewRefrash(self)
        }else{
             appliance?.RGBMode = true
        }
    }
    @IBAction func ledSetting(_ sender: Any) {
       if appliance!.ledMode{
           appliance?.ledMode = false
           self.delegate?.cellViewRefrash(self)
       }else{
           appliance?.ledMode = true
       }
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
        self.sliderTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block: { [self] (pTimer) in
            let aProperty1 = UtilityManager.property1(warmness: Int(self.warmnessSlider.value), brightness: Int(self.brightnessSlider.value))
            let aProperty2 = UtilityManager.property2(warmness: Int(self.warmnessSlider.value), brightness: Int(self.brightnessSlider.value))
            if  appliance?.stripType == Appliance.StripType.wc{  self.delegate?.cellView(self, didChangeProperty1: aProperty1, property2: aProperty2, property3: 255, glowPattern: Appliance.GlowPatternType.on)
            }else if appliance?.stripType == Appliance.StripType.rgb{
                var value:Float = self.warmnessSlider.value
                    value *= 2.55
                self.delegate?.cellView(self, didChangeProperty1: Int(value), property2: Int(value), property3: Int(value), glowPattern: Appliance.GlowPatternType.on)
            }else if appliance?.stripType == Appliance.StripType.singleStrip{
            let singleStripValue = (255.0 / 100.0) * Float(self.warmnessSlider.value)
               self.delegate?.cellView(self, didChangeProperty1: Int(singleStripValue), property2: 255, property3: 255, glowPattern: Appliance.GlowPatternType.on)
           }
        })
    }
    
    
    @objc func colorPickerDidChangeValue(_ pSender: ColorPickerControl) {
        self.colorPickerTimer?.invalidate()
        self.colorPickerTimer = nil
        self.colorPickerTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block: { (pTimer) in
//            let aProperty1 = UtilityManager.property1(color: self.colorPickerControl.color)
//            let aProperty2 = UtilityManager.property2(color: self.colorPickerControl.color)
//            let aProperty3 = UtilityManager.property3(color: self.colorPickerControl.color)
//            self.delegate?.cellView(self, didChangeProperty1: aProperty1, property2: aProperty2, property3: aProperty3, glowPattern: Appliance.GlowPatternType.on)
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
    func cellViewRefrash(_ pSender :SearchApplianceLedTableCellView)
}
