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
        var cell =  tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! camtableCell
        var data = dataArray[indexPath.row]
        cell.load(obj: data)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = dataArray[indexPath.row]
        if let url = URL(string: obj["Url"] as! String) {
            UIApplication.shared.open(url)
        }
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
        self.demokeyMap()
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
