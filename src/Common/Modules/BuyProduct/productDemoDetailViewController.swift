//
//  productDemoDetailViewController.swift
//  Wifinity
//
//  Created by Apple on 15/06/23.
//

import UIKit
import Foundation

class productDemoDetailViewController: BaseController {
    // MARK: - OUTLATE
        
    @IBOutlet weak var lblMenu: UIButton!
    @IBOutlet weak var lblCart: UIButton!
    @IBOutlet weak var lblProductDetail: UILabel!
        @IBOutlet weak var productInfo: UILabel!
        @IBOutlet weak var lbloffPercent: UILabel!
        @IBOutlet weak var lblDiscountPrice: UILabel!
        @IBOutlet weak var lblActualprice: UILabel!
        @IBOutlet weak var productName: UILabel!
        @IBOutlet weak var pageController: UIPageControl!
        @IBOutlet weak var imageview: UIImageView!
        
    
    @IBOutlet weak var viewFirstview: UIView!
    @IBOutlet weak var viewSecondview: UIView!
    @IBOutlet weak var viewThirdView: UIView!
    @IBOutlet weak var viewForthview: UIView!
    @IBOutlet weak var viewFipthview: UIView!
    @IBOutlet weak var viewsixthview: UIView!
    
    
    @IBOutlet weak var lblFrist: UILabel!
    @IBOutlet weak var lblSecond: UILabel!
    @IBOutlet weak var lblThird: UILabel!
    @IBOutlet weak var lblForth: UILabel!
    @IBOutlet weak var lblFipth: UILabel!
    @IBOutlet weak var lblSixth: UILabel!
    var count = 0
    var timer: Timer?
    var Product: Ecommerce?
    deinit{
        timer?.invalidate()
        timer = nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Product Detail"
        subTitle = ""
        let details = Product
        print(Product?.name)
        imageSlide()
        UiSetUp()
        tecnicalDetailManage()
        pageController.numberOfPages = Product?.productSlides.count ?? 0
        pageController.currentPage = 0
   
        let swipeGestureone = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        swipeGestureone.direction = .left
        self.view.addGestureRecognizer(swipeGestureone)
        let swipeGestureonee = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        swipeGestureonee.direction = .right
        self.view.addGestureRecognizer(swipeGestureonee)
     }
    @objc func swipeLeft(_ sender: UISwipeGestureRecognizer) {
        // Handle the swipe left gesture here
      if sender.direction == UISwipeGestureRecognizer.Direction.left{
            print("swipeleft")
          if count > 1{
              count -= 2
          }else if count > 0{
              count = 0
          }
          timerFired()
        }
        if sender.direction == UISwipeGestureRecognizer.Direction.right{
            print("swipeRight")
            timerFired()
        }
    }
    func imageSlide(){
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
     }
    

    @objc func timerFired() {
        pageController.currentPage = count
        let imageurl = Product?.productSlides
        if count < Product?.productSlides.count ?? 0{
            loadImage(url: (imageurl?[count].uri)!)
            count += 1
        }else{
            if Product?.productSlides != nil{
                count = 0
                loadImage(url: (imageurl?[count].uri)!)
            }
        }
    }
    func loadImage(url: String){
        imageview.downloaded(from:url)
    }
    @objc func pageControlDidChange(_ sender: UIPageControl) {
        let currentPage = sender.currentPage
        print("currentPage",currentPage)
//        let offset = CGPoint(x: scrollView.frame.width * CGFloat(currentPage), y: 0)
//        scrollView.setContentOffset(offset, animated: true)
    }
    func UiSetUp(){
        let price = Product?.price!
        let dprice = Product?.Dprice!
        var div = (Float(price ?? 0) - Float(dprice ?? 0)) / Float(price ?? 0)
        let off = div * 100
        productName.text = Product?.name!
        let attributedString = NSAttributedString(string: String(describing: price!),
                                                         attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
        lblActualprice.attributedText = attributedString
      //  lblActualprice.text = String(describing: price!)
        lblDiscountPrice.text = String(describing: dprice!)
        lbloffPercent.text = String(describing: "\(Int(off)) % off")
        productInfo.text = Product?.productSummary!
        lblProductDetail.text = Product?.summary!
        lblCart.setTitle("", for: .normal)
        lblMenu.setTitle("", for: .normal)
    }
    // MARK: - ACTION METHOD
    
    @IBAction func didtappedMenuOrder(_ sender: Any) {
   
    }
    @IBAction func didtappedCart(_ sender: Any) {
   
    }
    
    func tecnicalDetailManage(){
        
        if let products =  Product?.productDetails{
            print(products.alexaSupport)
           
            if products.installation != nil{
                viewFirstview.isHidden = false
                lblFrist.text = products.installation!
            }else{
                viewFirstview.isHidden = true
            }
            
            
             if products.googleHomeSupport != nil{
                 viewSecondview.isHidden = false
                 lblSecond.text = products.googleHomeSupport!
             }else{
                 viewSecondview.isHidden = true
             }
            
            
             if products.alexaSupport != nil{
                 viewThirdView.isHidden = false
                 lblThird.text = products.alexaSupport!
                 
             }else{
                 viewThirdView.isHidden = true
             }
            
            
             if products.operationRange != nil{
                 viewForthview.isHidden = false
                 lblForth.text = products.operationRange!
                 
             }else{
                 viewForthview.isHidden = true
             }
            
            
             if products.powerSupply != nil{
                 viewFipthview.isHidden = false
                 lblFipth.text = products.powerSupply!
                 
             }else{
                 viewFipthview.isHidden = true
             }
            
            if products.sensorDetectionRange != nil{
                viewsixthview.isHidden = false
                lblSixth.text = products.sensorDetectionRange!
                
            }else{
                viewsixthview.isHidden = true
            }
            }
    }

    
}
