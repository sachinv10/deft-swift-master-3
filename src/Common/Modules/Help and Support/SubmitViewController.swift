//
//  SubmitViewController.swift
//  Wifinity
//
//  Created by Apple on 05/11/22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

class SubmitViewController: BaseController {
    var controllerApplince :Array<ControllerAppliance> = Array<ControllerAppliance>()
    
    
    @IBOutlet weak var viewControllerList: UIView!
    @IBOutlet weak var viewControllerselection: UIView!
    
    @IBOutlet weak var showControllerTableview: UITableView!
    @IBOutlet weak var controllertableview: UITableView!
    var appType = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        subTitle = ""
        uisetup()
        getdata()
        view.backgroundColor = UIColor(named: "PrimaryLightestColor")
    }
    
    @IBAction func btnAddAction(_ sender: Any) {
        reloadAllView()
    }
    func reloadAllView()  {
        viewControllerList.isHidden = false
        showControllerTableview.reloadData()
        controllertableview.reloadData()
    }
    func uisetup()  {
        textviewQuery.layer.borderWidth = 1
        textviewQuery.layer.borderColor = UIColor.gray.cgColor
        textviewQuery.layer.masksToBounds = true
        textviewQuery.layer.cornerRadius = 10
        
        textviewNumber.layer.borderWidth = 1
        textviewNumber.layer.borderColor = UIColor.gray.cgColor
        textviewNumber.layer.masksToBounds = true
        textviewNumber.layer.cornerRadius = 10
        
        database = Database.database().reference()
        controllertableview.delegate = self
        controllertableview.dataSource = self
        if appType == "Issue with hardware"{
            viewControllerselection.isHidden = false
        }else{
            viewControllerselection.isHidden = true
        }
         viewControllerList.isHidden = true
        showControllerTableview.delegate = self
        showControllerTableview.dataSource = self
        
    }
 
    @IBOutlet weak var textviewQuery: UITextView!
    @IBOutlet weak var textviewNumber: UITextView!
    var database: DatabaseReference?
  
   
    @IBAction func btnSubmitt(_ sender: Any) {
        let timestamp = NSDate().timeIntervalSince1970
        let myTimeInterval = TimeInterval(timestamp)
 
        let x = Int(myTimeInterval * 1000)
        print("time=\(x)")
        let y = String(describing: x)
              var dictionary :Dictionary<String,Any?> = Dictionary<String,Any?>()
      //   var dictionary: Dictionary = Dictionary<AnyHashable, Any>()
        dictionary.updateValue(textviewQuery.text, forKey: "description")
        dictionary.updateValue(textviewNumber.text, forKey: "mobileNumber")
        dictionary.updateValue(Auth.auth().currentUser?.uid, forKey: "uid")
        dictionary.updateValue(y, forKey: "issueRaisedTime")
        dictionary.updateValue("", forKey: "issueResolvedTime")
        dictionary.updateValue("inProgress", forKey: "issueStatus")
        if "Hardware" == apptypedata(){
            dictionary.updateValue(apptypedata(), forKey: "issueType")
           dictionary.updateValue(diviceArray, forKey: "devices")
     //       add devices data in dictionary
        }else{
            dictionary.updateValue(apptypedata(), forKey: "issueType")
        }
        dictionary.updateValue(y, forKey: "ticketId")
        
        dictionary.updateValue(Auth.auth().currentUser?.email, forKey: "emailId")
        if let uid = Auth.auth().currentUser?.uid{
            dictionary.updateValue((uid + "_inProgress"), forKey: "filter")
        }
        
        database = database?.child("demoComplaints").child(y)
        if let uid = Auth.auth().currentUser?.uid{
            database!.setValue(dictionary, withCompletionBlock: {DataSnapshot,arg  in
                print("data=\(arg)")
            })
        }
    }
    var diviceArray: Array<Dictionary<String, Any>> = Array<Dictionary<String, Any>>()

    func newdataset(obj: ControllerAppliance) -> Dictionary<String, Any> {
        var dictionary: Dictionary = Dictionary<String, Any>()
        dictionary.updateValue(obj.id, forKey: "controlerId")
        dictionary.updateValue(obj.name, forKey: "name")
        dictionary.updateValue(obj.roomName, forKey: "roomName")
//        var dictionary :Dictionary<String,Any?> = Dictionary<String,Any?>()
//        dictionary = ["description":"yes"]
//        Database.database().reference().child("appVersion").setValue(dictionary, withCompletionBlock: { (pError, pDatabaseReference) in
//            if pError != nil{
//                print("error=\(pError)")
//            }else{
//                print("data update ")
//            }
//            })
         
        
       return dictionary
    }
  
    func apptypedata() -> String {
        var data = String()
      
        if appType == "Issue with installation"{
            data = "Installation"
        }else if appType == "Issue with hardware"{
            data = "Hardware"
        }else if appType == "Issue with application"{
            data = "Application"
        }else if appType == "Other"{
            data = "other"
        }
        return data
    }
    
}
extension SubmitViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var counts: Int = Int()
        if tableView == showControllerTableview{
            counts = controllerApplince.count
        }else{
            counts = diviceArray.count
        }
        return counts
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      //  var cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if tableView == showControllerTableview{
            let obj = controllerApplince[indexPath.row]
          
         let cell = tableView.dequeueReusableCell(withIdentifier: "cells", for: indexPath)
            cell.textLabel?.text = obj.name
            return cell
        }else{
            
           let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            let x = diviceArray[indexPath.row]
             cell.textLabel?.text = x["name"] as! String
            return cell
        }

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == showControllerTableview{
            viewControllerList.isHidden = true
            let obj = controllerApplince[indexPath.row]
            let x = newdataset(obj: obj)
            diviceArray.append(x)
            controllertableview.reloadData()
        }
    }
    
}
extension SubmitViewController{
    func getdata()  {
        
//        self.appliances.removeAll()
//        self.rooms.removeAll()
//        self.filteredRooms.removeAll()
        DispatchQueue.main.async {
        
     //   ProgressOverlay.shared.show()
        DataFetchManager.shared.deviceDetails(completion: { (pError, pApplianceArray) in
          //   ProgressOverlay.shared.hide()
            do
            {
            if pApplianceArray != nil {
                
                self.controllerApplince = try pApplianceArray!
                print(pApplianceArray)
             }
            }catch let error{
                print(error.localizedDescription)
            }
            // self.reloadAllView()
           
           
            })
        }
    }
}
