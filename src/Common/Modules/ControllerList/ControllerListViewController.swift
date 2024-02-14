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

class ControllerListViewController: BaseController{
    var appliances :Array<Appliance> = Array<Appliance>()
    var rooms :Array<Room> = Array<Room>()
    var roomsSelection :Array<Room>? = Array<Room>()
    var filteredRooms :Array<Room> = Array<Room>()
    static var contollerDeviceId = [String]()
    var controllerApplince :Array<ControllerAppliance> = Array<ControllerAppliance>()
    var controllerDevices :Array<ControllerAppliance> = Array<ControllerAppliance>()
    static var selectedRoom = "All"
    var data = ["Item 1"]
    
    var state = [true]
    override func viewDidLoad() {
        super.viewDidLoad()
        getdataRoom()
        backbtnlable.setTitle("", for: .normal)
        btnrightmenu.setTitle("", for: .normal)
        controllertableview.delegate = self
        controllertableview.dataSource = self
        self.view.backgroundColor = UIColor(named: "SecondaryLightestColor")
      //  getdata()
        customView.isHidden = true
       // self.activateListener()
        self.CollectionViewSetUp()
        gustureSweep()
    }
    func gustureSweep(){
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
               rightSwipeGesture.direction = .right
        controllertableview.addGestureRecognizer(rightSwipeGesture)
        let rightSwipeGestures = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        rightSwipeGestures.direction = .left
        controllertableview.addGestureRecognizer(rightSwipeGestures)
    }
    @objc func handleSwipe(_ gestureRecognizer: UISwipeGestureRecognizer) {
        if state.count > 0{
            let index = state.firstIndex(where: {(pObject)-> Bool in
                return pObject == true
            })
            if (index != nil){
                 if gestureRecognizer.direction == .left {
                    if (data.count - 1) > index!{
                        state.remove(at: index ?? 0)
                        print("Right swipe recognized!",(index ?? 0) + 1)
                        ControllerListViewController.selectedRoom = data[(index ?? 0) + 1]
                        state.insert(true, at: (index ?? 0) + 1)
                    }
                }
                if gestureRecognizer.direction == .right{
                    if index! > 0{
                        state.remove(at: index ?? 0)
                        print("Left swipe recognized!", (index ?? 1) - 1)
                        ControllerListViewController.selectedRoom = data[(index ?? 1) - 1]
                        state.insert(true, at: (index ?? 1) - 1)
                    }
                }
                roomCollectionView.reloadData()
                self.deviceSortRoomvise(roomName: "")
            }
        }
    }
    func CollectionViewSetUp(){
        roomCollectionView.dataSource = self
        roomCollectionView.delegate = self

      //  self.roomCollectionView.collectionViewLayout = AutoSizeFlowLayout()
        let aCollectionViewFlowLayout = UICollectionViewFlowLayout()
            aCollectionViewFlowLayout.scrollDirection = .horizontal
        self.roomCollectionView.collectionViewLayout = aCollectionViewFlowLayout
    }
    
    var customView = UIView()
    let myFirstButton = UIButton()
    let myDeletButton = UIButton()
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
        
        myDeletButton.setTitle("Delete Controller", for: .normal)
        myDeletButton.setTitleColor(UIColor.black, for: .normal)
        myDeletButton.frame = CGRect(x: 10, y: 50, width: 180, height: 50)
        myDeletButton.addTarget(self, action: #selector(pressedmenuDelete), for: .touchUpInside)
      //  customView.addSubview(myDeletButton)

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

    deinit{
        Database.database().reference().child("devices")
            .queryOrdered(byChild: "uid").queryEqual(toValue: Auth.auth().currentUser?.uid ?? "").keepSynced(false)
        ControllerListViewController.selectedRoom = "All"
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
           //       self.controllerApplince = try pApplianceArray!
                  self.controllerDevices = pApplianceArray!
             //   print("divice list:\(SearchApplianceController.applinceId)")
            }

            }catch let error{
                print(error.localizedDescription)
                ProgressOverlay.shared.hide()
            }
            self.reloadAllView()
         //   self.getTimestamp()
            self.deviceSortRoomvise(roomName: "")
            })
        }
    }
    func activateListener(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            for item in self.controllerApplince{
                Database.database().reference().child("devices").child(item.id ?? "").observe(.childChanged, with: {DataSnapshot in
                    self.reloadAllData()
                })
            }
        }
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeObserve()
    }
    func removeObserve(){
            for item in self.controllerApplince{
                Database.database().reference().child("devices").child(item.id ?? "").removeAllObservers()
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
         RoutingManager.shared.gotoResetAllControllerSetting(controller: self, controller: controllerApplince,userChoise: .Reset)
     }
    @objc func pressedmenuDelete(sender: UIButton!) {
        customView.isHidden = true
        RoutingManager.shared.gotoResetAllControllerSetting(controller: self, controller: controllerApplince,userChoise: .Delete)
    }
    
    @IBOutlet weak var roomCollectionView: UICollectionView!
    @IBOutlet weak var controllertableview: UITableView!
    @IBOutlet weak var backbtnlable: UIButton!
    @IBAction func btnbacktoDashboard(_ sender: Any) {
        RoutingManager.shared.goToPreviousScreen(self)
     }
}
// MARK: - Table view controller list
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
            let contollerapp = controllerApplince[indexPath.row]
            if DeviceSettingViewController.timestamp.count > indexPath.row{
              let times = DeviceSettingViewController.timestamp[indexPath.row]
                contollerapp.lastOperated = times["time"] as? Double
            }else{
                contollerapp.lastOperated = 1694772513821
            }
        RoutingManager.shared.gotoDeviceDetails(controller: self, selectedController: contollerapp)
     }
   }
}
//MARK: - room vise selection
extension ControllerListViewController{
    func getdataRoom(){
        data.removeAll()
        state.removeAll()
        DataFetchManager.shared.searchRoom(completion: { [self](error, rooms) in
            if error == nil{
                self.roomsSelection = rooms
                data.append("All")
                data.append(contentsOf: (rooms?.compactMap({$0.title}))!)
                for items in 0..<data.count{
                    if items != 0{
                        state.append(false)
                    }else{
                        state.append(true)
                    }
                }
                if data.count > 0{
                    roomCollectionView.reloadData()
                }
            }
        })
    }
   
