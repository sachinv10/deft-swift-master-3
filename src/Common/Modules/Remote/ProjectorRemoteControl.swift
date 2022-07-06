//
//  ProjectorRemoteControl.swift
//  DEFT
//
//  Created by Rupendra on 01/10/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit


class ProjectorRemoteControl :RemoteControl {
    @IBOutlet weak var powerButton: AppToggleButton!
    
    @IBOutlet weak var circularDirectionButton: CircularDirectionButton!
    @IBOutlet weak var volumeRectangularDirectionButton: RectangularDirectionButton!
    
    private var remote :Remote?
    
    private var _remoteKey :RemoteKey?
    override var remoteKey: RemoteKey? {
        return self._remoteKey
    }
    
    override var estimatedSize :CGSize {
        return CGSize(width: 320.0, height: 320.0)
    }
    
    
    override func setup() {
        super.setup()
        
        self.circularDirectionButton.delegate = self
        
        self.volumeRectangularDirectionButton.title = "VOL"
        self.volumeRectangularDirectionButton.delegate = self
    }
    
    
    override func load(remote pRemote :Remote) {
        self.remote = pRemote
        
        if let aPowerOnKey = pRemote.keyWithTag(RemoteKey.Tag.on), let aPowerOffKey = pRemote.keyWithTag(RemoteKey.Tag.off) {
            if aPowerOnKey.timestamp >= aPowerOffKey.timestamp {
                self.powerButton.isChecked = true
            } else {
                self.powerButton.isChecked = false
            }
        }
        
    }
    
    
    @IBAction private func didSelectPowerButton(_ pSender: AppToggleButton) {
        if self.powerButton.isChecked == true, let aPowerOnKey = self.remote?.keyWithTag(RemoteKey.Tag.off) {
            self._remoteKey = aPowerOnKey
            self.sendActions(for: UIControl.Event.valueChanged)
        } else if self.powerButton.isChecked == false, let aPowerOffKey = self.remote?.keyWithTag(RemoteKey.Tag.on) {
            self._remoteKey = aPowerOffKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    
    @IBAction private func didSelectBackButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.back) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
}


// MARK:- CircularDirectionButtonDelegate

extension ProjectorRemoteControl :CircularDirectionButtonDelegate {
    
    func circularDirectionButtonDidSelectUp(_ pSender: CircularDirectionButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.up) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    func circularDirectionButtonDidBeginEditingUp(_ pSender: CircularDirectionButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.up) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
    func circularDirectionButtonDidSelectDown(_ pSender: CircularDirectionButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.down) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    func circularDirectionButtonDidBeginEditingDown(_ pSender: CircularDirectionButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.down) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
    func circularDirectionButtonDidSelectLeft(_ pSender: CircularDirectionButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.left) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    func circularDirectionButtonDidBeginEditingLeft(_ pSender: CircularDirectionButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.left) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
    func circularDirectionButtonDidSelectRight(_ pSender: CircularDirectionButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.right) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    func circularDirectionButtonDidBeginEditingRight(_ pSender: CircularDirectionButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.right) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
    func circularDirectionButtonDidSelectOk(_ pSender: CircularDirectionButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.ok) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    func circularDirectionButtonDidBeginEditingOk(_ pSender: CircularDirectionButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.ok) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
}


// MARK:- RectangularDirectionButtonDelegate

extension ProjectorRemoteControl :RectangularDirectionButtonDelegate {
    
    func rectangularDirectionButtonDidSelectUp(_ pSender: RectangularDirectionButton) {
        if pSender.isEqual(self.volumeRectangularDirectionButton) {
            if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.volumeUp) {
                self._remoteKey = aRemoteKey
                self.sendActions(for: UIControl.Event.valueChanged)
            }
        }
    }
    
    func rectangularDirectionButtonDidBeginEditingUp(_ pSender: RectangularDirectionButton) {
        if pSender.isEqual(self.volumeRectangularDirectionButton) {
            if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.volumeUp) {
                self._remoteKey = aRemoteKey
                self.sendActions(for: UIControl.Event.editingDidBegin)
            }
        }
    }
    
    func rectangularDirectionButtonDidSelectDown(_ pSender: RectangularDirectionButton) {
        if pSender.isEqual(self.volumeRectangularDirectionButton) {
            if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.volumeUp) {
                self._remoteKey = aRemoteKey
                self.sendActions(for: UIControl.Event.valueChanged)
            }
        }
    }
    
    func rectangularDirectionButtonDidBeginEditingDown(_ pSender: RectangularDirectionButton) {
        if pSender.isEqual(self.volumeRectangularDirectionButton) {
            if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.volumeUp) {
                self._remoteKey = aRemoteKey
                self.sendActions(for: UIControl.Event.editingDidBegin)
            }
        }
    }
    
}
