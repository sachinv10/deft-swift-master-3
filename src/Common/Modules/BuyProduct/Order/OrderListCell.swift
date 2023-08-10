//
//  OrderListCell.swift
//  Wifinity
//
//  Created by Apple on 17/06/23.
//

import UIKit

class OrderListCell: UITableViewCell {

    @IBOutlet weak var Stackview: UIStackView!
    @IBOutlet weak var lblProductName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        Stackview.addSubview(lblProductName)
        Stackview.addSubview(lblProductName)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
     print("selected cell")
        // Configure the view for the selected state
    }
    
}
