//
//  OnGoingIssieViewController.swift
//  Wifinity
//
//  Created by Apple on 15/11/22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
class onGoingCell: UITableViewCell{
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor(named: "PrimaryLightestColor")
      //  viewHardare.isHidden = true
        stackview.layer.borderColor = UIColor.gray.cgColor
        stackview.layer.borderWidth = 1
        stackview.layer.cornerRadius = 7
       // stackview.sha
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        
    }
    
//  otp view
    @IBOutlet weak var lblDiscription: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblIssueType: UILabel!
    @IBOutlet weak var lblOtp: UILabel!
    // first view
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblComplentId: UILabel!
    //view
    
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var viewOtp: UIView!
    @IBOutlet weak var viewHardare: UIView!
    // last view
    @IBOutlet weak var Hardwaretype: UILabel!
    @IBOutlet weak var lblhardwareName: UILabel!
    //  @IBOutlet weak var lblname: UILabel!
    func load(obj: Complents){
        lblComplentId.text = obj.ticketId
        let time = Double(obj.issueRaisedTime ?? 0)
       let x = SharedFunction.shared.gotoTimetampTodayConvert(time: time / 1000)
          lblTime.text = x
        
      //  lblOtp.text = obj.resolveOtp
        lblIssueType.text = "Issue Type: \(obj.issueType!)"
        lblStatus.text = "Status: \(obj.issueStatus!)"
        lblDiscription.text = obj.descriptionn
        
        if obj.issueType == "Hardware"{
            viewHardare.isHidden = false
            Hardwaretype.text = obj.issueType
            lblhardwareName.text = obj.controllerName
        }else{
             viewHardare.isHidden = true

        }
           
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
class OnGoingIssieViewController: BaseController {
    
    
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.dataSource = self
        tableview.delegate = self
        getdata()
    }
    var dictionary: Dictionary<String,AnyObject> = Dictionary<String,AnyObject>()
    var dictionaryfinal = [String: AnyObject]()
    func getdata(){
        let uid = Auth.auth().currentUser!.uid + "_inProgress"
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
                //    pcomplent.resolvedBy = y["resolvedBy"]! as! String
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
extension OnGoingIssieViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return complentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellO", for: indexPath) as! onGoingCell
         let obj = complentArray[indexPath.row]
        cell.load(obj: obj)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didselect cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellO", for: indexPath) as! onGoingCell
        cell.viewHardare.isHidden = true
        self.tableview.reloadData()
    }
 
}
