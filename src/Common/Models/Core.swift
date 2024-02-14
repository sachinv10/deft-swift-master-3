//
//  Core.swift
//  Wifinity
//
//  Created by sachin on 26/05/22.
//

import Foundation


class Core: NSObject {
    var ruleName :String?
    var ruleId :String?
    var state :Bool?
    var coreEditData :coreEditdata?
    var appliances :Array<Appliance>?
    var createdBy: String?
    var deviceId: Array<String>?
    var ifStatement: String?
    var isCreatedBySensor: Bool?
    var duration: String?
    var from: String?
    var to: String?
    var Operator :String = "AND"
    var thenStatement: String?
    func clone(ruleName: String? = nil, ruleId: String? = nil, state: Bool? = nil, coreEditData: coreEditdata? = nil, appliances: Array<Appliance>? = nil, createdBy: String? = nil, deviceId: Array<String>? = nil, ifStatement: String? = nil, isCreatedBySensor: Bool? = nil, Operator: String, thenStatement: String? = nil) {
        self.ruleName = ruleName
        self.ruleId = ruleId
        self.state = state
        self.coreEditData = coreEditData
        self.appliances = appliances
        self.createdBy = createdBy
        self.deviceId = deviceId
        self.ifStatement = ifStatement
        self.isCreatedBySensor = isCreatedBySensor
        self.Operator = Operator
        self.thenStatement = thenStatement
    }
    static func gethardwareType(pid: String, list: actionSelectionList)-> String?{
        var htype: String? = String()
        if pid.hasPrefix("C") == true {
            htype = "switch"
        }
        if list.dimmable ?? false && list.applianceType == Appliance.ApplianceType.light.title && list.dimValue! != 1{
            htype = "dimming"
        }else if list.dimmable ?? false && list.applianceType == Appliance.ApplianceType.fan.title{
            htype = "switch"
        }
        if list.routineType == "goodbye"{
            htype = "goodbye"
        }
        return htype
    }
}
 
class coreEditdata: NSObject{
    var operation: String?
    var ruleId: String?
    var ruleName: String?
    var duration: String?
    var from: String?
    var to: String?
   
    var whenSelectionList: Array<actionSelectionList>?
    var actionSelectionList: Array<actionSelectionList>?
}
class actionSelectionList: NSObject{
    var appId: String?
    var id :String?
    var remoteKeys: Array<String>?
    var remoteKeysName: Array<String>?
    var remoteKeysId: Array<String>?
    var appName: String?
    var checked: Bool?
    var currentLevel: Int?
    var currentType: String?
    var currentState: Bool = false
    var dimValue: Int?
    var dimmable: Bool?
    var hardwareId: String?
    var maxDimming: Int = 5
    var minDimming: Int = 1
    var roomId: String?
    var roomName: String?
    var routineType :String?
    var applianceType :String?
    var state: Int?
    var intensity: Int?
    var sensorTypeId: Int?
    var operators: String?
    var uniqueKey: String?
    var appliancesStatment: String?
    // Strip light
    var ledStripProperty1 :Int?
    var ledStripProperty2 :Int?
    var ledStripProperty3 :Int?
    var stripLightEvent: String = "00"
    var stripType : Appliance.StripType?
    //
    enum actionSelectionList: String {
        case routineType = "switch"
    }
    
}

 class CoreDevicesData: NSObject {
    var controllerId :String?
    var applianceId :String?
    var coreComponentType :String?
    var expression :String?
}
