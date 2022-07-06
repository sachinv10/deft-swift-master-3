//
//  UpdateRemoteButtonController.swift
//  DEFT
//
//  Created by Rupendra on 07/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit


class UpdateRemoteButtonController: BaseController {
    @IBOutlet weak var remoteButtonTitleTextField: UITextField!
    @IBOutlet weak var commandTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    var selectedRemote :Remote?
    var selectedRemoteKey :RemoteKey?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "UPDATE REMOTE BUTTON"
        self.subTitle = nil
        
        self.commandTextView.textContainerInset = UIEdgeInsets.zero
        self.commandTextView.textContainer.lineFragmentPadding = 0
        
        self.reloadAllView()
    }
    
    
    override func viewDidAppear(_ pAnimated: Bool) {
        super.viewDidAppear(pAnimated)
        
        self.reloadAllData()
    }
    
    
    override func reloadAllData() {
        if let aRemote = self.selectedRemote {
            // ProgressOverlay.shared.show()
            DataFetchManager.shared.remoteDetails(completion: { (pError, pRemote) in
                // ProgressOverlay.shared.hide()
                if pError != nil {
                    PopupManager.shared.displayError(message: "Can not fetch remote details", description: pError!.localizedDescription)
                } else {
                    self.selectedRemote = pRemote
                    if let aKeyId = self.selectedRemoteKey?.id {
                        self.selectedRemoteKey = self.selectedRemote?.keyWithId(aKeyId)
                    }
                    self.reloadAllView()
                }
            }, remote: aRemote)
        }
    }
    
    
    func reloadAllView() {
        if let aRemoteKey = self.selectedRemoteKey {
            if let aTag = aRemoteKey.tag {
                self.remoteButtonTitleTextField.isEnabled = false
                self.remoteButtonTitleTextField.text = aTag.rawValue
                self.saveButton.isEnabled = false
            } else {
                self.remoteButtonTitleTextField.isEnabled = true
                self.remoteButtonTitleTextField.text = aRemoteKey.title
                self.saveButton.isEnabled = true
            }
            self.commandTextView.text = aRemoteKey.command
        }
    }
    
    
    private func updateRemoteKey(_ pRemoteKey :RemoteKey, remote pRemote :Remote) {
        let aRemoteKey = pRemoteKey.clone()
        aRemoteKey.title = self.remoteButtonTitleTextField.text
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateRemoteKey(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update remote key.", description: pError!.localizedDescription)
            } else {
                self.selectedRemoteKey = aRemoteKey
                if let aTag = aRemoteKey.tag, let anOldRemoteKey = self.selectedRemote?.keyWithTag(aTag) {
                    self.selectedRemote?.replace(key: anOldRemoteKey, withKey: aRemoteKey)
                }
                PopupManager.shared.displaySuccess(message: "Remote key updated successfully.", description: nil)
                self.reloadAllView()
            }
        }, remote: self.selectedRemote!, remoteKey: aRemoteKey)
    }
    
    
    private func recordRemoteKey(_ pRemoteKey :RemoteKey, remote pRemote :Remote) {
        let aRemoteKey = pRemoteKey.clone()
        aRemoteKey.timestamp = Int(Date().timeIntervalSince1970 * 1000)
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.recordRemoteKey(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not record remote key.", description: pError!.localizedDescription)
            } else {
                if let aTag = aRemoteKey.tag, let anOldRemoteKey = self.selectedRemote?.keyWithTag(aTag) {
                    self.selectedRemote?.replace(key: anOldRemoteKey, withKey: aRemoteKey)
                }
                self.reloadAllView()
            }
        }, remote: self.selectedRemote!, remoteKey: aRemoteKey)
    }
}


extension UpdateRemoteButtonController {
    @IBAction private func didSelectSaveButton(_ pSender: UIButton) {
        if let aRemote = self.selectedRemote
        , let aRemoteKey = self.selectedRemoteKey {
            self.updateRemoteKey(aRemoteKey, remote: aRemote)
        }
    }
    
    @IBAction private func didSelectRecordButton(_ pSender: UIButton) {
        if let aRemote = self.selectedRemote
           , let aRemoteKey = self.selectedRemoteKey {
            self.recordRemoteKey(aRemoteKey, remote: aRemote)
        }
    }
}


extension UpdateRemoteButtonController :UITextFieldDelegate {
    func textFieldShouldReturn(_ pTextField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
}
