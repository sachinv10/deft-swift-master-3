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
