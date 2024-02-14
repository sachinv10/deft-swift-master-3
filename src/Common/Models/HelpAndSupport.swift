//
//  HelpAndSupport.swift
//  Wifinity
//
//  Created by Apple on 15/11/22.
//

import Foundation
class Complents: NSObject {
     var descriptionn :String?
    var emailId :String?
    var filter :String?
    var issueRaisedTime :Int?
    var issueResolvedTime :Int?
    var issueStatus :String?
    var issueType :String?
    var mobileNumber :String?
    var resolveOtp :Int?
    var resolvedBy :String?
    var ticketId :String?
    var uid :String?
    var controllerName :String?
    var checked :Bool?
    var issueIcon : String {
        var icon = ""
        switch issueType {
        case "Hardware":
            icon = "Device"
        case "Application":
            icon = "app-development"
        case "Installation":
            icon = "HPinstallation"
        case "other":
            icon = "HPOthres"
        case .none:
            break
        case .some(_):
            break
        }
        return icon
    }
    func clone() -> Complents{
        var pComplent = Complents()
        pComplent.descriptionn = self.descriptionn
        pComplent.emailId = self.emailId
        pComplent.filter = self.filter
        pComplent.issueRaisedTime = self.issueRaisedTime
        pComplent.issueResolvedTime = self.issueResolvedTime
        pComplent.issueStatus = self.issueStatus
        pComplent.issueType = self.issueType
        pComplent.mobileNumber = self.mobileNumber
        pComplent.resolveOtp = self.resolveOtp
        pComplent.resolvedBy = self.resolvedBy
        pComplent.ticketId = self.ticketId
        pComplent.uid = self.uid
        pComplent.controllerName = self.controllerName
        return pComplent
    }
}
struct technicalSheet: Codable{
    let downloadUrl: String
    let productName: String
}
