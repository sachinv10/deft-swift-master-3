//
//  Remote.swift
//  DEFT
//
//  Created by Rupendra on 26/09/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class Remote: NSObject {
    var id :String?
    var title :String?
    
    var irId :String?
    var hardwareId :String?
    
    var roomId :String?
    var roomTitle :String?
    
    var hardwareGeneration :Device.HardwareGeneration?
    
    var type :RemoteType? {
        didSet {
            self.updateIcon()
        }
    }
    
    var keys :Array<RemoteKey>?
    
    var selectedRemoteKeys :Array<RemoteKey>?
    
    
    func clone() -> Remote {
        let aRemote = Remote()
        aRemote.id = self.id
        aRemote.title = self.title
        aRemote.irId = self.irId
        aRemote.hardwareId = self.hardwareId
        aRemote.roomId = self.roomId
        aRemote.roomTitle = self.roomTitle
        aRemote.hardwareGeneration = self.hardwareGeneration
        aRemote.type = self.type
        aRemote.keys = self.keys
        aRemote.selectedRemoteKeys = self.selectedRemoteKeys
        return aRemote
    }
    
    
    func replace(key pOldKey :RemoteKey, withKey pNewKey :RemoteKey) {
        if let anIndex = self.keys?.firstIndex(where: { (pRemoteKey) -> Bool in
            return pOldKey.id == pRemoteKey.id && pOldKey.irId == pRemoteKey.irId && pOldKey.tag == pRemoteKey.tag
        }) {
            self.keys?[anIndex] = pNewKey
        }
    }
    
    var dynamicKeys :Array<RemoteKey>? {
        var aReturnVal :Array<RemoteKey>? = Array<RemoteKey>()
        
        if let aRemoteKeyArray = self.keys {
            for aRemoteKey in aRemoteKeyArray {
                if (aRemoteKey.tag == nil || aRemoteKey.tag == RemoteKey.Tag.none)
                    && (aRemoteKey.title?.count ?? 0) > 0 {
                    aReturnVal?.append(aRemoteKey)
                }
            }
        }
        
        if (aReturnVal?.count ?? 0) <= 0 {
            aReturnVal = nil
        }
        
        return aReturnVal
    }
    
    func keyWithTag(_ pTag :RemoteKey.Tag) -> RemoteKey? {
        var aReturnVal :RemoteKey?
        
        if let aKeyArray = self.keys {
            for aKey in aKeyArray {
                print(aKey.tag)
                if aKey.tag == pTag {
                    aReturnVal = aKey
                    break
                }
            }
        }
        
        return aReturnVal
    }
    
    func keyWithId(_ pId :String) -> RemoteKey? {
        var aReturnVal :RemoteKey?
        
        if let aKeyArray = self.keys {
            for aKey in aKeyArray {
                if aKey.id == pId {
                    aReturnVal = aKey
                    break
                }
            }
        }
        
        return aReturnVal
    }
    
    func nextModeKey(currentModeKey pCurrentModeKey :RemoteKey) -> RemoteKey? {
        var aReturnVal :RemoteKey?
        
        if let aTag = pCurrentModeKey.tag {
            var aNextKeyTag :RemoteKey.Tag?
            switch aTag {
            case .acMode:
                aNextKeyTag = .acMode // DEFT has only one tag
            case .acMode1:
                aNextKeyTag = .acMode2
            case .acMode2:
                aNextKeyTag = .acMode3
            case .acMode3:
                aNextKeyTag = .acMode4
            case .acMode4:
                aNextKeyTag = .acMode1
            default:
                break
            }
            if aNextKeyTag != nil {
                aReturnVal = self.keyWithTag(aNextKeyTag!)
            }
        }
        
        return aReturnVal
    }
    
    func nextSpeedKey(currentSpeedKey pCurrentModeKey :RemoteKey) -> RemoteKey? {
        var aReturnVal :RemoteKey?
        
        if let aTag = pCurrentModeKey.tag {
            var aNextKeyTag :RemoteKey.Tag?
            switch aTag {
            case .acSpeed:
                aNextKeyTag = .acSpeed // DEFT has only one speed
            case .acSpeed1:
                aNextKeyTag = .acSpeed2
            case .acSpeed2:
                aNextKeyTag = .acSpeed3
            case .acSpeed3:
                aNextKeyTag = .acSpeed1
            default:
                break
            }
            if aNextKeyTag != nil {
                aReturnVal = self.keyWithTag(aNextKeyTag!)
            }
        }
        
        return aReturnVal
    }
    
    var temperatureKeys :Array<RemoteKey>? {
        var aReturnVal :Array<RemoteKey>? = Array<RemoteKey>()
        
        var aKeyArray = Array<RemoteKey>()
        if let aKey = self.keyWithTag(RemoteKey.Tag.acTemperature16) {
            aKeyArray.append(aKey)
        }
        if let aKey = self.keyWithTag(RemoteKey.Tag.acTemperature17) {
            aKeyArray.append(aKey)
        }
        if let aKey = self.keyWithTag(RemoteKey.Tag.acTemperature18) {
            aKeyArray.append(aKey)
        }
        if let aKey = self.keyWithTag(RemoteKey.Tag.acTemperature19) {
            aKeyArray.append(aKey)
        }
        if let aKey = self.keyWithTag(RemoteKey.Tag.acTemperature20) {
            aKeyArray.append(aKey)
        }
        if let aKey = self.keyWithTag(RemoteKey.Tag.acTemperature21) {
            aKeyArray.append(aKey)
        }
        if let aKey = self.keyWithTag(RemoteKey.Tag.acTemperature22) {
            aKeyArray.append(aKey)
        }
        if let aKey = self.keyWithTag(RemoteKey.Tag.acTemperature23) {
            aKeyArray.append(aKey)
        }
        if let aKey = self.keyWithTag(RemoteKey.Tag.acTemperature24) {
            aKeyArray.append(aKey)
        }
        if let aKey = self.keyWithTag(RemoteKey.Tag.acTemperature25) {
            aKeyArray.append(aKey)
        }
        if let aKey = self.keyWithTag(RemoteKey.Tag.acTemperature26) {
            aKeyArray.append(aKey)
        }
        if let aKey = self.keyWithTag(RemoteKey.Tag.acTemperature27) {
            aKeyArray.append(aKey)
        }
        if let aKey = self.keyWithTag(RemoteKey.Tag.acTemperature28) {
            aKeyArray.append(aKey)
        }
        if let aKey = self.keyWithTag(RemoteKey.Tag.acTemperature29) {
            aKeyArray.append(aKey)
        }
        if let aKey = self.keyWithTag(RemoteKey.Tag.acTemperature30) {
            aKeyArray.append(aKey)
        }
        
        if aKeyArray.count > 0 {
            aReturnVal = aKeyArray
        }
        
        return aReturnVal
    }
    
    var currentTemperatureKey :RemoteKey? {
        var aReturnVal :RemoteKey?
        
        if var aKeyArray = self.temperatureKeys {
            aKeyArray.sort { (pLhs, pRhs) -> Bool in
                return pLhs.timestamp > pRhs.timestamp
            }
            if let aSpeedKey = aKeyArray.first {
                aReturnVal = aSpeedKey
            }
        }
        
        return aReturnVal
    }
    
    func nextTemperatureKey(currentTemperatureKeyTag pCurrentTemperatureKeyTag :RemoteKey.Tag) -> RemoteKey? {
        var aReturnVal :RemoteKey?
        
        var aNextKeyTag :RemoteKey.Tag?
        switch pCurrentTemperatureKeyTag {
        case .acTemperature16:
            aNextKeyTag = .acTemperature17
        case .acTemperature17:
            aNextKeyTag = .acTemperature18
        case .acTemperature18:
            aNextKeyTag = .acTemperature19
        case .acTemperature19:
            aNextKeyTag = .acTemperature20
        case .acTemperature20:
            aNextKeyTag = .acTemperature21
        case .acTemperature21:
            aNextKeyTag = .acTemperature22
        case .acTemperature22:
            aNextKeyTag = .acTemperature23
        case .acTemperature23:
            aNextKeyTag = .acTemperature24
        case .acTemperature24:
            aNextKeyTag = .acTemperature25
        case .acTemperature25:
            aNextKeyTag = .acTemperature26
        case .acTemperature26:
            aNextKeyTag = .acTemperature27
        case .acTemperature27:
            aNextKeyTag = .acTemperature28
        case .acTemperature28:
            aNextKeyTag = .acTemperature29
        case .acTemperature29:
            aNextKeyTag = .acTemperature30
        default:
            break
        }
        if aNextKeyTag != nil {
            var aNextKey :RemoteKey? = self.keyWithTag(aNextKeyTag!)
            if aNextKey == nil && aNextKeyTag != .acTemperature30 {
                aNextKey = self.nextTemperatureKey(currentTemperatureKeyTag: aNextKeyTag!)
            }
            aReturnVal = aNextKey
        }
        
        return aReturnVal
    }
    
    func previousTemperatureKey(currentTemperatureKeyTag pCurrentTemperatureKeyTag :RemoteKey.Tag) -> RemoteKey? {
        var aReturnVal :RemoteKey?
        
        var aPreviousKeyTag :RemoteKey.Tag?
        switch pCurrentTemperatureKeyTag {
        case .acTemperature16:
            break
        case .acTemperature17:
            aPreviousKeyTag = .acTemperature16
        case .acTemperature18:
            aPreviousKeyTag = .acTemperature17
        case .acTemperature19:
            aPreviousKeyTag = .acTemperature18
        case .acTemperature20:
            aPreviousKeyTag = .acTemperature19
        case .acTemperature21:
            aPreviousKeyTag = .acTemperature20
        case .acTemperature22:
            aPreviousKeyTag = .acTemperature21
        case .acTemperature23:
            aPreviousKeyTag = .acTemperature22
        case .acTemperature24:
            aPreviousKeyTag = .acTemperature23
        case .acTemperature25:
            aPreviousKeyTag = .acTemperature24
        case .acTemperature26:
            aPreviousKeyTag = .acTemperature25
        case .acTemperature27:
            aPreviousKeyTag = .acTemperature26
        case .acTemperature28:
            aPreviousKeyTag = .acTemperature27
        case .acTemperature29:
            aPreviousKeyTag = .acTemperature28
        case .acTemperature30:
            aPreviousKeyTag = .acTemperature29
        default:
            break
        }
        if aPreviousKeyTag != nil {
            var aPreviousKey :RemoteKey? = self.keyWithTag(aPreviousKeyTag!)
            if aPreviousKey == nil && aPreviousKeyTag != .acTemperature16 {
                aPreviousKey = self.previousTemperatureKey(currentTemperatureKeyTag: aPreviousKeyTag!)
            }
            aReturnVal = aPreviousKey
        }
        
        return aReturnVal
    }
    
    private var _icon :UIImage?
    
    var icon :UIImage? {
        return self._icon
    }
    
    private func updateIcon() {
        switch self.type {
        case .ac:
            self._icon = UIImage(named: "RemoteAc")
        case .tv:
            self._icon = UIImage(named: "RemoteTv")
        case .musicSystem:
            self._icon = UIImage(named: "RemoteMusicSystem")
        case .setTopBox:
            self._icon = UIImage(named: "RemoteSetTopBox")
        case .projector:
            self._icon = UIImage(named: "RemoteProjector")
        default:
            self._icon = UIImage(named: "RemoteProjector")
        }
    }
    
    
    enum RemoteType :String {
        case ac = "AC"
        case tv = "TV"
        case moodLight = "MOOD LIGHT"
        case musicSystem = "MUSIC SYSTEM"
        case dvd = "DVD"
        case setTopBox = "SETTOP BOX"
        case projector = "PROJECTOR"
        case ledStrip = "LED STRIP"
        case fan = "FAN"
        case irFan = "IR FAN"
    }
}



