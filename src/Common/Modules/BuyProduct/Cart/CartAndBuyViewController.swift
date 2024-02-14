//
//  CartAndBuyViewController.swift
//  Wifinity
//
//  Created by Apple on 09/11/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class CartAndBuyViewController: BaseController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var cartTableView: UITableView!
    @IBOutlet weak var lblSubTotal: UILabel!
    @IBOutlet weak var lblProductCunt: UILabel!
    var orderList: [cartData]? = [cartData]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Buy Product"
        self.subTitle = nil
        cartTableView.delegate = self
        cartTableView.dataSource = self
        let nib = UINib(nibName: "cartTableViewCell", bundle: nil)
        cartTableView.register(nib, forCellReuseIdentifier: "cartTableViewCell")
        cartTableView.reloadData()
    }
    
    override func reloadAllData() {
        let paths: String = "Cart/\(Auth.auth().currentUser?.uid ?? "")"
        DataFetchManager.shared.fetchDataCommon(complition: {(error, data)in
            print(data)
         //   cartData
            self.orderList?.removeAll()
            guard let orderList = data as? Dictionary<String,Dictionary<String,Any>> else{return}
            do{
            for item in orderList{
                print("cart id=",item)
                let items = item.value
                    let jsonData = try JSONSerialization.data(withJSONObject: items, options: [])
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(cartData.self, from: jsonData)
                    self.orderList?.append(response)
                    self.orderList?.sort{(rhs, lhs)->Bool in
                    return rhs.Name?.lowercased() ?? "" < lhs.Name?.lowercased() ?? ""
                }
              }
            }catch{
                
            }
            self.cartTableView.reloadData()
            self.dataValueation()
        }, databasePath: paths)
 
    }
  
    @IBAction func didtappedBuyNow(_ sender: Any) {
        print("buy now")
        RoutingManager.shared.gotoProductAddress(controller: self, orderList: orderList)
    }
    var Product: Ecommerce?
    var productDetails: ProductDetails?
    var productSlides: Array<productSlides>?
}
// MARK: - TABLE VIEW CART
extension CartAndBuyViewController{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cartTableViewCell", for: indexPath) as! cartTableViewCell
        cell.delegate = self
        cell.loadData(obj: (orderList?[indexPath.row])!)
        return cell
    }
}
extension CartAndBuyViewController: MyProtocol{

    func doSomething(cell: cartTableViewCell, value: Double) {
        if let indexPath = cartTableView.indexPath(for: cell){
            print("index path = ",indexPath.row)
          let order = (orderList?[indexPath.row])!
         //   let products = Ecommerce(Dprice: Int(order.price ?? ""), name: order.Name, productDetails: productDetails, productSlides: productSlides, count: Int(value))
            guard let s = Product else{return}
            var x = s
            x.count = Int(value)
            Product?.count = Int(value)
            Product?.Dprice = Int(order.price ?? "")
            Product?.name = order.Name
            Product?.productImage = order.ImgUrl
            addToCart()
        }
    }

    func addToCart(){
        DataFetchManager.shared.addToCart(complition: {(error, anproduct) in
            if error == nil,anproduct != nil{
             
            }else{
                print("error Occured")
              //  self.reloadAllData()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
              
            }
        }, Product: Product!)
    }
    func dataValueation(){
        var productCnt = 0
        var productTotal = 0
        for items in orderList!{
            productCnt += items.Quantity ?? 0
            productTotal += (Int(items.price ?? "0") ?? 0) * (items.Quantity ?? 0)
        }
        lblProductCunt.text =  "Total Product: \(String(productCnt))"
        lblSubTotal.text = "SubTotal:  \(String(productTotal))"
    }
}
