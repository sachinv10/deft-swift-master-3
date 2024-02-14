//
//  YourOrderListViewController.swift
//  Wifinity
//
//  Created by Apple on 17/06/23.
//

import UIKit
import Foundation

class YourOrderListViewController: BaseController, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderListCell", for: indexPath) as! OrderListCell
        cell.loadData(obj: orderList![indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let orderdetail = orderList![indexPath.row]
        RoutingManager.shared.gotoProductOrderDetail(controller: self,orderDetail: orderdetail)
    }
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
    var menuItemsForAccepted: [UIAction] {
        return [
            UIAction(title: "Cart", image: nil, handler: { (_) in
                self.didSelectGoodbye()
            })
        ]
    }
    var orderList: [OrderList]? = [OrderList]()
    @IBOutlet weak var lblMenubtn: UIButton!
    @IBOutlet weak var tableviewOrderlist: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Buy Product"
        subTitle = "Your Order list"
        let nib = UINib(nibName: "OrderListCell", bundle: nil)
        tableviewOrderlist.register(nib, forCellReuseIdentifier: "OrderListCell")
        if #available(iOS 14.0, *) {
            lblMenubtn.menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItemsForAccepted)
            lblMenubtn.showsMenuAsPrimaryAction = true
        }
        lblMenubtn.isHidden = true
     }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableviewOrderlist.dataSource = self
        tableviewOrderlist.delegate = self
        tableviewOrderlist.rowHeight = UITableView.automaticDimension
        tableviewOrderlist.estimatedRowHeight = 200

        UIsetUp()
        DataFetchManager.shared.orderList(complition: { ordetList in
           if ordetList != nil{
               self.orderList?.append(contentsOf: ordetList!)
            }
            self.tableviewOrderlist.reloadData()
        })
    }
    
    func didSelectGoodbye()  {
        print("go to order list")
     //   RoutingManager.shared.gotoProductCartList(controller: self, product: <#T##Ecommerce#>)
    }
    
    func UIsetUp(){
        lblMenubtn.setTitle( "", for: .normal)
    }
    
    override func reloadAllData() {
        
    }
}
