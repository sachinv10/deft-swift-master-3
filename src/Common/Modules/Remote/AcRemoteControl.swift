//
//  AcRemoteControl.swift
//  DEFT
//
//  Created by Rupendra on 01/10/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit


class AcRemoteControl :RemoteControl {
    @IBOutlet weak var powerButton: AppToggleButton!
    @IBOutlet weak var modeButton: AppSegmentButton!
    @IBOutlet weak var speedButton: AppSegmentButton!
    
    @IBOutlet weak var temperatureRectangularDirectionButton: RectangularDirectionButton!
    
    private var temperature :Int = 24
    
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
        
        self.temperatureRectangularDirectionButton.delegate = self
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
        
        // Load mode button
        if let aMode1Key = pRemote.keyWithTag(RemoteKey.Tag.acMode1)
           , let aMode2Key = pRemote.keyWithTag(RemoteKey.Tag.acMode2)
           , let aMode3Key = pRemote.keyWithTag(RemoteKey.Tag.acMode3)
           , let aMode4Key = pRemote.keyWithTag(RemoteKey.Tag.acMode4) {
            var aModeSegmentArray = Array<AppSegment>()
            aModeSegmentArray.append(AppSegment(title: aMode1Key.title?.uppercased() ?? RemoteKey.Tag.acMode1.rawValue, value: RemoteKey.Tag.acMode1.rawValue))
            aModeSegmentArray.append(AppSegment(title: aMode2Key.title?.uppercased() ?? RemoteKey.Tag.acMode2.rawValue, value: RemoteKey.Tag.acMode2.rawValue))
            aModeSegmentArray.append(AppSegment(title: aMode3Key.title?.uppercased() ?? RemoteKey.Tag.acMode3.rawValue, value: RemoteKey.Tag.acMode3.rawValue))
            aModeSegmentArray.append(AppSegment(title: aMode4Key.title?.uppercased() ?? RemoteKey.Tag.acMode4.rawValue, value: RemoteKey.Tag.acMode4.rawValue))
            self.modeButton.segments = aModeSegmentArray
            
            var aModeKeyArray = Array<RemoteKey>()
            aModeKeyArray.append(aMode1Key)
            aModeKeyArray.append(aMode2Key)
            aModeKeyArray.append(aMode3Key)
            aModeKeyArray.append(aMode4Key)
            aModeKeyArray.sort { (pLhs, pRhs) -> Bool in
                return pLhs.timestamp > pRhs.timestamp
            }
            if let aModeKey = aModeKeyArray.first, let aValue = aModeKey.tag?.rawValue {
                self.modeButton.setSelectedSegmentValue(aValue)
            }
        } else if let aModeKey = pRemote.keyWithTag(RemoteKey.Tag.acMode) {
            // DEFT Remote
            var aModeSegmentArray = Array<AppSegment>()
            aModeSegmentArray.append(AppSegment(title: aModeKey.title?.uppercased() ?? "AUTO", value: RemoteKey.Tag.acMode.rawValue))
            self.modeButton.segments = aModeSegmentArray
            if let aValue = aModeKey.tag?.rawValue {
                self.modeButton.setSelectedSegmentValue(aValue)
            }
        }
        
        // Load speed button
        if let aSpeed1Key = pRemote.keyWithTag(RemoteKey.Tag.acSpeed1)
           , let aSpeed2Key = pRemote.keyWithTag(RemoteKey.Tag.acSpeed2)
           , let aSpeed3Key = pRemote.keyWithTag(RemoteKey.Tag.acSpeed3) {
            var aSpeedSegmentArray = Array<AppSegment>()
            aSpeedSegmentArray.append(AppSegment(title: aSpeed1Key.title?.uppercased() ?? RemoteKey.Tag.acSpeed1.rawValue, value: RemoteKey.Tag.acSpeed1.rawValue))
            aSpeedSegmentArray.append(AppSegment(title: aSpeed2Key.title?.uppercased() ?? RemoteKey.Tag.acSpeed2.rawValue, value: RemoteKey.Tag.acSpeed2.rawValue))
            aSpeedSegmentArray.append(AppSegment(title: aSpeed3Key.title?.uppercased() ?? RemoteKey.Tag.acSpeed3.rawValue, value: RemoteKey.Tag.acSpeed3.rawValue))
            self.speedButton.segments = aSpeedSegmentArray
            
            var aSpeedKeyArray = Array<RemoteKey>()
            aSpeedKeyArray.append(aSpeed1Key)
            aSpeedKeyArray.append(aSpeed2Key)
            aSpeedKeyArray.append(aSpeed3Key)
            aSpeedKeyArray.sort { (pLhs, pRhs) -> Bool in
                return pLhs.timestamp > pRhs.timestamp
            }
            if let aSpeedKey = aSpeedKeyArray.first, let aValue = aSpeedKey.tag?.rawValue {
                self.speedButton.setSelectedSegmentValue(aValue)
            }
        } else if let aSpeedKey = pRemote.keyWithTag(RemoteKey.Tag.acSpeed) {
            // DEFT Remote
            var aSpeedSegmentArray = Array<AppSegment>()
            aSpeedSegmentArray.append(AppSegment(title: aSpeedKey.title?.uppercased() ?? "AUTO", value: RemoteKey.Tag.acSpeed.rawValue))
            self.speedButton.segments = aSpeedSegmentArray
            if let aValue = aSpeedKey.tag?.rawValue {
                self.speedButton.setSelectedSegmentValue(aValue)
            }
        }
        
