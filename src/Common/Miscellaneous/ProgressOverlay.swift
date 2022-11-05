//
//  ProgressOverlay.swift
//  DEFT
//
//  Created by Rupendra on 21/08/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

/**
 The ProgressOverlay creates an overlay that can be used to indicate any application activity and to disable user interaction with the application for some time.
 */
public class ProgressOverlay: NSObject {
    /**
     The variable allows to get a singleton instance of the class.
     
     **Usage Example**
     ```swift
     ProgressOverlay.shared
     ```
     */
    public static let shared :ProgressOverlay = ProgressOverlay()
    
    
    /**
     The variable allows to have blur background for the progress overlay.
     
     **Usage Example**
     ```swift
     ProgressOverlay.shared.shouldBlurBackground = true
     ```
     */
    public var shouldBlurBackground :Bool = false
    
    
    /**
     The variable allows to set background color for the progress overlay.
     
     **Usage Example**
     ```swift
     ProgressOverlay.shared.backgroundColor = UIColor(red: 135.0/255.0, green: 206.0/255.0, blue: 250.0/255.0, alpha: 0.5)
     ```
     
     - Precondition: `shouldBlurBackground` should be set as false.
     */
    public var backgroundColor :UIColor? = nil
    
    
    /**
     The variable allows to set the visual style of the activity indicator on progress overlay.
     
     **Usage Example**
     ```swift
     ProgressOverlay.shared.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
     ```
     */
    public var activityIndicatorViewStyle :UIActivityIndicatorView.Style = UIActivityIndicatorView.Style.white
    
    
    /**
     The variable allows to hide / show the activity indicator on progress overlay.
     
     **Usage Example**
     ```swift
     ProgressOverlay.shared.isActivityIndicatorHidden = true
     ```
     */
    public var isActivityIndicatorHidden :Bool = false
    
    
    /**
     The variable allows to set the message on progress overlay.
     
     **Usage Example**
     ```swift
     ProgressOverlay.shared.message = "Loading your request, please wait until response is received from the server."
     ```
     */
    public var message :String? = nil
    
    
    /**
     The variable allows to set the message color on progress overlay.
     
     **Usage Example**
     ```swift
     ProgressOverlay.shared.messageColor = UIColor.orange
     ```
     */
    public var messageColor :UIColor? = nil
    
    private var showCount :Int = 0
    private var progressOverlayView :UIView?
    private var backgroundView :UIView?
    private var activityIndicatorView :UIActivityIndicatorView?
    private let defaultBackgroundColor :UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
    private var messageLabel :UILabel?
    private let defaultMessageColor :UIColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    
    
