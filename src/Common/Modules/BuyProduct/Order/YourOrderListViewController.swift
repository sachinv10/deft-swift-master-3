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
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderListCell", for: indexPath) as! OrderListCell
        return cell
    }
    
 
    @IBOutlet weak var lblMenubtn: UIButton!
    @IBOutlet weak var tableviewOrderlist: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
     
        title = "Buy Product"
        subTitle = "Your Order list"
        let nib = UINib(nibName: "OrderListCell", bundle: nil)
        tableviewOrderlist.register(nib, forCellReuseIdentifier: "OrderListCell")
     }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableviewOrderlist.dataSource = self
        tableviewOrderlist.delegate = self
        tableviewOrderlist.reloadData()
        UIsetUp()
    }
    func UIsetUp(){
        lblMenubtn.setTitle( "", for: .normal)
    }
    override func reloadAllData() {
        
    }
}
