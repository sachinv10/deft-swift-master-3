//
//  OrderItemTableViewCell.swift
//  Wifinity
//
//  Created by Apple on 21/11/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class OrderItemTableViewCell: UITableViewCell {

     
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func loadfnc(obj: Any){
        let x = obj as! items
      //  downloadImage(obj: x.name!)
        lblProductName.text = "\(String(describing: x.name ?? ""))\n quantity:\(String(x.quantity))"
        lblProductPrice.text = "₹ \(x.price ?? "0")"
        lblTotalAmount.text = "₹ \(String(x.quantity * (Int(x.price ?? "0")!)))"
        
    }
    func downloadImage(obj: String){
        
//        Database.database().reference().child("Ecommerce").child(obj).observeSingleEvent(of: .value, with: {dataSnapshot in
//            print(dataSnapshot)
//        })
    }
    @IBOutlet weak var ProfileImage: UIImageView!
    @IBOutlet weak var lblTotalAmount: UILabel!
    @IBOutlet weak var lblProductPrice: UILabel!
    @IBOutlet weak var lblProductName: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
}
