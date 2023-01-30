//
//  SelectTypeViewController.swift
//  Wifinity
//
//  Created by Apple on 05/11/22.
//

import UIKit

class tableCell: UITableViewCell{
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor(named: "PrimaryLightestColor")
    }

    @IBOutlet weak var lblName: UILabel!
    func load(obj: String){
        lblName.text = obj
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
class SelectTypeViewController: BaseController, UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! tableCell
        let name = dataArray[indexPath.row]
        cell.load(obj: name)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = dataArray[indexPath.row]
        manegeToNextViewController(name: name)
    }
    func  manegeToNextViewController(name: String) {
        if name == "Support"{
            RoutingManager.shared.gotoSupport(controller: self)
        }else if name == "Product Manual"{
            RoutingManager.shared.gotoProductManual(controller: self)
        }else if name == "Contact"{
            makeACall()
        }
    }
     
    @IBOutlet weak var typetableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Help"
        subTitle = ""
        typetableview.delegate = self
        typetableview.dataSource = self
        managetableview()
    }
    var dataArray: Array = Array<String>()
    func  managetableview()
    {
         self.view.backgroundColor = UIColor(named: "PrimaryLightestColor")
        dataArray = ["Support","Product Manual","Contact"]
    }
        func makeACall() {
            guard let url = URL(string: "tel://7767984645"),
                UIApplication.shared.canOpenURL(url) else { return }
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
}
