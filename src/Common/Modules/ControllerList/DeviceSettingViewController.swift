//
//  DeviceSettingViewController.swift
//  Wifinity
//
//  Created by Apple on 30/06/22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

class DeviceSettingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var backgroundview: UIView!
    var controllerApplince :ControllerAppliance?
    var pSensor = Sensor()
    static var timestamp = Array<Dictionary<String,Any>>()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Controller Settings"
        lblbtnback.setTitle("", for: .normal)
        view.backgroundColor = UIColor(named: "PrimaryLightestColor")
       
        lblHardwareId.text = controllerApplince?.id
        if let x = controllerApplince?.lastOperated{
            let time =  SharedFunction.shared.gotoTimetampTodayConvert(time: Double(x/1000))
            lblLastActivity.text = time
            
            if let wifis = controllerApplince?.wifiSignalStrength{
                let wifist =  self.wifistrenthcalulation(wifis: wifis)
                lblwifiSignal.text = "\(String(wifist)) %"
            }
        }
         Refrashbtn.setTitle("", for: .normal)
        self.collectionViewUIsetup()
        checkVersioning()
     
        self.activatelisner()
        getTimestamp()
    }
    func checkVersioning(){
        let result = (controllerApplince?.id?.hasPrefix("CS0"))!
          if result{
            if controllerApplince?.version ?? "1.0" >= "1.5"{
                self.stackviewfunc()
            }else{

                PopupManager.shared.displayBooleanOptionPopup(message: "Assing Version", description: "Are you sure you want to assign version to this device?", pOptionOneTitle: "YES", optionOneCompletion: {
                    self.changeMode(cmd: "Version")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                        self.reloadAllData()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            if self.controllerApplince?.version ?? "1.0" <= "1.5"{
                                self.showToast(message: "Unable to update version!", duration: 3)
                            }
                            self.stackviewfunc()
                        }
                    })
                }, pOptionTwoTitle: "NO", optionTwoCompletion: {
                    self.stackviewfunc()
                })
            }
        }else{
            self.stackviewfunc()
        }
    }
    @IBOutlet var collectionView: UICollectionView! // Connect this IBOutlet to your collection view in the storyboard
    var items = ["Led mode:", "Cleaning Mode", "Child lock", "State Retention"]

    func collectionViewUIsetup(){
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.minimumInteritemSpacing = 10
        collectionViewFlowLayout.scrollDirection = .horizontal
      //  collectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 60)
       // collectionViewFlowLayout.collectionView?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 60)
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50), collectionViewLayout: collectionViewFlowLayout)
        collectionView.backgroundColor = UIColor.clear
    
        collectionView.register(UINib(nibName: "DiveceSettingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DiveceSettingCollectionViewCellId")
        collectionView.delegate = self
        collectionView.dataSource = self
       // viewCollection.backgroundColor = UIColor.blue
        
    }
    func getTimestamp() {
            Database.database().reference().child("keepAliveTimeStamp").child(lblHardwareId.text ?? "")
                .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                    if let aDict = pDataSnapshot.value as? Dictionary<String,Any> {
                        if let x = aDict["time"] as? Double{
                            let time =  SharedFunction.shared.gotoTimetampTodayConvert(time: Double(x/1000))
                            self.lblLastActivity.text = time
                        }
                }
          }
    }
     func reloadAllData() {
         DispatchQueue.main.async {
         DataFetchManager.shared.deviceDetails(completion: { (pError, pApplianceArray) in
             do
            {

            if pApplianceArray != nil {
                print("reEnter controller....")
                let controllerApplince = pApplianceArray?.filter({(pObject) in
                    return self.controllerApplince?.id == pObject.id && self.controllerApplince?.roomId == pObject.roomId
                })
                self.controllerApplince = controllerApplince?.first
             }
            }catch let error{
                print(error.localizedDescription)
            }
             DispatchQueue.main.async {
                 self.collectionView.reloadData()
              }
             })
        }
    }
    @IBOutlet weak var lblbtnback: UIButton!
    
    @IBAction func didtappedBackbtn(_ sender: Any) {
        RoutingManager.shared.goToPreviousScreen(self)
    }
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var lblHardwareId: UILabel!
    @IBOutlet weak var lblProductionRegistrestion: UILabel!
    @IBOutlet weak var lblwifiSignal: UILabel!
    @IBOutlet weak var lblLastActivity: UILabel!
    
    @IBOutlet weak var Refrashbtn: UIButton!
    let button = UIButton()
    let buttonMac = UIButton()
    let viewCollection = UIView()
    let button4 = UIButton()
    let views = UIStackView()
    let button5 = UIButton()
    var button6 = UIButton()
    var button7 = UIButton()
    var touchModeCmd = ControllerAppliance.touchModeCmd.Led
    var deleteView = UIView()
    func stackviewfunc() {
        deleteView.isHidden = true
        viewCollection.addSubview(collectionView)
        buttonMac.setTitle("Mac Id: \(controllerApplince?.macId ?? "")", for: .normal)
        buttonMac.contentHorizontalAlignment = .left
        buttonMac.backgroundColor = UIColor.clear
        buttonMac.translatesAutoresizingMaskIntoConstraints = false

        buttonMac.setTitleColor(UIColor.black, for: .normal)
        button7 = UIButton(frame: CGRect(x: 320, y: 10, width: 30, height: 35))
        
        button7.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        button7.addTarget(self, action: #selector(fetchMacId), for: .touchUpInside)
        buttonMac.addSubview(button7)
        
        button.setTitle("Network Details                          ⌄", for: .normal)
        button.contentHorizontalAlignment = .left
        button.backgroundColor = UIColor.clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(myAction), for: .touchUpInside)
        button.setTitleColor(UIColor.black, for: .normal)
        button6 = UIButton(frame: CGRect(x: button.frame.width / 2, y: 0, width: button.frame.width / 2, height: button.frame.height))
        button6.setImage(UIImage(named: "free-arrow")?.withRenderingMode(.alwaysOriginal), for: .normal)
     //   button.addSubview(button6)
        //  views.backgroundColor = UIColor.placeholderText
        views.translatesAutoresizingMaskIntoConstraints = false
        button4.setTitle("Network Name(SSID):  ", for: .normal)
        if let nwname = controllerApplince?.wifiSsid {
            button4.setTitle("Network Name(SSID):  \(nwname)", for: .normal)
        }
        button4.translatesAutoresizingMaskIntoConstraints = false
        button4.setTitleColor(UIColor.darkGray, for: .normal)
        button4.contentHorizontalAlignment = .left
        
        button5.setTitle("password          :         ", for: .normal)
        if let nwnames = controllerApplince?.wifiPassword {
            button5.setTitle("password          : \(nwnames)", for: .normal)
        }
        
        button5.translatesAutoresizingMaskIntoConstraints = false
        button5.setTitleColor(UIColor.darkGray, for: .normal)
        button5.contentHorizontalAlignment = .left
        views.addArrangedSubview(button4)
        views.addArrangedSubview(button5)
        
        views.isHidden = true
        views.axis = .vertical
        views.translatesAutoresizingMaskIntoConstraints = false
        
        let button2 = UIButton()
        button2.setTitle("Reset", for: .normal)
        button2.setTitleColor(UIColor.black, for: .normal)
        button2.backgroundColor = UIColor.clear
        button2.translatesAutoresizingMaskIntoConstraints = false
        button2.addTarget(self, action: #selector(MyResetView), for: .touchUpInside)
        button2.contentHorizontalAlignment = .left
        
        let button3 = UIButton()
        button3.setTitle("Delete", for: .normal)
        button3.backgroundColor = UIColor.clear
        button3.setTitleColor(UIColor.black, for: .normal)
        button3.translatesAutoresizingMaskIntoConstraints = false
        button3.addTarget(self, action: #selector(MydeleteView), for: .touchUpInside)
        button3.contentHorizontalAlignment = .left
        
        let button4 = UIButton()
        button4.setTitle("Calibrate", for: .normal)
        button4.backgroundColor = UIColor.clear
        button4.setTitleColor(UIColor.black, for: .normal)
        button4.translatesAutoresizingMaskIntoConstraints = false
        button4.addTarget(self, action: #selector(MyCalibrateView), for: .touchUpInside)
        button4.contentHorizontalAlignment = .left
        
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        if controllerApplince?.version ?? "1.0" >= "1.5"{
            stackView.addArrangedSubview(viewCollection)
        }else{
            let result = (controllerApplince?.id?.hasPrefix("CS0"))!
            if result{
                items = ["Led mode:"]
                stackView.addArrangedSubview(viewCollection)
            }
        }
        stackView.addArrangedSubview(buttonMac)
        stackView.addArrangedSubview(button)
        stackView.addArrangedSubview(views)
        stackView.spacing = 8.0
        stackView.addArrangedSubview(button2)
        stackView.addArrangedSubview(button3)
        if Device.getHardwareType(id: controllerApplince?.id ?? "") == Device.HardwareType.Occupy{
            stackView.addArrangedSubview(button4)
         }
        collectionView.reloadData()
    }
    @objc func MyResetView() {
        RoutingManager.shared.gotoResetControllerSetting(controller: self, controller: controllerApplince!)
    }
    @objc func MyCalibrateView() {
        var database = Database.database().reference()
       
        if let ids = controllerApplince?.id{
            database = database.child("devices").child(ids)
            pSensor.id = ids
            database.updateChildValues(["calibrated": false])
        }
       
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateSensorCalibrate(completion: { (pError) in
         //   ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not Calibrate", description: pError!.localizedDescription)
                ProgressOverlay.shared.hide()
            } else {
               // PopupManager.shared.displaySuccess(message: "Calibrate successfully", description: "")
//                pSensor.occupancyState = pOccupancyState
//                self.reloadAllView()
            }
        }, sensor: pSensor)
        DispatchQueue.main.asyncAfter(deadline: .now() ){
            database.observe(.childChanged, with: { snapshot in
          
                    if let value = snapshot.value as? Bool {
                        print(" controller value =\(value)")
                        if value == true{
                            ProgressOverlay.shared.hide()
                              PopupManager.shared.displaySuccess(message: "Calibrate successfully", description: "")
                           
                        }
                    }
             
            })
        }
    }
    var customView = UIView()
    var lablehead = UILabel()
    var myTextField = UITextField()
    var myTextFieldpass = UITextField()
    var btnAthontication = UIButton()
    var btnCancel = UIButton()
   
    @objc func MydeleteView() {
        
        if Device.HardwareType.Occupy == Device.getHardwareType(id: (controllerApplince?.id) ?? ""){
            ProgressOverlay.shared.show()
            DataFetchManager.shared.deleteOccupySensorUnAssign(completion: {error, sensor in
                ProgressOverlay.shared.hide()
                if sensor?.id != nil && sensor?.uidAssign == false{
                    self.deleteViewCall()
                }else if (sensor?.uidAssign != false){
                    PopupManager.shared.displayInformation(message: "delete faild! try again", description: "")
                }
            }, sensor: controllerApplince!)
        }else{
            deleteViewCall()
        }
    }
    func deleteViewCall(){
        
        self.myTextField.delegate = self
        self.myTextFieldpass.delegate = self
        
        deleteView.isHidden = false
        deleteView.frame = CGRect.init(x: backgroundview.frame.width / 20, y: backgroundview.frame.height / 2, width: backgroundview.frame.width / 1.11, height: backgroundview.frame.height / 3)
        deleteView.backgroundColor = UIColor.white
       
        lablehead.frame = CGRect(x: 20, y: 0, width: deleteView.frame.width - 20, height: 50)
        lablehead.text = "Delete Controller?"
        lablehead.textColor = UIColor.black
        deleteView.addSubview(lablehead)
 
        myTextField.frame = CGRect(x: 15, y: 50, width: deleteView.frame.width - 30, height: 50)
        myTextField.placeholder = "Enter User Id"
        myTextField.text = UserDefaults.standard.value(forKey: "emailAddress") as? String
        myTextField.layer.cornerRadius = 15.0
        myTextField.layer.borderWidth = 1.0
        myTextField.layer.borderColor = UIColor.gray.cgColor
        myTextField.clipsToBounds = true
        myTextField.textColor = UIColor.blue
        myTextField.textAlignment = .center
        
        myTextFieldpass.frame = CGRect(x: 15, y: 110, width: deleteView.frame.width - 30, height: 50)
        myTextFieldpass.placeholder = "Password"
        myTextFieldpass.layer.cornerRadius = 15.0
        myTextFieldpass.layer.borderWidth = 1.0
        myTextFieldpass.layer.borderColor = UIColor.gray.cgColor
        myTextFieldpass.clipsToBounds = true
        myTextFieldpass.textColor = UIColor.blue
        myTextFieldpass.textAlignment = .center
        self.deleteView.addSubview(myTextFieldpass)
        self.deleteView.addSubview(myTextField)
        
        btnAthontication.setTitle("Authentication", for: .normal)
        btnAthontication.setTitleColor(UIColor.black, for: .normal)
        btnAthontication.frame = CGRect(x: 30, y: 175, width: 130, height: 50)
        btnAthontication.addTarget(self, action: #selector(pressedmenu), for: .touchUpInside)
        btnAthontication.backgroundColor = UIColor.gray
        btnAthontication.layer.cornerRadius = 14
        btnAthontication.layer.borderWidth = 1
        deleteView.addSubview(btnAthontication)

        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.setTitleColor(UIColor.black, for: .normal)
        btnCancel.frame = CGRect(x: 220, y: 175, width: 130, height: 50)
        btnCancel.addTarget(self, action: #selector(pressedCancel), for: .touchUpInside)
        btnCancel.backgroundColor = UIColor.gray
        btnCancel.layer.cornerRadius = 15
        btnCancel.layer.borderWidth = 1
        deleteView.addSubview(btnCancel)

        self.backgroundview.addSubview(deleteView)

        if deleteView.isHidden{
            deleteView.isHidden = true
        }else{
            deleteView.isHidden = false
        }
    }
    @objc func pressedmenu() {
        deleteView.isHidden = true
        //
        let emailAddress = UserDefaults.standard.value(forKey: "emailAddress") as? String
        let password =  UserDefaults.standard.value(forKey: "password") as? String
        
        if (emailAddress == myTextField.text?.lowercased()) && (password == myTextFieldpass.text) {
            self.deletecontroller(appliance: controllerApplince!)
        }else{
            let refreshAlert = UIAlertController(title: "Error", message: "Incorrect user Id and password", preferredStyle: UIAlertController.Style.alert)

            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                  print("Handle Ok logic here")
            }))
            present(refreshAlert, animated: true, completion: nil)
        }
        
    }
    @objc func pressedCancel() {
        deleteView.isHidden = true
 
    }
    @objc func fetchMacId(){
        print("featch mac Id")
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateMacId(completion: {error in
            print("get return")
            DispatchQueue.main.asyncAfter(deadline: .now() + 5){
                self.getId()
            }
        }, Appliances: controllerApplince, message: "{\"config\":\"true\"}")
    }
    func changeMode(cmd: String){
        print("changeMode")
        if cmd.count > 7{
            ProgressOverlay.shared.show()
            DataFetchManager.shared.updateMacId(completion: {error in
                print("get return")
                if error == nil{
                    
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    ProgressOverlay.shared.hide()
                    self.reloadAllData()
                }
            }, Appliances: controllerApplince, message: cmd)
        }
    }
    func getId(){
        ProgressOverlay.shared.hide()
        DataFetchManager.shared.getMacId(completion: {(error, data)in
           if data as? String != nil{
                self.controllerApplince?.macId = data as? String
            }
            if error == nil && ((data as? String) != nil){
                self.showToast(message: "Mac id get successfully",duration: 3)
            }else{
                self.showToast(message: error?.localizedDescription ?? "Unable to update Mac Id",duration: 3)
            }
            self.buttonMac.setTitle("Mac Id: \(self.controllerApplince?.macId ?? "")", for: .normal)
        }, Appliances: controllerApplince)
    }
    @objc func myAction() {
        
        if views.isHidden {
            views.isHidden = false
            button.setTitle("Network Details                          ^", for: .normal)
        }else{
             views.isHidden = true
            button.setTitle("Network Details                          ⌄", for: .normal)
        }
    }
    
    @IBAction func Refrashwifisignalbtn(_ sender: Any) {
        updateApplianceRefrashWifi(appliance: controllerApplince!)
    }
    func updateApplianceRefrashWifi(appliance pAppliance :ControllerAppliance) {
        let anAppliance = pAppliance.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.deleteControllerState(completion: { (pError) in
        ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update appliance.", description: pError!.localizedDescription)
            } else {
 
            }
        }, appliance: anAppliance)
    }
    func activatelisner() {
      
        Database.database().reference().child("devices").child((controllerApplince?.id)!).observe(.value) { (snapshot, key) in
             print(snapshot)
            if snapshot.childrenCount > 0 {
                var wifisign = snapshot.value as! Dictionary<String,Any>
                print(wifisign["wifiSignalStrength"])
                if let wifiid = wifisign["wifiSignalStrength"]{
                    let wifist =  self.wifistrenthcalulation(wifis: wifiid as! String)
                    self.lblwifiSignal.text = "\(String(wifist)) %"
                    
                }
            }
        }
    }
    
    func  wifistrenthcalulation(wifis: String)->Int {
        let wifistresnth = Int(wifis)
        if wifistresnth! >= 0{
            if wifistresnth! <= 50 {
                return 100
            }else if wifistresnth! >= 100{
                return 0
                
            }else{
                return 2 * (100 - wifistresnth!)
            }
        }else{
            if wifistresnth! <= -100{
                return 0
            }else if wifistresnth! >= -50{
                return 100
            }else{
                return 2 * (100 + wifistresnth!)
            }
        }
    }
}
extension DeviceSettingViewController:  UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.view.endEditing(true)
            return false
        }
}
extension DeviceSettingViewController{
    func deletecontroller(appliance pAppliance :ControllerAppliance) {
        let anAppliance = pAppliance.clone()
 
        ProgressOverlay.shared.show()
        DataFetchManager.shared.deleteController(completion: { (pError) in
        ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not delete controller.", description: pError!.localizedDescription)
            } else {
                PopupManager.shared.displayError(message: "Controller deleted", description: "", completion: {
                    RoutingManager.shared.goBackToDashboard()
                })
            }
        }, appliance: anAppliance)
    }
    func devidedetail(pcontrollerApplince: ControllerAppliance) ->  String{
        var aaaDeviceIdArray = [String: String]()
        var aFetchedRoomIdArray = Array<String>()
       let aRoomId = pcontrollerApplince.roomId!
        let controller_id = pcontrollerApplince.id
            let aDispatchSemaphore = DispatchSemaphore(value: 0)
            Database.database().reference()
                .child("rooms")
                .child(Auth.auth().currentUser!.uid)
                .child(aRoomId)
                .child("devices")
                .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                    if let aDeviceIdArray = pDataSnapshot.value as? Array<String> {
                        for i in 0..<aDeviceIdArray.count {
                            if controller_id == aRoomId{
                                pcontrollerApplince.hardwareId = String(i)
                            }
                        }
                    }
                    aDispatchSemaphore.signal()
                }

            _ = aDispatchSemaphore.wait(timeout: .distantFuture)
       
        return ""
     }
}

