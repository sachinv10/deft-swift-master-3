//
//  OfferDetailViewController.swift
//  Wifinity
//
//  Created by akshay patil on 06/05/22.
//

import UIKit

class OfferDetailViewController: UIViewController {
    
    @IBOutlet weak var offerImage: UIImageView!
    @IBOutlet weak var validTill: UILabel!
    @IBOutlet weak var offerValue: UILabel!
    @IBOutlet weak var offerTitle: UILabel!
    @IBOutlet weak var buyProduct: UIButton!
    @IBOutlet weak var backButton: UIButton!
    var offerData = OfferData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.layer.cornerRadius = 25
        buyProduct.layer.cornerRadius = 8

        setUpData()
    }
    
    
    func setUpData() {
        if let title = offerData.topic {
            offerTitle.text = title
        }
        
        if let imageLink = offerData.image {
            let url = URL(string: imageLink)
            offerImage.kf.setImage(with: url)
        }
        
        if let message = offerData.message {
            offerValue.text = message
        }
        
        if let timeResult = offerData.timestamp {
            if let unixtimeInterval = Double(timeResult) {
               
                let date = Date(timeIntervalSince1970: unixtimeInterval)
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
                dateFormatter.locale = NSLocale.current
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" //Specify your format that you want
                let strDate = dateFormatter.string(from: date)
                validTill.text = strDate
            }
        }
    }


    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buyProductClicked(_ sender: UIButton) {
        
        guard let url = URL(string: "https://homeonetechnologies.com/smart-products/") else {
          return //be safe
        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    
}
