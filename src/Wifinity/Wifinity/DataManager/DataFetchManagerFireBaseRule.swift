//
//  DataFetchManagerFireBaseRule.swift
//  Wifinity
//
//  Created by Rupendra on 24/10/21.
//

import Foundation


extension DataFetchManagerFireBase {
    
    func searchRule(completion pCompletion: @escaping (Error?, Array<Rule>?) -> Void) {
        pCompletion(NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Functionality not supported."]), nil)
    }
    
    
    func updateRuleState(completion pCompletion: @escaping (Error?) -> Void, rule pRule :Rule, state pState :Bool) {
        pCompletion(NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Functionality not supported."]))
    }
    
}

