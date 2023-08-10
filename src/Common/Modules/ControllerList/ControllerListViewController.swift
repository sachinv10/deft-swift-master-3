//
//  ControllerListViewController.swift
//  Wifinity
//
//  Created by Apple on 27/06/22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ControllerListViewController: BaseController {
    var appliances :Array<Appliance> = Array<Appliance>()
    var rooms :Array<Room> = Array<Room>()
    var filteredRooms :Array<Room> = Array<Room>()
    static var contollerDeviceId = [String]()
    var controllerApplince :Array<ControllerAppliance> = Array<ControllerAppliance>()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backbtnlable.setTitle("", for: .normal)
        btnrightmenu.setTitle("", for: .normal)
        controllertableview.delegate = self
        controllertableview.dataSource = self
        self.view.backgroundColor = UIColor(named: "SecondaryLightestColor")
        getdata()
        customView.isHidden = true
    }
    
    var customView = UIView()
    let myFirstButton = UIButton()
    let DeleteButton = UIButton()
    @IBOutlet weak var btnrightmenu: UIButton!
    @IBAction func btnmenu(_ sender: Any) {
        customView.isHidden = false
        customView.frame = CGRect.init(x: 200, y: 50, width: 200, height: 50)
        customView.backgroundColor = UIColor.white     //give color to the view
        customView.layer.borderColor = UIColor.gray.cgColor
        customView.layer.cornerRadius = 10
        customView.layer.borderWidth = 1
        //  customView.rightAnchor = self.view.center
        myFirstButton.setTitle("Reset Controller", for: .normal)
        myFirstButton.setTitleColor(UIColor.black, for: .normal)
        myFirstButton.frame = CGRect(x: 10, y: 0, width: 180, height: 50)
        myFirstButton.addTarget(self, action: #selector(pressedmenu), for: .touchUpInside)
        customView.addSubview(myFirstButton)

        self.view.addSubview(customView)
    }
    func getdata()  {
        self.appliances.removeAll()
        self.rooms.removeAll()
        self.filteredRooms.removeAll()
        DispatchQueue.main.async {
        
     //   ProgressOverlay.shared.show()
        DataFetchManager.shared.deviceDetails(completion: { (pError, pApplianceArray) in
          //   ProgressOverlay.shared.hide()
            do
            {
            if pApplianceArray != nil {
                self.controllerApplince = try pApplianceArray!
             }
            }catch let error{
                print(error.localizedDescription)
                
            }
          //  self.reloadAllView()
             self.getTimestamp()
            })
        }
    }
    func getTimestamp() {
      //  DeviceSettingViewController.timestamp.removeAll()
        for items in controllerApplince{
            Database.database().reference().child("keepAliveTimeStamp").child(items.id ?? "")
                .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                    if let aDict = pDataSnapshot.value as? Dictionary<String,Any> {
                        DeviceSettingViewController.timestamp.append(aDict)
                }
            }
        }
    }
    override func reloadAllData() {
        
        self.appliances.removeAll()
        self.rooms.removeAll()
        self.filteredRooms.removeAll()
         DispatchQueue.main.async {
      //  ProgressOverlay.shared.show()
        DataFetchManager.shared.deviceDetails(completion: { (pError, pApplianceArray) in
         //   ProgressOverlay.shared.hide()
            do
            {
            if pApplianceArray != nil {
                print("reEnter controller....")
                  self.controllerApplince = try pApplianceArray!
             //   print("divice list:\(SearchApplianceController.applinceId)")
            }

            }catch let error{
                print(error.localizedDescription)
                ProgressOverlay.shared.hide()
            }
            self.reloadAllView()

            })
        }
    }
    func reloadAllView(){
        DispatchQueue.main.async {
            // Update UI
            self.view.endEditing(true)
            self.controllertableview.reloadData()
            print("data get success")
        }
    }
     @objc func pressedmenu(sender: UIButton!) {
         customView.isHidden = true
         RoutingManager.shared.gotoResetAllControllerSetting(controller: self, controller: controllerApplince)
     }
    @IBOutlet weak var controllertableview: UITableView!
    @IBOutlet weak var backbtnlable: UIButton!
    @IBAction func btnbacktoDashboard(_ sender: Any) {
        RoutingManager.shared.goToPreviousScreen(self)
       // RoutingManager.shared.goBackToDashboard()
    }
    

}
extension ControllerListViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let applinceobj = controllerApplince.count
        print(applinceobj)
        return applinceobj
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ControllrTableViewCell
        let applinceobj = controllerApplince[indexPath.row]
        cell.load(cellobj: applinceobj)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if customView.isHidden == false{
            customView.isHidden = true
        }else{
        let times = DeviceSettingViewController.timestamp[indexPath.row]
        let contollerapp = controllerApplince[indexPath.row]
        contollerapp.lastOperated = times["time"] as? Double
        RoutingManager.shared.gotoDeviceDetails(controller: self, selectedController: contollerapp)
     }
    }
}
