//
//  Rule.swift
//  DEFT
//
//  Created by Rupendra on 24/10/21.
//  Copyright © 2021 Example. All rights reserved.
//

import Foundation


class Rule: NSObject {
    var id :String?
    var title :String?
    var isOn :Bool = false
    
    
    func clone() -> Rule {
        let aReturnVal = Rule()
        
        aReturnVal.id = self.id
        aReturnVal.title = self.title
        aReturnVal.isOn = self.isOn
        
        return aReturnVal
    }
    
}
