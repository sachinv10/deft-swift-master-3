//
//  DataFetchManagerFireBaseCurtain.swift
//  DEFT
//
//  Created by Rupendra on 08/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase


extension DataFetchManagerFireBase {
    
    func searchCurtain(completion pCompletion: @escaping (Error?, Array<Curtain>?) -> Void, room pRoom :Room?) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aCurtainArray :Array<Curtain>?
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                if (pRoom?.id?.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No room id available."])
                }
                
                // Fetch curtain IDs
                let aFilter = Auth.auth().currentUser!.uid + "_" + (pRoom?.id ?? "") + "_curtain"
                
                let aCurtainDispatchSemaphore = DispatchSemaphore(value: 0)
                self.database
                    .child("devices")
                    .queryOrdered(byChild: "filter")
                    .queryEqual(toValue: aFilter)
                    .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                        if let aDict = pDataSnapshot.value as? Dictionary<String,Dictionary<String,Any>> {
                            aCurtainArray = DataContractManagerFireBase.curtains(dict: aDict)
                        }
                        aCurtainDispatchSemaphore.signal()
                    }
                _ = aCurtainDispatchSemaphore.wait(timeout: .distantFuture)
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError, aCurtainArray)
            }
        }
        
    }
    
    
    func updateCurtainMotionState(completion pCompletion: @escaping (Error?) -> Void, curtain pCurtain :Curtain, motionState pMotionState :Curtain.MotionState) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Send message and reset it
                var aMessageValue = ""
                aMessageValue += "M012"
                aMessageValue += String(format: "%02d", pMotionState.rawValue)
                aMessageValue += "0F"
                anError = self.sendMessage(aMessageValue, entity: pCurtain)
                if anError != nil {
                    throw anError!
                }
            } catch {
                anError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(anError)
            }
        }
    }
    
    
    func updateCurtainDimmableValue(completion pCompletion: @escaping (Error?) -> Void, curtain pCurtain :Curtain, dimValue pDimValue :Int) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aReturnValError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                // Send message and reset it
                var aMessageValue = ""
                aMessageValue += "M012"
                aMessageValue += String(format: "%02d", pDimValue)
                aMessageValue += "0F"
                let anError = self.sendMessage(aMessageValue, entity: pCurtain)
                if anError != nil {
                    throw anError!
                }
            } catch {
                aReturnValError = error
            }
            
            DispatchQueue.main.async {
                self.requestCount -= 1
                pCompletion(aReturnValError)
            }
        }
        
    }
    func createEmailverification(emailstring: String) -> String {
        var result = emailstring.replacingOccurrences(of: ".", with: "_",
            options: NSString.CompareOptions.literal, range:nil)
          result = result.replacingOccurrences(of: ",", with: "_",
            options: NSString.CompareOptions.literal, range:nil)
          result = result.replacingOccurrences(of: "$", with: "_",
            options: NSString.CompareOptions.literal, range:nil)
        result = result.replacingOccurrences(of: "]", with: "_",
          options: NSString.CompareOptions.literal, range:nil)
        result = result.replacingOccurrences(of: "[", with: "_",
          options: NSString.CompareOptions.literal, range:nil)
        result = result.replacingOccurrences(of: "#", with: "_",
          options: NSString.CompareOptions.literal, range:nil)
        
        return result
    }
    func veryfyEmail(completion pCompletion: @escaping (Error?, String?) -> Void, email pemail :String?, otp pOtp :String?) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aCurtainArray :String?
            var anError :Error?
            
            var Loginparametor: Dictionary<String, Any>? = Dictionary<String, Any>()
            Loginparametor?.updateValue(pemail, forKey: "emailId")
            Loginparametor?.updateValue(pOtp, forKey: "verificationCode")
            let timestamp = NSDate().timeIntervalSince1970
            let timestamp1 = Int(timestamp * 1000)
            OTPVerifyViewController.timestampfinal = timestamp1
            Loginparametor?.updateValue(Int(timestamp1), forKey: "verifiedTime")
            
            // Fetch curtain IDs
           var emailstring = String()
                  let aCurtainDispatchSemaphore = DispatchSemaphore(value: 0)
            let x = pemail?.split(separator: "@")
            emailstring = String(x![0])
            let result = self.createEmailverification(emailstring: emailstring)
            OTPVerifyViewController.timestamp = result
                            self.database
                .child("emailVerification").child(result).updateChildValues(Loginparametor!, withCompletionBlock: {(error, pDataSnapshot)  in
                    print(pDataSnapshot)
 
                    if error == nil{
                        
                        let url = "http://34.68.55.33:3002/api-email"
                        guard let serviceUrl = URL(string: url) else { return }
                        
                        do {
                            var request = URLRequest(url: serviceUrl)
                            request.httpMethod = "POST"
                             request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                            let parameters = "code=\(pOtp!)&email=\(pemail!)"
                            let postData =  parameters.data(using: .utf8)
                            request.httpBody = postData
                            request.timeoutInterval = 20
                            let session = URLSession.shared
                            session.dataTask(with: request) { (data, response, error) in
                                if let response = response {
                                }
                                anError = error
                                if let httpResponse = response as? HTTPURLResponse {
                                    print(String(httpResponse.statusCode))
                                }
                                if let data = data {
                                    do {
                                        let json = try JSONSerialization.jsonObject(with: data, options:  JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                                        print(json)
                                        aCurtainArray = json["status"] as? String
                                        CreateAccountViewController.massege = json["message"] as! String
                                    } catch {
                                        print(error)
                                    }
                                }
                                DispatchQueue.main.async {
                                    self.requestCount -= 1
                                    pCompletion(anError, aCurtainArray)
                                }
                            }.resume()
                        
                        } catch {
                            anError = error
                        }
           
                    }
    
                                    aCurtainDispatchSemaphore.signal()
                                })
               _ = aCurtainDispatchSemaphore.wait(timeout: .distantFuture)
            
      
            
            
        }
        
    }
}
