//
//  OffersTableViewCell.swift
//  Wifinity
//
//  Created by akshay patil on 06/05/22.
//

import UIKit
import Kingfisher

class OffersTableViewCell: UITableViewCell {
    @IBOutlet weak var containerDataView: UIView!
    @IBOutlet weak var offerImage: UIImageView!
    @IBOutlet weak var offerTitle: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //containerDataView.setCornerRadiusWithBorder(color: UIColor(red: 219/255, green: 219/255, blue: 219/255, alpha: 1), radius: 8, width: 1)
        containerDataView.addShadowToView(cornerRadius: 8)


        // Initialization code
    }
    
    func configureCell(offerData: OfferData) {
        if let title = offerData.topic {
            offerTitle.text = title
        }
        
        if let imageLink = offerData.image {
            let url = URL(string: imageLink)

            offerImage.kf.setImage(with: url)
            offerImage.contentMode = .scaleAspectFill
        }
        
        // offerTitle.text = offerData.title
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension UIView {
    
    func setCornerRadiusWithBorder(color: UIColor,radius: CGFloat,width: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
    
    func addShadowToView(color: UIColor = UIColor.lightGray, cornerRadius: CGFloat) {
        self.backgroundColor = .white
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        self.clipsToBounds = false
        self.layer.shadowOpacity = 0.8
        self.layer.shadowOffset = CGSize(width: 0, height: 6)
        self.layer.shadowColor = color.cgColor
        self.layer.shadowRadius = 8
    }
    
}
