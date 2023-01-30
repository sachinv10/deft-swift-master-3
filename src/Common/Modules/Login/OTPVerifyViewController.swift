//
//  OTPVerifyViewController.swift
//  Wifinity
//
//  Created by Apple on 30/11/22.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import Foundation
//import FirebaseAnalytics
//import FirebaseCrashlytics

class OTPVerifyViewController: BaseController {
// text field outlet
    
    @IBOutlet weak var lblemail: UILabel!
    @IBOutlet weak var lbltimer: UILabel!
    @IBOutlet weak var textfldfirst: UITextField!
    @IBOutlet weak var textfldsecond: UITextField!
    @IBOutlet weak var textfldthird: UITextField!
    @IBOutlet weak var textfldforth: UITextField!
    @IBOutlet weak var textfldfipth: UITextField!
    @IBOutlet weak var textfldsixth: UITextField!
    var whiteOverlay :UIView?
    var msg = String()
    var password = String()
    var phoneNumber = String()
    var userName = String()
    var OTP = String()
    var email = String()
    static var timestampfinal = Int()
    static var timestamp = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        subTitle = ""
        textfldfirst.delegate = self
        textfldsecond.delegate = self
        textfldthird.delegate = self
        textfldforth.delegate = self
        textfldfipth.delegate = self
        textfldsixth.delegate = self

        textfldfirst.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        textfldsecond.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        textfldthird.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        textfldforth.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        textfldfipth.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        textfldsixth.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);
        uiSetup()
    }
   var timeInSeconds = 0
    var timer = Timer()
    func uiSetup(){
        if msg == "200"{
            PopupManager.shared.displayError(message: "OTP send successfully", description: "")
            msg = ""
        }
        lblemail.text = "please enter 6 dight code sent to \(email)"
         timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        let timestamp = NSDate().timeIntervalSince1970
        let timestamp1 = Int(timestamp * 1000)
        let second = (timestamp1 - (OTPVerifyViewController.timestampfinal)) / 1000
        timeInSeconds = 300 - second
        print((timestamp1 - (OTPVerifyViewController.timestampfinal)) / 1000)
        let timex = timestamp1 - (OTPVerifyViewController.timestampfinal / 1000)
        print("time in second=\(timex / 1000)")
            }
    @objc func update() {
         print("timerActive")
        timeInSeconds -= 1
        if timeInSeconds < 1{
            timer.invalidate()
        }
        
        let x = timeInSeconds % 60
        lbltimer.text = "\(timeInSeconds / 60): \(x)"
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        print("disappear Create Account ViewController")
    }
    var enterdOtp = ""
   @objc func textFieldDidChange(textField: UITextField){

        let text = textField.text

        if (text?.utf16.count)! >= 1{
            switch textField{
            case textfldfirst:
                enterdOtp += textfldfirst.text!
                textfldsecond.becomeFirstResponder()
            case textfldsecond:
                enterdOtp += textfldsecond.text!
                textfldthird.becomeFirstResponder()
            case textfldthird:
                enterdOtp += textfldthird.text!
                textfldforth.becomeFirstResponder()
            case textfldforth:
                enterdOtp += textfldforth.text!
                textfldfipth.becomeFirstResponder()
            case textfldfipth:
                enterdOtp += textfldfipth.text!
                textfldsixth.becomeFirstResponder()
            case textfldsixth:
                enterdOtp += textfldsixth.text!
                textfldsixth.resignFirstResponder()
            default:
                break
            }
        }else{

        }
    }
    @objc func keyboardWillShow(sender: NSNotification) {
         self.view.frame.origin.y = -220 // Move view 150 points upward
    }

    @objc func keyboardWillHide(sender: NSNotification) {
         self.view.frame.origin.y = 0 // Move view to original position
    }
    
    @IBAction func didTappedSaveAlldeatail(_ sender: Any) {
        if OTP == enterdOtp{
            print("otp success")
            createfirebaseAccount()
        }
    }
    func createfirebaseAccount() {
        if !email.isEmpty, !password.isEmpty {
            Auth.auth().createUser(withEmail: email, password: password, completion: { (result, error) -> Void in
                if (error == nil) {
                    //   UserDefaults.standardUserDefaults().setValue(result.uid, forKey: "uid")
                    if ((Auth.auth().currentUser?.uid) != nil){
                        print("Account created :)")
                        self.accountCreatedSuccessfully()
                    }
                }
                else{
                    PopupManager.shared.displayError(message: "", description: error?.localizedDescription)
                    print(error)
                }
            })
        }
    }
    func accountCreatedSuccessfully() {
        self.uploaddataInFirebase()
        self.deleteEmailVerification()
    }
}
extension OTPVerifyViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
}
extension OTPVerifyViewController{
    func uploaddataInFirebase() {
        let timestamp = NSDate().timeIntervalSince1970
        let timestamp1 = Int(timestamp * 1000)
        var stanAloanDic: Dictionary<String, Any>? = Dictionary<String, Any>()
        stanAloanDic?.updateValue(userName, forKey: "userName")
        stanAloanDic?.updateValue(phoneNumber, forKey: "phoneNumber")
        stanAloanDic?.updateValue(email, forKey: "email")
        stanAloanDic?.updateValue(password, forKey: "password")
        stanAloanDic?.updateValue("false", forKey: "numberVerified")
        stanAloanDic?.updateValue("Wifinity", forKey: "origin")
        stanAloanDic?.updateValue(timestamp1, forKey: "created")
        DispatchQueue.global(qos: .background).async {
            if let uid = (Auth.auth().currentUser?.uid){
                Database.database().reference().child("standaloneUserDetails").child(uid).updateChildValues(stanAloanDic!, withCompletionBlock: { (error, pdatabaserefrances) in
                    if (error != nil){
                        PopupManager.shared.displayError(message: "", description: error?.localizedDescription)
                    }else
                    {
                     //   PopupManager.shared.displayError(message: "Data save successfully", description: "")
                        DispatchQueue.main.async {
                            self.demologin()
                        }
                       
                    }
                })
            }
        }
    }
   
    func demologin(){
            _ = KeychainManager.shared.save(key: "emailAddress", value: email)
            _ = KeychainManager.shared.save(key: "password", value: password)
            UserDefaults.standard.set(email, forKey: "emailAddress")
            let aUser = User()
            aUser.emailAddress = Auth.auth().currentUser?.email
            aUser.password = password
            aUser.firebaseUserId = Auth.auth().currentUser?.uid
            DataFetchManager.shared.loggedInUser = aUser
            RoutingManager.shared.gotoDashboard(controller: self)
            self.whiteOverlay = UIView(frame: self.view.bounds)
            self.whiteOverlay?.backgroundColor = UIColor(named: "SecondaryLightestColor")
            self.view.addSubview(self.whiteOverlay!)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.whiteOverlay?.isHidden = true
            }
    }
    func deleteEmailVerification(){
        DispatchQueue.global(qos: .background).async {
            if (Auth.auth().currentUser?.uid) != nil{
                Database.database().reference().child("emailVerification").child(OTPVerifyViewController.timestamp).removeValue()
            }
        }
    }
    
}
extension TimeInterval {

    var seconds: Int {
        return Int(self.rounded())
    }

    var milliseconds: Int {
        return Int(self * 1_000)
    }
}
