//
//  SensorDetailsController.swift
//  DEFT
//
//  Created by Rupendra on 10/10/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SensorDetailsController: BaseController {
    @IBOutlet weak var motionLightContainerView: UIView!
    @IBOutlet weak var motionLightSwitch: AppSwitch!
    @IBOutlet weak var motionLightTimeoutSlider: AppSlider!
    @IBOutlet weak var motionLightIntensityContainerView: UIView!
    @IBOutlet weak var motionLightIntensitySlider: AppSlider!
    
    @IBOutlet weak var sirenContainerView: UIView!
    @IBOutlet weak var sirenSliderContainerView: UIView!
    @IBOutlet weak var sirenSwitch: AppSwitch!
    @IBOutlet weak var sirenTimeoutSlider: AppSlider!
    
    @IBOutlet weak var smokeDetectorThresholdContainerView: UIView!
    @IBOutlet weak var smokeThresholdSlider: AppSlider!
    @IBOutlet weak var coThresholdSlider: AppSlider!
    @IBOutlet weak var lpgThresholdSlider: AppSlider!
    
    @IBOutlet weak var notificationContainerView: UIView!
    @IBOutlet weak var notificationSubscriptionSwitch: AppSwitch!
    @IBOutlet weak var notificationSoundSwitch: AppSwitch!
    
    var sliderTimer: Timer?
    
    var selectedSensor :Sensor?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "SENSOR DETAILS"
        self.subTitle = self.selectedSensor?.title
        
        self.motionLightContainerView.isHidden = true
        self.sirenContainerView.isHidden = true
        self.smokeDetectorThresholdContainerView.isHidden = true
        self.notificationContainerView.isHidden = true
    }
    
    
    override func reloadAllData() {
        if let aSensor = self.selectedSensor {
            // ProgressOverlay.shared.show()
            DataFetchManager.shared.sensorDetails(completion: { (pError, pSensor) in
                // ProgressOverlay.shared.hide()
                if pError != nil {
                    PopupManager.shared.displayError(message: "Can not fetch sensor details.", description: pError!.localizedDescription)
                } else {
                    self.selectedSensor = pSensor
                    self.reloadAllView()
                }
            }, sensor: aSensor)
        }
    }
    
    
    func reloadAllView() {
        if self.selectedSensor?.hardwareType == Device.HardwareType.smokeDetector {
            self.motionLightContainerView.isHidden = true
        } else {
            self.motionLightContainerView.isHidden = false
        }
        if self.selectedSensor?.hardwareType == Device.HardwareType.smartSecuritySensor {
            self.motionLightIntensityContainerView.isHidden = true
        } else {
            self.motionLightIntensityContainerView.isHidden = false
        }
        self.motionLightSwitch.isOn = self.selectedSensor?.lightSettingsState == Sensor.LightState.on
        self.motionLightTimeoutSlider.value = Float(self.selectedSensor?.motionLightTimeout ?? 0)
        self.motionLightIntensitySlider.value = Float(self.selectedSensor?.motionLightIntensity ?? 0)
        if self.selectedSensor?.lightState == Sensor.LightState.on {
            self.motionLightTimeoutSlider.isEnabled = true
            self.motionLightIntensitySlider.isEnabled = true
        } else {
            self.motionLightTimeoutSlider.isEnabled = false
            self.motionLightIntensitySlider.isEnabled = false
        }
        
        self.sirenContainerView.isHidden = false
        if self.selectedSensor?.hardwareType == Device.HardwareType.smokeDetector {
            self.sirenSliderContainerView.isHidden = true
        } else {
            self.sirenSliderContainerView.isHidden = false
        }
        self.sirenSwitch.isOn = self.selectedSensor?.sirenSettingsState == Sensor.SirenState.on
        self.sirenTimeoutSlider.value = Float(self.selectedSensor?.sirenTimeout ?? 0)
        if self.selectedSensor?.sirenSettingsState == Sensor.SirenState.on {
            self.sirenTimeoutSlider.isEnabled = true
        } else {
            self.sirenTimeoutSlider.isEnabled = false
        }
        
        if self.selectedSensor?.hardwareType == Device.HardwareType.smartSensor {
            self.smokeDetectorThresholdContainerView.isHidden = true
        } else if self.selectedSensor?.hardwareType == Device.HardwareType.smokeDetector {
            self.smokeDetectorThresholdContainerView.isHidden = false
        }
        
        self.smokeThresholdSlider.value = Float(self.selectedSensor?.smokeThreshold ?? 0)
        self.coThresholdSlider.value = Float(self.selectedSensor?.co2Threshold ?? 0)
        self.lpgThresholdSlider.value = Float(self.selectedSensor?.lpgThreshold ?? 0)
        
        if self.selectedSensor?.hardwareGeneration == .wifinity {
            self.notificationContainerView.isHidden = false
        } else {
            self.notificationContainerView.isHidden = true
        }
        if self.selectedSensor?.notificationSettingsState == true {
            self.notificationSoundSwitch.isEnabled = true
        } else {
            self.notificationSoundSwitch.isEnabled = false
        }
        self.notificationSubscriptionSwitch.isOn = self.selectedSensor?.notificationSettingsState ?? false
        self.notificationSoundSwitch.isOn = self.selectedSensor?.notificationSoundState ?? false
    }
    
    
    func updateSensorMotionLightState(sensor pSensor :Sensor, lightState pLightState :Sensor.LightState) {
        let aSensor = pSensor.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateSensorMotionLightState(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update sensor.", description: pError!.localizedDescription)
            } else {
                self.selectedSensor?.lightSettingsState = pLightState
                self.reloadAllView()
            }
        }, sensor: aSensor, motionLightState: pLightState, isSettings: true)
    }
    
    
    func updateSensorMotionLightTimeout(sensor pSensor :Sensor, motionLightTimeout pMotionLightTimeout :Int) {
        let aSensor = pSensor.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateSensorMotionLightTimeout(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update sensor.", description: pError!.localizedDescription)
            } else {
                pSensor.motionLightTimeout = pMotionLightTimeout
                self.reloadAllView()
            }
        }, sensor: aSensor, motionLightTimeout: pMotionLightTimeout)
    }
    
    
    func updateSensorMotionLightIntensity(sensor pSensor :Sensor, motionLightIntensity pMotionLightIntensity :Int) {
        let aSensor = pSensor.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateSensorMotionLightIntensity(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update sensor.", description: pError!.localizedDescription)
            } else {
                pSensor.motionLightIntensity = pMotionLightIntensity
                self.reloadAllView()
            }
        }, sensor: aSensor, motionLightIntensity: pMotionLightIntensity)
    }
    
    
    func updateSensorSirenSettingsState(sensor pSensor :Sensor, sirenState pSirenState :Sensor.SirenState) {
        let aSensor = pSensor.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateSensorSirenSettingsState(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update sensor.", description: pError!.localizedDescription)
            } else {
                self.selectedSensor?.sirenSettingsState = pSirenState
                self.reloadAllView()
            }
        }, sensor: aSensor, sirenState: pSirenState)
    }
    
    
    func updateSensorSirenTimeout(sensor pSensor :Sensor, sirenTimeout pSirenTimeout :Int) {
        let aSensor = pSensor.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateSensorSirenTimeout(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update sensor.", description: pError!.localizedDescription)
            } else {
                pSensor.sirenTimeout = pSirenTimeout
                self.reloadAllView()
            }
        }, sensor: aSensor, sirenTimeout: pSirenTimeout)
    }
    
    
    func updateSensorThreshold(sensor pSensor :Sensor, smokeThreshold pSmokeThreshold :Int, coThreshold pCoThreshold :Int, lpgThreshold pLpgThreshold :Int) {
        let aSensor = pSensor.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateSensorThreshold(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update sensor.", description: pError!.localizedDescription)
            } else {
                pSensor.smokeThreshold = pSmokeThreshold
                pSensor.co2Threshold = pCoThreshold
                pSensor.lpgThreshold = pLpgThreshold
                self.reloadAllView()
            }
        }, sensor: aSensor, smokeThreshold: pSmokeThreshold, coThreshold: pCoThreshold, lpgThreshold: pLpgThreshold)
    }
    
    
    func updateSensorNotificationSettings(sensor pSensor :Sensor, notificationSettingsState pNotificationSettingsState :Bool, notificationSoundState pNotificationSoundState :Bool) {
        let aSensor = pSensor.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateSensorNotificationSettings(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update sensor.", description: pError!.localizedDescription)
            } else {
                pSensor.notificationSettingsState = pNotificationSettingsState
                pSensor.notificationSoundState = pNotificationSoundState
                self.reloadAllView()
            }
        }, sensor: aSensor, fcmToken: CacheManager.shared.fcmToken, notificationSubscriptionState: pNotificationSettingsState, notificationSoundState: pNotificationSoundState)
    }
    
}



