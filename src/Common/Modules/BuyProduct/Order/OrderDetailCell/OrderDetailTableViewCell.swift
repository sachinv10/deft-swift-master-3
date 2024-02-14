//
//  OrderDetailTableViewCell.swift
//  Wifinity
//
//  Created by Apple on 21/11/23.
//

import UIKit
import Foundation

class OrderDetailTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var lblGrandTotal: UILabel!
    @IBOutlet weak var lblContact: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblOrderOn: UILabel!
    @IBOutlet weak var lblExpectedDeleveryDate: UILabel!
    @IBOutlet weak var lblOrderStatus: UILabel!
    let currentTimestamp = Date().timeIntervalSince1970
    func loadData(obj: Any, totol: String){
        let x = obj as! OrderList
        lblGrandTotal.text = "Granc Total Rs: \(totol)"
        lblOrderStatus.text = x.orderStatus
        lblOrderOn.text = SharedFunction.shared.timeStampToDate(time: x.timestamp ?? 0)
        var time = (x.expectedDate ?? x.timestamp ?? 0)
        let currentDate = Date(timeIntervalSince1970: TimeInterval(time))
        if let futureDate = Calendar.current.date(byAdding: .day, value: 2, to: currentDate) {
            let futureTimestamp = futureDate.timeIntervalSince1970
            lblExpectedDeleveryDate.text = SharedFunction.shared.timeStampToOnlyDate(time: Int(futureTimestamp))
        }
        lblAddress.text = "\(x.address.flat ?? ""), \(x.address.society ?? ""), \(x.address.socity ?? ""), \(x.address.city ?? ""), \(x.address.state ?? ""), \(x.address.pincode ?? "")"
        lblContact.text = x.number
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
