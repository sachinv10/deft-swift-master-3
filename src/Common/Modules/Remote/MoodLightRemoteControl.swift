//
//  MoodLightRemoteControl.swift
//  DEFT
//
//  Created by Rupendra on 01/10/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit


class MoodLightRemoteControl :RemoteControl {
    @IBOutlet weak var powerButton: AppToggleButton!
    
    private var remote :Remote?
    
    private var _remoteKey :RemoteKey?
    override var remoteKey: RemoteKey? {
        return self._remoteKey
    }
    
    override var estimatedSize :CGSize {
        return CGSize(width: 320.0, height: 480.0)
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
    
    
    @IBAction private func didSelectPowerButton(_ pSender: AppToggleButton) {
        if self.powerButton.isChecked == true, let aPowerOnKey = self.remote?.keyWithTag(RemoteKey.Tag.off) {
            self._remoteKey = aPowerOnKey
            self.sendActions(for: UIControl.Event.valueChanged)
        } else if self.powerButton.isChecked == false, let aPowerOffKey = self.remote?.keyWithTag(RemoteKey.Tag.on) {
            self._remoteKey = aPowerOffKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
}


// MARK:- Color Button Selectors

extension MoodLightRemoteControl {
    
    @IBAction private func didSelectRedButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.moodLightRed) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didBeginEditingRedButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.moodLightRed) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
    
    @IBAction private func didSelectGreenButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.moodLightGreen) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didSelectYellowButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.moodLightYellow) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didSelectVioletButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.moodLightViolet) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didSelectWhiteButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.moodLightWhite) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didSelectPurpleButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.moodLightPurple) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didSelectBlueButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.moodLightBlue) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didSelectBPlusButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.moodLightBPlus) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didSelectBMinusButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.moodLightBMinus) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
}



// MARK:- Color Button Selectors

extension MoodLightRemoteControl {
    
    @IBAction private func didSelectSplashButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.moodLightSplash) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didSelectStrobeButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.moodLightStrobe) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didSelectFadeButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.moodLightFade) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didSelectSmoothButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.moodLightSmooth) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
}
