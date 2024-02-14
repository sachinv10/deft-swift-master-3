//
//  CamerasViewController.swift
//  Wifinity
//
//  Created by Apple on 04/11/22.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import Foundation
import CoreLocation
class camtableCell: UITableViewCell{
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imageview: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func load(obj: Dictionary<String,Any>){
        lblName.text = obj["Name"] as! String
        imageview.image = UIImage(named: obj["ImageString"] as! String)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
class CamerasViewController: BaseController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(90.0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! camtableCell
        let data = dataArray[indexPath.row]
        cell.load(obj: data)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = dataArray[indexPath.row]
        if let url = URL(string: obj["Url"] as! String) {
            UIApplication.shared.open(url)
        }
//        let demo = demoModel()
//        demo.y = indexPath.row
//        viewModel.updateData(newData: demo)
    }
    
    @IBOutlet weak var camtableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cameras"
        subTitle = ""
        camtableview.delegate = self
        camtableview.dataSource = self
        datamanage()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // self.demokeyMap()
       // self.demo()
     //  self.demojump()
        let email = "exampgmail.com"
        if isValidEmail(email) {
            print("Valid email address")
        } else {
            print("Invalid email address")
        }
       // 55.755786, 37.617633 (rus)
//        let region = CLCircularRegion(
//            center: CLLocationCoordinate2D(latitude: 55.755786, longitude: 37.617633),
//            radius: 100.0,
//            identifier: "russia"
//        )
//        region.notifyOnExit = true
//        region.notifyOnEntry = true
//       // 18.562232,73.912947
//       AppDelegate.locationManager.startMonitoring(for: region)
    //    AppDelegate.locationManager.stopMonitoring(for: region)
      //  openNewApp()
    }
    func demojump(){
        var num = 99
        print(num)
        for i in 0..<num{
            if i < 10{
                print(i,"\n")
                continue
            }
            let x = i % 10
            let y = i / 10
            if x - y == 1 || y - x == 1{
                print(i,"\n")
            }
        }
    }
    var dataArray: Array = Array<Dictionary<String,Any>>()
    func datamanage()  {
        var dictinary: Dictionary = Dictionary<String, Any>()
        dictinary = ["Name": "Sricam","ImageString": "sricam_pic","Url": "https://apps.apple.com/us/app/sricam/id1040907995"]
        dataArray.append(dictinary)
        dictinary = ["Name": "Panabell","ImageString": "panabell_pic","Url": "https://apps.apple.com/in/app/pana-bell/id1477796691"]
        dataArray.append(dictinary)
        dictinary = ["Name": "gCMOB","ImageString": "gCMOB_pic","Url": "https://apps.apple.com/in/app/icmob/id551876751"]
        dataArray.append(dictinary)
        dictinary = ["Name": "Yele CCTV","ImageString": "Yele CCTV_pic","Url": "https://apps.apple.com/gb/app/yale-cctv/id919088510"]
        dataArray.append(dictinary)
        dictinary = ["Name": "Trueview 360","ImageString": "Trueview 360_pic","Url": "https://apps.apple.com/in/app/trueview360/id1477314275"]
        dataArray.append(dictinary)
        dictinary = ["Name": "Hikvision views","ImageString": "Hikvision views_pic","Url": "https://apps.apple.com/us/app/hikvision-views/id1136095609"]
        dataArray.append(dictinary)
        dictinary = ["Name": "Xiaomi Home","ImageString": "Xiaomi Home_pic","Url": "https://apps.apple.com/in/app/xiaomi-home-xiaomi-smarthome/id957323480"]
        dataArray.append(dictinary)
        print(dataArray)
        camtableview.reloadData()
    }
    var viewModel = MyViewModel()
    deinit {
       //   viewModel.removeObserver(self, forKeyPath: #keyPath(MyViewModel.data))
      }
}
// MARK : - DEMO
extension CamerasViewController{
    func demokeyMap() {
        var xSensor = Sensor()
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("devices").queryOrdered(byChild: "uid").queryEqual(toValue: uid).observe(.value, with: {(DataSnapshot) in
            print(DataSnapshot.value as Any)
            let json = DataSnapshot.value as? Dictionary<String, Any>
            if let aDict = DataSnapshot.value as? Dictionary<String, Any> {
                do{
                    for item in aDict.values{
                        let jsonData = try JSONSerialization.data(withJSONObject: item, options: [])
                        if let jsonString = String(data: jsonData, encoding: .utf8) {
                            //   print(jsonString)
                            let data = jsonString.data(using: .utf8)
                            let decoder = JSONDecoder()
                            let response = try decoder.decode(ResponseDevice.self, from: jsonData)
                            print(response.name,"\n id=", response.id)
                        }
                    }
                }catch{
                    
                }
            }
            
            //            do{
            //                let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            //                if let jsonString = String(data: jsonData, encoding: .utf8) {
            //                    print(jsonString)
            //                    let data = jsonString.data(using: .utf8)
            //                    let response = try decoder.decode(ResponseDemo.self, from: data!)
            //             print(response.sensorSensitivity)
            //                }
            //
            //            }catch{
            //
            //            }
        })
    }
   
    func demo(){
        viewModel.addObserver(self, forKeyPath: #keyPath(MyViewModel.data), options: [.new], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(MyViewModel.data), let newData = change?[.newKey] as? String {
            print("updated data:",newData)
           }
        if let newData = change?[.newKey] as? demoModel {
            print("updated data:",newData)
            self.xydemo()
           }
       }

     func xydemo(){
         self.camtableview.reloadData()
    }
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    func openNewApp()
    {   // https://apps.apple.com/in/app/smart-life-smart-living/id1115101477
        let appURL = URL(string: "https://apps.apple.com/in/app/smart-life-smart-living/id1115101477") // Replace "xyapp" with the actual custom URL scheme of the app you want to open
        if let appURL = appURL, UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL, options: [:], completionHandler: { success in
                if success {
                    print("Successfully opened the installed app.")
                } else {
                    print("Failed to open the installed app.")
                }
            })
        } else{
            if UIApplication.shared.canOpenURL(appURL!) {
                UIApplication.shared.open(appURL!, options: [:], completionHandler: nil)
            } else {
                print("The XY app is not installed.")
            }
        }
    }
    }
struct ResponseDemo: Codable {
    let wakeUpTimeMedium: String
    let sensorSensitivity: String
    let batterySaverMode: String
    let wakeUpTimeLow: String
    let sensorState: String
}
struct Response: Codable {
    let name: String
    let age: Int
}
struct ResponseDevice: Codable {
    let controllerType: String
    let id: String
    let name: String
    let roomName: String
    let uid: String
}

class demoModel: NSObject {
    var x : String?
    var y: Int?
}
class MyViewModel: NSObject {
    @objc dynamic var data: demoModel?
    
    func updateData(newData: demoModel) {
        data = newData
    }
}