        // Load temperature
        if let aKey = pRemote.currentTemperatureKey {
            self.temperatureRectangularDirectionButton.title = String(format: "%@ºC", aKey.tag?.rawValue ?? "")
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
    
    @IBAction private func didBeginEditingPowerButton(_ pSender: RemoteButton) {
        if self.powerButton.isChecked == true, let aPowerOnKey = self.remote?.keyWithTag(RemoteKey.Tag.off) {
            self._remoteKey = aPowerOnKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        } else if self.powerButton.isChecked == false, let aPowerOffKey = self.remote?.keyWithTag(RemoteKey.Tag.on) {
            self._remoteKey = aPowerOffKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
    
    @IBAction private func didSelectModeButton(_ pSender: AppSegmentButton) {
        if let aValue = self.modeButton.selectedSegment?.value
           , let aTag = RemoteKey.Tag(rawValue: aValue)
           , let aRemoteKey = self.remote?.keyWithTag(aTag) {
            self._remoteKey = self.remote?.nextModeKey(currentModeKey: aRemoteKey)
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didBeginEditingModeButton(_ pSender: RemoteButton) {
        if let aValue = self.modeButton.selectedSegment?.value
           , let aTag = RemoteKey.Tag(rawValue: aValue)
           , let aRemoteKey = self.remote?.keyWithTag(aTag) {
            self._remoteKey = self.remote?.nextModeKey(currentModeKey: aRemoteKey)
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
    
    @IBAction private func didSelectFanButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.acFan) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didBeginEditingFanButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.acFan) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
    
    @IBAction private func didSelectSpeedButton(_ pSender: RemoteButton) {
        if let aValue = self.speedButton.selectedSegment?.value
           , let aTag = RemoteKey.Tag(rawValue: aValue)
           , let aRemoteKey = self.remote?.keyWithTag(aTag) {
            self._remoteKey = self.remote?.nextSpeedKey(currentSpeedKey: aRemoteKey)
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didBeginEditingSpeedButton(_ pSender: RemoteButton) {
        if let aValue = self.speedButton.selectedSegment?.value
           , let aTag = RemoteKey.Tag(rawValue: aValue)
           , let aRemoteKey = self.remote?.keyWithTag(aTag) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
    
    @IBAction private func didSelectSwingButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.acSwing) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    @IBAction private func didBeginEditingSwingButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remote?.keyWithTag(RemoteKey.Tag.acSwing) {
            self._remoteKey = aRemoteKey
            self.sendActions(for: UIControl.Event.editingDidBegin)
        }
    }
    
}



extension AcRemoteControl :RectangularDirectionButtonDelegate {
    
    func rectangularDirectionButtonDidSelectUp(_ pSender: RectangularDirectionButton) {
        if pSender.isEqual(self.temperatureRectangularDirectionButton) {
            if let aRemoteKey = self.remote?.currentTemperatureKey
            , let aRemoteKeyTag = aRemoteKey.tag
            , let aNextRemoteKey = self.remote?.nextTemperatureKey(currentTemperatureKeyTag: aRemoteKeyTag) {
                self._remoteKey = aNextRemoteKey
                self.sendActions(for: UIControl.Event.valueChanged)
            }
        }
    }
    
    func rectangularDirectionButtonDidBeginEditingUp(_ pSender: RectangularDirectionButton) {
        if pSender.isEqual(self.temperatureRectangularDirectionButton) {
            if let aRemoteKey = self.remote?.currentTemperatureKey {
                self._remoteKey = aRemoteKey
                self.sendActions(for: UIControl.Event.editingDidBegin)
            }
        }
    }
    
    func rectangularDirectionButtonDidSelectDown(_ pSender: RectangularDirectionButton) {
        if pSender.isEqual(self.temperatureRectangularDirectionButton) {
            if let aRemoteKey = self.remote?.currentTemperatureKey
            , let aRemoteKeyTag = aRemoteKey.tag
            , let aPreviousRemoteKey = self.remote?.previousTemperatureKey(currentTemperatureKeyTag: aRemoteKeyTag) {
                self._remoteKey = aPreviousRemoteKey
                self.sendActions(for: UIControl.Event.valueChanged)
            }
        }
    }
    
    func rectangularDirectionButtonDidBeginEditingDown(_ pSender: RectangularDirectionButton) {
        if pSender.isEqual(self.temperatureRectangularDirectionButton) {
            if let aRemoteKey = self.remote?.currentTemperatureKey {
                self._remoteKey = aRemoteKey
                self.sendActions(for: UIControl.Event.editingDidBegin)
            }
        }
    }
    
}
