//
//  RemoteDetailsController.swift
//  DEFT
//
//  Created by Rupendra on 26/09/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class RemoteDetailsController: BaseController {
    var selectedRemote :Remote?
    
    @IBOutlet weak var dynamicButtonContainerView :DynamicButtonContainerView!
    
    @IBOutlet weak var remoteControlScrollView :UIScrollView!
    var remoteControl :RemoteControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "REMOTE DETAILS"
        self.subTitle = self.selectedRemote?.title
        
        self.dynamicButtonContainerView.isForAppliance = false
        self.dynamicButtonContainerView.delegate = self
        
        self.reloadAllView()
    }
    
    
    override func viewDidAppear(_ pAnimated: Bool) {
        super.viewDidAppear(pAnimated)
        
        self.dynamicButtonContainerView.toggle(forceCollpase: true)
        self.reloadAllData()
        self.remoteObserver()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Database.database().reference().removeAllObservers()
    }
    func remoteObserver(){
        if let aRemote = self.selectedRemote {
            DataFetchManager.shared.remoteChangesObserver(completion: {(error, remote) in
                self.reloadAllData()
            }, remote: aRemote)
        }
    }
    
    override func reloadAllData() {
        if let aRemote = self.selectedRemote {
            // ProgressOverlay.shared.show()
            DataFetchManager.shared.remoteDetails(completion: { (pError, pRemote) in
                // ProgressOverlay.shared.hide()
                if pError != nil {
                    PopupManager.shared.displayError(message: "Can not search remotes", description: pError!.localizedDescription)
                } else {
                    self.selectedRemote = pRemote
                    self.reloadAllView()
                }
            }, remote: aRemote)
        }
    }
    
    
    func reloadAllView() {
        var aRemoteControl :RemoteControl? = nil
        print(self.selectedRemote!.type!)
        switch self.selectedRemote?.type {
        case .ac:
            if !(self.remoteControl is AcRemoteControl) {
                aRemoteControl = AcRemoteControl()
            }
        case .tv:
            if !(self.remoteControl is TvRemoteControl) {
                aRemoteControl = TvRemoteControl()
            }
        case .moodLight:
            if !(self.remoteControl is MoodLightRemoteControl) {
                aRemoteControl = MoodLightRemoteControl()
            }
        case .musicSystem:
            if !(self.remoteControl is DvdRemoteControl) {
                aRemoteControl = DvdRemoteControl()
            }
        case .dvd:
            if !(self.remoteControl is DvdRemoteControl) {
                aRemoteControl = DvdRemoteControl()
            }
        case .setTopBox:
            if !(self.remoteControl is TvRemoteControl) {
                aRemoteControl = TvRemoteControl()
            }
        case .projector:
            if !(self.remoteControl is ProjectorRemoteControl) {
                aRemoteControl = ProjectorRemoteControl()
            }
        case .ledStrip:
            if !(self.remoteControl is LedStripRemoteControl) {
                aRemoteControl = LedStripRemoteControl()
            }
        case .fan:
            if !(self.remoteControl is FanRemoteControl) {
                aRemoteControl = FanRemoteControl()
            }
        case .irFan:
            if !(self.remoteControl is IRFanRemoteControl) {
                aRemoteControl = IRFanRemoteControl()
            }
        case .none:
            break
        }
        
        if let aRemoteControl = aRemoteControl {
            var aTopPadding :Int = 20
            if UtilityManager.shared.screenSizeType == UtilityManager.ScreenSizeType.small {
                aTopPadding = 16
            } else if UtilityManager.shared.screenSizeType == UtilityManager.ScreenSizeType.medium {
                aTopPadding = 22
            } else {
                aTopPadding = 30
            }
            self.remoteControlScrollView.addSubview(aRemoteControl)
            aRemoteControl.translatesAutoresizingMaskIntoConstraints = false
            let aHorizontalAlignConstraint = NSLayoutConstraint(
                item: aRemoteControl
                , attribute: NSLayoutConstraint.Attribute.centerX
                , relatedBy: NSLayoutConstraint.Relation.equal
                , toItem: self.remoteControlScrollView
                , attribute: NSLayoutConstraint.Attribute.centerX
                , multiplier: 1
                , constant: 0)
            self.view.addConstraint(aHorizontalAlignConstraint)
            
            let aWidthConstraint = NSLayoutConstraint(
                item: aRemoteControl
                , attribute: NSLayoutConstraint.Attribute.width
                , relatedBy: NSLayoutConstraint.Relation.equal
                , toItem: nil
                , attribute: NSLayoutConstraint.Attribute.notAnAttribute
                , multiplier: 1
                , constant: aRemoteControl.estimatedSize.width)
            self.view.addConstraint(aWidthConstraint)
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: String(format: "V:|-%d-[aRemoteControl(%d)]-0-|", aTopPadding, Int(aRemoteControl.estimatedSize.height)), options: [], metrics: nil, views: ["aRemoteControl":aRemoteControl]))
            
            aRemoteControl.addTarget(self, action: #selector(self.remoteControlDidChageValue(_:)), for: UIControl.Event.valueChanged)
            aRemoteControl.addTarget(self, action: #selector(self.remoteControlDidBeginEditing(_:)), for: UIControl.Event.editingDidBegin)
            self.remoteControl = aRemoteControl
        }
        
        if let aRemote = self.selectedRemote {
            self.remoteControl?.load(remote: aRemote)
            self.dynamicButtonContainerView.load(remote: aRemote)
            self.view.bringSubviewToFront(self.dynamicButtonContainerView)
        }
    }
    
    
    private func clickRemoteKey(_ pRemoteKey :RemoteKey) {
        let aRemoteKey = pRemoteKey.clone()
        aRemoteKey.timestamp = Int(Date().timeIntervalSince1970 * 1000)
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.clickRemoteKey(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not click remote key.", description: pError!.localizedDescription)
            } else {
                if let aTag = aRemoteKey.tag, let anOldRemoteKey = self.selectedRemote?.keyWithTag(aTag) {
                    self.selectedRemote?.replace(key: anOldRemoteKey, withKey: aRemoteKey)
                }
                self.reloadAllView()
            }
        }, remote: self.selectedRemote!, remoteKey: aRemoteKey)
    }
    
    
    @IBAction private func remoteControlDidChageValue(_ pSender: RemoteControl) {
        if let aRemoteKey = pSender.remoteKey {
            self.clickRemoteKey(aRemoteKey)
        }
    }
    
    @IBAction private func remoteControlDidBeginEditing(_ pSender: RemoteControl) {
        if let aRemote = self.selectedRemote
        , let aRemoteKey = pSender.remoteKey {
            RoutingManager.shared.gotoUpdateRemoteButton(controller: self, selectedRemote: aRemote, selectedRemoteKey: aRemoteKey)
        }
    }
}


extension RemoteDetailsController :DynamicButtonContainerViewDelegate {
    func dynamicButtonContainerView(_ pSender: DynamicButtonContainerView, didSelectRemoteKey pRemoteKey: RemoteKey) {
        self.clickRemoteKey(pRemoteKey)
    }
    
    func dynamicButtonContainerView(_ pSender: DynamicButtonContainerView, didSelectEditRemoteKey pRemoteKey: RemoteKey) {
        if let aRemote = self.selectedRemote {
            RoutingManager.shared.gotoUpdateRemoteButton(controller: self, selectedRemote: aRemote, selectedRemoteKey: pRemoteKey)
        }
    }
}
