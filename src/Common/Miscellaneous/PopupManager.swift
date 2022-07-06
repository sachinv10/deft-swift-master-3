//
//  PopupManager.swift
//  DEFT
//
//  Created by Rupendra on 21/08/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class PopupManager: NSObject {
    /**
     * Variable that will hold singleton instance of PopupManager.
     */
    static var shared :PopupManager = {
        return PopupManager()
    }()
    
    
    private func topViewController(controller pController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        var aReturnVal :UIViewController?
        
        if let aNavigationController = pController as? UINavigationController {
            aReturnVal = self.topViewController(controller: aNavigationController.visibleViewController)
        } else if let aTabController = pController as? UITabBarController, let aSelectedViewController = aTabController.selectedViewController {
            aReturnVal = self.topViewController(controller: aSelectedViewController)
        } else if let aPresentedViewController = pController?.presentedViewController {
            aReturnVal = self.topViewController(controller: aPresentedViewController)
        } else {
            aReturnVal = pController
        }
        
        return aReturnVal
    }
    
    
    /**
     * Method that displays error to user.
     * @param: pMessage. String. Message to be displayed.
     * @param: pDescription. String. Description i.e additional information to be displayed.
     */
    func displayError(message pMessage :String, description pDescription :String?, completion pCompletion: (() -> Void)? = nil) {
        let anAlertController = UIAlertController(title: pMessage, message: pDescription, preferredStyle: UIAlertController.Style.alert)
        anAlertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (pUIAlertAction) in
            pCompletion?()
        }))
        self.topViewController()!.present(anAlertController, animated: true, completion: nil)
    }
    
    
    /**
     * Method that displays success to user.
     * @param: pMessage. String. Message to be displayed.
     * @param: pDescription. String. Description i.e additional information to be displayed.
     */
    func displaySuccess(message pMessage :String, description pDescription :String?, completion pCompletion: (() -> Void)? = nil) {
        let anAlertController = UIAlertController(title: pMessage, message: pDescription, preferredStyle: UIAlertController.Style.alert)
        anAlertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (pUIAlertAction) in
            pCompletion?()
        }))
        self.topViewController()!.present(anAlertController, animated: true, completion: nil)
    }
    
    
    /**
     * Method that displays information to user.
     * @param: pMessage. String. Message to be displayed.
     * @param: pDescription. String. Description i.e additional information to be displayed.
     */
    func displayInformation(message pMessage :String, description pDescription :String?, completion pCompletion: (() -> Void)? = nil) {
        let anAlertController = UIAlertController(title: pMessage, message: pDescription, preferredStyle: UIAlertController.Style.alert)
        anAlertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (pUIAlertAction) in
            pCompletion?()
        }))
        self.topViewController()!.present(anAlertController, animated: true, completion: nil)
    }
    
    
    /**
     * Method that asks confirmation to user.
     * @param: pMessage. String. Message to be displayed.
     * @param: pDescription. String. Description i.e additional information to be displayed.
     * @param: pCompletion. () -> Void. Closure that should be called when user confirms by tapping on YES.
     */
    func displayConfirmation(message pMessage :String, description pDescription :String?, completion pCompletion: @escaping () -> Void) {
        let anAlertController = UIAlertController(title: pMessage, message: pDescription, preferredStyle: UIAlertController.Style.alert)
        anAlertController.addAction(UIAlertAction(title: "YES", style: UIAlertAction.Style.default, handler: { _ in
            pCompletion()
        }))
        anAlertController.addAction(UIAlertAction(title: "NO", style: UIAlertAction.Style.cancel, handler: nil))
        self.topViewController()!.present(anAlertController, animated: true, completion: nil)
    }
    
    
    func displayBooleanOptionPopup(message pMessage :String, description pDescription :String?, pOptionOneTitle :String, optionOneCompletion pOptionOneCompletion: @escaping () -> Void, pOptionTwoTitle :String, optionTwoCompletion pOptionTwoCompletion: @escaping () -> Void) {
        let anAlertController = UIAlertController(title: pMessage, message: pDescription, preferredStyle: UIAlertController.Style.alert)
        anAlertController.addAction(UIAlertAction(title: pOptionOneTitle, style: UIAlertAction.Style.default, handler: { _ in
            pOptionOneCompletion()
        }))
        anAlertController.addAction(UIAlertAction(title: pOptionTwoTitle, style: UIAlertAction.Style.default, handler: { _ in
            pOptionTwoCompletion()
        }))
        self.topViewController()!.present(anAlertController, animated: true, completion: nil)
    }
    
}
