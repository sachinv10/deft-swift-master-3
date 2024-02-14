//
//  SearchSensorTableCellView.swift
//  DEFT
//
//  Created by Rupendra on 20/09/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SearchSensorTableCellView: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var onlineIndicatorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var lightContainerView: UIView!
    @IBOutlet weak var lightValueLabel: UILabel!
    
    @IBOutlet weak var motionContainerView: UIView!
    @IBOutlet weak var motionValueLabel: UILabel!
    
    @IBOutlet weak var temperatureContainerView: UIView!
    @IBOutlet weak var temperatureValueLabel: UILabel!
    
    @IBOutlet weak var smokeContainerView: UIView!
    @IBOutlet weak var smokeValueLabel: UILabel!
    
    @IBOutlet weak var co2ContainerView: UIView!
    @IBOutlet weak var co2ValueLabel: UILabel!
    
    @IBOutlet weak var lpgContainerView: UIView!
    @IBOutlet weak var lpgValueLabel: UILabel!
    
    @IBOutlet weak var wifinityOccupancySwitch: AppSwitch!
    @IBOutlet weak var deftOccupancyButton: AppToggleButton!
    
    @IBOutlet weak var lightSwitchContainerView: UIView!
    @IBOutlet weak var motionSwitchContainerView: UIView!
    @IBOutlet weak var sirenSwitchContainerView: UIView!
    @IBOutlet weak var onlineSwitchContainerView: UIView!
    @IBOutlet weak var actionButtonContainerView: UIStackView!
    
    @IBOutlet weak var lightSwitch: AppSwitch!
    @IBOutlet weak var motionSwitch: AppSwitch!
    @IBOutlet weak var sirenSwitch: AppSwitch!
    @IBOutlet weak var onlineSwitch: AppSwitch!
    @IBOutlet weak var onlineButton: AppToggleButton!
    @IBOutlet weak var syncButton: UIButton!
    @IBOutlet weak var appNotificationButton: UIButton!
    
    @IBOutlet weak var disclosureIndicatorImageView: UIImageView!
    
    @IBOutlet weak var btnResetCount: UIButton!
    var sensor :Sensor?
    weak var delegate :SearchSensorTableCellViewDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.iconImageView.tintColor = UIColor.darkGray
        self.iconImageView.layer.borderWidth = 1.0
        self.iconImageView.layer.borderColor = self.iconImageView.tintColor.cgColor
        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.size.height / 2.0
        self.onlineIndicatorView.layer.cornerRadius = self.onlineIndicatorView.frame.size.height / 2
        self.titleLabel.textColor = UIColor.darkGray
        
        self.deftOccupancyButton.checkedButtonTitle = "ARMED"
        self.deftOccupancyButton.uncheckedButtonTitle = "DISARMED"
        
        self.onlineButton.checkedButtonTitle = "ONLINE"
        self.onlineButton.uncheckedButtonTitle = "OFFLINE"
        
        self.syncButton.backgroundColor = UIColor(named: "SecondaryLightestColor")
        self.syncButton.tintColor = UIColor(named: "ControlNormalColor")
        self.syncButton.layer.borderWidth = 1.0
        self.syncButton.layer.borderColor = UIColor(named: "ControlNormalColor")?.cgColor
        self.syncButton.layer.cornerRadius = 4.0
        
        self.appNotificationButton.backgroundColor = UIColor(named: "SecondaryLightestColor")
        self.appNotificationButton.tintColor = UIColor(named: "ControlNormalColor")
        self.appNotificationButton.layer.borderWidth = 1.0
        self.appNotificationButton.layer.borderColor = UIColor(named: "ControlNormalColor")?.cgColor
        self.appNotificationButton.layer.cornerRadius = 4.0
        if ConfigurationManager.shared.appType == ConfigurationManager.AppType.wifinity {
            self.appNotificationButton.isHidden = false
        } else {
            self.appNotificationButton.isHidden = true
        }
    }
    func timeDateComvetor(time: Double) -> String {
        let timestamp = NSDate().timeIntervalSince1970
        let diff = timestamp - time
        let myTimeInterval = TimeInterval(diff)
        let minute = myTimeInterval / 60
        let hours = minute / 60
        let day = hours / 24
        let month = day / 30
        let year = month / 12
        if myTimeInterval < 60{
            return "a few seconds ago"
        }else if minute < 60{
            return "\(String(Int(minute))) Minute ago"
        }else if hours <= 24{
            return "\(String(Int(hours))) hours ago"
        }else if day < 31 {
            return "\(String(Int(day))) day ago"
        }else if month < 12 {
            return "\(String(Int(month))) month ago"
        }else{
            return "\(String(Int(year))) year ago"
        }
        
    }
    
    
    @IBOutlet weak var btnfixnow: UIButton!
    
    func load(sensor pSensor :Sensor) {
        self.sensor = pSensor
        self.btnResetCount.isHidden = true
        viewUidSatus.isHidden = true
        self.iconImageView.image = pSensor.icon
        if let anOnlineState = pSensor.onlineState {
            self.onlineIndicatorView.isHidden = false
            self.onlineIndicatorView.backgroundColor = anOnlineState == Sensor.OnlineState.on ? UIColor.green : UIColor.red
        } else {
            self.onlineIndicatorView.isHidden = true
        }
        self.titleLabel.text = pSensor.title
        if  pSensor.calibrated == false, "Lidar Sensor" == pSensor.controllerType{
            viewCalibrate.isHidden = false
        }else{
            viewCalibrate.isHidden = true
        }
        
        if pSensor.hardwareGeneration == Device.HardwareGeneration.deft {
            self.deftOccupancyButton.isHidden = false
            self.wifinityOccupancySwitch.isHidden = true
        } else {
            self.deftOccupancyButton.isHidden = true
            self.wifinityOccupancySwitch.isHidden = false
        }
        
        self.deftOccupancyButton.isChecked = pSensor.occupancyState == Sensor.OccupancyState.armed
        self.wifinityOccupancySwitch.isOn = pSensor.occupancyState == Sensor.OccupancyState.armed
        
        self.lightSwitch.isOn = pSensor.lightState == Sensor.LightState.on
        
        self.motionSwitch.isOn = pSensor.motionState == Sensor.MotionState.on
        
        self.sirenSwitch.isOn = pSensor.sirenState == Sensor.SirenState.on
        
        self.onlineSwitch.isEnabled = false
        self.onlineSwitch.isOn = pSensor.onlineState == Sensor.OnlineState.on
        
        self.onlineButton.isHidden = true
        self.onlineButton.isEnabled = false
        self.onlineButton.isChecked = pSensor.onlineState == Sensor.OnlineState.on
        
        if let aLightIntensity = pSensor.lightIntensity {
            self.lightValueLabel.text = String(format: ": %d", aLightIntensity)
        } else {
            self.lightValueLabel.text = ": NA"
        }
        
        if let aLastMotionDate = pSensor.lastMotionDate {
            let aDateFormatter = DateFormatter()
            aDateFormatter.dateFormat = "dd-MMM-yyyy 'at' hh:mm a"
            self.motionValueLabel.text = ": " + aDateFormatter.string(from: aLastMotionDate)
        } else {
            self.motionValueLabel.text = ": NA"
        }
        
        if let aTemperature = pSensor.temperature {
            self.temperatureValueLabel.text = String(format: ": %d °C", aTemperature)
        } else {
            self.temperatureValueLabel.text = ": NA"
        }
        
        if let aSmoke = pSensor.smoke {
            self.smokeValueLabel.text = String(format: ": %d ppm", aSmoke)
        } else {
            self.smokeValueLabel.text = ": NA"
        }
        
        if let aCo2 = pSensor.co2 {
            self.co2ValueLabel.text = String(format: ": %d ppm", aCo2)
        } else {
            self.co2ValueLabel.text = ": NA"
        }
        
        if let anLpg = pSensor.lpg {
            self.lpgValueLabel.text = String(format: ": %d ppm", anLpg)
        } else {
            self.lpgValueLabel.text = ": NA"
        }
        
        if pSensor.hardwareGeneration == Device.HardwareGeneration.deft {
            self.selectionStyle = .none
            self.disclosureIndicatorImageView.isHidden = true
            
            self.smokeContainerView.isHidden = true
            self.co2ContainerView.isHidden = true
            self.lpgContainerView.isHidden = true
            
            self.motionSwitchContainerView.isHidden = false
            self.lightSwitchContainerView.isHidden = true
            self.sirenSwitchContainerView.isHidden = true
            self.onlineSwitchContainerView.isHidden = true
            self.actionButtonContainerView.isHidden = true
        } else {
            self.selectionStyle = .default
            self.disclosureIndicatorImageView.isHidden = false
            self.syncButton.isHidden = false
            self.lblIntensity.text = "Light Intensity"
            self.lblTemperature.text = "Temperature"
            self.lblLastmotionOn.text = "Last Motion On"
            
            let result = pSensor.id!.starts(with: "P001")
            if result{
                self.lightContainerView.isHidden = false
                self.temperatureContainerView.isHidden = false
                self.motionContainerView.isHidden = false
                self.lightSwitchContainerView.isHidden = true
                self.sirenSwitchContainerView.isHidden = true
                self.motionSwitchContainerView.isHidden = true
                self.onlineSwitchContainerView.isHidden = true
                self.btnResetCount.isHidden = false
                self.smokeContainerView.isHidden = true
                self.co2ContainerView.isHidden = true
                self.lpgContainerView.isHidden = true
                if pSensor.controllerType == "Lidar Sensor"{
                    syncButton.isHidden = true
                  //  appNotificationButton.isHidden = true
                }
                self.lblIntensity.text = "Last Operation:"
                print(pSensor.lastOperationTime)
                if pSensor.lastOperation == "-1"{
                    self.lightValueLabel.text =  "OUT"
                }else{
                    self.lightValueLabel.text = "IN"
                }
                
                self.lblLastmotionOn.text = "Operation Time:"
                self.lblTemperature.text = "People Count"
                
                self.temperatureValueLabel.text = String(format: ": %d", pSensor.peopleCount!)
                if pSensor.lastOperationTime! != nil{
                    let day = timeDateComvetor(time: pSensor.lastOperationTime!)
                    self.motionValueLabel.text = day
                }
                if pSensor.uidAssign != true {
                    viewUidSatus.isHidden = false
                    self.textUidstatus.text = "Device installation not done. click fix now to complete installations."
                }
                
            }else{
                
                if pSensor.hardwareType == Device.HardwareType.smokeDetector ||  pSensor.hardwareType == Device.HardwareType.smokeDetectorBattery {
                    self.lightContainerView.isHidden = true
                    self.motionContainerView.isHidden = true
                    self.temperatureContainerView.isHidden = true
                    
                    self.smokeContainerView.isHidden = false
                    self.co2ContainerView.isHidden = false
                    self.lpgContainerView.isHidden = false
                    
                    self.motionSwitchContainerView.isHidden = true
                    self.lightSwitchContainerView.isHidden = true
                    self.sirenSwitchContainerView.isHidden = false
                    self.onlineSwitchContainerView.isHidden = true
                    self.actionButtonContainerView.isHidden = false
                    
                    if ((pSensor.id?.prefix(3)) == "S11"){
                        self.syncButton.isHidden = true
                        self.sirenSwitchContainerView.isHidden = true
                        self.lightContainerView.isHidden = false
                        self.temperatureContainerView.isHidden = false
                        self.motionContainerView.isHidden = false
                        self.smokeContainerView.isHidden = true
                        self.co2ContainerView.isHidden = true
                        self.lpgContainerView.isHidden = true
                        self.lblIntensity.text = "Battery Mode"
                        if pSensor.Batterysevermode != nil{
                            self.lightValueLabel.text = ":\(String(describing: pSensor.Batterysevermode ?? ""))"
                        }else{self.lightValueLabel.text = "NA"}
                        self.lblLastmotionOn.text = "Sensitivity"
                        self.motionValueLabel.text = ":\(pSensor.sensorSensitivity ?? "")"
                        self.lblTemperature.text = "Battery"
                        if (pSensor.sensorSensitivity != nil){
                            self.temperatureValueLabel.text = ":\(String(describing: pSensor.BatteryPercentage ?? "")) %"
                        }else{
                            self.temperatureValueLabel.text = "NA"
                        }
                    }
                } else {
                    if pSensor.hardwareType == Device.HardwareType.smartSecuritySensor {
                        self.lightContainerView.isHidden = true
                    } else {
                        self.lightContainerView.isHidden = false
                    }
                    self.motionContainerView.isHidden = false
                    self.temperatureContainerView.isHidden = false
                    
                    self.smokeContainerView.isHidden = true
                    self.co2ContainerView.isHidden = true
                    self.lpgContainerView.isHidden = true
                    
                    self.motionSwitchContainerView.isHidden = true
                    self.lightSwitchContainerView.isHidden = false
                    self.sirenSwitchContainerView.isHidden = false
                    self.onlineSwitchContainerView.isHidden = true
                    self.actionButtonContainerView.isHidden = false
                    if ((pSensor.id?.prefix(3)) == "S10"){  // battery smart sensor
                        self.smokeContainerView.isHidden = true
                        self.co2ContainerView.isHidden = true
                        self.lpgContainerView.isHidden = true
                        self.lightSwitchContainerView.isHidden = true
                        
                        self.syncButton.isHidden = true
                        self.sirenSwitchContainerView.isHidden = true
                        self.lightContainerView.isHidden = false
                        self.temperatureContainerView.isHidden = false
                        
                        self.lblIntensity.text = "Battery Mode"
                        if (pSensor.Batterysevermode != nil){
                            self.lightValueLabel.text = ":\(String(describing: pSensor.Batterysevermode ?? ""))"
                        }else{self.lightValueLabel.text = "NA"}
                        self.lblTemperature.text = "Battery"
                        if (pSensor.BatteryPercentage != nil){
                            self.temperatureValueLabel.text = ":\(String(describing: pSensor.BatteryPercentage ?? "")) %"
                        }else{ self.temperatureValueLabel.text = "NA"}
                    }
                }
            }
        }
    }
    
    @IBOutlet weak var viewCalibrate: UIView!
    @IBAction func funcCalibratebtn(_ sender: Any) {
        self.delegate?.cellView(self)
    }
    @IBOutlet weak var viewUidSatus: UIView!
    
    @IBOutlet weak var textUidstatus: UILabel!
    
    @IBAction func btnFixnowFunc(_ sender: Any) {
        let sensorvalue = ((sender as AnyObject).tag)!
        self.delegate?.cellViewDidSelectFixnow(sensorvalue)
    }
    @IBOutlet weak var lblLastmotionOn: UILabel!
    
    @IBAction func occupancySwitchDidChangeValue(_ pSender: AppSwitch) {
        self.delegate?.cellView(self, didChangeOccupancyState: self.wifinityOccupancySwitch.isOn ? Sensor.OccupancyState.armed : Sensor.OccupancyState.disarmed)
        
    }
    
    
    @IBAction func motionSwitchDidChangeValue(_ pSender: AppSwitch) {
        self.delegate?.cellView(self, didChangeMotionState: self.motionSwitch.isOn ? Sensor.MotionState.on : Sensor.MotionState.off)
    }
    
    
    @IBAction func lightSwitchDidChangeValue(_ pSender: AppSwitch) {
        self.delegate?.cellView(self, didChangeLightState: self.lightSwitch.isOn ? Sensor.LightState.on : Sensor.LightState.off)
    }
    
    
    @IBAction func sirenSwitchDidChangeValue(_ pSender: AppSwitch) {
        self.delegate?.cellView(self, didChangeSirenState: self.sirenSwitch.isOn ? Sensor.SirenState.on : Sensor.SirenState.off)
    }
    
    
    @IBAction func deftOccupancyButtonDidChangeValue(_ pSender: UIButton) {
        self.delegate?.cellView(self, didChangeOccupancyState: self.deftOccupancyButton.isChecked ? Sensor.OccupancyState.armed : Sensor.OccupancyState.disarmed)
    }
    
    
    @IBAction func didSelectSyncButton(_ pSender: UIButton) {
        self.delegate?.cellViewDidSelectSync(self)
    }
    
    @IBAction func didSelectAppNotificationButton(_ pSender: UIButton) {
        self.delegate?.cellViewDidSelectAppNotifications(self)
    }
    
    @IBAction func btnresetCountfun(_ sender: Any) {
        self.delegate?.cellViewResetCount(self)
    }
    
    @IBOutlet weak var lblIntensity: UILabel!
    
    @IBOutlet weak var lblTemperature: UILabel!
    
}



protocol SearchSensorTableCellViewDelegate :AnyObject {
    func cellView(_ pSender: SearchSensorTableCellView, didChangeOccupancyState pOccupancyState :Sensor.OccupancyState)
    func cellView(_ pSender: SearchSensorTableCellView, didChangeLightState pLightState :Sensor.LightState)
    func cellView(_ pSender: SearchSensorTableCellView, didChangeMotionState pMotionState :Sensor.MotionState)
    func cellView(_ pSender: SearchSensorTableCellView, didChangeSirenState pSirenState: Sensor.SirenState)
    func cellView(_ pSender: SearchSensorTableCellView)
    func cellViewDidSelectSync(_ pSender: SearchSensorTableCellView)
    func cellViewDidSelectAppNotifications(_ pSender: SearchSensorTableCellView)
    func cellViewDidSelectFixnow(_ pindex: Int)
    func cellViewResetCount(_ pSender: SearchSensorTableCellView)
}
