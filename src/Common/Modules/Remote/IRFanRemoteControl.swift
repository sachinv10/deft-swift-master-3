//
//  IRFanRemoteControl.swift
//  Wifinity
//
//  Created by Vivek V. Unhale on 19/05/22.
//

import UIKit

class IRFanRemoteControl: RemoteControl {
    
    @IBOutlet weak var powerButton: AppToggleButton!
    
    private var remote :Remote?
    
    private var _remoteKey :RemoteKey?
    override var remoteKey: RemoteKey? {
        return self._remoteKey
    }
    
    override var estimatedSize :CGSize {
        return CGSize(width: 320.0, height: 450.0)
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
        cctview.layer.borderColor = UIColor.systemBlue.cgColor
        intview.layer.borderColor = UIColor.systemBlue.cgColor
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
    
    @IBAction private func didSelectOneButton(_ pSender: AppToggleButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.tvNumberOne) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didSelectTwoButton(_ pSender: AppToggleButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.tvNumberTwo) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didSelectThreeButton(_ pSender: AppToggleButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.tvNumberThree) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didSelectFourButton(_ pSender: AppToggleButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.tvNumberFour) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didSelectFiveButton(_ pSender: AppToggleButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.tvNumberFive) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction func didtappedReduceINT(_ sender: Any) {
        print("Reduce INT")
     
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.Int_dowN) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction func didtappedIncreseINT(_ sender: Any) {
        print("IncreseINT")
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.Int_UP) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
        
    }
    
    @IBAction func didtappedIncreseCCT(_ sender: Any) {
        print("IncreseCCT")
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.CCT_UP) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    
    @IBOutlet weak var cctview: UIView!
    @IBOutlet weak var intview: UIView!
    
    @IBAction func didtappedReduceCCT(_ sender: Any) {
        print("ReduceCCT")
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.CCT_DOWN) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    
}


// MARK: - Selectors

extension IRFanRemoteControl {
    
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
    
    
}
