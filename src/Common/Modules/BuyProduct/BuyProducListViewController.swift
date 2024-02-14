//
//  BuyProducListViewController.swift
//  Wifinity
//
//  Created by Sachin on 12/06/23.
//

import UIKit

class BuyProducListViewController: BaseController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var lblcart: UIButton!
    @IBOutlet weak var lblMenubtn: UIButton!
    
    @IBOutlet weak var productlistTableview: UITableView!
    var ProductList: Array<Ecommerce>? = Array<Ecommerce>()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Buy product"
        subTitle = ""
     }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        productlistTableview.delegate = self
        productlistTableview.dataSource = self
        let nib = UINib(nibName: "TableViewCell", bundle: nil)
        productlistTableview.register(nib, forCellReuseIdentifier: "cell")
        productlistTableview.reloadData()
        uiSetup()
    }
    func uiSetup(){
        lblcart.setTitle("", for: .normal)
        lblMenubtn.setTitle("", for: .normal)
        myView.isHidden = true
    }
    override func reloadAllData() {
        DataFetchManager.shared.selectProductList(completion: { (pError, pMoodArray) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not search moods", description: pError!.localizedDescription)
            } else {
                if pMoodArray != nil && pMoodArray!.count > 0 {
                     print(pMoodArray)
                     self.ProductList = pMoodArray
                     self.productlistTableview.reloadData()
                }
            }
        })
    }

    @IBAction func didtappedCart(_ sender: Any) {
        if ProductList?.count ?? 0 > 0 {
            RoutingManager.shared.gotoProductCartList(controller: self, product: ProductList![0])
        }
    }
    var myButton = UIButton()
    var myView = UIView()
    @IBAction func didtappedYourOrder(_ sender: Any) {
        myView.isHidden = false
        myView = UIView(frame: CGRect(x: 170, y: 120, width: 200, height: 50))

            // Create a UIButton
            myButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        myButton.backgroundColor = .gray
        myButton.layer.borderColor = UIColor.black.cgColor
        myButton.layer.borderWidth = 0.5
        myButton.layer.masksToBounds = true
        myButton.layer.cornerRadius = 5
            myButton.setTitle("Your Orders", for: .normal)
            myButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
         self.view.addSubview(myView)
         myView.addSubview(myButton)
    }
    @objc func buttonTapped() {
        myView.isHidden = true
           print("Button tapped!")
        if ProductList?.count ?? 0 > 0{
            RoutingManager.shared.gotoProductOrderList(controller: self)
        }
       }
}
extension BuyProducListViewController{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ProductList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        let object = ProductList?[indexPath.row]
        cell.load(obj: object!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if myView.isHidden == true{
            myView.isHidden = true
            RoutingManager.shared.gotoProductDetail(controller: self, product: (ProductList?[indexPath.row])!)
        }else{
            myView.isHidden = true
        }
    }
    
}
