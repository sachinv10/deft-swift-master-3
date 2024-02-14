//
//  User.swift
//  DEFT
//
//  Created by Rupendra on 21/08/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class User: NSObject {
    var firebaseUserId :String?
    var emailAddress :String?
    var password :String?
    var lockPassword :String?
}
class UserAuth: Encodable {
     var emailAddress :String?
    var password :String?
 }
class UserVerify: NSObject {
    var email :String?
    var flatNumber :String?
    var numberVerified :String?
    var phoneNumber :String?
    var userName :String?
    var dob :String?
    init(email: String? = nil, flatNumber: String? = nil, numberVerified: String? = nil, phoneNumber: String? = nil, userName: String? = nil, dob: String? = nil) {
        self.email = email
        self.flatNumber = flatNumber
        self.numberVerified = numberVerified
        self.phoneNumber = phoneNumber
        self.userName = userName
        self.dob = dob
    }
    func clone() -> UserVerify {
        var user = UserVerify()
        user.email = self.email
        user.flatNumber = self.flatNumber
        user.numberVerified = self.numberVerified
        user.phoneNumber = self.phoneNumber
        user.userName = self.userName
        user.dob = self.dob
        return user
    }
 }
class UserProfile: Encodable {
    var email :String?
    var flatNumber :String?
    var numberVerified :Bool?
    var phoneNumber :String?
    var userName :String?
    var dob :String?
    init(email: String? = nil, flatNumber: String? = nil, numberVerified: Bool? = nil, phoneNumber: String? = nil, userName: String? = nil, dob: String? = nil) {
        self.email = email
        self.flatNumber = flatNumber
        self.numberVerified = numberVerified
        self.phoneNumber = phoneNumber
        self.userName = userName
        self.dob = dob
    }
    func clone() -> UserProfile{
        var user = UserProfile()
        user.email = self.email
        user.flatNumber = self.flatNumber
        user.numberVerified = self.numberVerified
        user.phoneNumber = self.phoneNumber
        user.userName = self.userName
        user.dob = self.dob
        return user
    }
 }
struct Post: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
