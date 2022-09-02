//
//  OfflineApplinceViewController.swift
//  Wifinity
//
//  Created by Apple on 01/09/22.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import Firebase

protocol SearchAppliancesTableCellViewDelegate :AnyObject {
    func cellView(_ pSender: applincessCell, didChangePowerState pPowerState :Bool)
    func cellView(_ pSender: applincessCell, didChangeDimmableValue pDimmableValue :Int)
}

class applincessCell: UITableViewCell{
    var delegate: SearchAppliancesTableCellViewDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        isOnlineCell.layer.cornerRadius = 5
        isOnlineCell.layer.masksToBounds = true
        lblImgBackground.layer.cornerRadius = 38
        lblImgBackground.layer.masksToBounds = true
        LblSlider.isHidden = true
        backgroundeffectiveView.layer.cornerRadius = 20
        backgroundeffectiveView.layer.masksToBounds = false
        
        backgroundeffectiveView.dropShadow(color: .gray, opacity: 1, offSet: CGSize(width: 1, height: 1), radius: 5, scale: true)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func loaddata(pApplince: Appliance) {
        self.appliance = pApplince
        if pApplince.isOnline == true{
            isOnlineCell.backgroundColor = .green
            // dimable value
        }else{
            isOnlineCell.backgroundColor = .red
        }
      
        if pApplince.isOn == true{
            btnSwitch.isOn = true
            LblSlider.value = Float(pApplince.dimmableValue!)

        }else{

            btnSwitch.isOn = false
        }
        if pApplince.type != Appliance.ApplianceType.ledStrip {
            if pApplince.isOn && pApplince.isDimmable {
                LblSlider.isHidden = false
            }else{
                LblSlider.isHidden = true
            }
        }


        lblApplinceName.text = pApplince.title
        lblRoomName.text = pApplince.roomTitle
    }
    var appliance: Appliance?
    var sliderTimer: Timer?
    @IBAction func didselectSlidervalue(_ sender: UISlider) {
        
        let aRoundedValue = round(sender.value / 1) * 1
        sender.value = aRoundedValue
        self.sliderTimer?.invalidate()
        self.sliderTimer = nil
        
        self.sliderTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false, block: { (pTimer) in
            let aSliderValue = Int(self.LblSlider?.value ?? 0)
            print("Slider Value = \(aSliderValue)")
            if let anAppliance = self.appliance {
                
                let aDimmableValue :Int = UtilityManager.dimmableValueFromSliderValue(appliance: anAppliance, sliderValue: aSliderValue)
                print(aDimmableValue)
                self.delegate?.cellView(self, didChangeDimmableValue: aDimmableValue)
            }
        })
    }
    
    @IBAction func didselectSwithBtn(_ sender: Any) {
        delegate?.cellView(self, didChangePowerState: btnSwitch.isOn)
    }
    @IBOutlet weak var backgroundeffectiveView: UIView!
    @IBOutlet weak var imageviewApplince: UIImageView!
    @IBOutlet weak var lblApplinceName: UILabel! //
    @IBOutlet weak var lblRoomName: UILabel! //
    @IBOutlet weak var btnSwitch: UISwitch! //
    @IBOutlet weak var LblSlider: UISlider!
    @IBOutlet weak var lblImgBackground: UILabel!
    @IBOutlet weak var isOnlineCell: UILabel! //
}
class OfflineApplinceViewController: UIViewController {
    var Applinces = [Appliance]()
    var controller_id = [String]()
    @IBOutlet weak var lblbackbtn: UIButton!
    @IBOutlet weak var ApplincesTableview: UITableView!
    var database :DatabaseReference?
    var devicearray = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.database = Database.database().reference()
        ApplincesTableview.delegate = self
        ApplincesTableview.dataSource = self
        ApplincesTableview.estimatedRowHeight = 75.0
        ApplincesTableview.rowHeight = UITableView.automaticDimension
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblbackbtn.setTitle("", for: .normal)
        
