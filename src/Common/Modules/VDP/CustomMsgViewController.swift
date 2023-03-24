//
//  CustomMsgViewController.swift
//  Wifinity
//
//  Created by Apple on 24/01/23.
//

import UIKit
import Firebase
import FirebaseAuth


class CustomMsgViewController: BaseController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myCustomMsgArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "CustommsgtblCell", for: indexPath) as! CustommsgtblCell
        let obj = myCustomMsgArray[indexPath.row]
        cell.loaddata(obj: obj)
        cell.delegate = self
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    //appHeaderBarView
    
    @IBOutlet weak var tableview: UITableView!
    var vdpmodule: VDPModul!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Custom Messages"
        subTitle = ""
        
        tableview.register(UINib(nibName: "CustommsgtblCell", bundle: nil), forCellReuseIdentifier: "CustommsgtblCell")
        tableview.delegate = self
        tableview.dataSource = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tableview.addGestureRecognizer(tapGesture)
    }
    @objc func handleTap() {
        editview.isHidden = true
    }
    var myCustomMsgArray :Array<MyModel> = Array<MyModel>()
    override func reloadAllData() {
        var ref = Database.database().reference()
        
        do {
            if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
            }
            ref.child("vdpCustomMessages").child(vdpmodule.id!)
                .observeSingleEvent(of: DataEventType.value) { (pDataSnapshot) in
                    // Fetch objects
                    
                    if let aDict = pDataSnapshot.value as? Dictionary<String,Dictionary<String,Any>> {
                        for item in aDict{
                            let dicvalue = item.value as Dictionary<String, Any>
                            let mydataobj = self.dataparse(obj: dicvalue)
                            self.myCustomMsgArray.append(mydataobj)
                        }
                        if  self.myCustomMsgArray.count > 0{
                            self.tableview.reloadData()
                        }
                    }
                }
        } catch {
            
        }
    }
    func dataparse(obj: Dictionary<String, Any>) -> MyModel{
        var myModel: MyModel?
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: obj, options: [])
            myModel = try JSONDecoder().decode(MyModel.self, from: jsonData)
            print(myModel)
        }catch{
            
        }
        return myModel!
    }
    
    
    var editview = UIView()
    var hedinglbl = UILabel()
    var txtfld = UITextField()
    var cancelbtn = UIButton()
    var savebtn = UIButton()
    var selectedmodel: MyModel!
    func EditView(obj: MyModel){
        selectedmodel = obj
        editview = UIView(frame: CGRect(x: self.view.frame.width * 0.10, y: 300, width: self.view.frame.width * 0.80, height: 180))
        editview.backgroundColor = .systemGray2
        editview.layer.cornerRadius = 10
        editview.layer.masksToBounds = true
        self.view.addSubview(editview)
        
        hedinglbl.frame =  CGRect(x: 10, y: 0, width: self.view.frame.width * 0.70, height: 50)
        hedinglbl.text = obj.msgType
        hedinglbl.tintColor = .white
        // hedinglbl.textAlignment = .center
        editview.addSubview(hedinglbl)
        
        txtfld.frame =  CGRect(x: 10, y: 40, width: 400, height: 50)
        txtfld.layer.cornerRadius = 5
        txtfld.layer.masksToBounds = true
        txtfld.placeholder = obj.msgContent
        txtfld.tintColor = .white
        editview.addSubview(txtfld)
        
        cancelbtn.frame =  CGRect(x: 50, y: 110, width: 100, height: 40)
        cancelbtn.backgroundColor = .red
        cancelbtn.layer.cornerRadius = 7
        cancelbtn.setTitle("Cancel", for: .normal)
        cancelbtn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        editview.addSubview(cancelbtn)
        
        savebtn.frame =  CGRect(x: 195, y: 110, width: 100, height: 40)
        savebtn.backgroundColor = .green
        savebtn.layer.cornerRadius = 7
        savebtn.setTitle("Save", for: .normal)
        savebtn.addTarget(self, action: #selector(buttonTappedsave), for: .touchUpInside)
        editview.addSubview(savebtn)
    }
    @objc func buttonTapped() {
        editview.isHidden = true
    }
    @objc func buttonTappedsave() {
        let ref = Database.database().reference().child("vdpCustomMessages").child(vdpmodule.id!).child(selectedmodel.msgId)
        ref.updateChildValues(["msgContent": txtfld.text as Any], withCompletionBlock: {(error, DataSnapshot) in
            if (error == nil){
                self.updatemsg()
            }
        })
        editview.isHidden = true
    }
    func updatemsg(){
        let myDictionary = ["type":"voiceMessage", selectedmodel.msgType: txtfld.text] as [String : Any]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: myDictionary, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
            let ref = Database.database().reference().child("vdpMessages").child(vdpmodule.id!).child("vdpData")
            ref.setValue(["message": jsonString as Any], withCompletionBlock: {(error, DataSnapshot) in
                if (error == nil){
                    print("update succesfully")
                }
            })
            ref.setValue(["message": "aa" as Any], withCompletionBlock: {(error, DataSnapshot) in
                if (error == nil){
                    print("Message update successfully")
                    PopupManager.shared.displaySuccess(message: "Message update successfully", description: "")
                }
            })
        }
    }
}
extension CustomMsgViewController: CustmsgProtocall{
    func cellCustommsg(cell: CustommsgtblCell) {
        print("tapped Edit button")
        EditView(obj: cell.model!)
    }
    
    
}