    func deviceSortRoomvise(roomName: String){
        if ControllerListViewController.selectedRoom != "All"{
            let applinceobj = controllerApplince
            controllerApplince = controllerDevices.filter({pobject -> Bool in
                return ControllerListViewController.selectedRoom.lowercased() == pobject.roomName?.lowercased()
            })
        }else{
            controllerApplince = controllerDevices
        }
        self.reloadAllView()
        DispatchQueue.main.async { [self] in
        if let index = state.firstIndex(where: {(pObject)-> Bool in
            return pObject == true
        }){
            let indexPath = IndexPath(item: index, section: 0)
            self.roomCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
      }
    }
}
//MARK: - ROOM COLLECTION CELL
extension ControllerListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ pCollectionView: UICollectionView, cellForItemAt pIndexPath: IndexPath) -> UICollectionViewCell {
        let aCell = pCollectionView.dequeueReusableCell(withReuseIdentifier: "roomCollectionViewCellId", for: pIndexPath) as? roomCollectionViewCell
        aCell?.roomName.text = data[pIndexPath.row]
        let st = state[pIndexPath.row]
        aCell?.selectedState(state: st)
        return aCell!
    }
    func collectionView(_ pCollectionView: UICollectionView, didSelectItemAt pIndexPath: IndexPath) {
        let aCell = pCollectionView.dequeueReusableCell(withReuseIdentifier: "roomCollectionViewCellId", for: pIndexPath) as! roomCollectionViewCell
        aCell.roomName.textColor = UIColor.red
        var x = state.filter({(pObject)->Bool in
            return pObject == false
        })
        x.append(false)
        x[pIndexPath.row] = true
        state = x
        roomCollectionView.reloadData()
        let name = data[pIndexPath.row]
        ControllerListViewController.selectedRoom = name
        self.deviceSortRoomvise(roomName: name)
     }
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Calculate the desired size based on the content
        let s = data[indexPath.row]
        let font = UIFont.systemFont(ofSize: 16.0)
        let width = calculateStringWidth(s, font: font)
        let itemHeight: CGFloat = 50 // Set a default height
        return CGSize(width: width + 35, height: itemHeight)
    }
    func calculateStringWidth(_ inputString: String, font: UIFont) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let size = (inputString as NSString).size(withAttributes: attributes)
        return size.width
    }
}
// MARK: - Room collection cell
class roomCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var roomName: UILabel!
    
   
    @IBOutlet weak var viewCell: UIView!
    
    override class func awakeFromNib() {
        
    }
    
    func cellUiSetUp(){
        viewCell.backgroundColor = UIColor(named: "PrimaryLightestColor")
        viewCell.layer.cornerRadius = 5
        viewCell.layer.borderWidth = 0.7
        self.layer.cornerRadius = 5
    }
    func selectedState(state: Bool){
        cellUiSetUp()
        if state{
            self.backgroundColor = UIColor.purple
            self.viewCell.layer.borderColor = UIColor.purple.cgColor
        }else{
            self.backgroundColor = UIColor.clear
            self.viewCell.layer.borderColor = UIColor.gray.cgColor
        }
    }
}