// MARK: - UICollectionViewDataSource and Delegate
extension DeviceSettingViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ pCollectionView: UICollectionView, cellForItemAt pIndexPath: IndexPath) -> UICollectionViewCell {
        let aCell = (pCollectionView.dequeueReusableCell(withReuseIdentifier: "DiveceSettingCollectionViewCellId", for: pIndexPath) as? DiveceSettingCollectionViewCell)!
        // Configure the cell with your data
       // aCell.isSelected = true
        if pIndexPath.row == 0{
            aCell.roomNamelbl.text = "Led mode: \(String(describing: controllerApplince?.touchLedMode ?? "On"))"
            if controllerApplince?.touchLedMode ?? "On" == "off"{
                aCell.layer.borderColor = UIColor.gray.cgColor
                aCell.roomNamelbl.textColor = UIColor.gray
            }else{
                aCell.layer.borderColor = UIColor.purple.cgColor
                aCell.roomNamelbl.textColor = UIColor.purple
            }
         }else if pIndexPath.row == 1{
           if controllerApplince?.cleaningMode == true{
               aCell.layer.borderColor = UIColor.purple.cgColor
               aCell.roomNamelbl.textColor = UIColor.purple
            }else{
                aCell.layer.borderColor = UIColor.gray.cgColor
                aCell.roomNamelbl.textColor = UIColor.gray
            }
            aCell.roomNamelbl.text = items[pIndexPath.row]
        }else if pIndexPath.row == 2{
            aCell.roomNamelbl.text = items[pIndexPath.row]
            if controllerApplince?.childLock == true{
                aCell.layer.borderColor = UIColor.purple.cgColor
                aCell.roomNamelbl.textColor = UIColor.purple
             }else{
                 aCell.layer.borderColor = UIColor.gray.cgColor
                 aCell.roomNamelbl.textColor = UIColor.gray
             }
        }else if pIndexPath.row == 3{
            aCell.roomNamelbl.text = items[pIndexPath.row]
            if controllerApplince?.stateRetention == true{
                aCell.layer.borderColor = UIColor.purple.cgColor
                aCell.roomNamelbl.textColor = UIColor.purple
             }else{
                 aCell.layer.borderColor = UIColor.gray.cgColor
                 aCell.roomNamelbl.textColor = UIColor.gray
             }
        }
        return aCell
    }
    func collectionView(_ pCollectionView: UICollectionView, didSelectItemAt pIndexPath: IndexPath) {
           // Handle the selection event here
        let aCell = (pCollectionView.dequeueReusableCell(withReuseIdentifier: "DiveceSettingCollectionViewCellId", for: pIndexPath) as? DiveceSettingCollectionViewCell)!
        
           let selectedItem = items[pIndexPath.row]
        if aCell.isSelected != false{
            aCell.isSelected = false
            aCell.backgroundColor = UIColor.white
        }else{
            aCell.isSelected = true
            aCell.backgroundColor = UIColor.clear
        }
        var cmd = "$C"
        if pIndexPath.row == 0{
            DispatchQueue.main.async {
                ProgressOverlay.shared.hide()
            }
            PopupManager.shared.displaySelectinOptionPopup(message: "Select any one", description: "", pOptionOneTitle: "ON", optionOneCompletion: {data in
                cmd = "$C"
                cmd += data
                cmd += "0000000F"
                switch data{
                case "1":
                    self.controllerApplince?.touchLedMode = "off"
                case "2":
                    self.controllerApplince?.touchLedMode = "on"
                case "3":
                    self.controllerApplince?.touchLedMode = "auto"
                default:
                    print("none")
                }
               
                self.changeMode(cmd: cmd)
            }, pOptionTwoTitle: "OFF", pOptionThreeTitle: "Auto", pOptionFourTitle: "None")
         //   cmd += "0000"
        }else if pIndexPath.row == 2{
            cmd += "0"
            controllerApplince?.childLock = !controllerApplince!.childLock
            cmd += DataContractManagerFireBase.isOnCommandValue(controllerApplince!.childLock)
            self.touchModeCmd = .clild
            cmd += "00"
        }else if pIndexPath.row == 1{
            cmd += "00"
            controllerApplince?.cleaningMode = !controllerApplince!.cleaningMode
            cmd += DataContractManagerFireBase.isOnCommandValue(controllerApplince!.cleaningMode)
            self.touchModeCmd = .cleaning
            cmd += "0"
        }else if pIndexPath.row == 3{
            cmd += "000"
            controllerApplince?.stateRetention = !controllerApplince!.stateRetention
            cmd += DataContractManagerFireBase.isOnCommandValue(controllerApplince!.stateRetention)
            self.touchModeCmd = .retaintion
        }
        cmd += "0000F"
        changeMode(cmd: cmd)
        debugPrint("comand",cmd)
         //  collectionView.reloadItems(at: [pIndexPath])
           print("Selected item: \(selectedItem)")
       }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Calculate the desired size based on the content
        let s = items[indexPath.row]
        let font = UIFont.systemFont(ofSize: 16.0)
        let width = calculateStringWidth(s, font: font)
        let itemHeight: CGFloat = 40 // Set a default height
        return CGSize(width: width + 55, height: itemHeight)
    }
    func calculateStringWidth(_ inputString: String, font: UIFont) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let size = (inputString as NSString).size(withAttributes: attributes)
        return size.width
    }
}
