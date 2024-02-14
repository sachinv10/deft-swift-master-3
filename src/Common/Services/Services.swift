//
//  Services.swift
//  Wifinity
//
//  Created by Apple on 02/02/24.
//

import Foundation

class Services: NSObject{
    static let Shared:Services = {
        return Services()
    }()
    
    func createURLRequest(reqPara: RequestParameters) -> URLRequest? {
        let url = URL(string: "https://jaderesidencies.homeonetechnologies.in/api/wifinityOperationLog")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
       // let parameters = RequestParameters(uid: "FfSECPSfLVdChRjfVICwzcFAlWF2", date: "02/02/2024 11:25:00", deviceName: "Samsung SM-G970F", command: "C051648371836631:C0232105F", description: "appliance Operated")
        
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(reqPara)
        } catch {
            print("Error encoding request parameters: \(error)")
            return nil
        }
        
        return request
    }
    func serviceUrlDiviceOperated(reqPara: RequestParameters){
        if let urlRequest = createURLRequest(reqPara: reqPara) {
            DispatchQueue.global(qos: .background).async {
             URLSession.shared.dataTask(with: urlRequest) { data, response, error in
               print("Updated")
              }.resume()
          }
       }
    }
}
