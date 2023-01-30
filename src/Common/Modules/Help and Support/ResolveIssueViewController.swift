//
//  ResolveIssueViewController.swift
//  Wifinity
//
//  Created by Apple on 14/11/22.
//

import UIKit
import Firebase
import FirebaseAuth

class resolveCell: tableviewCell{
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor(named: "PrimaryLightestColor")
      //  viewHardare.isHidden = true
    }
    
    @IBOutlet weak var lbldiscription: UILabel!
    @IBOutlet weak var lblHardwaretype: UILabel!
    @IBOutlet weak var lbltime: UILabel!
    func load(obj: Complents){
        lbldiscription.text = obj.issueType
        lbldiscription.text = obj.descriptionn
        let time = Double(obj.issueResolvedTime ?? 0)
       let x = SharedFunction.shared.gotoTimetampTodayConvert(time: time / 1000)
        lbltime.text = x
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class ResolveIssueViewController: BaseController {

   
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title  = "Resolved issue"
        subTitle = ""
        tableview.delegate = self
        tableview.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getdata()
    }
    var dictionary: Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
    var dictionaryfinal = [String: AnyObject]()
    func getdata(){
        let uid = Auth.auth().currentUser!.uid + "_resolved"
        Database.database().reference().child("complaints").queryOrdered(byChild: "filter")
            .queryEqual(toValue: uid)
            .observeSingleEvent(of: .value, with: { snapshot in
            print(snapshot.value as! Dictionary<String,AnyObject>)
                print("data=\( snapshot.value as? Array<Dictionary<String,Any>?>)")
                
                self.dictionary = snapshot.value as! Dictionary<String,AnyObject>
                let  USD = snapshot.value.map { ($0 as! [String: AnyObject]) }
                print("data=\(USD)")
               // self.dictionaryfinal = USD!
                 
                for x in self.dictionary{
                    var pcomp = Complents()
                 var pcomplent = pcomp.clone()
                    let registId = x.key
                    let y = x.value
                    print(y["uid"]!)
                    pcomplent.uid = y["uid"]! as! String
                    pcomplent.descriptionn = y["description"]! as! String
                    pcomplent.emailId = y["emailId"]! as! String
                    pcomplent.filter = y["filter"]! as! String
                    pcomplent.issueRaisedTime = y["issueRaisedTime"]! as! Int
                    pcomplent.issueResolvedTime = y["issueResolvedTime"]! as! Int
                    pcomplent.issueStatus = y["issueStatus"]! as! String
                    pcomplent.issueType = y["issueType"]! as! String
                    pcomplent.mobileNumber = y["mobileNumber"]! as! String
//                    if y["resolveOtp"] != nil{
//                        pcomplent.resolveOtp = y["resolveOtp"]! as! Int
//                    }
                   pcomplent.resolvedBy = y["resolvedBy"]! as! String
                    pcomplent.ticketId = y["ticketId"]! as! String
                    pcomplent.uid = y["uid"]! as! String
                    if y["issueType"]! as! String == "Hardware"{
                        let devices = y["devices"] as! [Dictionary<String,AnyObject>]
                        for item in devices{
                            pcomplent.controllerName = "\(item["name"]!) of \(item["roomName"]!)"
                        }
                    }
                     self.complentArray.append(pcomplent)
                  }
                self.tableview.reloadData()
            })
    }
    var complentArray = [Complents]()
    
}
extension ResolveIssueViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return complentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellR", for: indexPath) as! resolveCell
        let obj = complentArray[indexPath.row]
        cell.load(obj: obj)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = complentArray[indexPath.row]
        RoutingManager.shared.gotoResolveDetialVC(controller: self, pcomplent: obj)
    }
    
}
