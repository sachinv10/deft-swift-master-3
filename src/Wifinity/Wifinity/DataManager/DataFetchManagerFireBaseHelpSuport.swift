//
//  DataFetchManagerFireBaseHelpSuport.swift
//  Wifinity
//
//  Created by Apple on 13/02/24.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import Firebase
extension DataFetchManagerFireBase {
  
    func getTechnicalSheet(comletion pCompletion: @escaping(Result<[technicalSheet],Error>)-> Void){
        Database.database().reference().child("files").child("technicalSheet")
           .observeSingleEvent(of: .value, with: { snapshot in

               if let aDict = snapshot.value as? Array<Dictionary<String, Any>> {
                   do{
                           let jsonData = try JSONSerialization.data(withJSONObject: aDict, options: [])
                           if let jsonString = String(data: jsonData, encoding: .utf8) {
                               let data = jsonString.data(using: .utf8)
                               let decoder = JSONDecoder()
                               let response = try decoder.decode([technicalSheet].self, from: jsonData)
                               pCompletion(.success(response))
                           }
                   }catch{
                       pCompletion(.failure(error))
                   }
               }else{
                   pCompletion(.failure(NSError(domain: "com", code: 1,userInfo: [NSLocalizedDescriptionKey : "Data not found"])))
               }
            
           })
   }
    enum result: String{
        case technical = "technical"
        case product = "product"
        case loding
        case loded
        case stop
    }
}
