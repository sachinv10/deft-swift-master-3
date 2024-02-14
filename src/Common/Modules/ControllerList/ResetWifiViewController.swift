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
    
    @IBOutlet weak var nametextView: UITextView!
    
    @IBOutlet weak var lblNameEdit: UIButton!
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
        lblcontrollerName.textColor = UIColor.white
        nametextView.text = controllerApplince?.name
        if let idd = controllerApplince.id{
            lblwifiId_pass.text = "2> Once restarted connect to \(idd) Wifi, Password: 12345678"
        }
//        if let idd = controllerApplince.id, let pass = controllerApplince.wifiPassword {
//            lblwifiId_pass.text = "2> Once restarted connect to \(idd) Wifi, Password: \(pass)"
//        }
        viewInstruction.layer.borderWidth = 1
        viewInstruction.layer.borderColor = UIColor.gray.cgColor
        viewInstruction.backgroundColor = UIColor(named: "PrimaryLightestColor")
        
        viewIdPassowrd.layer.borderWidth = 1
        viewIdPassowrd.layer.borderColor = UIColor.gray.cgColor
        viewIdPassowrd.backgroundColor = UIColor(named: "PrimaryLightestColor")
        self.nametextView.isEditable = false
        self.nametextView.backgroundColor = UIColor.clear
        
        self.txtfldSSID.delegate = self
        self.txtfldPassword.delegate = self
    }
    
    func donefinc()  {
        var databaseref: DatabaseReference?
        databaseref = Database.database().reference().child("routerDetails")
            .child((self.controllerApplince?.id) ?? "")
        
        databaseref?.observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
            print(pDataSnapshot.value)
            if let aDict = pDataSnapshot.value as? Dictionary<String,Any> {
                if (aDict["wCommand"] as! Bool != false), (aDict["xCommand"] as! Bool != false){
                    //   update database id and  passwd
                    var dataidpass: [String: AnyHashable] = [String: AnyHashable]()
                    dataidpass.updateValue(self.txtfldPassword.text, forKey:    "wifiPassword")
                    dataidpass.updateValue(self.txtfldSSID.text, forKey: "wifiSsid")
                    databaseref?.child("temp").updateChildValues(dataidpass)
                 
                    if ProgressOverlay.shared.progressOverlayView != nil{
                      Database.database().reference().child("devices").child(self.controllerApplince.id ?? "").updateChildValues(dataidpass)
                        ProgressOverlay.shared.hide()
                        PopupManager.shared.displaySuccess(message: "Reset successfully", description: "")
                        self.txtfldSSID.text = ""
                        self.txtfldPassword.text = ""
                    }
                }
            }
        }
    }
    
    
    @IBOutlet weak var lblnext: UIButton!
    @IBOutlet weak var txtfldPassword: UITextField!
    @IBOutlet weak var txtfldSSID: UITextField!
    @IBAction func didtappedSendbtn(_ sender: Any) {
        do{
            if (txtfldPassword.text?.count ?? 0 > 0), (txtfldSSID.text?.count ?? 0 > 0) {
                txtfldSSID.text = whiteSpaceRemove(obj: txtfldSSID.text!)
                txtfldPassword.text = whiteSpaceRemove(obj: txtfldPassword.text!)
                calltoResetFunc()
            }else{
                throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey:"Please enter ssid and password"])
             }
        }catch let error{
            PopupManager.shared.displayError(message: error.localizedDescription, description: "")
        }
    }
    func whiteSpaceRemove(obj: String)-> String{
        let stringWithSpaces = obj
        let trimmedString = stringWithSpaces.trimmingCharacters(in: .whitespaces)
        print("Original String: '\(stringWithSpaces)'")
        print("Trimmed String: '\(trimmedString)'")
        return trimmedString
    }
    func calltoResetFunc() {
        ProgressOverlay.shared.show()
        DataFetchManager.shared.resetController(completion: { (pError, pApplianceArray) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 20){
                if ProgressOverlay.shared.progressOverlayView != nil{
                    PopupManager.shared.displayError(message: "Unable to update credentials", description: "")
                    ProgressOverlay.shared.hide()
                }
            }
            if pError != nil {
                
                //  displaySuccess
                if pError?.localizedDescription == "Success"{
                    self.donefinc()
                }else{
                    PopupManager.shared.displayError(message: "Can not search appliances", description: pError!.localizedDescription)
                }
            } else {
                // self.donefinc()
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

extension ResetWifiViewController{
    func editName(){
       print(nametextView.text)
        controllerApplince.name = nametextView.text
        ProgressOverlay.shared.show()
        DataFetchManager.shared.reNameControllername(Controller: {(error, success) in
        ProgressOverlay.shared.hide()
            if success{
               // PopupManager.shared.displaySuccess(message: "Name changed successfully", description: "")
                self.showToast(message: "Name changed successfully!", duration: 3.0)
            }else{
                PopupManager.shared.displaySuccess(message: "Error", description: error?.localizedDescription)
            }
        }, Appliance: controllerApplince)
    }
}
extension ResetWifiViewController: UITextFieldDelegate {
    @IBAction func didtappedEditName(_ sender: Any) {
        self.EditName()
    }
    func EditName(){
        lblNameEdit.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        if self.nametextView.isEditable != true{
            self.nametextView.isEditable = true
        self.lblNameEdit.setTitle("Save", for: .normal)
            nametextView.layer.borderWidth = 0.5
            nametextView.layer.cornerRadius = 5
        }else{
            self.nametextView.isEditable = false
            self.lblNameEdit.setTitle("Edit", for: .normal)
            self.nametextView.backgroundColor = UIColor.clear
        //   edit name
            editName()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
