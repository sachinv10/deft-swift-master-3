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

class DeviceSettingViewController: UIViewController {
    
    @IBOutlet weak var backgroundview: UIView!
    var controllerApplince :ControllerAppliance?
    static var timestamp = Array<Dictionary<String,Any>>()
    override func viewDidLoad() {
        super.viewDidLoad()
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
        self.stackviewfunc()
        self.activatelisner()
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
    let button4 = UIButton()
    let views = UIStackView()
    let button5 = UIButton()
    var button6 = UIButton()
    
    var deleteView = UIView()
    func stackviewfunc()  {
        deleteView.isHidden = true
        button.setTitle("Network Details                          ^", for: .normal)
        button.contentHorizontalAlignment = .left
        button.backgroundColor = UIColor.clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(myAction), for: .touchUpInside)
        button.setTitleColor(UIColor.black, for: .normal)
        button6 = UIButton(frame: CGRect(x: button.frame.width / 2, y: 0, width: button.frame.width / 2, height: button.frame.height))
        
        button6.setImage(UIImage(named: "free-arrow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addSubview(button6)
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
        button2.contentHorizontalAlignment = .left
        
        let button3 = UIButton()
        button3.setTitle("Delete", for: .normal)
        button3.backgroundColor = UIColor.clear
        button3.setTitleColor(UIColor.black, for: .normal)
        button3.translatesAutoresizingMaskIntoConstraints = false
        button3.addTarget(self, action: #selector(MydeleteView), for: .touchUpInside)
        button3.contentHorizontalAlignment = .left
        
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        
        stackView.addArrangedSubview(button)
        stackView.addArrangedSubview(views)
        stackView.spacing = 8.0
        stackView.addArrangedSubview(button2)
        stackView.addArrangedSubview(button3)
    }
    var customView = UIView()
    var lablehead = UILabel()
    var myTextField = UITextField()
    var myTextFieldpass = UITextField()
    var btnAthontication = UIButton()
    var btnCancel = UIButton()
    @objc func MydeleteView() {
        
        
        
        deleteView.isHidden = false
        deleteView.frame = CGRect.init(x: backgroundview.frame.width / 20, y: backgroundview.frame.height / 2, width: backgroundview.frame.width / 1.11, height: backgroundview.frame.height / 3)
        deleteView.backgroundColor = UIColor.white
       
        lablehead.frame = CGRect(x: 20, y: 0, width: deleteView.frame.width - 20, height: 50)
        lablehead.text = "Delete Controller?"
        lablehead.textColor = UIColor.black
        deleteView.addSubview(lablehead)
 
        myTextField.frame = CGRect(x: 15, y: 50, width: deleteView.frame.width - 30, height: 50)
        myTextField.placeholder = "Enter User Id"
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
        
        btnAthontication.setTitle("Athontication", for: .normal)
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
      
        Database.database().reference().child("devices").child((controllerApplince?.id)!).observe(.childChanged) { (snapshot, key) in
             print(snapshot)
            var wifisign = snapshot.value
            print(wifisign)
             let wifist =  self.wifistrenthcalulation(wifis: wifisign as! String)
             self.lblwifiSignal.text = "\(String(wifist)) %"
                          
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
extension DeviceSettingViewController{
    func deletecontroller(appliance pAppliance :ControllerAppliance) {
        let anAppliance = pAppliance.clone()
 
        ProgressOverlay.shared.show()
        DataFetchManager.shared.deleteController(completion: { (pError) in
        ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update appliance.", description: pError!.localizedDescription)
            } else {

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
//            Database.database().reference()
//                .child("rooms")
//                .child(Auth.auth().currentUser!.uid)
//                .child(aRoomId)
//                .child("curtains")
//                .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
//                    if let aDeviceIdArray = pDataSnapshot.value as? Array<String> {
//                        for i in 0..<aDeviceIdArray.count {
//                            if controller_id == aRoomId{
//                                pcontrollerApplince.hardwareId = String(i)
//                            }
//                        }
//
//                    }
//                    aDispatchSemaphore.signal()
//                }
//
//            Database.database().reference()
//                .child("rooms")
//                .child(Auth.auth().currentUser!.uid)
//                .child(aRoomId)
//                .child("remotes")
//                .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
//                    if let aDeviceIdArray = pDataSnapshot.value as? Array<String> {
//                        for i in 0..<aDeviceIdArray.count {
//                            if controller_id == aRoomId{
//                                pcontrollerApplince.hardwareId = String(i)
//                            }
//                        }
//
//                    }
//                    aDispatchSemaphore.signal()
//                }
//            Database.database().reference()
//                .child("rooms")
//                .child(Auth.auth().currentUser!.uid)
//                .child(aRoomId)
//                .child("sensors")
//                .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
//                    if let aDeviceIdArray = pDataSnapshot.value as? Array<String> {
//                        for i in 0..<aDeviceIdArray.count {
//                            if controller_id == aRoomId{
//                                pcontrollerApplince.hardwareId = String(i)
//                            }
//                        }
//
//                    }
                 //   aDispatchSemaphore.signal()
            //    }
            _ = aDispatchSemaphore.wait(timeout: .distantFuture)
       
        return ""
      //  return aFetchedRoomIdArray
    }
}
