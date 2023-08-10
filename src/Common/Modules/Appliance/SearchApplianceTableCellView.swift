//
//  SearchApplianceTableCellView.swift
//  DEFT
//
//  Created by Rupendra on 21/08/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SearchApplianceTableCellView: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var onlineIndicatorView: UIView!
    @IBOutlet weak var disclosureIndicatorImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var roomTitleLabel: UILabel!
    @IBOutlet weak var onOffSwitch: AppSwitch!
    @IBOutlet weak var slider: AppSlider!
    
    @IBOutlet weak var titleContaintView: UIView!
    @IBOutlet weak var btnbackgroundhandel: UIButton!
    var sliderTimer: Timer?
    
    var appliance: Appliance?
    var appliances: [Appliance] = []
    weak var delegate :SearchApplianceTableCellViewDelegate?
    
    var showDisclosureIndicator :Bool = false {
        didSet {
            if self.showDisclosureIndicator {
          //      self.disclosureIndicatorImageView.isHidden = false
                self.selectionStyle = UITableViewCell.SelectionStyle.default
          //      self.containerViewTrailingConstraint.constant = 30
            } else {
             //   self.disclosureIndicatorImageView.isHidden = true
                self.selectionStyle = UITableViewCell.SelectionStyle.none
            //    self.containerViewTrailingConstraint.constant = 15
            }
        }
    }
    
    
    @IBAction func btnbackgroundact(_ sender: Any) {
        
    }
    
    @IBOutlet weak var containerViewTrailingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.iconImageView.tintColor = UIColor.darkGray
        self.iconImageView.layer.borderWidth = 1.0
        self.iconImageView.layer.borderColor = self.iconImageView.tintColor.cgColor
        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.size.height / 2.0
        self.onlineIndicatorView.layer.cornerRadius = self.onlineIndicatorView.frame.size.height / 2
        self.titleLabel.textColor = UIColor.darkGray
        self.roomTitleLabel.textColor = UIColor.gray
        
        self.slider.minimumTrackTintColor = UIColor(hex: "#A48DC1")
     //   UIColor(named: "ControlCheckedColor")
        self.slider.maximumTrackTintColor = UIColor(hex: "#DABBFF")
        btnbackgroundhandel.setTitle("", for: .normal)
        // UI changes
        titleContaintView.layer.borderColor = UIColor(hex: "#7749A6").cgColor
        titleContaintView.layer.borderWidth = 2
        titleContaintView.layer.masksToBounds = true
        titleContaintView.layer.cornerRadius = 10
        onOffSwitch.isHidden = true
        disclosureIndicatorImageView.isHidden = true
        
     }
    
    var propObserve = 1 {
        willSet {
           print("my previous value was \(propObserve) and my future value will be \(newValue)")
        }
        didSet {
             
        }
    }

    
    var indepath = Int()
    func load(appliance pAppliance :Appliance, shouldShowRoomTitle pShouldShowRoomTitle :Bool) {
        self.appliance = pAppliance
        
        self.iconImageView.image = pAppliance.icon?.resizableImage(withCapInsets: UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0), resizingMode: UIImage.ResizingMode.stretch)
        if ConfigurationManager.shared.appType == .wifinity {
            if let anIsOnline = pAppliance.isOnline {
                self.onlineIndicatorView.isHidden = false
                self.onlineIndicatorView.backgroundColor = anIsOnline ? UIColor.green : UIColor.red
            } else {
                self.onlineIndicatorView.isHidden = true
            }
        } else {
            self.onlineIndicatorView.isHidden = true
        }
        
        self.titleLabel.text = pAppliance.title
        self.roomTitleLabel.isHidden = !pShouldShowRoomTitle
        self.roomTitleLabel.text = pAppliance.roomTitle
        
        self.onOffSwitch.isOn = pAppliance.isOn
        if ConfigurationManager.shared.appType == .wifinity {
            self.onOffSwitch.isEnabled = pAppliance.isOnline == true
            titleContaintView.backgroundColor = pAppliance.isOn == true ? UIColor(hex: "#F8E8BE") : UIColor.clear
        }
        
        self.slider.isHidden = true
        if ConfigurationManager.shared.appType == .wifinity {
            self.slider.isEnabled = pAppliance.isOnline == true
        }
        
        if pAppliance.isOn && pAppliance.isDimmable {
            self.slider.isHidden = false
           
            if SearchApplianceTableCellView.slidervalIndexpath ?? 100 == indepath {
                print("indexpath=\(indepath)&& indexpath Slider=\(SearchApplianceTableCellView.slidervalIndexpath ?? 0)")
                
                if  SearchApplianceTableCellView.slidervalue ?? 1 == Int(pAppliance.dimmableValue ?? 0) || SearchApplianceTableCellView.slidervalue ?? 1 == Int(pAppliance.dimmableValueTriac ?? 0){
                    print("Slider \(SearchApplianceTableCellView.slidervalue ?? 1) == dimble \(Int(pAppliance.dimmableValue ?? 0)) ")
                    print(SearchApplianceTableCellView.slidervalue ?? 1 == Int(pAppliance.dimmableValue ?? 0))
                    print("In..........")
                    print("my previous value was Reset")
                    SearchApplianceTableCellView.slidervalue = nil
                    SearchApplianceTableCellView.slidervalIndexpath = nil
                    
                    if pAppliance.dimType == Appliance.DimType.rc {
                        if pAppliance.dimmableValueMin != nil {
                            self.slider.minimumValue = Float(pAppliance.dimmableValueMin!)
                        } else {
                            self.slider.minimumValue = 1
                        }
                    } else if pAppliance.dimType == Appliance.DimType.triac {
                        self.slider.minimumValue = 1
                    } else if pAppliance.dimmableValueMin != nil {
                        self.slider.minimumValue = Float(pAppliance.dimmableValueMin!)
                    } else {
                        self.slider.minimumValue = 1
                    }
                    
                    if pAppliance.dimType == Appliance.DimType.rc {
                        self.slider.maximumValue = 5
                    } else if pAppliance.dimType == Appliance.DimType.triac {
                        self.slider.maximumValue = 99
                    } else if pAppliance.dimmableValueMax != nil {
                        self.slider.maximumValue = Float(pAppliance.dimmableValueMax!)
                    } else {
                        self.slider.maximumValue = 5
                    }
                    
                    if pAppliance.dimType == Appliance.DimType.rc {
                        if let aDimmableValue = pAppliance.dimmableValue {
                            self.slider.value = Float(aDimmableValue)
                        }
                    } else if pAppliance.dimType == Appliance.DimType.triac {
                        if let aDimmableValue = pAppliance.dimmableValueTriac {
                            self.slider.value = Float(UtilityManager.sliderValueFromDimmableValue(appliance: pAppliance, dimmableValue: aDimmableValue))
                        }
                    } else {
                        if let aDimmableValue = pAppliance.dimmableValue {
                            self.slider.value = Float(aDimmableValue)
                        }
                    }
                }
            }else{
                print("Else part")
                if pAppliance.dimType == Appliance.DimType.rc {
                    if pAppliance.dimmableValueMin != nil {
                        self.slider.minimumValue = Float(pAppliance.dimmableValueMin!)
                    } else {
                        self.slider.minimumValue = 1
                    }
                } else if pAppliance.dimType == Appliance.DimType.triac {
                    self.slider.minimumValue = 1
                } else if pAppliance.dimmableValueMin != nil {
                    self.slider.minimumValue = Float(pAppliance.dimmableValueMin!)
                } else {
                    self.slider.minimumValue = 1
                }
                
                if pAppliance.dimType == Appliance.DimType.rc {
                    self.slider.maximumValue = 5
                } else if pAppliance.dimType == Appliance.DimType.triac {
                    self.slider.maximumValue = 99
                } else if pAppliance.dimmableValueMax != nil {
                    self.slider.maximumValue = Float(pAppliance.dimmableValueMax!)
                } else {
                    self.slider.maximumValue = 5
                }
                
                if pAppliance.dimType == Appliance.DimType.rc {
                    if let aDimmableValue = pAppliance.dimmableValue {
                        self.slider.value = Float(aDimmableValue)
                    }
                } else if pAppliance.dimType == Appliance.DimType.triac {
                    if let aDimmableValue = pAppliance.dimmableValueTriac {
                        self.slider.value = Float(UtilityManager.sliderValueFromDimmableValue(appliance: pAppliance, dimmableValue: aDimmableValue))
                    }
                } else {
                    if let aDimmableValue = pAppliance.dimmableValue {
                        self.slider.value = Float(aDimmableValue)
                    }
                }
            }
        }
    }
    
    
    static func cellHeight(appliance pAppliance :Appliance) -> CGFloat {
        var aReturnVal :CGFloat = 100.0
        
        if pAppliance.isOn && pAppliance.isDimmable {
            aReturnVal = 145.0
        }
        
        return aReturnVal
    }
    
    
    @IBAction func onOffSwitchDidChangeValue(_ pSender: AppSwitch) {
        self.delegate?.cellView(self, didChangePowerState: self.onOffSwitch.isOn)
    }
    
    static var slideflag: Bool  = false
    static var slidervalue: Int?
    static var slidervalIndexpath: Int?
    
    @IBAction func sliderDidChangeValue(_ pSender: UISlider) {
        SearchApplianceTableCellView.slideflag = true
    
        let aRoundedValue = round(pSender.value / 1) * 1
        pSender.value = aRoundedValue
        self.sliderTimer?.invalidate()
        self.sliderTimer = nil
      
        self.sliderTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false, block: { (pTimer) in
            if let anAppliance = self.appliance {
                let aSliderValue = Int(self.slider?.value ?? 0)
                let aDimmableValue :Int = UtilityManager.dimmableValueFromSliderValue(appliance: anAppliance, sliderValue: aSliderValue)
                SearchApplianceTableCellView.slidervalue = aDimmableValue
                SearchApplianceTableCellView.slidervalIndexpath = nil
                let x = pSender.tag
                SearchApplianceTableCellView.slidervalIndexpath = x
                self.appliances[x].dimmableValue =  aDimmableValue
                SearchApplianceController.celltappedcounter += 1
                print("Selected indexparh=\(SearchApplianceTableCellView.slidervalIndexpath)")
                self.propObserve = x
                self.delegate?.cellView(self, didChangeDimmableValue: aDimmableValue)
            }
        })
    }
}


protocol SearchApplianceTableCellViewDelegate :AnyObject {
    func cellView(_ pSender: SearchApplianceTableCellView, didChangePowerState pPowerState :Bool)
    func cellView(_ pSender: SearchApplianceTableCellView, didChangeDimmableValue pDimmableValue :Int)
}