    /**
     Initializer.
     */
    private override init() {
        
    }
    
    
    /**
     The function allows to show the progress overlay.
     
     - Parameter pIsNetworkActivity: Parameter to show network activity indicator on status bar.
     
     **Usage Example**
     ```swift
     ProgressOverlay.shared.show() // Does not show network activity indicator on status bar.
     
     ProgressOverlay.shared.show(isNetworkActivity: true) // Shows network activity indicator on status bar.
     ```
     
     - SeeAlso: `func hide(force :Bool)`
     */
    public func show(isNetworkActivity pIsNetworkActivity :Bool = false) {
        self.showCount += 1
        
        if self.progressOverlayView != nil {
            if self.progressOverlayView!.superview != nil {
                self.progressOverlayView!.removeFromSuperview()
            }
            self.progressOverlayView = nil
        }
        self.progressOverlayView = UIView()
        self.progressOverlayView!.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
        
        // Take top-most window, as this will hide the keyboard and other windows as well.
        var aTopWindow :UIWindow? = UIApplication.shared.windows.last
        if aTopWindow == nil {
            aTopWindow = UIApplication.shared.keyWindow
        }
        aTopWindow!.addSubview(self.progressOverlayView!)
        aTopWindow!.bringSubviewToFront(self.progressOverlayView!)
        
        self.progressOverlayView!.translatesAutoresizingMaskIntoConstraints = false
        aTopWindow!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[progressOverlayView]|", options: [], metrics: nil, views: ["progressOverlayView":self.progressOverlayView!]))
        aTopWindow!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[progressOverlayView]|", options: [], metrics: nil, views: ["progressOverlayView":self.progressOverlayView!]))
        
        
        // Set up background view
        if self.backgroundView != nil {
            if self.backgroundView!.superview != nil {
                self.backgroundView!.removeFromSuperview()
            }
            self.backgroundView = nil
        }
        if self.shouldBlurBackground == true {
            self.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.light))
        } else {
            self.backgroundView = UIView()
            if self.backgroundColor != nil {
                self.backgroundView!.backgroundColor = self.backgroundColor
            } else {
                self.backgroundView!.backgroundColor = self.defaultBackgroundColor
            }
        }
        self.progressOverlayView!.addSubview(self.backgroundView!)
        
        self.backgroundView!.translatesAutoresizingMaskIntoConstraints = false
        self.progressOverlayView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundView]|", options: [], metrics: nil, views: ["backgroundView":self.backgroundView!]))
        self.progressOverlayView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundView]|", options: [], metrics: nil, views: ["backgroundView":self.backgroundView!]))
        
        
        // Set activity indicator spinner
        if self.activityIndicatorView != nil {
            if self.activityIndicatorView!.superview != nil {
                self.activityIndicatorView!.removeFromSuperview()
            }
            self.activityIndicatorView = nil
        }
        self.activityIndicatorView = UIActivityIndicatorView()
        self.activityIndicatorView!.style = self.activityIndicatorViewStyle
        self.progressOverlayView!.addSubview(self.activityIndicatorView!)
        self.progressOverlayView!.bringSubviewToFront(self.activityIndicatorView!)
        
        self.activityIndicatorView!.translatesAutoresizingMaskIntoConstraints = false
        self.progressOverlayView!.addConstraint(NSLayoutConstraint(item: self.activityIndicatorView!, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.activityIndicatorView!.superview, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0))
        self.progressOverlayView!.addConstraint(NSLayoutConstraint(item: self.activityIndicatorView!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 40))
        self.progressOverlayView!.addConstraint(NSLayoutConstraint(item: self.activityIndicatorView!, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.activityIndicatorView!.superview, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: (self.message != nil ? -25 : 0.0)))
        self.progressOverlayView!.addConstraint(NSLayoutConstraint(item: self.activityIndicatorView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 40))
        
        if self.isActivityIndicatorHidden == true {
            self.activityIndicatorView!.isHidden = true
        } else {
            self.activityIndicatorView!.startAnimating()
        }
        
        
        // Set network activity indicator on status bar
        UIApplication.shared.isNetworkActivityIndicatorVisible = pIsNetworkActivity
        
        
        // Set message label
        if self.messageLabel != nil {
            if self.messageLabel!.superview != nil {
                self.messageLabel!.removeFromSuperview()
            }
            self.messageLabel = nil
        }
        self.messageLabel = UILabel()
        self.messageLabel!.font = UIFont.systemFont(ofSize: 13.0)
        if self.messageColor != nil {
            self.messageLabel!.textColor = self.messageColor
        } else {
            self.messageLabel!.textColor = self.defaultMessageColor
        }
        self.messageLabel!.textAlignment = NSTextAlignment.center
        self.messageLabel!.numberOfLines = 0
        self.progressOverlayView!.addSubview(self.messageLabel!)
        self.progressOverlayView!.bringSubviewToFront(self.messageLabel!)
        
        self.messageLabel!.translatesAutoresizingMaskIntoConstraints = false
        self.progressOverlayView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[messageLabel]-15-|", options: [], metrics: nil, views: ["messageLabel":self.messageLabel!]))
        if self.isActivityIndicatorHidden == true {
            self.progressOverlayView!.addConstraint(NSLayoutConstraint(item: self.messageLabel!, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.messageLabel!.superview, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0.0))
        } else {
            self.progressOverlayView!.addConstraint(NSLayoutConstraint(item: self.messageLabel!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.activityIndicatorView!, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 5))
        }
        
        self.messageLabel!.text = self.message
        self.messageLabel!.isHidden = self.message == nil
    }
    
    
    /**
     The function allows to hide the progress overlay.
     
     Note that if you call show method twice, then you have to call hide method twice to hide the overlay, otherwise call hide with force parameter as true. In short it goes like, 1) show - hide - show - hide 2) show - show - hide - hide 3) show - show - hide (force :true)
     
     - Parameter pForce: Parameter to hide the progress overlay forcefully.
     
     **Usage Example**
     ```swift
     // Scenario 1
     ProgressOverlay.shared.show()
     ProgressOverlay.shared.hide()
     ProgressOverlay.shared.show()
     ProgressOverlay.shared.hide()
     
     // Scenario 2
     ProgressOverlay.shared.show()
     ProgressOverlay.shared.show()
     ProgressOverlay.shared.hide()
     ProgressOverlay.shared.hide()
     
     // Scenario 3
     ProgressOverlay.shared.show()
     ProgressOverlay.shared.show()
     ProgressOverlay.shared.hide(force: true)
     
     ```
     
     - SeeAlso: `func show(isNetworkActivity :Bool)`
     */
    public func hide(force pForce :Bool = false) {
        if pForce == true {
            self.showCount = 0
        } else {
            self.showCount -= 1
        }
        
        if self.showCount <= 0 {
            self.showCount = 0
            
            if self.backgroundView != nil {
                if self.backgroundView!.superview != nil {
                    self.backgroundView!.removeFromSuperview()
                }
                self.backgroundView = nil
            }
            
            if self.progressOverlayView != nil {
                if self.progressOverlayView!.superview != nil {
                    self.progressOverlayView!.removeFromSuperview()
                }
                self.progressOverlayView = nil
            }
            
            // Set network activity indicator
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    
    public func restoreDefaults() {
        self.backgroundColor = self.defaultBackgroundColor
        self.messageColor = self.defaultMessageColor
    }
}
