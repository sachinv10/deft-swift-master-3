//
//  ChangePasswordViewController.swift
//  Wifinity
//
//  Created by Apple on 29/04/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
class ChangePasswordViewController: BaseController {
    var userProfile = UserVerify()

    override func viewDidLoad() {
        super.viewDidLoad()
         title = "Change Password"
         subTitle = ""
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UiSetUp()
    }
    func UiSetUp()  {
        lblcurrentLogin.setTitle("", for: .normal)
        lblNewLogin.setTitle("", for: .normal)
        lblConfirmLogin.setTitle("", for: .normal)
    }
    //MARK: - outlate
    
    @IBOutlet weak var txtfldCurrentLogin: UITextField!
    @IBOutlet weak var txtfldNewLogin: UITextField!
    @IBOutlet weak var txtfldConfirmNewLogin: UITextField!
    
    
    @IBOutlet weak var lblcurrentLogin: UIButton!
    @IBOutlet weak var lblNewLogin: UIButton!
    @IBOutlet weak var lblConfirmLogin: UIButton!
 
    @IBAction func currentLoginPasswordSequery(_ sender: Any) {
        if 0 == (sender as AnyObject).tag{
            lblcurrentLogin.tag = 1
            lblcurrentLogin.setImage(UIImage(named: "show"), for: .normal)
            txtfldCurrentLogin.isSecureTextEntry = false
        }else if 1 == (sender as AnyObject).tag{
            lblcurrentLogin.tag = 0
            lblcurrentLogin.setImage(UIImage(named: "hide"), for: .normal)
            txtfldCurrentLogin.isSecureTextEntry = true
        }
        if 2 == (sender as AnyObject).tag{
            lblNewLogin.tag = 3
            lblNewLogin.setImage(UIImage(named: "show"), for: .normal)
            txtfldNewLogin.isSecureTextEntry = false
        }else if 3 == (sender as AnyObject).tag{
            lblNewLogin.tag = 2
            lblNewLogin.setImage(UIImage(named: "hide"), for: .normal)
            txtfldNewLogin.isSecureTextEntry = true
        }
        if 4 == (sender as AnyObject).tag{
            lblConfirmLogin.tag = 5
            lblConfirmLogin.setImage(UIImage(named: "show"), for: .normal)
            txtfldConfirmNewLogin.isSecureTextEntry = false
        }else if 5 == (sender as AnyObject).tag{
            lblConfirmLogin.tag = 4
            lblConfirmLogin.setImage(UIImage(named: "hide"), for: .normal)
            txtfldConfirmNewLogin.isSecureTextEntry = true
        }
    }
    
    @IBAction func didtappedSubmit(_ sender: Any) {
        if txtfldConfirmNewLogin.text == txtfldNewLogin.text && txtfldCurrentLogin.text != nil{
            // hit api
            guard let currentUser = Auth.auth().currentUser else {
                return
            }
            if  let userId = Auth.auth().currentUser?.email{
                let credential = EmailAuthProvider.credential(withEmail: userId, password: txtfldCurrentLogin.text ?? "")
                
                currentUser.reauthenticate(with: credential) { (result, error) in
                    if let error = error {
                        // An error occurred while reauthenticating.
                        print("Error reauthenticating: \(error.localizedDescription)")
                    } else {
                        // The user has been successfully reauthenticated.
                        print("User reauthenticated.")
                        self.updatePassword()
                    }
                }
            }
        }
    }
    func updatePassword()  {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
         if txtfldNewLogin.text == txtfldConfirmNewLogin.text, let pass = txtfldNewLogin.text{
        currentUser.updatePassword(to: pass) { (error) in
            if let error = error {
                // An error occurred while updating the password.
                print("Error updating password: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    PopupManager.shared.displayError(message: "", description: error.localizedDescription)
                }
            } else {
                // The password has been successfully updated.
                DispatchQueue.main.async {
                    PopupManager.shared.displayError(message: "The password has been successfully updated.", description: "", completion: {
                        self.navigationController?.popViewController(animated: true)
                    })
                   
                }
            }
        }
    }
    }
}
