//
//  Ecommerce.swift
//  Wifinity
//
//  Created by Sachin on 12/06/23.
//

import Foundation

struct Ecommerce: Codable{
     var Dprice: Int?
     var deviceId: String?
     var name: String?
     var price: Int?
    // var itemCount: Int16 = 0
     var productDetails: ProductDetails
     var productImage: String?
     var productSlides: Array<productSlides>
     var productSummary: String?
     var subType: String?
     var summary: String?
     var count: Int? = 1
    var productSlidesString: String? {
        var rValue = ""
        for item in productSlides{
            if rValue == ""{
                rValue = item.uri ?? ""
            }else{
                rValue += ", \(item.uri ?? "")"
            }
        }
        return rValue
    }
}

struct ProductDetails: Codable {
    var alexaSupport: String?
    var googleHomeSupport: String?
    var installation: String?
    var operationRange: String?
    var powerSupply: String?
    var sensorDetectionRange: String?
    
    enum CodingKeys: String, CodingKey {
        case alexaSupport = "Alexa Support"
        case googleHomeSupport = "GoogleHome Support"
        case installation = "Installation"
        case operationRange = "Operation Range"
        case powerSupply = "Power Supply"
        case sensorDetectionRange = "Sensor detection Range"
    }
}

struct productSlides: Codable{
    var uri: String?
}
//MARK: - Order detail
struct OrderList: Codable{
    var address: address
    var email: String?
    var expectedDate: Int?
    var items: Array<items>
    var name: String?
    var number: String?
    var orderId: String?
    var orderStatus: String?
    var payment: String?
    var timestamp: Int?
    var uid:String?
}
struct items: Codable{
    var name: String?
    var price:String?
    var quantity: Int
}
struct address: Codable{
    var city: String?
    var flat: String?
    var pincode: String?
    var society: String?
    var socity: String?
    var state: String?
}

struct cartData: Codable{
    var Name: String?
    var Quantity: Int?
    var price: String?
    var ImgUrl: String?
}
