//
//  SupportViewController.swift
//  Wifinity
//
//  Created by Apple on 05/11/22.
//

import UIKit
class tableviewCell: UITableViewCell{
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor(named: "PrimaryLightestColor")
    }

    @IBOutlet weak var lblname: UILabel!
    func load(obj: String){
        lblname.text = obj
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
class SupportViewController: BaseController, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arraydata.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! tableviewCell
        cell.backgroundColor = UIColor(named: "PrimaryLightestColor")
        let name = arraydata[indexPath.row]
        cell.load(obj: name)
       // cell.textLabel?.text = arraydata[indexPath.row]
     //   cell.imageView?.image = UIImage(named: "ChevronRight")
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(60)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = arraydata[indexPath.row]
        gotofinalvc(name: name)
    }
    func gotofinalvc(name: String){
        RoutingManager.shared.gotoSubmitSupport(controller: self)
        
    }
    @IBOutlet weak var apptableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Support"
        subTitle = ""
        apptableview.dataSource = self
        apptableview.delegate = self
        arrangeArraydata()
    }
    var arraydata: Array = Array<String>()
    func arrangeArraydata() {
        arraydata = ["Issue with installation","Issue with hardware","Issue with application","Other"]
        apptableview.reloadData()
    }

    

}
