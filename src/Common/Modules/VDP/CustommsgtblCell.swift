//
//  CustommsgtblCell.swift
//  Wifinity
//
//  Created by Apple on 24/01/23.
//

import UIKit
protocol CustmsgProtocall: AnyObject{
    func cellCustommsg(cell: CustommsgtblCell)
}
class CustommsgtblCell: UITableViewCell {

    @IBOutlet weak var lbldiscreption: UILabel!
    @IBOutlet weak var lblWelcomemsge: UILabel!
    
    @IBOutlet weak var lblEditbtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblEditbtn.setTitle("", for: .normal)
    }
    var model: MyModel?
    func loaddata(obj: MyModel){
        model = obj
        lblWelcomemsge.text = obj.msgType
        lbldiscreption.text = obj.msgContent
    }
    var delegate: CustmsgProtocall?
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didtappedEditbtn(_ sender: Any) {
        print("tapped Edit button cell")
        delegate?.cellCustommsg(cell: self)
    }
}
