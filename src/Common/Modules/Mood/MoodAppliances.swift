//
//  MoodAppliances.swift
//  Wifinity
//
//  Created by Apple on 25/05/23.
//

import Foundation

class MoodAppliances: NSObject{
    
    var hederType: String?
    var list: [applianeslist] = []
    
    func clone()-> MoodAppliances{
        var mooda = MoodAppliances()
        mooda.hederType = self.hederType
        mooda.list = self.list
        return mooda
    }
}
class applianeslist: NSObject{
    var name: String?
    var id: String?
    var remoteType: String?
    var remoteId : String?
    var hardwareId : String?
    var checked :Bool = false
    var SelectedremoteKey: Array<RemoteKey>? = Array<RemoteKey>()
}
class remotelist: NSObject{
    var name: [String]?
    var id: [String]?
    var remoteType: [String]?
    var remoteId : String?
    var hardwareId : String?
}
