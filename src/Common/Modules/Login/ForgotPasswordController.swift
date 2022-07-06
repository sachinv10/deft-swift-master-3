//
//  ForgotPasswordController.swift
//  DEFT
//
//  Created by Rupendra on 31/10/21.
//  Copyright © 2021 Example. All rights reserved.
//

import UIKit


class ForgotPasswordController: BaseController {
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var emailAddress :String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "FORGOT PASSWORD"
        self.subTitle = nil
        
        self.emailAddressTextField.text = self.emailAddress
    }
    
    
    func resetPassword() {
        let aUser = User()
        aUser.emailAddress = self.emailAddressTextField.text
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.resetPassword(completion: { (pError, pUser) in
            ProgressOverlay.shared.hide()
            if let aUser = pUser {
                self.emailAddressTextField.text = nil
                PopupManager.shared.displaySuccess(message: "Password reset email sent to your email", description: aUser.emailAddress)
            } else {
                PopupManager.shared.displayError(message: "Can not reset password", description: pError?.localizedDescription ?? "Unknown error")
            }
        }, user: aUser)
    }
    
    
    @IBAction func didSelectSubmitButton(_ pSender: UIButton?) {
        self.resetPassword()
    }
    
}
