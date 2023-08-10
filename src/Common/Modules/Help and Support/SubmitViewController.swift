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
import Foundation

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
        do{
            let timestamp = NSDate().timeIntervalSince1970
            let myTimeInterval = TimeInterval(timestamp)
            
            let x = Int(myTimeInterval * 1000)
            print("time=\(x)")
            let y = String(describing: x)
            var dictionary :Dictionary<String,Any?> = Dictionary<String,Any?>()
            //   var dictionary: Dictionary = Dictionary<AnyHashable, Any>()
            let aTitle = textviewNumber.text
            if (aTitle?.count ?? 0) < 10 || (aTitle?.count ?? 0) > 10 {
                throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Enter 10 digit Mobile number"])
            }
            
            dictionary.updateValue(textviewQuery.text, forKey: "description")
            dictionary.updateValue(textviewNumber.text, forKey: "mobileNumber")
            dictionary.updateValue(Auth.auth().currentUser?.uid, forKey: "uid")
            dictionary.updateValue(x, forKey: "issueRaisedTime")
            dictionary.updateValue(0, forKey: "issueResolvedTime")
            dictionary.updateValue("inProgress", forKey: "issueStatus")
            if "Hardware" == apptypedata(){
                if diviceArray.isEmpty{
                    throw NSError(domain: "com", code: 1 ,userInfo: [NSLocalizedDescriptionKey: "Please select controller"])
                }
                
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
            
            database = database?.child("complaints").child(y)
            if let uid = Auth.auth().currentUser?.uid{
                database!.setValue(dictionary, withCompletionBlock: {DataSnapshot,arg  in
                    if DataSnapshot == nil{
                        PopupManager.shared.displaySuccess(message: "Issue raised succesfully", description: ""){
                            RoutingManager.shared.goToPreviousScreen(self)
                        }
                    }else{
                        PopupManager.shared.displayError(message: "Error", description: DataSnapshot?.localizedDescription)
                    }
                    print("data=\(arg)")
                })
            }
        }catch let error{
            print(error.localizedDescription)
            PopupManager.shared.displayError(message: error.localizedDescription, description: nil)
            
        }
    }
    var diviceArray: Array<Dictionary<String, Any>> = Array<Dictionary<String, Any>>()
    
    func newdataset(obj: ControllerAppliance) -> Dictionary<String, Any> {
        var dictionary: Dictionary = Dictionary<String, Any>()
        dictionary.updateValue(obj.id, forKey: "controlerId")
        dictionary.updateValue(obj.name, forKey: "name")
        dictionary.updateValue(obj.roomName, forKey: "roomName")
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
            if let data = diviceArray.firstIndex(where: { (pObject) -> Bool in
                return (obj.id == pObject["controlerId"] as? String)
                && (obj.roomName == pObject["roomName"] as? String)
                && (obj.name == pObject["name"] as? String)
            }){
                //  diviceArray.remove(at: obj)
            }else{
                let x = newdataset(obj: obj)
                diviceArray.append(x)
            }
            
            controllertableview.reloadData()
        }else{
            
        }
    }
    
    func tableView(_ pTableView: UITableView, commit pEditingStyle: UITableViewCell.EditingStyle, forRowAt pIndexPath: IndexPath) {
        if controllertableview == pTableView{
            if pEditingStyle == .delete {
                if pIndexPath.row < self.diviceArray.count {
                    let acore = self.diviceArray[pIndexPath.row]
                    PopupManager.shared.displayConfirmation(message: "Do you want delete controller", description: "", completion: {
                        self.diviceArray.remove(at: pIndexPath.row)
                        self.controllertableview.reloadData()
                    })
                }
            }
        }
    }
}
extension SubmitViewController{
    func getdata()  {
        
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
