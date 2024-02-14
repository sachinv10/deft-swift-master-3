//
//  TableViewCell.swift
//  Wifinity
//
//  Created by Apple on 12/06/23.
//

import UIKit

class TableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var lblOffPercentage: UILabel!
    @IBOutlet weak var imageviwe: UIImageView!
 
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDiscount: UILabel!
    @IBOutlet weak var lblamount: UILabel!
    @IBOutlet weak var lblDiscountAmount: UILabel!
    func load(obj: Ecommerce)
    {
        imageviwe.downloaded(from: obj.productImage ?? "")
        lblName.text =  obj.name!
         let offer = "You Save ₹ \(String(describing: obj.price! - obj.Dprice!)) On This Product"
        lblDiscount.text = offer
        lblDiscountAmount.text = "₹ \(String(describing: obj.Dprice!))"
        let attributedString = NSAttributedString(string: "₹ \( String(describing: obj.price!))",
                                                         attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
        lblamount.attributedText = attributedString
        lblOffPercentage.text = ""
        let dis = obj.price! - obj.Dprice!
        if dis > 0{
            var x = (110 / 100) * 100
            let off = (Float(dis) / Float(obj.price!)) * 100
            lblOffPercentage.text = "\(String(describing: Int(off))) % off"
        }
    }
}
extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
