//
//  ResetWifiViewController.swift
//  Wifinity
//
//  Created by Apple on 06/09/22.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import WebKit

class ResetWifiViewController: BaseController, WKUIDelegate {
    var controllerApplince :ControllerAppliance!
    @IBOutlet weak var webview2: WKWebView!
    @IBOutlet weak var webvewi: UIView!
    @IBOutlet weak var viewIdPassowrd: UIView!
    @IBOutlet weak var viewInstruction: UIView!
    @IBOutlet weak var lblc_name: UIView!
    
    @IBOutlet weak var lblwifiId_pass: UILabel!
    @IBOutlet weak var lblcontrollerName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // webvewi.isHidden = true
        self.title = "Reset Switch"
        self.subTitle = controllerApplince?.title
        uiSetup()
    }
    func addview()  {
        //screenSize.height / 2.12
        let screenSize: CGRect = UIScreen.main.bounds
        let myView = UIView(frame: CGRect(x: 10, y: screenSize.height / 2.125, width: screenSize.width - 20, height: screenSize.height / 4.5))
        myView.backgroundColor = UIColor(named: "PrimaryLightestColor")
        
        webview2 = WKWebView(frame: CGRect(x: 0, y: 0, width: myView.frame.size.width, height: myView.frame.size.height))
        myView.addSubview(webview2)
        let url = URL(string: "http://192.168.4.1/")
        webview2.load(URLRequest(url: url!))
        myView.layer.borderWidth = 1
        myView.layer.borderColor = UIColor.gray.cgColor
        self.view.addSubview(myView)
    }
    func uiSetup()  {
        lblc_name.layer.borderWidth = 1
        lblc_name.layer.borderColor = UIColor.gray.cgColor
        lblc_name.backgroundColor = UIColor(named: "PrimaryLightestColor")
        lblcontrollerName.text = controllerApplince?.name
        if let idd = controllerApplince.id{
            lblwifiId_pass.text = "2> Once restarted connect to \(idd) Wifi, Password: 12345678"
        }
        if let idd = controllerApplince.id, let pass = controllerApplince.wifiPassword {
            lblwifiId_pass.text = "2> Once restarted connect to \(idd) Wifi, Password: \(pass)"
        }
        viewInstruction.layer.borderWidth = 1
        viewInstruction.layer.borderColor = UIColor.gray.cgColor
        viewInstruction.backgroundColor = UIColor(named: "PrimaryLightestColor")
        
        viewIdPassowrd.layer.borderWidth = 1
        viewIdPassowrd.layer.borderColor = UIColor.gray.cgColor
        viewIdPassowrd.backgroundColor = UIColor(named: "PrimaryLightestColor")
        
        self.txtfldSSID.delegate = self
        self.txtfldPassword.delegate = self
    }
    
    func donefinc()  {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            var dataidpass: [String: AnyHashable] = [String: AnyHashable]()
            dataidpass.updateValue(self.txtfldPassword.text, forKey: "wifiPassword")
            dataidpass.updateValue(self.txtfldSSID.text, forKey: "wifiSsid")
            var databaseref: DatabaseReference?
            databaseref =  Database.database().reference().child("routerDetails")
                .child((self.controllerApplince?.id) ?? "")
            
            databaseref?.observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                print(pDataSnapshot.value)
                if let aDict = pDataSnapshot.value as? Dictionary<String,Any> {
                    if (aDict["wCommand"] as! Bool != false), (aDict["xCommand"] as! Bool != false){
                        //    update database id and  passwd
                        databaseref?.child("temp").updateChildValues(dataidpass)
                        Database.database().reference().child("devices").child(self.controllerApplince.id ?? "").updateChildValues(dataidpass)

                        PopupManager.shared.displaySuccess(message: "Reset successfully", description: "")
                    }
                }
            }
        }
    }
    
    
    @IBOutlet weak var lblnext: UIButton!
    @IBOutlet weak var txtfldPassword: UITextField!
    @IBOutlet weak var txtfldSSID: UITextField!
    @IBAction func didtappedSendbtn(_ sender: Any) {
        if (txtfldPassword != nil), (txtfldSSID != nil) {
            calltoResetFunc()
        }
    }
    func calltoResetFunc() {
        DataFetchManager.shared.resetController(completion: { (pError, pApplianceArray) in
            ProgressOverlay.shared.hide()
            
            if pError != nil {
                //  displaySuccess
                PopupManager.shared.displayError(message: "Can not search appliances", description: pError!.localizedDescription)
            } else {
                self.donefinc()
                if pApplianceArray != nil && pApplianceArray!.count > 0 {
                    //    self.appliances = pApplianceArray!
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                    //   self.reloadAllView()
                }
            }
        }, room: txtfldSSID.text, room: txtfldPassword.text, Applinces: controllerApplince, includeOnOnly: true)
    }
    
    @IBAction func didtappedNextbtn(_ sender: Any) {
        lblnext.setTitle("RELOAD", for: .normal)
        addview()
    }
}
extension ResetWifiViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.view.endEditing(true)
            return false
        }
}
