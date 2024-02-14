//
//  cartTableViewCell.swift
//  Wifinity
//
//  Created by Apple on 10/11/23.
//

import UIKit

class cartTableViewCell: UITableViewCell {

    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var steperlbl: UIStepper!
    var delegate: MyProtocol?
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var ImgeIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
 
    func loadData(obj: cartData){
        lblAmount.text = String(Int(obj.price!)! * Int(obj.Quantity!))
        lblCount.text = String(Int(obj.Quantity!))
        steperlbl.value = Double(obj.Quantity!)
        productName.text = obj.Name
        ImgeIcon.downloaded(from: obj.ImgUrl ?? "")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didTappedSteper(_ sender: Any) {
        delegate?.doSomething(cell: self, value: steperlbl.value)
    }
    
}
protocol MyProtocol {
    func doSomething(cell: cartTableViewCell,value: Double)
}
