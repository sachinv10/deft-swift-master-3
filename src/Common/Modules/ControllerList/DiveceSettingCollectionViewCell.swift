//
//  DiveceSettingCollectionViewCell.swift
//  Wifinity
//
//  Created by Apple on 12/10/23.
//

import UIKit

class DiveceSettingCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var roomNamelbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = 7
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.purple.cgColor
    }

}