       // for item in controller_id {
        getofflineMode(controller_id: "CS091651819470701")
      //  }
     
    }
    func getofflineMode(controller_id: String){
        let scoresRef = Database.database().reference(withPath: "applianceDetails/\(controller_id)") //CS091651819470701
        
        scoresRef.queryOrderedByValue().queryLimited(toLast: 10).observe(.childAdded) { snapshot in
          print("The \(snapshot.key) dinosaur's score is \(snapshot.value ?? "null")")
            let aDict = snapshot.value as? Dictionary<String,Any>
            
                if let anApplianceDict = aDict, let anAppliance = OfflineApplinceViewController.appliance(dict: anApplianceDict) {
                    self.Applinces.append(anAppliance)
                }
         
            self.ApplincesTableview.reloadData()

        }
    }
    
    private static func appliance(dict pDict :Dictionary<String,Any>) -> Appliance? {
        var aReturnVal :Appliance? = nil
        
        if let aName = pDict["applianceName"] as? String
           , aName.count > 0 {
            let anAppliance = Appliance()
            anAppliance.id = pDict["id"] as? String
            anAppliance.title = (pDict["applianceName"] as? String)?.capitalized
            if let anApplianceTypeId = pDict["applianceTypeId"] as? String {
                anAppliance.type = Appliance.ApplianceType(rawValue: anApplianceTypeId)
            }
            
            anAppliance.roomId = pDict["roomId"] as? String
            anAppliance.roomTitle = pDict["roomName"] as? String
            
            anAppliance.slaveId = pDict["slaveId"] as? String
            anAppliance.hardwareId = pDict["hardwareId"] as? String
            
            if let aState = pDict["state"] as? Int, aState == 1 {
                anAppliance.isOn = true
            } else if let aState = pDict["state"] as? String, aState == "1" {
                anAppliance.isOn = true
            }
            
            anAppliance.isOnline = pDict["status"] as? Bool == true
            
            anAppliance.operatedCount = pDict["applianceOperatedCount"] as? Int
            
            if let anIsDimmable = pDict["dimmable"] as? String, anIsDimmable == "1" {
                anAppliance.isDimmable = true
            } else if let anIsDimmable = pDict["dimmable"] as? Int, anIsDimmable == 1 {
                anAppliance.isDimmable = true
            }
            if let aDimType = pDict["dimType"] as? String {
                anAppliance.dimType = Appliance.DimType(rawValue: aDimType)
            }
            if let aValue = pDict["dimableValue"] as? String {
                anAppliance.dimmableValue = Int(aValue)
            } else if let aValue = pDict["dimableValue"] as? Int {
                anAppliance.dimmableValue = aValue
            }
            if let aValue = pDict["triacDimableValue"] as? String {
                anAppliance.dimmableValueTriac = Int(aValue)
            } else if let aValue = pDict["triacDimableValue"] as? Int {
                anAppliance.dimmableValueTriac = aValue
            }
            if let aValue = pDict["minDimming"] as? String {
                anAppliance.dimmableValueMin = Int(aValue)
            } else if let aValue = pDict["minDimming"] as? Int {
                anAppliance.dimmableValueMin = aValue
            }
            if let aValue = pDict["maxDimming"] as? String {
                anAppliance.dimmableValueMax = Int(aValue)
            } else if let aValue = pDict["maxDimming"] as? Int {
                anAppliance.dimmableValueMax = aValue
            }
            
            if let aStripType = pDict["stripType"] as? String {
                anAppliance.stripType = Appliance.StripType(rawValue: aStripType)
            }
            
            if let aValue = pDict["property1"] as? String {
                anAppliance.ledStripProperty1 = Int(aValue)
            } else if let aValue = pDict["property1"] as? Int {
                anAppliance.ledStripProperty1 = aValue
            }
            if let aValue = pDict["property2"] as? String {
                anAppliance.ledStripProperty2 = Int(aValue)
            } else if let aValue = pDict["property2"] as? Int {
                anAppliance.ledStripProperty2 = aValue
            }
            if let aValue = pDict["property3"] as? String {
                anAppliance.ledStripProperty3 = Int(aValue)
            } else if let aValue = pDict["property3"] as? Int {
                anAppliance.ledStripProperty3 = aValue
            }
            
            aReturnVal = anAppliance
        }
        
        return aReturnVal
    }
    
    
    @IBAction func didselectBackbtn(_ sender: Any) {
        
        RoutingManager.shared.goToPreviousScreen(self)
    }
     
    @IBAction func didtappedGoodbye(_ sender: Any) {
        for Applince in Applinces {
            print(Applince)
            updateAppliancePowerState(appliance: Applince, powerState: false)
        }
    }
}

extension OfflineApplinceViewController: SearchAppliancesTableCellViewDelegate{
    func cellView(_ pSender: applincessCell, didChangePowerState pPowerState: Bool) {
         if let anIndexPath = self.ApplincesTableview.indexPath(for: pSender), anIndexPath.row < self.Applinces.count {
            print(anIndexPath.row)
            let anAppliance = self.Applinces[anIndexPath.row]
            self.updateAppliancePowerState(appliance: anAppliance, powerState: pPowerState)
        }
    }
    
