//
//  NewApplianceController.swift
//  Wifinity
//
//  Created by Rupendra on 17/01/21.
//

import UIKit


class NewApplianceController: BaseController {
    @IBOutlet weak var applianceDeviceTextField: UITextField!
    @IBOutlet weak var applianceNameTextField: UITextField!
    @IBOutlet weak var applianceTypeTextField: UITextField!
    
    @IBOutlet weak var dimTypeLabel: UILabel!
    @IBOutlet weak var dimTypeTextField: UITextField!
    @IBOutlet weak var dimmableValueMinLabel: UILabel!
    @IBOutlet weak var dimmableValueMinSlider: AppSlider!
    @IBOutlet weak var dimmableValueMaxLabel: UILabel!
    @IBOutlet weak var dimmableValueMaxSlider: AppSlider!
    
    @IBOutlet weak var dimableValueMaxView: UIView!
    @IBOutlet weak var lblDeletebtn: UIButton!
    
    var room :Room?
    
    var appliance :Appliance?
    var delegate: SelectedAppliandesDelegate?
    
    var editedApplianceDevice :Device?
    var editedApplianceName :String?
    var editedApplianceType :Appliance.ApplianceType?
    var editedApplianceLedStripType :Appliance.StripType?
    var editedDimType :Appliance.DimType = Appliance.DimType.none
    var editedDimmableValueMin :Int?
    var editedDimmableValueMax :Int?
    var editedDimmableValueMaxvalue :Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.appliance != nil {
            self.title = "APPLIANCE DETAILS"
            self.subTitle = self.appliance?.title
             lblDeletebtn.isHidden = false
            if self.appliance?.dimType == .triac {
                
            }
        } else {
            self.title = "NEW APPLIANCE"
            self.subTitle = self.room?.title
            lblDeletebtn.isHidden = true
         }

