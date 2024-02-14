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
    
    @IBOutlet weak var lblAppMode: UIButton!
    var menuItemsForAccepted: [UIAction] {
        return [
            UIAction(title: "Online", image: nil, handler: { (_) in
               // self.addAppliance()
                Database.database().isPersistenceEnabled = false
                UserDefaults.standard.set("Online", forKey: "Mode")
             }),
            UIAction(title: "Online and offLine", image: nil, handler: { (_) in
                self.offlineModeConfig()
                UserDefaults.standard.set("Online and offLine", forKey: "Mode")
             })
        ]
    }
   
    /**
     * UIViewController method, called after the view has been loaded.
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
      //  Database.database().isPersistenceEnabled = true
 
        if #available(iOS 14.0, *) {
            lblAppMode.menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItemsForAccepted)
            lblAppMode.showsMenuAsPrimaryAction = true
        } else {
            // Fallback on earlier versions
        }
        if UserDefaults.standard.value(forKey: "userId") != nil{
            modeConfig()
            demologin()
          }
        
         //   else if let anEmailAddress = KeychainManager.shared.getValue(forKey: "emailAddress"), let aPassword = KeychainManager.shared.getValue(forKey: "password") {
//            self.emailAddressTextField.text = anEmailAddress
//            self.passwordTextField.text = aPassword
//            self.whiteOverlay = UIView(frame: self.view.bounds)
//            self.whiteOverlay?.backgroundColor = UIColor(named: "SecondaryLightestColor")
//            self.view.addSubview(self.whiteOverlay!)
//            self.login()
//        }
            else{
            
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
        lblpassUnmask.setTitle("", for: .normal)
        lbldropdown.setTitle("", for: .normal)
  
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTableView()
        print("viewWillAppear")
        let mode = UserDefaults.standard.string(forKey: "Mode")
    }
   
    override func viewDidAppear(_ pAnimated: Bool) {
        super.viewDidAppear(pAnimated)
        self.whiteOverlay?.frame = self.view.bounds
        
        if ConfigurationManager.shared.isDebugMode {
            if ConfigurationManager.shared.appType == ConfigurationManager.AppType.wifinity
            {
                self.emailAddressTextField.text = "wifinity@gmail.com"
            } else {
                self.emailAddressTextField.text = "deft.ios@gmail.com"
            }
        }
    }
    func modeConfig(){
        let mode = UserDefaults.standard.string(forKey: "Mode")
        if mode != "Online and offLine"{
            Database.database().isPersistenceEnabled = false
        }else{
            offlineModeConfig()
        }
    }
    func offlineModeConfig()
    {
        Database.database().isPersistenceEnabled = true
        let dataReff = Database.database().reference().child("vdpDevices")
        dataReff.keepSynced(true)
         let applincesdata = Database.database().reference().child("standaloneUserDetails")
             applincesdata.keepSynced(true)
        
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
          //  self.saveAppNotificationSettings(completion: {
                RoutingManager.shared.gotoDashboard(controller: self)
          //  })
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
                DataFetchManager.shared.updateUserDetail(completion: {(error, user) in }, user: pUser!)
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
    
    private func setupTableView() {
        sortedKeys.removeAll()
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: "myUserProfile") {
            let decoder = PropertyListDecoder()
            if let decoded = try? decoder.decode([[String: String]].self, from: data) {
                print(decoded) // [["name": "John", "age": 25], ["name": "Jane", "age": 30], ["name": "Bob", "age": 20]]
            sortedKeys = decoded
            }
        }
        viewtbl.frame = CGRect(x: 50, y: 450, width: Int(UIScreen.main.bounds.width) - 100, height: 50 * sortedKeys.count)
        viewtbl.backgroundColor = .white
        tableView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width) - 100, height: 50 * sortedKeys.count)
        viewtbl.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        viewtbl.isHidden = true
        self.view.addSubview(viewtbl)
   
    }
    let tableView = UITableView()
    @IBOutlet weak var lbldropdown: UIButton!
    
    @IBAction func didtappeddropdown(_ sender: Any) {
   
       userDropdown()
    }
    
    var viewtbl = UIView()
    func userDropdown(){
        if viewtbl.isHidden == true{
            viewtbl.isHidden = false
        }else{
            viewtbl.isHidden = true
        }
        tableView.reloadData()
    }
    /**
     * Method that will be called when user selects the login button.
     */
    @IBAction func didSelectLoginButton(_ pSender: UIButton?) {
         if self.rememberMeCheckboxButton?.image(for: UIControl.State.normal) != nil {
             let userProfile = [passwordTextField.text: emailAddressTextField.text]
             let aUser = UserAuth()
            var userp = ["self.emailAddressTextField.text": "self.passwordTextField.text"]
             userp.removeAll()
             userp = [emailAddressTextField.text!: passwordTextField.text!]
             var isprofilePesent = false
             for item in sortedKeys{
                 if item.first?.key == emailAddressTextField.text!{
                     isprofilePesent = false
                     sortedKeys = sortedKeys.filter({(pObject)-> Bool in
                         return item.first?.key != pObject.first?.key
                    })
                 }
             }
             if isprofilePesent != true{
                 sortedKeys.append(userp)
             }
             let defaults = UserDefaults.standard
             let encoder = PropertyListEncoder()
             if let encoded = try? encoder.encode(sortedKeys) {
                 defaults.set(encoded, forKey: "myUserProfile")
             }
        }
        self.login()
    }
    var sortedKeys = [[String: String]()]
    @IBOutlet weak var lblpassUnmask: UIButton!
    @IBAction func didtappedPasswordUnmask(_ sender: Any) {
        if (sender as AnyObject).tag == 0{
            lblpassUnmask.tag = 1
            passwordTextField.isSecureTextEntry = false
            lblpassUnmask.setImage(UIImage(named: "show"), for: .normal)
        }else{
            lblpassUnmask.tag = 0
            passwordTextField.isSecureTextEntry = true
            lblpassUnmask.setImage(UIImage(named: "hide"), for: .normal)
        }
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
extension LoginController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      //  return 3 // For example
         return sortedKeys.count // For example
     }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: CustomTableViewCell.identifier)
        let name = sortedKeys[indexPath.row]
        print(name.keys)
        let credentioal = sortedKeys[indexPath.row]
        let names = credentioal.first?.key
        cell.textLabel?.text = names
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected auth= \(sortedKeys[indexPath.row].keys)")
        let credentioal = sortedKeys[indexPath.row]
        print(credentioal.first?.key)
        emailAddressTextField.text = credentioal.first?.key
        passwordTextField.text = credentioal.first?.value
        viewtbl.isHidden = true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            PopupManager.shared.displayConfirmation(message: "Do you want to delete selected Credential?", description: nil, completion: { [self] in
            let credentioal = sortedKeys[indexPath.row]
            sortedKeys = sortedKeys.filter({(pObject)-> Bool in
                return pObject.first?.key != credentioal.first?.key
            })
                tableView.reloadData()
            })

       }
    }
}
class CustomTableViewCell: UITableViewCell {
    static let identifier = "CustomTableViewCell"
}