class RemoteKey: NSObject {
    var id :String?
    var title :String?
    var remoteId :String?
    var irId :String?
    
    var isStatic :Bool = false
    var command :String?
    var recordCommand :String?
    var tag :RemoteKey.Tag?
    
    var timestamp :Int = 0
    var checked :Bool = false

    
    func clone() -> RemoteKey {
        let aReturnVal = RemoteKey()
        
        aReturnVal.id = self.id
        aReturnVal.title = self.title
        aReturnVal.irId = self.irId
        aReturnVal.isStatic = self.isStatic
        aReturnVal.command = self.command
        aReturnVal.recordCommand = self.recordCommand
        aReturnVal.tag = self.tag
        aReturnVal.timestamp = self.timestamp
        
        return aReturnVal
    }
    
    
    enum Tag :String {
        case on = "ON"
        case off = "OFF"
        case back = "BACK"
        
        case ok = "OK"
        case up = "UP"
        case down = "DOWN"
        case left = "LEFT"
        case right = "RIGHT"
        
        case volumeUp = "VOL UP"
        case volumeDown = "VOL DOWN"
        
        case acFan = "FAN"
        case acMode = "MODE"
        case acMode1 = "MODE 1"
        case acMode2 = "MODE 2"
        case acMode3 = "MODE 3"
        case acMode4 = "MODE 4"
        case acSwing = "SWING"
        case acSpeed = "SPEED"
        case acSpeed1 = "SPEED 1"
        case acSpeed2 = "SPEED 2"
        case acSpeed3 = "SPEED 3"
        case acTemperature16 = "16"
        case acTemperature17 = "17"
        case acTemperature18 = "18"
        case acTemperature19 = "19"
        case acTemperature20 = "20"
        case acTemperature21 = "21"
        case acTemperature22 = "22"
        case acTemperature23 = "23"
        case acTemperature24 = "24"
        case acTemperature25 = "25"
        case acTemperature26 = "26"
        case acTemperature27 = "27"
        case acTemperature28 = "28"
        case acTemperature29 = "29"
        case acTemperature30 = "30"
        
