//
//  Core.swift
//  Wifinity
//
//  Created by Vivek V. Unhale on 26/05/22.
//

import Foundation


class Core: NSObject {
    var ruleName :String?
    var ruleId :String?
    var state :Bool?
}


class CoreDevicesData: NSObject {
    var controllerId :String?
    var applianceId :String?
    var coreComponentType :String?
    var expression :String?
}
