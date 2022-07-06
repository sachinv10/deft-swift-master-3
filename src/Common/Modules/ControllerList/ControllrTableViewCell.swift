//
//  TableViewCell.swift
//  Wifinity
//
//  Created by Apple on 27/06/22.
//

import UIKit

class ControllrTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor(named: "PrimaryLightestColor")
        lableonline.layer.cornerRadius = 7.5
        lableonline.layer.masksToBounds = true
    }

    @IBOutlet weak var lblswitchname: UILabel!
    @IBOutlet weak var lblRoomName: UILabel!
    @IBOutlet weak var lblControllerId: UILabel!
    func load(cellobj: ControllerAppliance) {
        
       if cellobj.online == true{
           lableonline.backgroundColor = UIColor.green
       }else{
           lableonline.backgroundColor = UIColor.red
       }
        
        lblswitchname.text = cellobj.name
        lblControllerId.text = cellobj.id
        lblRoomName.text = cellobj.roomName
        
    }
    
    
    @IBOutlet weak var lableonline: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
}