        case tvHome = "HOME"
        case mute = "MUTE"
        case tvMenu = "MENU"
        
        case tvChannelUp = "CH UP"
        case tvChannelDown = "CH DOWN"
        
        case tvNumberZero = "0"
        case tvNumberOne = "1"
        case tvNumberTwo = "2"
        case tvNumberThree = "3"
        case tvNumberFour = "4"
        case tvNumberFive = "5"
        case tvNumberSix = "6"
        case tvNumberSeven = "7"
        case tvNumberEight = "8"
        case tvNumberNine = "9"
       // LIGHT
        case led_light = "LIGHT"
        case ledLed = "LED"
        case ledBoost = "BOOST"
        case ledTimer = "TIMER"
        case ledSleep = "SLEEP"
        case ledSpeedPlus = "SPEED +"
        case ledSpeedMinus = "SPEED -"
        
        case play = "PLAY"
        case pause = "PAUSE"
        case stop = "STOP"
        
        case previous = "PREV"
        case rewind = "REWIND"
        case forward = "FORWARD"
        case next = "NEXT"
        case eject = "EJECT"
        
        case moodLightRed = "RED"
        case moodLightGreen = "GREEN"
        case moodLightYellow = "YELLOW"
        case moodLightViolet = "VIOLET"
        case moodLightWhite = "WHITE"
        case moodLightPurple = "PURPLE"
        case moodLightBlue = "BLUE"
        case moodLightBPlus = "BPLUS"
        case moodLightBMinus = "BMINUS"
        
        case moodLightSplash = "SPLASH"
        case moodLightStrobe = "STROBE"
        case moodLightFade = "FADE"
        case moodLightSmooth = "SMOOTH"
        case Int_UP = "INT UP"
        case Int_dowN = "INT DOWN"
        case CCT_UP = "CCT UP"
        case CCT_DOWN = "CCT DOWN"
        
        case none
    }
    
}