    func cellView(_ pSender: applincessCell, didChangeDimmableValue pDimmableValue: Int) {
        if let anIndexPath = self.ApplincesTableview.indexPath(for: pSender), anIndexPath.row < self.Applinces.count {
            let anAppliance = self.Applinces[anIndexPath.row]
            self.updateApplianceDimmableValue(appliance: anAppliance, dimmableValue: pDimmableValue)
        }
    }
    func updateApplianceDimmableValue(appliance pAppliance :Appliance, dimmableValue pDimmableValue :Int) {
        let anAppliance = pAppliance.clone()
        
        //   ProgressOverlay.shared.show()
        DataFetchManager.shared.updateApplianceDimmableValue(completion: { (pError) in
            //     ProgressOverlay.shared.hide()
            if pError != nil {
                //  PopupManager.shared.displayError(message: "Can not update appliance.", description: pError!.localizedDescription)
            } else {
                if pAppliance.dimType == Appliance.DimType.rc {
                    pAppliance.dimmableValue = pDimmableValue
                } else if pAppliance.dimType == Appliance.DimType.triac {
                    pAppliance.dimmableValueTriac = pDimmableValue
                } else {
                    pAppliance.dimmableValue = pDimmableValue
                }
                
                // self.reloadAllView()
            }
        }, appliance: anAppliance, dimValue: pDimmableValue)
    }
    
    func updateAppliancePowerState(appliance pAppliance :Appliance, powerState pPowerState :Bool) {
        let anAppliance = pAppliance
        var aDimValue = 0
        var aNodeId :String? = nil
        if pAppliance.dimType == Appliance.DimType.rc {
            aDimValue = pAppliance.dimmableValue ?? 5
        } else if pAppliance.dimType == Appliance.DimType.triac {
            aDimValue = pAppliance.dimmableValueTriac ?? 99
        }
        if let anAppliance = pAppliance as? Appliance {
            aNodeId = anAppliance.hardwareId
        }
        
        let aMessageValue = Appliance.command(appliance: pAppliance, powerState: pPowerState, dimValue: aDimValue)
        
        var aMessageField :DatabaseReference? = nil
        aMessageField = self.database!
            .child("messages")
            .child(aNodeId!)
            .child("applianceData")
            .child("message")
        
        
        // Send message
        var aSetMessageError :Error? = nil
        let aMessageDispatchSemaphore = DispatchSemaphore(value: 0)
        aMessageField?.setValue(aMessageValue, withCompletionBlock: { (pError, pDatabaseReference) in
            aSetMessageError = pError
            //  aMessageDispatchSemaphore.signal()
        })
        // _ = aMessageDispatchSemaphore.wait(timeout: .distantFuture)
        
        
        // Reset message
        var aResetMessageError :Error? = nil
        let aResetMessageDispatchSemaphore = DispatchSemaphore(value: 0)
        aMessageField?.setValue("aa", withCompletionBlock: { (pError, pDatabaseReference) in
            aResetMessageError = pError
            // aResetMessageDispatchSemaphore.signal()
        })
        //  _ = aResetMessageDispatchSemaphore.wait(timeout: .distantFuture)
        if let aCount = self.fetchApplianceProperty(pAppliance, propertyName: "applianceOperatedCount") as? Int {
            let anError = self.updateApplianceProperty(pAppliance, propertyName: "applianceOperatedCount", propertyValue: aCount + 1)
        }
        
        
        
        //  ProgressOverlay.shared.show()
        //        DataFetchManager.shared.updateAppliancePowerState(completion: { (pError) in
        //         //   ProgressOverlay.shared.hide()
        //            if pError != nil {
        //              //  PopupManager.shared.displayError(message: "Can not update appliance.", description: pError!.localizedDescription)
        //             //   self.reloadAllView()
        //            } else {
        ////                if self.selectedRoom != nil {
        ////                   // pAppliance.isOn = pPowerState
        ////                } else {
        ////                //    self.reloadAllData()
        ////                }
        //              //  self.reloadAllView()
        //            }
        //        }, appliance: anAppliance, powerState: pPowerState)
    }
    
    private func updateApplianceProperty(_ pAppliance :Appliance, propertyName pPropertyName :String, propertyValue pPropertyValue :Any) -> Error? {
        var aReturnVal :Error? = nil
        
        
        return aReturnVal
    }
    
    
    private func fetchApplianceProperty(_ pAppliance :Appliance, propertyName pPropertyName :String) -> Any? {
        var aReturnVal :Any? = nil
        
        
        return aReturnVal
    }
    
}
extension OfflineApplinceViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Applinces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let Cell = ApplincesTableview.dequeueReusableCell(withIdentifier: "Cell")! as! applincessCell
        let obj = Applinces[indexPath.row]
        Cell.loaddata(pApplince: obj)
        Cell.delegate = self
        return Cell
    }
    
    func tableView(_ tableView: UITableView,heightForRowAt indexPath:IndexPath) -> CGFloat
    {
        let pAppliance = Applinces[indexPath.row]
        
        var aReturnVal :CGFloat = UITableView.automaticDimension
        if pAppliance.type != Appliance.ApplianceType.ledStrip {
            if pAppliance.isOn && pAppliance.isDimmable {
                aReturnVal = 145.0
            }
        }
        return aReturnVal
        
    }
    
    
}
extension UIView {
    
    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
