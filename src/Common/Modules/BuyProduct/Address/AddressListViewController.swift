//
//  AddressListViewController.swift
//  Wifinity
//
//  Created by Apple on 22/11/23.
//

import UIKit

class AddressListViewController: BaseController{
   
    var orderList: [cartData]? = [cartData]()
    @IBOutlet weak var tableViewAddress: UITableView!
    var addressList: [address] = [address]()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Buy Product"
        subTitle = "Select Address"
        tableViewAddress.dataSource = self
        tableViewAddress.delegate = self
       
    }

    override func reloadAllData() {
        DataFetchManager.shared.selectProductAddressList(completion: {(error, data) in
            if error == nil && data != nil{
                self.addressList.append(contentsOf: data!)
                self.tableViewAddress.reloadData()
            }
        })
        
    }
    
    @IBAction func didtappedAddNewAddress(_ sender: Any) {
        RoutingManager.shared.gotoProductCreateAddress(controller: self, address: nil, orderList: orderList)
    }
}
//MARK: - table view
extension AddressListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return addressList.count
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! addressTableViewCell
        let addres = addressList[indexPath.row]
        let strin = "\(addres.flat ?? ""), \(addres.society ?? ""), \(addres.city ?? ""), \(addres.state ?? ""), \(addres.pincode ?? "")"
        cell.lblName.text = strin
        return cell
       }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        RoutingManager.shared.gotoProductCreateAddress(controller: self, address: addressList[indexPath.row], orderList: orderList)
    }
}
class addressTableViewCell: UITableViewCell{
    override func awakeFromNib() {
        super.awakeFromNib()
    }
     
    @IBOutlet weak var lblName: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
