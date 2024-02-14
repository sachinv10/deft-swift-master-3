//
//  GeoListTableViewCell.swift
//  Wifinity
//
//  Created by Apple on 03/01/24.
//

import UIKit

class GeoListTableViewCell: UITableViewCell {

    @IBOutlet weak var lblBtnActivate: UIButton!
    @IBOutlet weak var lblName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func loaddata(){
        lblName.text = "Geo Name"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func didtappedActivatebtn(_ sender: Any) {
        print("Activate")
    }
}
