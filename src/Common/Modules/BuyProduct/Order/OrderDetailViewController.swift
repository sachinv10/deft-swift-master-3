//
//  OrderDetailViewController.swift
//  Wifinity
//
//  Created by Apple on 21/11/23.
//

import UIKit

class OrderDetailViewController: BaseController, UITableViewDataSource, UITableViewDelegate {
   
    

    @IBOutlet weak var ProductStack: UIStackView!
    var orderDetail: OrderList?  
    @IBOutlet weak var tableViewOrderDetail: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Buy Product"
        self.subTitle = "Order Detail"
   
       
        tableViewOrderDetail.register(UINib(nibName: "OrderItemTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderItemTableViewCell")
        tableViewOrderDetail.register(UINib(nibName: "OrderDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderDetailTableViewCell")
        tableViewOrderDetail.dataSource = self
        tableViewOrderDetail.delegate = self
    }
   
}
extension OrderDetailViewController{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = orderDetail?.items.count ?? -1
        count += 1
        return count
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var aCell :UITableViewCell?
        var count = orderDetail?.items.count ?? -1
            count += 1
        if indexPath.row != count - 1{
           let cell = tableView.dequeueReusableCell(withIdentifier: "OrderItemTableViewCell", for: indexPath) as! OrderItemTableViewCell
            cell.loadfnc(obj: orderDetail?.items[indexPath.row] as Any)
            aCell = cell
        }else{
           let cell = tableView.dequeueReusableCell(withIdentifier: "OrderDetailTableViewCell", for: indexPath) as! OrderDetailTableViewCell
            let total = totolAmount()
            cell.loadData(obj: orderDetail as Any, totol: total)
            aCell = cell
        }
        return aCell!
    }
    func totolAmount()-> String{
        var x = 0
        if let total = orderDetail?.items{
            for i in total{
              x += Int(i.price ?? "0")! * i.quantity
            }
        }
       return String(x)
    }
}
