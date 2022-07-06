//
//  BaseController.swift
//  DEFT
//
//  Created by Rupendra on 21/08/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class BaseController: UIViewController {
    @IBOutlet weak var appHeaderBarView: AppHeaderBarView?
    
    override var title: String? {
        didSet {
            self.appHeaderBarView?.title = self.title
        }
    }
    
    var subTitle: String? {
        didSet {
            self.appHeaderBarView?.subTitle = self.subTitle
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = UIUserInterfaceStyle.light
        }
        
        self.view.backgroundColor = UIColor(named: "PrimaryLightestColor")
        self.appHeaderBarView?.backgroundColor = UIColor(named: "SecondaryLightestColor")
        self.appHeaderBarView?.delegate = self
        if let anAppHeaderBarView = self.appHeaderBarView, let aHeightConstraint = UtilityManager.heightConstraint(view: anAppHeaderBarView) {
            if UtilityManager.hasTopNotch {
                aHeightConstraint.constant = 95
            } else {
                aHeightConstraint.constant = 75
            }
        }
        
//        NotificationCenter.default.addObserver(self, selector: #selector(BaseController.orientationDidChangeNotificationReceived(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(self.didUpdateDatabase), name: NSNotification.Name(DataFetchManager.databaseValueChangedNotificationName), object: nil)
        
        let aGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapView(_:)))
        aGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(aGesture)
    }
    
    
    override func viewDidAppear(_ pAnimated: Bool) {
        super.viewDidAppear(pAnimated)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        if self.isLoadedOnce == false {
            self.isLoadedOnce = true
            self.reloadAllData()
        }
    }
    
    
    @objc func didUpdateDatabase() {
        self.reloadAllData()
    }
    
    
    var isLoadedOnce :Bool = false
    
    func reloadAllData() {
        
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(DataFetchManager.databaseValueChangedNotificationName), object: nil)
    }
    
    
    @IBAction func didSelectBackButton(_ pSender: UIButton?) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc private func orientationDidChangeNotificationReceived(_ pSender :Notification) {
        self.orientationDidChange()
    }
    
    
    func orientationDidChange() {
        
    }
    
    
    @objc func didTapView(_ pSender :UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}


extension BaseController :UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


extension BaseController :AppHeaderBarViewDelegate {
    
    func appHeaderBarDidSelectBackButton(_ pSender: AppHeaderBarView) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
