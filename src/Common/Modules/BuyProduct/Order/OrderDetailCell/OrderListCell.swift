//
//  OrderListCell.swift
//  Wifinity
//
//  Created by Apple on 17/06/23.
//

import UIKit

class OrderListCell: UITableViewCell {

    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblOrderDate: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblOrderId: UILabel!
    @IBOutlet weak var Stackview: UIStackView!
    @IBOutlet weak var lblProductName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 10
        self.contentView.layer.borderWidth = 0.5
        self.contentView.layer.borderColor = UIColor.gray.cgColor
        // Initialization code
//        Stackview.addSubview(lblProductName)
//        Stackview.addSubview(lblProductName)
        lblProductName.isHidden = true
        Stackview.spacing = 15
    }
    func loadData(obj: OrderList){
        
        var priseAmt = 0
        for subview in Stackview.arrangedSubviews {
            Stackview.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        for item in obj.items{
            let lblname = UILabel()
            lblname.text =  (item.name ?? "") + " (quantity: \(String(item.quantity)))"
            self.Stackview.addArrangedSubview(lblname)
            priseAmt += ((Int(item.price ?? "0") ?? 0) * Int(item.quantity))
        }
        lblAmount.text = "Rs: " + String(priseAmt)
        lblOrderId.text = obj.orderId
        lblStatus.text = obj.orderStatus
        lblOrderDate.text = SharedFunction.shared.timeStampToDate(time: obj.timestamp ?? 0)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        print("selected cell")
        // Configure the view for the selected state
    }
    
}
