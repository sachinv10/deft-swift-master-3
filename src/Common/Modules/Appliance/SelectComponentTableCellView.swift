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
    
    var appliance :Appliance?
    var curtain :Curtain?
    var remote :Remote?
    var sensor :Sensor?
    
    weak var delegate :SelectComponentTableCellViewDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func load(appliance pAppliance :Appliance, isChecked pIsChecked :Bool, powerState pPowerState :Bool?, dimmableValue pDimmableValue :Int?) {
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
    
    
    @IBAction func sensorActivateWholeSegmentedControlDidChangeValue(_ pSender: UISegmentedControl) {
        self.updateSensorCommand()
    }
    
    
    @IBAction func sensorActivateMotionLightSegmentedControlDidChangeValue(_ pSender: UISegmentedControl) {
        self.updateSensorCommand()
    }
    
    
    @IBAction func sensorActivateSirenSegmentedControlDidChangeValue(_ pSender: UISegmentedControl) {
        self.updateSensorCommand()
    }
    
}



protocol SelectComponentTableCellViewDelegate :AnyObject {
    func selectComponentTableCellViewDidUpdate(_ pSender :SelectComponentTableCellView)
}
