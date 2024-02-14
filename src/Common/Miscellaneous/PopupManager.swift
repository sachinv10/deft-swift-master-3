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
    
    func displayUpdateAlert(message pMessage :String, description pDescription :String?, completion pCompletion: (() -> Void)? = nil) {
        let anAlertController = UIAlertController(title: pMessage, message: pDescription, preferredStyle: UIAlertController.Style.alert)
        anAlertController.addAction(UIAlertAction(title: "VERIFY", style: UIAlertAction.Style.default, handler: { (pUIAlertAction) in
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
    
    func displaySelectinOptionPopup(message pMessage :String, description pDescription :String?, pOptionOneTitle :String, optionOneCompletion pOptionOneCompletion: @escaping (String) -> Void, pOptionTwoTitle :String, pOptionThreeTitle :String, pOptionFourTitle :String) {
        let anAlertController = UIAlertController(title: pMessage, message: pDescription, preferredStyle: UIAlertController.Style.alert)
        anAlertController.addAction(UIAlertAction(title: pOptionOneTitle, style: UIAlertAction.Style.default, handler: { _ in
            pOptionOneCompletion("2")
        }))
        anAlertController.addAction(UIAlertAction(title: pOptionTwoTitle, style: UIAlertAction.Style.default, handler: { _ in
            pOptionOneCompletion("1")
        }))
        anAlertController.addAction(UIAlertAction(title: pOptionThreeTitle, style: UIAlertAction.Style.default, handler: { _ in
            pOptionOneCompletion("3")
        }))
        anAlertController.addAction(UIAlertAction(title: pOptionFourTitle, style: UIAlertAction.Style.default, handler: { _ in
            pOptionOneCompletion("0")
        }))
        self.topViewController()!.present(anAlertController, animated: true, completion: nil)
    }
    
}


extension UIViewController {
    func showToast(message: String, duration: TimeInterval = 2.0) {
        let toast = ToastView(message: message)
        self.view.addSubview(toast)
        
        toast.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toast.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            toast.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            toast.bottomAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -16)
        ])
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
            toast.alpha = 0.0
        }, completion: { (_) in
            toast.removeFromSuperview()
        })
    }
}

class ToastView: UIView {
    init(message: String) {
        super.init(frame: CGRect.zero)
        
        // Customize the appearance of the toast view
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
        // Create and configure the label to display the message
        let label = UILabel()
        label.text = message
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 0 // Allow multiple lines if needed
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the label to the toast view
        self.addSubview(label)
        
        // Define constraints for the label
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
