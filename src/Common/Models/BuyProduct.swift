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
     var productDetails: ProductDetails
     var productImage: String?
     var productSlides: Array<productSlides>
     var productSummary: String?
     var subType: String?
     var summary: String?
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
