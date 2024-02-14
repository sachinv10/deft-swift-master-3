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
    func selectBuyProductAddressList(completion pCompletion: @escaping (Error?, Array<address>?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.requestCount += 1
            
            var aMoodArray :Array<address>? = Array<address>()
        
            var anError :Error?
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
            
                // Buy Product list
                     var aFetchedApplianceArray = Array<Appliance>()
              
                        let aDispatchSemaphore = DispatchSemaphore(value: 0)
                        var databs = self.database
                    .child("Address").child(Auth.auth().currentUser!.uid)
                         databs.observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                             print(pDataSnapshot.value)
                             guard let pdata = pDataSnapshot.value as? Dictionary<String, Dictionary<String,Any>> else{return}
                             if let productlist = DataContractManagerFireBase.BuyProductAddressList(dict: pdata){
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
    
    func orderList(complition pComplition:@escaping([OrderList]?)-> Void) {
        DispatchQueue.global(qos: .background).async {
            var anError :Error?
            var orderlist:[OrderList]? = [OrderList]()
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                let aDispatchSemaphore = DispatchSemaphore(value: 0)
                let databs = self.database
                    .child("Orders").child(Auth.auth().currentUser!.uid)
                           databs.observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                               print(pDataSnapshot.value)
                               guard let pdata = pDataSnapshot.value as? Dictionary<String,Dictionary<String,Any>> else{return}
                               if let productlist = DataContractManagerFireBase.orderListDataParsse(dict: pdata){
                                   print("order count:",productlist.count)
                                   orderlist?.append(contentsOf: productlist)
                               }
//                               orderlist!.sort { (pLhs, pRhs) -> Bool in
//                                   return pLhs < pRhs
//                               }
                               
                                  aDispatchSemaphore.signal()
                               
                               pComplition(orderlist)
                              }
                          _ = aDispatchSemaphore.wait(timeout: .distantFuture)
            }catch{
                
            }
        }
    }
    func orderPlace(complition pComplition:@escaping(Error?)-> Void, OrderList POrderList: [cartData]?, address Paddress: address?, user pUser: UserVerify?) {
        DispatchQueue.global(qos: .background).async {
            var anError :Error?
     //       var orderlist:[OrderList]? = [OrderList]()
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                let currentTimestamp = Date().timeIntervalSince1970
                let currentTimestampInt = Int(currentTimestamp) * 1000
                
                var dicOrderDetail: Dictionary<String,Any> = Dictionary<String,Any>()
                if let user = pUser{
                    dicOrderDetail.updateValue(user.userName, forKey: "name")
                    dicOrderDetail.updateValue(user.email, forKey: "email")
                    dicOrderDetail.updateValue(user.phoneNumber, forKey: "number")
                }
                dicOrderDetail.updateValue("Pending", forKey: "orderStatus")
                dicOrderDetail.updateValue(String(currentTimestampInt), forKey: "orderId")
                dicOrderDetail.updateValue(currentTimestampInt, forKey: "timestamp")
                
                if let add = Paddress{
                    var dicaddressDetail: Dictionary<String,Any> = Dictionary<String,Any>()
                    dicaddressDetail.updateValue(add.city, forKey: "city")
                    dicaddressDetail.updateValue(add.flat, forKey: "flat")
                    dicaddressDetail.updateValue(add.pincode, forKey: "pincode")
                    dicaddressDetail.updateValue(add.society, forKey: "society")
                    dicaddressDetail.updateValue(add.state, forKey: "state")
                    
                    dicOrderDetail.updateValue(dicaddressDetail, forKey: "address")
                }
                var ItemList: Dictionary<String,Any> = Dictionary<String,Any>()
                if let orders = POrderList{
                    
                    for items in orders{
                        var cnt = String(ItemList.count)
                        var dicItemDetail: Dictionary<String,Any> = Dictionary<String,Any>()
                        dicItemDetail.updateValue(items.Name, forKey: "name")
                        dicItemDetail.updateValue(items.price, forKey: "price")
                        dicItemDetail.updateValue(items.Quantity, forKey: "quantity")
                        ItemList.updateValue(dicItemDetail, forKey: cnt)
                    }
                    dicOrderDetail.updateValue(ItemList, forKey: "items")
                }
                
                
                let aDispatchSemaphore = DispatchSemaphore(value: 0)
                let databs = self.database
                    .child("Orders").child(Auth.auth().currentUser!.uid)
                let orderid = dicOrderDetail["orderId"] as! String
                databs.child(orderid).updateChildValues(dicOrderDetail, withCompletionBlock: {(error, DatabaseReference )in
                    if error == nil{
                        print(DatabaseReference)
                      
                    }
                    pComplition(error)
                })
                
                          _ = aDispatchSemaphore.wait(timeout: .distantFuture)
            }catch{
                
            }
        }
    }
    
    func saveAddress(complition pComplition:@escaping(Error?)-> Void, address Paddress: address?) {
        DispatchQueue.global(qos: .background).async {
            var anError :Error?
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                
                 var dicaddressDetail: Dictionary<String,Any> = Dictionary<String,Any>()
                
                if let add = Paddress{
                    dicaddressDetail.updateValue(add.city, forKey: "city")
                    dicaddressDetail.updateValue(add.flat, forKey: "flat")
                    dicaddressDetail.updateValue(add.pincode, forKey: "pincode")
                    dicaddressDetail.updateValue(add.society, forKey: "society")
                    dicaddressDetail.updateValue(add.state, forKey: "state")
                }
                
                let aDispatchSemaphore = DispatchSemaphore(value: 0)
                let databs = self.database
                    .child("Address").child(Auth.auth().currentUser!.uid)
              //  databs.childByAutoId()
                let randomgenId = UtilityManager.randomUuid()
                databs.child(randomgenId).updateChildValues(dicaddressDetail, withCompletionBlock: {(error, DatabaseReference )in
                    if error == nil{
                        print(DatabaseReference)
                    }
                    pComplition(error)
                })
                
                          _ = aDispatchSemaphore.wait(timeout: .distantFuture)
            }catch{
                
            }
        }
    }
    
    func addToCart(complition pComlition: @escaping(Error?, Array<Ecommerce>?)-> Void, product : Ecommerce){
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                let pr = String(product.Dprice ?? 0)
                var dic: Dictionary<AnyHashable,Any> = Dictionary<AnyHashable,Any>()
                dic.updateValue(product.name, forKey: "Name")
                dic.updateValue(product.count, forKey: "Quantity")
                dic.updateValue(pr, forKey: "price")
                dic.updateValue(product.productImage, forKey: "ImgUrl")
                
                let databaseref = self.database.child("Cart").child(Auth.auth().currentUser!.uid).child(product.name!)
                if product.count ?? 0 > 0{
                    databaseref.updateChildValues(dic, withCompletionBlock: {(error, database)in
                        pComlition(error, nil)
                    })
                }else{
                    databaseref.removeValue(completionBlock: {(error, databaseref)in
                        pComlition(error, nil)
                    })
                }
            }catch{
                pComlition(error, nil)
            }
            
        }
    }

    func fetchDataCommon(complition pComlition: @escaping(Error?, Any)-> Void, databasePath: String){
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                self.database.child(databasePath).observe(.value, with: {datasnapshot in
                    pComlition(nil, datasnapshot.value)
                })
                
            }catch{
                pComlition(error, "x")
            }
            
        }
    }

}
