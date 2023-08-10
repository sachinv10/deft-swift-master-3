//
//  KeychainManager.swift
//  DEFT
//
//  Created by Rupendra on 29/08/20.
//  Copyright © 2020 Example. All rights reserved.
//

import Foundation
import Security


class KeychainManager: NSObject {

    static var shared :KeychainManager = {
        return KeychainManager()
    }()
    
    
    func save(key pKey :String, value pValue :String) -> Error? {
        var aReturnVal :Error? = nil
        
        if UtilityManager.isSimulator {
            UserDefaults.standard.set(pValue, forKey: pKey)
        } else {
            var aDict :[String:AnyObject] = [:]
            aDict[kSecClass as String] = kSecClassGenericPassword as AnyObject
            aDict[kSecAttrAccount as String] = pKey as AnyObject
            aDict[kSecValueData as String] = pValue.data(using: String.Encoding.utf8) as AnyObject
            SecItemDelete(aDict as CFDictionary)
            var aResult : AnyObject?
            let aStatus = SecItemAdd(aDict as CFDictionary, &aResult)
            if aStatus != Security.errSecSuccess {
                aReturnVal = NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Can not save data."])
            }
        }
        return aReturnVal
    }
    
    
    func getValue(forKey pKey :String) -> String? {
        var aReturnVal :String? = nil
        
        if UtilityManager.isSimulator {
            aReturnVal = UserDefaults.standard.string(forKey: pKey)
        } else {
            var aDict :[String:AnyObject] = [:]
            aDict[kSecClass as String] = kSecClassGenericPassword as AnyObject
            aDict[kSecAttrAccount as String] = pKey as AnyObject
            aDict[kSecReturnAttributes as String] = true as AnyObject
            aDict[kSecReturnData as String] = true as AnyObject
            var aResult : AnyObject?
            let aStatus = SecItemCopyMatching(aDict as CFDictionary, &aResult)
            if aStatus == Security.errSecSuccess {
                if let aResultDict = aResult as? [NSString : AnyObject], let aValue = aResultDict[kSecValueData] as? Data {
                    aReturnVal = String(data: aValue, encoding: String.Encoding.utf8)
                }
            } else if aStatus == Security.errSecItemNotFound {
                aReturnVal = nil
            }
        }
        
        return aReturnVal
    }
    
    
    func remove(valueForKey pKey :String) {
        if UtilityManager.isSimulator {
            UserDefaults.standard.removeObject(forKey: pKey)
        } else {
            var aDict :[String:String] = [:]
            aDict[kSecClass as String] = kSecClassGenericPassword as String
            aDict[kSecAttrAccount as String] = pKey
            SecItemDelete(aDict as CFDictionary)
        }
    }
    
}
