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
        RoutingManager.shared.gotoSubmitSupport(controller: self, name: name)
        
    }
    
    @IBOutlet weak var apptableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Support"
        subTitle = ""
        apptableview.dataSource = self
        apptableview.delegate = self
        lblRightMenu.setTitle("", for: .normal)
        arrangeArraydata()
    }
    
    @IBOutlet weak var lblRightMenu: UIButton!
    @IBAction func didtappedRightMenu(_ sender: Any) {
        RightbtnView()
    }
    var customView = UIView()
    let myFirstButton = UIButton()
    let goodbyButton = UIButton()

    func RightbtnView(){
        customView.isHidden = false
        customView.frame = CGRect.init(x: 200, y: 50, width: 200, height: 100)
        customView.backgroundColor = UIColor.white     //give color to the view
        customView.layer.borderColor = UIColor.gray.cgColor
        customView.layer.cornerRadius = 10
      //  customView.rightAnchor = self.view.center
        myFirstButton.setTitle("Ongoing issue", for: .normal)
        myFirstButton.setTitleColor(UIColor.black, for: .normal)
        myFirstButton.frame = CGRect(x: 10, y: 0, width: 180, height: 50)
        myFirstButton.addTarget(self, action: #selector(pressed), for: .touchUpInside)
        customView.addSubview(myFirstButton)
        
        goodbyButton.setTitle("Resolved issue", for: .normal)
        goodbyButton.setTitleColor(UIColor.black, for: .normal)
        goodbyButton.frame = CGRect(x: 10, y: 50, width: 180, height: 50)
        goodbyButton.addTarget(self, action: #selector(pressedGoodbye), for: .touchUpInside)
        customView.addSubview(goodbyButton)
            self.view.addSubview(customView)
    }
    @objc func pressed(sender: UIButton!) {
    RoutingManager.shared.gotoOnGoingVC(controller: self)
        customView.isHidden = true
    }
    @objc func pressedGoodbye(sender: UIButton!) {
        RoutingManager.shared.gotoResolveVC(controller: self)
        customView.isHidden = true
    }
    var arraydata: Array = Array<String>()
    func arrangeArraydata() {
        arraydata = ["Issue with installation","Issue with hardware","Issue with application","Other"]
        apptableview.reloadData()
    }

    

}