extension SensorDetailsController {
    
    @IBAction func motionLightSwitchDidChangeValue(_ pSender: UISwitch) {
        if let aSensor = self.selectedSensor {
            self.updateSensorMotionLightState(sensor: aSensor, lightState: pSender.isOn ? Sensor.LightState.on : Sensor.LightState.off)
        }
    }
    
    
    @IBAction func motionLightTimeoutSliderDidChangeValue(_ pSender: UISlider) {
        let aRoundedValue = round(pSender.value / 1) * 1
        pSender.value = aRoundedValue
        
        self.sliderTimer?.invalidate()
        self.sliderTimer = nil
        self.sliderTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block: { (pTimer) in
            if let aSensor = self.selectedSensor {
                self.updateSensorMotionLightTimeout(sensor: aSensor, motionLightTimeout: Int(pSender.value))
            }
        })
    }
    
    
    @IBAction func motionLightIntensitySliderDidChangeValue(_ pSender: UISlider) {
        let aRoundedValue = round(pSender.value / 1) * 1
        pSender.value = aRoundedValue
        
        self.sliderTimer?.invalidate()
        self.sliderTimer = nil
        self.sliderTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block: { (pTimer) in
            if let aSensor = self.selectedSensor {
                self.updateSensorMotionLightIntensity(sensor: aSensor, motionLightIntensity: Int(pSender.value))
            }
        })
    }
    
    
    @IBAction func sirenSwitchDidChangeValue(_ pSender: UISwitch) {
        if let aSensor = self.selectedSensor {
            self.updateSensorSirenSettingsState(sensor: aSensor, sirenState: pSender.isOn ? Sensor.SirenState.on : Sensor.SirenState.off)
        }
    }
    
    
    @IBAction func sirenTimeoutSliderDidChangeValue(_ pSender: UISlider) {
        let aRoundedValue = round(pSender.value / 1) * 1
        pSender.value = aRoundedValue
        
        self.sliderTimer?.invalidate()
        self.sliderTimer = nil
        self.sliderTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block: { (pTimer) in
            if let aSensor = self.selectedSensor {
                self.updateSensorSirenTimeout(sensor: aSensor, sirenTimeout: Int(pSender.value))
            }
        })
    }
    
    
    @IBAction func smokeThresholdSliderDidChangeValue(_ pSender: UISlider) {
        let aRoundedValue = round(pSender.value / 1) * 1
        pSender.value = aRoundedValue
        
        self.sliderTimer?.invalidate()
        self.sliderTimer = nil
        self.sliderTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block: { (pTimer) in
            if let aSensor = self.selectedSensor {
                self.updateSensorThreshold(sensor: aSensor, smokeThreshold: Int(pSender.value), coThreshold: aSensor.co2Threshold ?? 0, lpgThreshold: aSensor.lpgThreshold ?? 0)
            }
        })
    }
    
    
    @IBAction func coThresholdSliderDidChangeValue(_ pSender: UISlider) {
        let aRoundedValue = round(pSender.value / 1) * 1
        pSender.value = aRoundedValue
        
        self.sliderTimer?.invalidate()
        self.sliderTimer = nil
        self.sliderTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block: { (pTimer) in
            if let aSensor = self.selectedSensor {
                self.updateSensorThreshold(sensor: aSensor, smokeThreshold: aSensor.smokeThreshold ?? 0, coThreshold: Int(pSender.value), lpgThreshold: aSensor.lpgThreshold ?? 0)
            }
        })
    }
    
    
    @IBAction func lpgThresholdSliderDidChangeValue(_ pSender: UISlider) {
        let aRoundedValue = round(pSender.value / 1) * 1
        pSender.value = aRoundedValue
        
        self.sliderTimer?.invalidate()
        self.sliderTimer = nil
        self.sliderTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block: { (pTimer) in
            if let aSensor = self.selectedSensor {
                self.updateSensorThreshold(sensor: aSensor, smokeThreshold: aSensor.smokeThreshold ?? 0, coThreshold: aSensor.co2Threshold ?? 0, lpgThreshold: Int(pSender.value))
            }
        })
    }
    
    
    @IBAction func notificationSubscriptionSwitchDidChangeValue(_ pSender: UISwitch) {
        if let aSensor = self.selectedSensor {
            self.updateSensorNotificationSettings(sensor: aSensor, notificationSettingsState: self.notificationSubscriptionSwitch.isOn, notificationSoundState: self.notificationSoundSwitch.isOn)
        }
    }
    
    
    @IBAction func notificationSoundSwitchDidChangeValue(_ pSender: UISwitch) {
        if let aSensor = self.selectedSensor {
            self.updateSensorNotificationSettings(sensor: aSensor, notificationSettingsState: self.notificationSubscriptionSwitch.isOn, notificationSoundState: self.notificationSoundSwitch.isOn)
        }
    }
    
}
