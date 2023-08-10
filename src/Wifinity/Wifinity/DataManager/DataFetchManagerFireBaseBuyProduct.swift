//
//  DataFetchManagerFireBaseBuyProduct.swift
//  Wifinity
//
//  Created by Apple on 12/06/23.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase


extension DataFetchManagerFireBase {
    
    func selectProductList(completion pCompletion: @escaping (Error?, Array<Ecommerce>?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aMoodArray :Array<Ecommerce>? = Array<Ecommerce>()
        
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }

            
                // Buy Product list
                     var aFetchedApplianceArray = Array<Appliance>()
              
                        let aDispatchSemaphore = DispatchSemaphore(value: 0)
                        var databs = self.database
                            .child("Ecommerce")
                         databs.observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                             print(pDataSnapshot.value)
                             let pdata = pDataSnapshot.value as? Dictionary<String, Dictionary<String,Any>>
                             if let productlist = DataContractManagerFireBase.BuyProductList(dict: pdata!){
                                 print(productlist)
                                 aMoodArray?.append(contentsOf: productlist)
                             }
                                aDispatchSemaphore.signal()
                            }
                        _ = aDispatchSemaphore.wait(timeout: .distantFuture)
              
        
                
                if (aMoodArray?.count ?? 0) <= 0 {
                    aMoodArray = nil
                }
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, aMoodArray)
            }
        }
        
    }
}
