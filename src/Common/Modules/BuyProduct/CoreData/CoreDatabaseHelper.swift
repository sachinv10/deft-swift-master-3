//
//  CoreDatabaseHelper.swift
//  Wifinity
//
//  Created by Apple on 23/10/23.
//

import Foundation
import UIKit
import CoreData

class CoreDatabaseHelper{
    static var Shared = CoreDatabaseHelper()
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    func save(object: Ecommerce?){
        let productdata = NSEntityDescription.insertNewObject(forEntityName: "CartBuyProduct", into: context!) as! CartBuyProduct
        productdata.name = object?.name
        productdata.dprice = Int64(object?.Dprice ?? 0)
    //    productdata.itemCount = Int16(object!.itemCount)
        productdata.deviceId = object?.deviceId
        productdata.price = Int64(object?.price ?? 0)
        productdata.productSummary = object?.productSummary
        productdata.summary = object?.summary
        productdata.subType = object?.subType
        productdata.productImage = object?.productImage
        productdata.productSlides = object?.productSlidesString
        if let productdetail = object?.productDetails{
            productdata.alexaSupport = productdetail.alexaSupport
            productdata.googleHomeSupport = productdetail.googleHomeSupport
            productdata.installation = productdetail.installation
            productdata.operationRange = productdetail.operationRange
            productdata.powerSupply = productdetail.powerSupply
            productdata.sensorDetectionRange = productdetail.sensorDetectionRange
        }
        do{
           try context?.save()
        }catch{
            print("data not save")
        }
    }
    func deleteProduct(object: Ecommerce?){

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CartBuyProduct")
        let predicate = NSPredicate(format: "deviceId == %@", (object?.deviceId)!)
        fetchRequest.predicate = predicate

        do {
            let objectsToDelete = try context?.fetch(fetchRequest)
            for object in objectsToDelete! {
                context!.delete(object as! NSManagedObject)
            }
            try context?.save()
            print("Data deleted successfully.")
         } catch {
            print("Error deleting data: \(error)")
        }
      }
}
