//
//  ProductDetailViewController.swift
//  Wifinity
//
//  Created by Apple on 13/06/23.
//

import UIKit

class ProductDetailViewController: BaseController {
// MARK: - OUTLATE
    
    @IBOutlet weak var lblProductDetail: UILabel!
    @IBOutlet weak var productInfo: UILabel!
    @IBOutlet weak var lbloffPercent: UILabel!
    @IBOutlet weak var lblDiscountPrice: UILabel!
    @IBOutlet weak var lblActualprice: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var mainview: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Buy Product"
        subTitle = ""
        UiSetUp()
    }
    func UiSetUp(){
        
        
        
       
        
    }

}
