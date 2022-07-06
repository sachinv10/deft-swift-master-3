//
//  FanRemoteControl.swift
//  DEFT
//
//  Created by Rupendra on 01/10/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit


class FanRemoteControl :RemoteControl {
    @IBOutlet weak var powerButton: AppToggleButton!
    
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
    
}


// MARK:- Selectors

extension FanRemoteControl {
    
    @IBAction private func didSelectPowerButton(_ pSender: AppToggleButton) {
        if self.powerButton.isChecked == true, let aPowerOnKey = self.remote?.keyWithTag(RemoteKey.Tag.off) {
            self._remoteKey = aPowerOnKey
            self.sendActions(for: UIControl.Event.valueChanged)
        } else if self.powerButton.isChecked == false, let aPowerOffKey = self.remote?.keyWithTag(RemoteKey.Tag.on) {
            self._remoteKey = aPowerOffKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didBeginEditingPowerButton(_ pSender: RemoteButton) {
        if self.powerButton.isChecked == true, let aPowerOnKey = self.remote?.keyWithTag(RemoteKey.Tag.off) {
            self._remoteKey = aPowerOnKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        } else if self.powerButton.isChecked == false, let aPowerOffKey = self.remote?.keyWithTag(RemoteKey.Tag.on) {
            self._remoteKey = aPowerOffKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
    @IBAction private func didSelectLedButton(_ pSender: AppToggleButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.ledLed) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didBeginEditingLedButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.ledLed) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
    @IBAction private func didSelectBoostButton(_ pSender: AppToggleButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.ledBoost) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didBeginEditingBoostButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.ledBoost) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
    @IBAction private func didSelectTimerButton(_ pSender: AppToggleButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.ledTimer) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didBeginEditingTimerButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.ledTimer) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
    @IBAction private func didSelectSleepButton(_ pSender: AppToggleButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.ledSleep) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didBeginEditingSleepButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.ledSleep) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
    @IBAction private func didSelectSpeedPlusButton(_ pSender: AppToggleButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.ledSpeedPlus) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didBeginEditingSpeedPlusButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.ledSpeedPlus) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
    @IBAction private func didSelectSpeedMinusButton(_ pSender: AppToggleButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.ledSpeedMinus) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didBeginEditingSpeedMinusButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.ledSpeedMinus) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
}
