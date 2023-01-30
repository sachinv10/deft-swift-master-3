//
//  CreateAccountViewController.swift
//  Wifinity
//
//  Created by Apple on 30/11/22.
//

import UIKit

class CreateAccountViewController: BaseController {

    
    
    
    @IBOutlet weak var textfldUserName: UITextField!
    @IBOutlet weak var textfldPhoneNumber: UITextField!
    
    @IBOutlet weak var textfldPassword: UITextField!
    @IBOutlet weak var textfldEmail: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        subTitle = ""
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);
      
       
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        print("disappear Create Account ViewController")
    }
    func random(digits:Int) -> String {
        var number = String()
        for _ in 1...digits {
           number += "\(Int.random(in: 1...9))"
        }
        return number
    }
    @objc func keyboardWillShow(sender: NSNotification) {
         self.view.frame.origin.y = -220 // Move view 150 points upward
    }

    @objc func keyboardWillHide(sender: NSNotification) {
         self.view.frame.origin.y = 0 // Move view to original position
    }
    static var massege = String()

    @IBAction func didTappedVerifiybtn(_ sender: Any) {
 
        let potp = random(digits: 6)
        print("otp",potp)
        if textfldEmail.text!.count > 0, !potp.isEmpty, !textfldUserName.text!.isEmpty, !textfldPhoneNumber.text!.isEmpty, !textfldPassword.text!.isEmpty{
            DataFetchManager.shared.verifyEmail(completion: { [self] (pError, pCurtainArray) in
                ProgressOverlay.shared.hide()
                if pError != nil {
                    PopupManager.shared.displayError(message: "OTP cant send", description: pError!.localizedDescription)
                } else {
                    if pCurtainArray == "200" {
                        RoutingManager.shared.gotoVerifyOtp(controller: self, msg: pCurtainArray!, userName: textfldUserName.text!, phoneN: textfldPhoneNumber.text!, password: textfldPassword.text!, otp: potp, email: textfldEmail.text!)
                        
                    }else{
                         PopupManager.shared.displayError(message: CreateAccountViewController.massege, description: "")
                    }
                    print("Data fetch curtun vc")
                    //  self.reloadAllView()
                }
            }, email: textfldEmail.text ?? "", Otp: potp)
            
        }else{
             PopupManager.shared.displayError(message: "Please enter all details", description: "")

        }
   
    }
    
}