        self.applianceNameTextField.addTarget(self, action: #selector(self.applianceNameTextFieldDidChangeValue(_:)), for: UIControl.Event.editingChanged)
        self.applianceDeviceTextField.delegate = self
        self.applianceNameTextField.delegate = self
        self.applianceTypeTextField.delegate = self
        self.dimTypeTextField.delegate = self
        
        self.dimmableValueMinSlider.minimumTrackTintColor = UIColor(named: "ControlCheckedColor")
        self.dimmableValueMinSlider.maximumTrackTintColor = UIColor(named: "ControlNormalColor")
        
        self.dimmableValueMaxSlider.minimumTrackTintColor = UIColor(named: "ControlCheckedColor")
        self.dimmableValueMaxSlider.maximumTrackTintColor = UIColor(named: "ControlNormalColor")
        
        if let anAppliance = self.appliance {
            let aDevice = Device()
            aDevice.id = anAppliance.hardwareId
            self.editedApplianceDevice = aDevice
            
            self.editedApplianceName = anAppliance.title
            
            self.editedApplianceType = anAppliance.type
            
            self.editedApplianceLedStripType = anAppliance.stripType

            if anAppliance.isDimmable {
                self.editedDimType = anAppliance.dimType ?? Appliance.DimType.none
            } else {
                self.editedDimType = Appliance.DimType.none
            }
            
            self.editedDimmableValueMin = anAppliance.dimmableValueMin
            self.editedDimmableValueMaxvalue = anAppliance.dimmableValueMax
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        dimableValueMaxView.isHidden = true
        if  editedDimType != nil {
            
            if editedDimType == .triac {
                // maxdiming hidden
                dimableValueMaxView.isHidden = false
            } else{
            dimableValueMaxView.isHidden = true
            }
        }else  if let anAppliance = self.appliance {
            if let x = anAppliance.dimType{
                if x == .triac {
                    // Maxdiming hidden
                   dimableValueMaxView.isHidden = false

                }
                else{
                    dimableValueMaxView.isHidden = true
                }
            }
        }
            
      
    }
    override func reloadAllData() {
        self.reloadAllView()
    }
    
    
    func reloadAllView() {
        var anApplianceDeviceTitle :String?
        if let aTitle = self.editedApplianceDevice?.title {
            anApplianceDeviceTitle = aTitle + " (" + (self.editedApplianceDevice?.id ?? "") + ")"
        } else {
            anApplianceDeviceTitle = self.editedApplianceDevice?.id
        }
        self.applianceDeviceTextField.text = anApplianceDeviceTitle
        
        self.applianceNameTextField.text = self.editedApplianceName
        
        if let anApplianceTypeTitle = self.editedApplianceType?.title {
            var aTitle = anApplianceTypeTitle
            if let aStripTypeTitle = self.editedApplianceLedStripType?.title {
                aTitle += " (" + aStripTypeTitle + ")"
            }
            self.applianceTypeTextField.text = aTitle
        } else {
            self.applianceTypeTextField.text = nil
        }
        
        var anIsDimAvailable = true
        var aHardwareType = self.editedApplianceDevice?.hardwareType
        if aHardwareType == nil, let aHardwareId = self.appliance?.hardwareId, let aType = Device.getHardwareType(id: aHardwareId) {
            aHardwareType = aType
        }
        switch aHardwareType {
        case .clOneSwitch:
            anIsDimAvailable = false
        default:
            anIsDimAvailable = true
        }
        
        
        if anIsDimAvailable == true {
            self.dimTypeLabel.textColor = UIColor(named: "SecondaryDarkestColor")
            self.dimTypeTextField.isEnabled = true
            self.dimTypeTextField.textColor = UIColor(named: "SecondaryDarkestColor")
            self.dimTypeTextField.text = self.editedDimType.title
        } else {
            self.editedDimType = Appliance.DimType.none
            
            self.dimTypeLabel.textColor = UIColor(named: "ControlDisabledColor")
            self.dimTypeTextField.isEnabled = false
            self.dimTypeTextField.textColor = UIColor(named: "ControlDisabledColor")
            self.dimTypeTextField.text = self.editedDimType.title
        }
        
        switch self.editedDimType {
        case .rc:
            self.dimmableValueMinLabel.textColor = UIColor(named: "SecondaryDarkestColor")
            self.dimmableValueMinSlider.isEnabled = true
            self.dimmableValueMinSlider.minimumValue = 1
            self.dimmableValueMinSlider.maximumValue = 5
            self.dimmableValueMinSlider.value = Float(self.editedDimmableValueMin ?? 1)
        case .triac:
            self.dimmableValueMinLabel.textColor = UIColor(named: "SecondaryDarkestColor")
            self.dimmableValueMinSlider.isEnabled = true
            self.dimmableValueMinSlider.minimumValue = 10
            self.dimmableValueMinSlider.maximumValue = 99
            self.dimmableValueMinSlider.value = Float(self.editedDimmableValueMin ?? 10)
            self.dimmableValueMaxLabel.textColor = UIColor(named: "SecondaryDarkestColor")
            self.dimmableValueMaxSlider.isEnabled = true
            self.dimmableValueMaxSlider.minimumValue = 10
            self.dimmableValueMaxSlider.maximumValue = 99
            self.dimmableValueMaxSlider.value = Float(self.editedDimmableValueMaxvalue ?? 99)
            
        case .none:
            self.dimmableValueMinLabel.textColor = UIColor(named: "ControlDisabledColor")
            self.dimmableValueMinSlider.isEnabled = false
            self.dimmableValueMinSlider.minimumValue = 0
            self.dimmableValueMinSlider.maximumValue = 1
            self.dimmableValueMinSlider.value = 0
        }
    }
    
    
    func gotoSelectApplianceType() {
        RoutingManager.shared.gotoSelectApplianceType(controller: self, delegate: self)
    }
    
    
    func gotoSelectDimType() {
        RoutingManager.shared.gotoSelectDimType(controller: self, delegate: self, hardwareType: self.editedApplianceDevice?.hardwareType)
    }
    
    
    func gotoSelectDevice() {
        #if APP_WIFINITY
        RoutingManager.shared.gotoSelectDevice(controller: self, delegate: self, room: self.room, hardwareTypes: [Device.HardwareType.oneSwitch, Device.HardwareType.twoSwitch, Device.HardwareType.threeSwitch, Device.HardwareType.fourSwitch, Device.HardwareType.fiveSwitch, Device.HardwareType.sixSwitch, Device.HardwareType.sevenSwitch, Device.HardwareType.eightSwitch, Device.HardwareType.nineSwitch, Device.HardwareType.tenSwitch, Device.HardwareType.ctOneSwitch, Device.HardwareType.ctTwoSwitch, Device.HardwareType.ctThreeSwitch, Device.HardwareType.ctFourSwitch, Device.HardwareType.ctFiveSwitch, Device.HardwareType.ctSixSwitch, Device.HardwareType.ctSevenSwitch, Device.HardwareType.ctEightSwitch, Device.HardwareType.ctNineSwitch, Device.HardwareType.ctTenSwitch, Device.HardwareType.ctNineSwitch, Device.HardwareType.clOneSwitch,Device.HardwareType.CSoneSwitch, Device.HardwareType.CStwoSwitch, Device.HardwareType.CSthreeSwitch, Device.HardwareType.CSfourSwitch, Device.HardwareType.CSfiveSwitch, Device.HardwareType.CSsixSwitch, Device.HardwareType.CSsevenSwitch, Device.HardwareType.CSeightSwitch, Device.HardwareType.CSnineSwitch, Device.HardwareType.CStenSwitch],
            shouldCheckForAddedApplianceCount: true)
        #endif
    }
    
    
    func saveAppliance(appliance pAppliance :Appliance) {
        let anAppliance = pAppliance.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.saveAppliance(completion: { (pError, pAppliance) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not save appliance.", description: pError!.localizedDescription)
            } else {
                anAppliance.id = pAppliance?.id
                self.appliance = anAppliance
                self.reloadAllView()
                PopupManager.shared.displaySuccess(message: "Appliance saved successfully.", description: nil, completion: {
                    self.delegate?.didtappedDonebtn()
                 })
            }
        }, appliance: anAppliance)
    }
    
    
    func saveAppliance() {
        do {
            let aDevice = self.editedApplianceDevice
            if aDevice == nil {
                throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Please provide device / hardware."])
            }
            
            let aTitle = self.applianceNameTextField.text
            if (aTitle?.count ?? 0) <= 0 {
                throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Please provide appliance name."])
            }
            
            let anApplianceType = self.editedApplianceType
            if anApplianceType == nil {
                throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Please provide appliance type."])
            }
            
            let anApplianceLedStripType = self.editedApplianceLedStripType
            
            let aDimType = self.editedDimType
            
            let aMinDimValue = self.editedDimmableValueMin
            
            let anAppliance = self.appliance?.clone() ?? Appliance()
            anAppliance.hardwareId = aDevice?.id
            anAppliance.roomId = self.room?.id ?? self.appliance?.roomId
            anAppliance.roomTitle = self.room?.title ?? self.appliance?.roomTitle
            anAppliance.title = aTitle
            anAppliance.type = anApplianceType
            anAppliance.stripType = anApplianceLedStripType
            if aDimType != Appliance.DimType.none {
                anAppliance.isDimmable = true
                anAppliance.dimType = aDimType
            } else {
                anAppliance.isDimmable = false
                anAppliance.dimType = nil
            }
            anAppliance.dimmableValueMin = aMinDimValue
            
            if anAppliance.dimType == Appliance.DimType.rc {
                anAppliance.dimmableValueMax = 5
            } else if anAppliance.dimType == Appliance.DimType.triac {
                anAppliance.dimmableValueMax = self.editedDimmableValueMax ?? 99
            } else {
                anAppliance.dimmableValueMin = nil
                anAppliance.dimmableValueMax = nil
            }
            self.saveAppliance(appliance: anAppliance)
        } catch {
            PopupManager.shared.displayError(message: error.localizedDescription, description: nil)
        }
    }
    
