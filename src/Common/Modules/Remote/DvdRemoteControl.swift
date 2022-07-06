//
//  DvdRemoteControl.swift
//  DEFT
//
//  Created by Rupendra on 01/10/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit


class DvdRemoteControl :RemoteControl {
    @IBOutlet weak var powerButton: AppToggleButton!
    
    @IBOutlet weak var directionButtonContainerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var directionButtonContainerViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var circularDirectionButton: CircularDirectionButton!
    @IBOutlet weak var volumeRectangularDirectionButton: RectangularDirectionButton!
    @IBOutlet weak var numberPadControl: NumberPadControl!
    
    private var remote :Remote?
    
    private var _remoteKey :RemoteKey?
    override var remoteKey: RemoteKey? {
        return self._remoteKey
    }
    
    override var estimatedSize :CGSize {
        return CGSize(width: 320.0, height: 550.0)
    }
    
    
    override func setup() {
        super.setup()
        
        if UtilityManager.shared.screenSizeType == UtilityManager.ScreenSizeType.small
        || UtilityManager.shared.screenSizeType == UtilityManager.ScreenSizeType.medium {
            self.directionButtonContainerViewTopConstraint.constant = 14.0
            self.directionButtonContainerViewBottomConstraint.constant = 14.0
        } else {
            self.directionButtonContainerViewTopConstraint.constant = 24.0
            self.directionButtonContainerViewBottomConstraint.constant = 24.0
        }
        
        self.circularDirectionButton.delegate = self
        self.volumeRectangularDirectionButton.delegate = self
        self.numberPadControl.delegate = self
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
        
        // TODO: Disable and grayout the key if tag is not found.
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
    
    @IBAction private func didSelectPlayButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.play) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didSelectPauseButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.pause) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didSelectStopButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.stop) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didSelectPreviousButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.previous) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didSelectRewindButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.rewind) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didSelectForwardButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.forward) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didSelectNextButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.next) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didSelectEjectButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.eject) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didSelectMuteButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.mute) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
}


// MARK:- Number Button Selectors

extension DvdRemoteControl: CircularDirectionButtonDelegate {
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


extension DvdRemoteControl: RectangularDirectionButtonDelegate {
    func rectangularDirectionButtonDidSelectUp(_ pSender: RectangularDirectionButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.volumeUp) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    func rectangularDirectionButtonDidBeginEditingUp(_ pSender: RectangularDirectionButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.volumeUp) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
    func rectangularDirectionButtonDidSelectDown(_ pSender: RectangularDirectionButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.volumeDown) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    func rectangularDirectionButtonDidBeginEditingDown(_ pSender: RectangularDirectionButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.volumeDown) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
}


// MARK:- Number Button Selectors

extension DvdRemoteControl: NumberPadControlDelegate {
    
    func numberPadControlDidSelectZero(_ pSender: NumberPadControl) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.tvNumberZero) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    func numberPadControlDidBeginEditingZero(_ pSender: NumberPadControl) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.tvNumberZero) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
    func numberPadControlDidSelectOne(_ pSender: NumberPadControl) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.tvNumberOne) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    func numberPadControlDidBeginEditingOne(_ pSender: NumberPadControl) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.tvNumberOne) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
    func numberPadControlDidSelectTwo(_ pSender: NumberPadControl) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.tvNumberTwo) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    func numberPadControlDidBeginEditingTwo(_ pSender: NumberPadControl) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.tvNumberTwo) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
    func numberPadControlDidSelectThree(_ pSender: NumberPadControl) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.tvNumberThree) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    func numberPadControlDidBeginEditingThree(_ pSender: NumberPadControl) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.tvNumberThree) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
    func numberPadControlDidSelectFour(_ pSender: NumberPadControl) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.tvNumberFour) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    func numberPadControlDidBeginEditingFour(_ pSender: NumberPadControl) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.tvNumberFour) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
    func numberPadControlDidSelectFive(_ pSender: NumberPadControl) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.tvNumberFive) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    func numberPadControlDidBeginEditingFive(_ pSender: NumberPadControl) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.tvNumberFive) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
    func numberPadControlDidSelectSix(_ pSender: NumberPadControl) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.tvNumberSix) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    func numberPadControlDidBeginEditingSix(_ pSender: NumberPadControl) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.tvNumberSix) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
    func numberPadControlDidSelectSeven(_ pSender: NumberPadControl) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.tvNumberSeven) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    func numberPadControlDidBeginEditingSeven(_ pSender: NumberPadControl) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.tvNumberSeven) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
    func numberPadControlDidSelectEight(_ pSender: NumberPadControl) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.tvNumberEight) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    func numberPadControlDidBeginEditingEight(_ pSender: NumberPadControl) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.tvNumberEight) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
    func numberPadControlDidSelectNine(_ pSender: NumberPadControl) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.tvNumberNine) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    func numberPadControlDidBeginEditingNine(_ pSender: NumberPadControl) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.tvNumberNine) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
}

