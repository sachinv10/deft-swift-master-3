//
//  SelectComponentTableCellView.swift
//  DEFT
//
//  Created by Rupendra on 18/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SelectComponentTableCellView: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkboxImageView: UIImageView!
    
    @IBOutlet weak var glowPatternButtonContainerView: UIView!
    @IBOutlet weak var applianceOptionsStackView: UIStackView!
    @IBOutlet weak var appliancePowerStateSwitch: AppSwitch!
    @IBOutlet weak var applianceDimStateOptionsContainerView: UIView!
    @IBOutlet weak var applianceDimmableValueSlider: AppSlider!
    
    @IBOutlet weak var curtainOptionsStackView: UIStackView!
    @IBOutlet weak var curtainPositionSegmentedControlContainerView: UIView!
    @IBOutlet weak var curtainPositionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var curtainPositionSliderContainerView: UIView!
    @IBOutlet weak var curtainPositionSlider: AppSlider!
    
    @IBOutlet weak var sensorOptionsStackView: UIStackView!
    @IBOutlet weak var sensorActivateWholeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var sensorActivateMotionLightSegmentedControl: UISegmentedControl!
    @IBOutlet weak var sensorActivateSirenSegmentedControl: UISegmentedControl!
    @IBOutlet weak var sensorOptionContainerView: UIView!
    
    @IBOutlet weak var sensorSirenStateOptionsContainerView: UIView!
    @IBOutlet weak var sensorMotionLightStateOptionsContainerView: UIView!
    @IBOutlet weak var sensorWholeStateOptionsView: UIView!
    
    @IBOutlet weak var sensorRoutingTypeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var sensorActionTypeView: UIView!
    
    @IBOutlet weak var sensorActionTemperaturView: UIView!
    
    @IBOutlet weak var sensorActionTypeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var sensorActionTypeAppSlider: AppSlider!
    
    @IBOutlet weak var viewColorCode: UIView!
    
    @IBOutlet weak var colorPickerControl: ColorPickerControl!
    var colorPickerTimer: Timer?
    var appliance :Appliance?
    var curtain :Curtain?
    var remote :Remote?
    var sensor :Sensor?
    
    weak var delegate :SelectComponentTableCellViewDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.sensorOptionContainerView.isHidden = true
        self.sensorActionTemperaturView.isHidden = true
        self.sensorActionTypeView.isHidden = true
        self.glowPatternButtonContainerView.isHidden = true
        self.viewColorCode.isHidden = true
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
        self.colorPickerControl.isExclusiveTouch = true
        self.colorPickerControl.addTarget(self, action: #selector(self.colorPickerDidChangeValue(_:)), for: UIControl.Event.valueChanged)
        
    }

    
    func load(appliance pAppliance :Appliance, isChecked pIsChecked :Bool, powerState pPowerState :Bool?, dimmableValue pDimmableValue :Int?, sripLight psripLight: Bool) {
        self.appliance = pAppliance
        self.curtain = nil
        self.remote = nil
        self.sensor = nil
        
        self.titleLabel.text = pAppliance.title
        self.checkboxImageView.isHidden = !pIsChecked
        self.applianceOptionsStackView.isHidden = pIsChecked ? false : true
        self.curtainOptionsStackView.isHidden = true
        self.sensorOptionsStackView.isHidden = true
        self.appliancePowerStateSwitch.isOn = pPowerState ?? false
        self.applianceDimStateOptionsContainerView.isHidden = pAppliance.isDimmable == false

        if SelectComponentController.ApplianceType == "Then"{
            self.glowPatternButtonContainerView.isHidden = psripLight ? false : true
            self.viewColorCode.isHidden = !(pAppliance.isDimmable == false &&  (pAppliance.stripType == Appliance.StripType.rgb && pIsChecked))
        }
        if pAppliance.dimType == Appliance.DimType.rc {
            if pAppliance.dimmableValueMin != nil {
                self.applianceDimmableValueSlider.minimumValue = Float(pAppliance.dimmableValueMin!)
            } else {
                self.applianceDimmableValueSlider.minimumValue = 1
            }
        } else if pAppliance.dimType == Appliance.DimType.triac {
            self.applianceDimmableValueSlider.minimumValue = 1
        } else if pAppliance.dimmableValueMin != nil {
            self.applianceDimmableValueSlider.minimumValue = Float(pAppliance.dimmableValueMin!)
        } else {
            self.applianceDimmableValueSlider.minimumValue = 1
        }
        
        if pAppliance.dimType == Appliance.DimType.rc {
            self.applianceDimmableValueSlider.maximumValue = 5
        } else if pAppliance.dimType == Appliance.DimType.triac {
            self.applianceDimmableValueSlider.maximumValue = 99
        } else if pAppliance.dimmableValueMax != nil {
            self.applianceDimmableValueSlider.maximumValue = Float(pAppliance.dimmableValueMax!)
        } else {
            self.applianceDimmableValueSlider.maximumValue = 5
        }
        
        if pDimmableValue != nil {
            self.applianceDimmableValueSlider.value = Float(UtilityManager.sliderValueFromDimmableValue(appliance: pAppliance, dimmableValue: pDimmableValue!))
        }
        
        self.updateApplianceCommand()
    }
    
    
    func load(curtain pCurtain :Curtain, isChecked pIsChecked :Bool, level pLevel :Int) {
        self.appliance = nil
        self.curtain = pCurtain
        self.remote = nil
        self.sensor = nil
        
        self.titleLabel.text = pCurtain.title
        self.checkboxImageView.isHidden = !pIsChecked
        self.applianceOptionsStackView.isHidden = true
        self.curtainOptionsStackView.isHidden = pIsChecked ? false : true
        self.sensorOptionsStackView.isHidden = true
        
        if pCurtain.type == .rolling {
            self.curtainPositionSegmentedControlContainerView.isHidden = true
            self.curtainPositionSliderContainerView.isHidden = false
        } else {
            self.curtainPositionSegmentedControlContainerView.isHidden = false
            self.curtainPositionSliderContainerView.isHidden = true
        }
        
        if pLevel == Curtain.MotionState.reverse.rawValue {
            self.curtainPositionSegmentedControl.selectedSegmentIndex = 1
        } else {
            self.curtainPositionSegmentedControl.selectedSegmentIndex = 0
        }
        
        self.curtainPositionSlider.minimumValue = 1
        self.curtainPositionSlider.maximumValue = 5
        self.curtainPositionSlider.value = Float(pLevel)
        
        self.updateCurtainCommand()
    }
    
    
    func load(remote pRemote :Remote, isChecked pIsChecked :Bool) {
        self.appliance = nil
        self.curtain = nil
        self.remote = pRemote
        self.sensor = nil
        
        self.titleLabel.text = pRemote.title
        self.checkboxImageView.isHidden = !pIsChecked
        self.applianceOptionsStackView.isHidden = true
        self.curtainOptionsStackView.isHidden = true
        self.sensorOptionsStackView.isHidden = true
    }
    
    
    func load(sensor pSensor :Sensor, isChecked pIsChecked :Bool, activatedState pActivatedState :Sensor.OnlineState?, motionLightState pMotionLightState :Sensor.LightState?, sirenState pSirenState :Sensor.SirenState?) {
        self.appliance = nil
        self.curtain = nil
        self.remote = nil
        self.sensor = pSensor
        sensorActionTemperaturView.isHidden = true
        sensorActionTypeView.isHidden = true
        sensorOptionContainerView.isHidden = true
 
        self.titleLabel.text = pSensor.title
        self.checkboxImageView.isHidden = !pIsChecked
        self.applianceOptionsStackView.isHidden = true
        self.curtainOptionsStackView.isHidden = true
        self.sensorOptionsStackView.isHidden = pIsChecked ? false : true
        
        if pActivatedState == Sensor.OnlineState.on {
            self.sensorActivateWholeSegmentedControl.selectedSegmentIndex = 0
        } else if pActivatedState == Sensor.OnlineState.off {
            self.sensorActivateWholeSegmentedControl.selectedSegmentIndex = 1
        } else {
            self.sensorActivateWholeSegmentedControl.selectedSegmentIndex = 2
        }
        
        if pMotionLightState == Sensor.LightState.on {
            self.sensorActivateMotionLightSegmentedControl.selectedSegmentIndex = 0
        } else if pMotionLightState == Sensor.LightState.off {
            self.sensorActivateMotionLightSegmentedControl.selectedSegmentIndex = 1
        } else {
            self.sensorActivateMotionLightSegmentedControl.selectedSegmentIndex = 2
        }
        
        if pSirenState == Sensor.SirenState.on {
            self.sensorActivateSirenSegmentedControl.selectedSegmentIndex = 0
        } else if pSirenState == Sensor.SirenState.off {
            self.sensorActivateSirenSegmentedControl.selectedSegmentIndex = 1
        } else {
            self.sensorActivateSirenSegmentedControl.selectedSegmentIndex = 2
        }
        
        self.updateSensorCommand()
    }
    func loadx(sensor pSensor :Sensor, isChecked pIsChecked :Bool, activatedState pActivatedState :Sensor.OnlineState?, motionLightState pMotionLightState :Sensor.LightState?, sirenState pSirenState :Sensor.SirenState?) {
        self.appliance = nil
        self.curtain = nil
        self.remote = nil
        self.sensor = pSensor
        sensorWholeStateOptionsView.isHidden = true
        sensorMotionLightStateOptionsContainerView.isHidden = true
        sensorSirenStateOptionsContainerView.isHidden = true
        sensorActionTemperaturView.isHidden = false
        sensorActionTypeView.isHidden = false
        sensorOptionContainerView.isHidden = false
        
        self.titleLabel.text = pSensor.title
        self.checkboxImageView.isHidden = !pIsChecked
        self.applianceOptionsStackView.isHidden = true
        self.curtainOptionsStackView.isHidden = true
        self.sensorOptionsStackView.isHidden = pIsChecked ? false : true
        
        if pSensor.routineType == nil || pSensor.routineType == "motion"{
            self.sensorRoutingTypeSegmentedControl.selectedSegmentIndex = 0
        } else if pSensor.routineType == "light" {
            self.sensorRoutingTypeSegmentedControl.selectedSegmentIndex = 1
        }else if pSensor.routineType == "temperature"{
            self.sensorRoutingTypeSegmentedControl.selectedSegmentIndex = 2
        }
        updateRoutingType()
        
        self.updateSensorCommand()
    }
    
    @objc func didSelectGlowPatternButton(_ pSender :UIButton) {
        let aButtonIndex = pSender.tag - 2100
        var aGlowPattern = Appliance.GlowPatternType.auto
         for anIndex in 0..<self.glowPatternButtonContainerView.subviews.count {
             if let aButton = self.glowPatternButtonContainerView.subviews[anIndex] as? UIButton {
                aButton.layer.borderColor = UIColor(named: "ControlNormalColor")?.cgColor
              //   aButton.isSelected = false
             }}
        switch aButtonIndex {
        case 0:
            aGlowPattern = Appliance.GlowPatternType.shock
            appliance?.isDimmable = false
        case 1:
            aGlowPattern = Appliance.GlowPatternType.dimBlink
            appliance?.isDimmable = false
        case 2:
            aGlowPattern = Appliance.GlowPatternType.colourJump
            appliance?.isDimmable = false
        case 3:
            aGlowPattern = Appliance.GlowPatternType.flicker
            appliance?.isDimmable = false
        case 4:
            aGlowPattern = Appliance.GlowPatternType.colourFlash
            appliance?.isDimmable = false
        case 5:
            aGlowPattern = Appliance.GlowPatternType.strobe
            appliance?.isDimmable = false
        case 6:
            aGlowPattern = Appliance.GlowPatternType.alternate
            appliance?.isDimmable = false
        case 7:
            aGlowPattern = Appliance.GlowPatternType.singleFade
            appliance?.isDimmable = false
        case 8:
            aGlowPattern = Appliance.GlowPatternType.mountain
            appliance?.isDimmable = false
        case 9:
            aGlowPattern = Appliance.GlowPatternType.flash
            appliance?.isDimmable = false
        case 10:
            aGlowPattern = Appliance.GlowPatternType.auto
            appliance?.isDimmable = false
        case 11 :
            aGlowPattern = Appliance.GlowPatternType.dimming
            stripDim(aGlowPattern: aGlowPattern)
        default:
            aGlowPattern = Appliance.GlowPatternType.auto
            appliance?.isDimmable = false
        }
        UIupdate(pSender: pSender)
        if let aProperty1 = self.appliance?.ledStripProperty1, let aProperty2 = self.appliance?.ledStripProperty2, let aProperty3 = self.appliance?.ledStripProperty3 {
            self.delegate?.cellView(self, didChangeProperty1: aProperty1, property2: aProperty2, property3: aProperty3, glowPattern: String(aGlowPattern.rawValue))
         }
    }
    func stripDim(aGlowPattern: Appliance.GlowPatternType){
        switch aGlowPattern{
            case .dimBlink:
            appliance?.stripLightEvent = String(aGlowPattern.rawValue)
            case .colourFlash:     appliance?.stripLightEvent = String(aGlowPattern.rawValue)
            case .shock:     appliance?.stripLightEvent = String(aGlowPattern.rawValue)
            case .colourJump:     appliance?.stripLightEvent = String(aGlowPattern.rawValue)
            case .flicker:     appliance?.stripLightEvent = String(aGlowPattern.rawValue)
            case .alternate:     appliance?.stripLightEvent = String(aGlowPattern.rawValue)
            case .strobe:     appliance?.stripLightEvent = String(aGlowPattern.rawValue)
            case .singleFade:     appliance?.stripLightEvent = String(aGlowPattern.rawValue)
            case .mountain:     appliance?.stripLightEvent = String(aGlowPattern.rawValue)
            case .flash:     appliance?.stripLightEvent = String(aGlowPattern.rawValue)
            case .dimming:
                 if applianceDimStateOptionsContainerView.isHidden{
                  appliance?.isDimmable = true
                  applianceDimStateOptionsContainerView.isHidden = false
                 }else{
                  appliance?.isDimmable = false
                  applianceDimStateOptionsContainerView.isHidden = true
                 }
            case .auto:
                    break
            case .on:
                break
            case .rgb:
                break
            case .off:
                break
        }
//        if let aProperty1 = self.appliance?.ledStripProperty1, let aProperty2 = self.appliance?.ledStripProperty2, let aProperty3 = self.appliance?.ledStripProperty3 {
//            self.delegate?.cellView(self, didChangeProperty1: aProperty1, property2: aProperty2, property3: aProperty3, glowPattern: aGlowPattern)
//        }

       //   delegate?.selectComponentSensorTableCellView(self)
    }
    @objc func colorPickerDidChangeValue(_ pSender: ColorPickerControl) {
        self.colorPickerTimer?.invalidate()
        self.colorPickerTimer = nil
        self.colorPickerTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block: { (pTimer) in
            let appliances = self.appliance?.clone()
             let aProperty1 = UtilityManager.property1(color: self.colorPickerControl.color)
            let aProperty2 = UtilityManager.property2(color: self.colorPickerControl.color)
            let aProperty3 = UtilityManager.property3(color: self.colorPickerControl.color)
            self.delegate?.cellView(self, didChangeProperty1: aProperty1, property2: aProperty2, property3: aProperty3, glowPattern: self.appliance?.stripLightEvent ?? "0")
        })
    }
    func UIupdate(pSender: UIButton) {
        pSender.layer.borderColor = UIColor.green.cgColor
      //  pSender.isSelected = true
    }
    static func cellHeight() -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    private func updateApplianceCommand() {
        if let anAppliance = self.appliance {
            let aSliderValue = Int(self.applianceDimmableValueSlider?.value ?? 0)
            let aDimmableValue :Int = UtilityManager.dimmableValueFromSliderValue(appliance: anAppliance, sliderValue: aSliderValue)
            anAppliance.scheduleState = self.appliancePowerStateSwitch.isOn
            anAppliance.scheduleDimmableValue = aDimmableValue
            anAppliance.scheduleCommand = Appliance.command(appliance: anAppliance, powerState: self.appliancePowerStateSwitch.isOn, dimValue: aDimmableValue)
            self.delegate?.selectComponentTableCellViewDidUpdate(self)
        }
    }
    
    
    private func updateCurtainCommand() {
        if let aCurtain = self.curtain {
            if aCurtain.type == .rolling {
                let aLevel = Int(self.curtainPositionSlider.value)
                aCurtain.scheduleLevel = aLevel
                aCurtain.scheduleCommand = Curtain.levelCommand(curtain: aCurtain, level: aLevel)
            } else {
                let aMotionState = self.curtainPositionSegmentedControl.selectedSegmentIndex == 0 ? Curtain.MotionState.forward : Curtain.MotionState.reverse
                aCurtain.scheduleLevel = aMotionState.rawValue
                aCurtain.scheduleCommand = Curtain.motionStateCommand(motionState: aMotionState)
            }
            self.delegate?.selectComponentTableCellViewDidUpdate(self)
        }
    }
    private func updateRoutingType(){
        if let aSensor = self.sensor {
           if sensorRoutingTypeSegmentedControl.selectedSegmentIndex == 0{
               aSensor.routineType = "motion"
               aSensor.sensorTypeId = 3
               sensorActionTypeView.isHidden = true
               sensorActionTemperaturView.isHidden = true
             //  aSensor.subLine = aSensor.selectedAppType
               sensorActionTypeSegmentedControl.isEnabled = false
               sensorActionTypeAppSlider.isEnabled = false

           }else  if sensorRoutingTypeSegmentedControl.selectedSegmentIndex == 1{
               aSensor.routineType = "light"
               aSensor.sensorTypeId = 2
               sensorActionTypeView.isHidden = false
               sensorActionTemperaturView.isHidden = false
               
              // aSensor.subLine = aSensor.selectedAppType
               sensorActionTypeSegmentedControl.isEnabled = true
               sensorActionTypeAppSlider.isEnabled = true
               sensorActionTypeAppSlider.minimumValue = 100
               sensorActionTypeAppSlider.maximumValue = 440
               sensorActionTypeAppSlider.value = Float(aSensor.temperature!)
           }else  if sensorRoutingTypeSegmentedControl.selectedSegmentIndex == 2{
               aSensor.routineType = "temperature"
               aSensor.sensorTypeId = 1
               sensorActionTypeView.isHidden = false
               sensorActionTemperaturView.isHidden = false
           //    aSensor.subLine = aSensor.selectedAppType
               sensorActionTypeSegmentedControl.isEnabled = true
               sensorActionTypeAppSlider.isEnabled = true
               sensorActionTypeAppSlider.minimumValue = 5
               sensorActionTypeAppSlider.maximumValue = 50
               sensorActionTypeAppSlider.value = Float(aSensor.temperature!)
           }
            if aSensor.optators == ">"{
                 sensorActionTypeSegmentedControl.selectedSegmentIndex = 0
             }else if aSensor.optators == "<"{
                 sensorActionTypeSegmentedControl.selectedSegmentIndex = 1
             }else if aSensor.optators == "="{
                 sensorActionTypeSegmentedControl.selectedSegmentIndex = 2
             }else{
                 sensorActionTypeSegmentedControl.selectedSegmentIndex = 0
             }
            print("selected sensor",aSensor.routineType)
            sensor = aSensor.clone()
        }
        updateSensorCommand()
    }
    
    private func updateSensorCommand() {
        if let aSensor = self.sensor {
            var aSensorActivateWholeValue = 0
            if self.sensorActivateWholeSegmentedControl.selectedSegmentIndex == 0 {
                aSensor.scheduleSensorActivatedState = Sensor.OnlineState.on
                aSensorActivateWholeValue = Sensor.OnlineState.on.rawValue
            } else if self.sensorActivateWholeSegmentedControl.selectedSegmentIndex == 1 {
                aSensor.scheduleSensorActivatedState = Sensor.OnlineState.off
                aSensorActivateWholeValue = Sensor.OnlineState.off.rawValue
            } else {
                aSensor.scheduleSensorActivatedState = nil
                aSensorActivateWholeValue = 0
            }
            
            var aSensorActivateMotionLightValue = 0
            if self.sensorActivateMotionLightSegmentedControl.selectedSegmentIndex == 0 {
                aSensor.scheduleMotionLightActivatedState = Sensor.LightState.on
                aSensorActivateMotionLightValue = Sensor.LightState.on.rawValue
            } else if self.sensorActivateMotionLightSegmentedControl.selectedSegmentIndex == 1 {
                aSensor.scheduleMotionLightActivatedState = Sensor.LightState.off
                aSensorActivateMotionLightValue = Sensor.LightState.off.rawValue
            } else {
                aSensor.scheduleMotionLightActivatedState = nil
                aSensorActivateMotionLightValue = 0
            }
            
            var aSensorActivateSirenValue = 0
            if self.sensorActivateSirenSegmentedControl.selectedSegmentIndex == 0 {
                aSensor.scheduleSirenActivatedState = Sensor.SirenState.on
                aSensorActivateSirenValue = 2
            } else if self.sensorActivateSirenSegmentedControl.selectedSegmentIndex == 1 {
                aSensor.scheduleSirenActivatedState = Sensor.SirenState.off
                aSensorActivateSirenValue = 1
            } else {
                aSensor.scheduleSirenActivatedState = nil
                aSensorActivateSirenValue = 0
            }
            
            if self.sensorRoutingTypeSegmentedControl.selectedSegmentIndex == 0 {
                aSensor.routineType = "motion"
                aSensor.sensorTypeId = 3
            } else if self.sensorRoutingTypeSegmentedControl.selectedSegmentIndex == 1 {
                aSensor.routineType = "light"
                aSensor.sensorTypeId = 2
            } else {
                aSensor.routineType = "temperature"
                aSensor.sensorTypeId = 1
            }
            
            if self.sensorActionTypeSegmentedControl.selectedSegmentIndex == 0 {
                aSensor.optators = ">"
            } else if self.sensorActionTypeSegmentedControl.selectedSegmentIndex == 1 {
                aSensor.optators = "<"
            } else {
                aSensor.optators = "="
            }
           let tempvalue = Int(sensorActionTypeAppSlider.value)
            aSensor.temperature = tempvalue
           
            var aMessageValue = "$M"
            aMessageValue += String(format: "%d", aSensorActivateWholeValue)
            aMessageValue += String(format: "%d", aSensorActivateSirenValue)
            aMessageValue += String(format: "%d", aSensorActivateMotionLightValue)
            aMessageValue += "2"
            aMessageValue += "#"
            aSensor.scheduleCommands = Array<String>()
            aSensor.scheduleCommands?.append(aMessageValue)
            self.delegate?.selectComponentTableCellViewDidUpdate(self)
        }
    }
    
    
    @IBAction func appliancePowerStateSwitchDidChangeValue(_ pSender: AppSwitch) {
        self.updateApplianceCommand()
    }
    
    
    @IBAction func applianceDimmableValueSliderDidChangeValue(_ pSender: UISlider) {
        let aRoundedValue = round(pSender.value / 1) * 1
        pSender.value = aRoundedValue
        self.updateApplianceCommand()
    }
    
    
    @IBAction func curtainPositionSegmentedControlDidChangeValue(_ pSender: UISegmentedControl) {
        self.updateCurtainCommand()
    }
    
    
    @IBAction func curtainPositionSliderDidChangeValue(_ pSender: UISlider) {
        let aRoundedValue = round(pSender.value / 1) * 1
        pSender.value = aRoundedValue
        self.updateCurtainCommand()
    }
    
    @IBAction func sensortemperatureSliderDidChangeValue(_ pSender: UISlider) {
        let aRoundedValue = round(pSender.value / 1) * 1
        pSender.value = aRoundedValue
        self.updateSensorCommand()
    }
    
    @IBAction func sensorActivateWholeSegmentedControlDidChangeValue(_ pSender: UISegmentedControl) {
        self.updateSensorCommand()
    }
    
    @IBAction func sensorActivateMotionLightSegmentedControlDidChangeValue(_ pSender: UISegmentedControl) {
        self.updateSensorCommand()
    }
    
    @IBAction func sensorActivateSirenSegmentedControlDidChangeValue(_ pSender: UISegmentedControl) {
        self.updateSensorCommand()
    }
    
    @IBAction func sensorRoutingSegmentedControlDidChangeValue(_ sender: Any) {
        self.updateRoutingType()
        self.delegate?.selectComponentSensorTableCellView(self)
    }
    
    @IBAction func sensorRoutingTypeSegmentedControlDidChangeValue(_ sender: Any) {
        self.updateSensorCommand()
    }
    
}



protocol SelectComponentTableCellViewDelegate :AnyObject {
    func selectComponentTableCellViewDidUpdate(_ pSender :SelectComponentTableCellView)
    func selectComponentSensorTableCellView(_ pSender :SelectComponentTableCellView)
    func cellView(_ pSender :SelectComponentTableCellView, didChangeProperty1 pProperty1 :Int, property2 pProperty2 :Int, property3 pProperty3 :Int, glowPattern pGlowPatternValue : String?)

}
