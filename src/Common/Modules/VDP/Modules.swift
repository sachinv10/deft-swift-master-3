//
//  Modules.swift
//  Wifinity
//
//  Created by Sachin on 26/12/22.
//

import Foundation

struct ResponceResult: Codable {
    var peer_id: String?
    var should_create_offer: Bool?
    var vdp_id: String?
}
class MyModel: Codable {
    var msgContent: String
    var msgType: String
    var msgId: String
    
    init(msgContent: String, msgType: String, msgId: String) {
        self.msgContent = msgContent
        self.msgType = msgType
        self.msgId = msgId
    }
}
class IceServer: Codable{
    var credential: String? = nil
    var url: String? = nil
    var username: String? = nil
    init(credential: String? = nil, url: String? = nil, username: String? = nil) {
        self.credential = credential
        self.url = url
        self.username = username
    }
}
