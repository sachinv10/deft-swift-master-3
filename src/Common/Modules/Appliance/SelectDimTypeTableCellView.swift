//
//  SelectDimTypeTableCellView.swift
//  Wifinity
//
//  Created by Rupendra on 17/01/21.
//

import UIKit

class SelectDimTypeTableCellView: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func load(dimType pDimType :Appliance.DimType) {
        self.titleLabel.text = pDimType.title
    }
    
    
    static func cellHeight() -> CGFloat {
        return 48.0
    }
    
}
