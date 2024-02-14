//
//  CartBuyProduct+CoreDataProperties.swift
//  Wifinity
//
//  Created by Apple on 23/10/23.
//
//

import Foundation
import CoreData


extension CartBuyProduct {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CartBuyProduct> {
        return NSFetchRequest<CartBuyProduct>(entityName: "CartBuyProduct")
    }

    @NSManaged public var name: String?
    @NSManaged public var dprice: Int64
    @NSManaged public var itemCount: Int16
    @NSManaged public var deviceId: String?
    @NSManaged public var productImage: String?
    @NSManaged public var price: Int64
    @NSManaged public var productSummary: String?
    @NSManaged public var subType: String?
    @NSManaged public var summary: String?
    @NSManaged public var productSlides: String?
    @NSManaged public var alexaSupport: String?
    @NSManaged public var googleHomeSupport: String?
    @NSManaged public var installation: String?
    @NSManaged public var operationRange: String?
    @NSManaged public var powerSupply: String?
    @NSManaged public var sensorDetectionRange: String?
}

extension CartBuyProduct : Identifiable {

}
