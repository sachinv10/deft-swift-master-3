//
//  LoginController.swift
//  DEFT
//
//  Created by Rupendra on 21/08/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginController: BaseController {
    /**
    * Variable that will hold reference to email address text field.
    */
    @IBOutlet weak var emailAddressTextField: UITextField!
    
    /**
    * Variable that will hold reference to password text field.
    */
    @IBOutlet weak var passwordTextField: UITextField!
    
    /**
    * Variable that will hold reference to login button.
    */
    @IBOutlet weak var loginButton: UIButton!
    
    /**
    * Variable that will hold reference to add user button.
    */
    @IBOutlet weak var addUserButton: UIButton?
    
    /**
    * Variable that will hold reference to demo button.
    */
    @IBOutlet weak var demoButton: UIButton?
    
    /**
    * Variable that will hold reference to remember me checkbox button.
    */
    @IBOutlet weak var rememberMeCheckboxButton: UIButton?
    
    var whiteOverlay :UIView?
    
    
    /**
    * UIViewController method, called after the view has been loaded.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
      //   Database.database().isPersistenceEnabled = true
        
        if ((Auth.auth().currentUser?.uid) != nil){
            demologin()
        }else if let anEmailAddress = KeychainManager.shared.getValue(forKey: "emailAddress"), let aPassword = KeychainManager.shared.getValue(forKey: "password") {
            self.emailAddressTextField.text = anEmailAddress
            self.passwordTextField.text = aPassword
            self.whiteOverlay = UIView(frame: self.view.bounds)
            self.whiteOverlay?.backgroundColor = UIColor(named: "SecondaryLightestColor")
            self.view.addSubview(self.whiteOverlay!)
            self.login()
        }else{
        
        self.emailAddressTextField.attributedPlaceholder = NSAttributedString(string: "Email Address", attributes: [NSAttributedString.Key.foregroundColor : UIColor(named: "SecondaryDarkColor")!])
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor(named: "SecondaryDarkColor")!])
        
        self.updateTextFieldUi(self.emailAddressTextField)
        self.updateTextFieldUi(self.passwordTextField)
        
        self.updatePushButtonUi(self.loginButton)
        if let anAddUserButton = self.addUserButton {
            self.updatePushButtonUi(anAddUserButton)
        }
        if let aDemoButton = self.demoButton {
            self.updatePushButtonUi(aDemoButton)
        }
        
        self.rememberMeCheckboxButton?.layer.borderWidth = 1.0
        self.rememberMeCheckboxButton?.layer.borderColor = UIColor(named: "SecondaryDarkColor")?.cgColor
        self.rememberMeCheckboxButton?.layer.cornerRadius = 4.0
        
        }
    }
  
    
    override func viewDidAppear(_ pAnimated: Bool) {
        super.viewDidAppear(pAnimated)
        
        self.whiteOverlay?.frame = self.view.bounds
        
        if ConfigurationManager.shared.isDebugMode {
            if ConfigurationManager.shared.appType == ConfigurationManager.AppType.wifinity {
                self.emailAddressTextField.text = "wifinity@gmail.com"
            } else {
                self.emailAddressTextField.text = "deft.ios@gmail.com"
            }
        }
    }
    
    func gotochecken() {

            if let anEmailAddress = KeychainManager.shared.getValue(forKey: "emailAddress"), let aPassword = KeychainManager.shared.getValue(forKey: "password") {
                self.emailAddressTextField.text = anEmailAddress
                self.passwordTextField.text = aPassword
                self.whiteOverlay = UIView(frame: self.view.bounds)
                self.whiteOverlay?.backgroundColor = UIColor(named: "SecondaryLightestColor")
                self.view.addSubview(self.whiteOverlay!)
                self.login()
            }else{
            
            self.emailAddressTextField.attributedPlaceholder = NSAttributedString(string: "Email Address", attributes: [NSAttributedString.Key.foregroundColor : UIColor(named: "SecondaryDarkColor")!])
            self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor(named: "SecondaryDarkColor")!])
            
            self.updateTextFieldUi(self.emailAddressTextField)
            self.updateTextFieldUi(self.passwordTextField)
            
            self.updatePushButtonUi(self.loginButton)
            if let anAddUserButton = self.addUserButton {
                self.updatePushButtonUi(anAddUserButton)
            }
            if let aDemoButton = self.demoButton {
                self.updatePushButtonUi(aDemoButton)
            }
            
            self.rememberMeCheckboxButton?.layer.borderWidth = 1.0
            self.rememberMeCheckboxButton?.layer.borderColor = UIColor(named: "SecondaryDarkColor")?.cgColor
            self.rememberMeCheckboxButton?.layer.cornerRadius = 4.0
            
            }
        
    }
    func demologin(){
        if let anEmailAddress = KeychainManager.shared.getValue(forKey: "emailAddress"), let aPassword = KeychainManager.shared.getValue(forKey: "password"){
            _ = KeychainManager.shared.save(key: "emailAddress", value: anEmailAddress)
            _ = KeychainManager.shared.save(key: "password", value: aPassword)
            let aUser = User()
            aUser.emailAddress = Auth.auth().currentUser?.email
            aUser.password = aPassword
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
    }
    func login() {
        let aUser = User()
        aUser.emailAddress = self.emailAddressTextField.text
        aUser.password = self.passwordTextField.text
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.login(completion: { (pError, pUser) in
        ProgressOverlay.shared.hide()
            if pUser != nil {
                if let anEmailAddress = self.emailAddressTextField.text, let aPassword = self.passwordTextField.text {
                    _ = KeychainManager.shared.save(key: "emailAddress", value: anEmailAddress)
                    _ = KeychainManager.shared.save(key: "password", value: aPassword)
                   }
                self.emailAddressTextField.text = nil
                self.passwordTextField.text = nil
                DataFetchManager.shared.loggedInUser = pUser
                
                self.saveAppNotificationSettings(completion: {
                    RoutingManager.shared.gotoDashboard(controller: self)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                        self.whiteOverlay?.isHidden = true
                    }
                })
            } else {
                self.whiteOverlay?.isHidden = true
                PopupManager.shared.displayError(message: "Can not login", description: pError?.localizedDescription ?? "Unknown error")
            }
        }, user: aUser)
    }
    
    func saveAppNotificationSettings(completion pCompletion :@escaping(()->())) {
        if let aUserId = DataFetchManager.shared.loggedInUser?.firebaseUserId
        , let anAppNotificationSettings = CacheManager.shared.appNotificationSettings(userId: aUserId) {
            DataFetchManager.shared.saveAppNotificationSettings(completion: { (pError, pAppNotificationSettings) in
                pCompletion()
            }, appNotificationSettings: anAppNotificationSettings)
        } else {
            pCompletion()
        }
    }
    
    @IBAction func didtappedCreateNewAccount(_ sender: Any) {
        RoutingManager.shared.gotoCreateAccount(controller: self)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    
    /**
    * Method that will update the text field UI.
    * @param UITextField. Text field of which UI is to be updated.
    */
    private func updateTextFieldUi(_ pTextField :UITextField) {
        let aBottomLine = CALayer()
        aBottomLine.frame = CGRect(x: 0.0, y: pTextField.frame.height - 1, width: pTextField.frame.width, height: 1.0)
        aBottomLine.backgroundColor = UIColor(named: "SecondaryDarkColor")?.cgColor
        pTextField.borderStyle = UITextField.BorderStyle.none
        pTextField.layer.addSublayer(aBottomLine)
    }
    
    
    /**
    * Method that will update the push button UI.
    * @param UIButton. Button of which UI is to be updated.
    */
    private func updatePushButtonUi(_ pButton :UIButton) {
        pButton.layer.borderWidth = 1.0
        pButton.layer.borderColor = UIColor(named: "SecondaryDarkColor")?.cgColor
        pButton.layer.cornerRadius = 4.0
    }
    
    
    /**
    * Method that will be called when user selects the login button.
    */
    @IBAction func didSelectLoginButton(_ pSender: UIButton?) {
        self.login()
    }
    
    
    /**
    * Method that will be called when user selects the remember me button.
    */
    @IBAction func didSelectRememberMeButton(_ pSender: UIButton?) {
        if self.rememberMeCheckboxButton?.image(for: UIControl.State.normal) == nil {
            self.rememberMeCheckboxButton?.setImage(UIImage(named: "Checkmark"), for: UIControl.State.normal)
        } else {
            self.rememberMeCheckboxButton?.setImage(nil, for: UIControl.State.normal)
        }
    }
    
    
    @IBAction func didSelectForgotPasswordButton(_ pSender: UIButton?) {
        RoutingManager.shared.gotoForgotPassword(controller: self, emailAddress: self.emailAddressTextField.text)
    }
    
}



extension LoginController :UITextFieldDelegate {
    func textFieldShouldReturn(_ pTextField: UITextField) -> Bool {
        if pTextField.isEqual(self.emailAddressTextField) {
            self.passwordTextField.becomeFirstResponder()
        } else if pTextField.isEqual(self.passwordTextField) {
            self.view.endEditing(true)
        }
        return true
    }
}