    @IBAction func didtappedDeletebtn(_ sender: Any) {
        let x = appliance?.clone() ?? Appliance()
         delegate?.didtappedBacktoController(obj: x as Any)
    }
    
}



extension NewApplianceController {
    
    @IBAction func didSelectDoneButton(_ pSender: UIButton?) {
        self.saveAppliance()
    }
    
    
    @IBAction func sliderDidChangeValue(_ pSender: UISlider) {
        let aRoundedValue = round(pSender.value / 1) * 1
        pSender.value = aRoundedValue
        self.editedDimmableValueMin = Int(pSender.value)
        self.dimmableValueMaxSlider.minimumValue = Float(Int(pSender.value) + 5)
        
    }
    @IBAction func sliderMaxDidChangeValue(_ pSender: UISlider) {
        let aRoundedValue = round(pSender.value / 1) * 1
        pSender.value = aRoundedValue
        self.editedDimmableValueMax = Int(pSender.value)
    }
}


extension NewApplianceController :UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ pTextField: UITextField) -> Bool {
        var aReturnVal = true
        
        if pTextField.isEqual(self.applianceDeviceTextField) {
            self.gotoSelectDevice()
            aReturnVal = false
        } else if pTextField.isEqual(self.applianceTypeTextField) {
            self.gotoSelectApplianceType()
            aReturnVal = false
        } else if pTextField.isEqual(self.dimTypeTextField) {
            self.gotoSelectDimType()
            aReturnVal = false
        }
        
        return aReturnVal
    }
    
    func textFieldShouldReturn(_ pTextField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
    
    @objc func applianceNameTextFieldDidChangeValue(_ pSender :UITextField) {
        self.editedApplianceName = self.applianceNameTextField.text
    }
    
}



#if APP_WIFINITY
extension NewApplianceController :SelectDeviceControllerDelegate {
    
    func selectDeviceControllerDidSelect(_ pSender: SelectDeviceController, device pDevice: Device) {
        RoutingManager.shared.goBackToController(self)
        self.editedApplianceDevice = pDevice
        self.reloadAllView()
    }
    
}
#endif



extension NewApplianceController :SelectApplianceTypeControllerDelegate {
    
    func selectApplianceTypeControllerDidSelect(_ pSender: SelectApplianceTypeController, applianceType pApplianceType: Appliance.ApplianceType, stripType pStripType: Appliance.StripType?) {
        RoutingManager.shared.goBackToController(self)
        self.editedApplianceType = pApplianceType
        self.editedApplianceLedStripType = pStripType
        self.reloadAllView()
    }
    
}



extension NewApplianceController :SelectDimTypeControllerDelegate {
    
    func selectDimTypeControllerDidSelect(_ pSender: SelectDimTypeController, dimType pDimType: Appliance.DimType) {
        RoutingManager.shared.goBackToController(self)
        self.editedDimType = pDimType
        self.reloadAllView()
    }
    
}
