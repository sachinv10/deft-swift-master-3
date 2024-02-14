//
//  DashboardController.swift
//  DEFT
//
//  Created by Rupendra on 21/08/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import SocketIO

class DashboardController: BaseController {
    var drawerController :DrawerController!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var applianceCollectionView: AppCollectionView!
    @IBOutlet weak var applianceCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var roomCollectionView: UICollectionView!
    @IBOutlet weak var roomFilterTextField: UITextField!
    
    @IBOutlet weak var frequantlyOperatedView: UIView!
    var appliances :Array<Appliance> = Array<Appliance>()
    var rooms :Array<Room> = Array<Room>()
    var filteredRooms :Array<Room> = Array<Room>()
    var controllerflag: Bool = true
    var delegate: webrtcDelegate?
    var delegatevdpvc: webrtcDelegate?
    var userverifyy = UserVerify()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controllerflag = true
        self.view.backgroundColor = UIColor(named: "SecondaryLightestColor")
        leftmenubtn.setTitle("", for: .normal)
        if ConfigurationManager.shared.appType == ConfigurationManager.AppType.wifinity {
            self.titleLabel.text = "WIFINITY"
        } else {
            self.titleLabel.text = "DEFT"
        }
        
        self.drawerController = RoutingManager.shared.drawerControllerUsingStoryboard()
        self.addChild(self.drawerController)
        self.view.addSubview(self.drawerController.view)
        self.drawerController.didMove(toParent: self)
        self.drawerController.close()
        self.drawerController.emailAddressLabel.text = UserDefaults.standard.value(forKey: "emailAddress") as? String
        //    self.drawerController.emailAddressLabel.text = DataFetchManager.shared.loggedInUser?.emailAddress
        self.applianceCollectionView.clipsToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapViewmenu(_:)))
        applianceCollectionView.addGestureRecognizer(tapGestureRecognizer)
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(didTapViewmenu(_:)))
        roomCollectionView.addGestureRecognizer(tapGestureRecognizer1)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
           roomCollectionView.addGestureRecognizer(longPressGesture)
         //  UpdateVdpNotification()
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        print("appversion=\(appVersion!)")
        checkApplicationVersion(appversion: appVersion!)
        mobileNumberVerify()
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.minimumInteritemSpacing = 10
        applianceCollectionView.collectionViewLayout = collectionViewFlowLayout
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            guard let selectedIndexPath = roomCollectionView.indexPathForItem(at: gestureRecognizer.location(in: roomCollectionView)) else {
                return
            }
            roomCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            roomCollectionView.updateInteractiveMovementTargetPosition(gestureRecognizer.location(in: gestureRecognizer.view))
        case .ended:
            roomCollectionView.endInteractiveMovement()
        default:
            roomCollectionView.cancelInteractiveMovement()
        }
      //  roomCollectionView.reloadData()
    }

    
    @objc func didTapViewmenu(_ sender: UITapGestureRecognizer) {
        customView.isHidden = true
    }
    override func didTapView(_ pSender :UITapGestureRecognizer) {
        super.didTapView(pSender)
        let location = pSender.location(in: nil)
        if self.drawerController.view.frame.contains(location) == false {
            self.drawerController.close()
        }
    }
    
    @IBOutlet weak var leftmenubtn: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        DispatchQueue.main.async {
        //        do{
        //        let aCollectionViewFlowLayout = UICollectionViewFlowLayout()
        //        aCollectionViewFlowLayout.scrollDirection = .vertical
        //        aCollectionViewFlowLayout.itemSize = CGSize(width: self.applianceCollectionView.frame.size.width, height: self.applianceCollectionView.frame.size.width)
        //           aCollectionViewFlowLayout.minimumLineSpacing = 1
        //            aCollectionViewFlowLayout.minimumInteritemSpacing = 1
        //            self.applianceCollectionView.clipsToBounds = true
        //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        //                self.applianceCollectionView.collectionViewLayout = aCollectionViewFlowLayout
        //            }
        //
        //        self.applianceCollectionView.delaysContentTouches = false
        //
        //        self.applianceCollectionViewHeightConstraint.constant = self.applianceCollectionView.frame.size.width * 2 / 3
        //        let aRoomCollectionViewFlowLayout = UICollectionViewFlowLayout()
        //        aRoomCollectionViewFlowLayout.scrollDirection = .vertical
        //        aRoomCollectionViewFlowLayout.itemSize = CGSize(width: self.roomCollectionView.frame.size.width, height: self.roomCollectionView.frame.size.width)
        //        aRoomCollectionViewFlowLayout.minimumLineSpacing = 1
        //        aRoomCollectionViewFlowLayout.minimumInteritemSpacing = 1
        //            self.roomCollectionView.clipsToBounds = true
        //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        //                self.roomCollectionView.collectionViewLayout = aRoomCollectionViewFlowLayout
        //            }
        //        self.roomCollectionView.delaysContentTouches = false
        //        }catch let error{
        //            print(error.localizedDescription)
        //        }
        //      }
        
        if #available(iOS 14.0, *) {
            self.leftmenubtn.menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: lfltChildBtn)
            leftmenubtn.showsMenuAsPrimaryAction = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    var lfltChildBtn:[UIAction] {
        return [ UIAction(title: "Controller Setting", handler: { [self]_ in
                   pressed()
               }),
                 UIAction(title: "Good Bye", handler: { [self]_ in
                   pressedGoodbye()
             }) ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        controllerflag = true
        SelectComponentController.coreSensor = false
        loadVdp()
        applianceCollectionView.delegate = self
        self.reloadAllData()
        activatdatalistner()
        let connection = SocketConnectionPool.shared.getConnection()
    }
    func loadcollectionView() {
        
        do{
            let aCollectionViewFlowLayout = UICollectionViewFlowLayout()
            aCollectionViewFlowLayout.scrollDirection = .vertical
            aCollectionViewFlowLayout.itemSize = CGSize(width: self.applianceCollectionView.frame.size.width, height: self.applianceCollectionView.frame.size.width)
            aCollectionViewFlowLayout.minimumLineSpacing = 1
            aCollectionViewFlowLayout.minimumInteritemSpacing = 1
            self.applianceCollectionView.clipsToBounds = true
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.applianceCollectionView.collectionViewLayout = aCollectionViewFlowLayout
            }
            self.applianceCollectionView.delaysContentTouches = false
            self.applianceCollectionViewHeightConstraint.constant = self.applianceCollectionView.frame.size.width * 2 / 3
            let aRoomCollectionViewFlowLayout = UICollectionViewFlowLayout()
            aRoomCollectionViewFlowLayout.scrollDirection = .vertical
            aRoomCollectionViewFlowLayout.itemSize = CGSize(width: self.roomCollectionView.frame.size.width, height: self.roomCollectionView.frame.size.width)
            aRoomCollectionViewFlowLayout.minimumLineSpacing = 1
            aRoomCollectionViewFlowLayout.minimumInteritemSpacing = 1
            self.roomCollectionView.clipsToBounds = true
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.roomCollectionView.collectionViewLayout = aRoomCollectionViewFlowLayout
            }
            self.roomCollectionView.delaysContentTouches = false
        }catch let error{
            print(error.localizedDescription)
        }
    }
    func UpdateVdpNotification(){
        if let uid = Auth.auth().currentUser?.uid{
            let ref = Database.database().reference()
                .child("vdpDeviceToken")
                .child(uid)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
            ref.observeSingleEvent(of: DataEventType.value) { [self](pDataSnapshot, error)  in
                    let token = CacheManager.shared.fcmToken
                    var randomNumber = Int(arc4random_uniform(100)) + 1
                    let data: Optional<Any> = pDataSnapshot.value
                    let update = parsefunction(data: data)
                    
                    if update == false
                    {
                        ref.child(String(describing: randomNumber)).setValue(token)
                    }
                }
            }
        }
    }
    func parsefunction(data: Optional<Any>)-> Bool{
        var update = false
        if let dataArray = data as? [Any] {
            let token = CacheManager.shared.fcmToken
            for ix in dataArray {
                print(ix)
                if  ix as? String == token {
                    update = true
                }
            }
        }
        var key = String()
        if let x = data as? [String: Any]{
            if x != nil{
                let token = CacheManager.shared.fcmToken
                for data in x{
                    if data.value as! String == token{
                        print(token!)
                        update = true
                        key = data.key as! String
                    }
                }
            }
        }
        return update
    }
    
    
    func checkApplicationVersion(appversion: String) {
        
        if let uid = Auth.auth().currentUser?.uid{
            Database.database().reference().child("appVersion").queryOrdered(byChild: "ios")
                .observe(DataEventType.childAdded) {(pDataSnapshot) in
                    print("appversion=\(appversion)")
                    print(pDataSnapshot.value!)
                    var versioindic = (pDataSnapshot.value as? Array<String>)
                    if appversion != pDataSnapshot.value! as! String {
                        print("call to update version")
                        LocalNotificationManager.shared.scheduleLocalNotification(title: "Update available!", body: "Update the Wifinity pro aplication to enjoy new features", timeInterval: 5)
                        //  self.UpdateAleart()
                    }
                }
        }
    }
    
    func UpdateAleart() {
        
        let alertController = UIAlertController(title: "Update!!!", message: "Newer update available and can be installed from the AppStore", preferredStyle: .alert)
        // Create OK button
        let OKAction = UIAlertAction(title: "Update", style: .default) {
            (action: UIAlertAction!) in
            self.updateApptoAppstore()
        }
        alertController.addAction(OKAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            (action: UIAlertAction!) in
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func updateApptoAppstore(){
        if let url = URL(string: "https://apps.apple.com/in/app/wifinity-pro/id1576478142") {
            UIApplication.shared.open(url)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        controllerflag = false
        SelectComponentController.ApplianceType = nil
    }
    func activatdatalistner()  {
        DispatchQueue.main.asyncAfter(deadline: .now() + 7){
            print("get applianceDetails")
            for i in (0 ..< SearchApplianceController.applinceId.count) {
                print(SearchApplianceController.applinceId[i])
                Database.database().reference().child("applianceDetails").child( SearchApplianceController.applinceId[i]).observe(.childChanged) { (snapshot, key) in
                    if self.controllerflag == true {
                        self.reloadAllData()
                    }
                }
            }
        }
    }

    // https://34.68.55.33:8081
    static var socket: SocketIOClient? = nil
    let manager = SocketManager(socketURL: URL(string: "https://vdp1.homeonetechnologies.in/")!, config: [.log(false), .compress])
    var timer = Timer()
    func timestamp(){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            let date = Date()
            let dateString = dateFormatter.string(from: date)
          //  print("datetime= \(dateString)")
        }
    }
    
    override func reloadAllData() {
        
        self.appliances.removeAll()
        self.rooms.removeAll()
        self.filteredRooms.removeAll()
        self.roomFilterTextField.text = nil
        
        //   ProgressOverlay.shared.show()
        DataFetchManager.shared.dashboardDetails(completion: { (pError, pApplianceArray, pRoomArray) in
            ProgressOverlay.shared.hide()
            do
            {
                if pApplianceArray != nil {
                    self.appliances = try pApplianceArray!
                }
                if  pApplianceArray == nil {
                    self.applianceCollectionView.backgroundView = FrequentlyOperatedCollectionCellView(frame: self.applianceCollectionView.frame)
                } else {
                    self.applianceCollectionView.backgroundView = nil
                    self.applianceCollectionView.reloadData()
                }
                
                if pRoomArray != nil {
                    self.rooms = pRoomArray!
                }
                
                if  pRoomArray == nil {
                    self.roomCollectionView.backgroundView = RoomCollectionCellView(frame: self.roomCollectionView.frame)
                } else {
                    self.roomCollectionView.backgroundView = nil
                    self.roomCollectionView.reloadData()
                }
            }catch let error{
                print(error.localizedDescription)
            }
            self.reloadAllView()
        })
    }
    
    func updateAppliancePowerState(appliance pAppliance :Appliance, powerState pPowerState :Bool) {
        let anAppliance = pAppliance.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateAppliancePowerState(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update appliance.", description: pError!.localizedDescription)
            } else {
                pAppliance.isOn = pPowerState
                self.reloadAllView()
            }
        }, appliance: anAppliance, powerState: pPowerState)
    }
    func updateAppliance(appliance pAppliance :Appliance, property1 pProperty1: Int, property2 pProperty2: Int, property3 pProperty3: Int, glowPattern pGlowPattern: Appliance.GlowPatternType) {
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateAppliance(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update appliance.", description: pError!.localizedDescription)
            } else {
                pAppliance.ledStripProperty1 = pProperty1
                pAppliance.ledStripProperty2 = pProperty2
                pAppliance.ledStripProperty3 = pProperty3
                if pGlowPattern == Appliance.GlowPatternType.on {
                    pAppliance.isOn = true
                } else if pGlowPattern == Appliance.GlowPatternType.off {
                    pAppliance.isOn = false
                }
                self.reloadAllView()
            }
        }, appliance: pAppliance, property1: pProperty1, property2: pProperty2, property3: pProperty3, glowPatternValue: pGlowPattern.rawValue)
    }
    
    func reloadAllView() {
        self.view.endEditing(true)
        self.filteredRooms.removeAll()
        if let aQuery = self.roomFilterTextField.text, aQuery.count > 0 {
            for aRoom in self.rooms {
                if let aRoomTitle = aRoom.title?.lowercased(), aRoomTitle.count > 0, aRoomTitle.range(of: aQuery.lowercased()) != nil {
                    self.filteredRooms.append(aRoom)
                }
            }
        } else {
            self.filteredRooms = self.rooms
        }
        
        self.applianceCollectionView.reloadData()
        self.roomCollectionView.reloadData()
        loadcollectionView()
    }
    
    
    func logout() {
        ProgressOverlay.shared.show()
        self.clearAppNotificationSettings(completion: {
            let vdp = VDPListViewController()
            vdp.removeTokenFunc()
            DataFetchManager.shared.logout(completion: { (pError) in
                ProgressOverlay.shared.hide()
                if pError == nil {
                    DataFetchManager.shared.loggedInUser = nil
                    KeychainManager.shared.remove(valueForKey: "emailAddress")
                    KeychainManager.shared.remove(valueForKey: "password")
                     UserDefaults.standard.removeObject(forKey: "userId")
                     UserDefaults.standard.setValue("Online and offLine", forKey: "Mode")
                    do {
                        try Auth.auth().signOut()
                    } catch let signOutError as NSError {   print ("Error signing out: %@", signOutError)}
                    RoutingManager.shared.goBackToLogin()
                } else {
                    PopupManager.shared.displayError(message: "Can not logout.", description: pError?.localizedDescription)
                }
            })
        })
    }
    
    func clearAppNotificationSettings(completion pCompletion :@escaping(()->())) {
        if let aUserId = DataFetchManager.shared.loggedInUser?.firebaseUserId {
            CacheManager.shared.cacheAppNotificationSettings(completion: {
                let anAppNotificationSettings = AppNotificationSettings()
                anAppNotificationSettings.fcmToken = CacheManager.shared.fcmToken
                anAppNotificationSettings.isCriticalNotificationDeviceToken = false
                DataFetchManager.shared.saveAppNotificationSettings(completion: { (pError, pAppNotificationSettings) in
                    pCompletion()
                }, appNotificationSettings: anAppNotificationSettings)
            }, userId: aUserId)
        } else {
            pCompletion()
        }
    }
    var customView = UIView()
    let myFirstButton = UIButton()
    let goodbyButton = UIButton()
    
    @IBAction func btnRightMenuBtn(_ sender: Any) {
//        customView.isHidden = false
//        customView.frame = CGRect.init(x: 200, y: 50, width: 200, height: 100)
//        customView.backgroundColor = UIColor.white     //give color to the view
//        customView.layer.borderColor = UIColor.gray.cgColor
//        customView.layer.cornerRadius = 10
//        //  customView.rightAnchor = self.view.center
//        myFirstButton.setTitle("Controller Setting", for: .normal)
//        myFirstButton.setTitleColor(UIColor.black, for: .normal)
//        myFirstButton.frame = CGRect(x: 10, y: 0, width: 180, height: 50)
//        myFirstButton.addTarget(self, action: #selector(pressed), for: .touchUpInside)
//        customView.addSubview(myFirstButton)
//
//        goodbyButton.setTitle("Good Bye", for: .normal)
//        goodbyButton.setTitleColor(UIColor.black, for: .normal)
//        goodbyButton.frame = CGRect(x: 10, y: 50, width: 180, height: 50)
//        goodbyButton.addTarget(self, action: #selector(pressedGoodbye), for: .touchUpInside)
//        customView.addSubview(goodbyButton)
//        self.view.addSubview(customView)
    }
    
    @objc func pressed() {
        customView.isHidden = true
        self.didSelectControllerSetthingButton()
    }
    @objc func pressedGoodbye() {
        customView.isHidden = true
        self.updateControllers()
    }
    
    
    @IBAction func didSelectMenuButton(_ pSender: UIButton?) {
        self.drawerController.toggle()
    }
    
}
extension DashboardController{
    func updateControllers() {
        for room in rooms{
            if let device = room.devices{
                for item in device{
                   print("get good bey controller= \(item)")
                    DataFetchManager.shared.updateDevice(completion: { (pError) in
                        ProgressOverlay.shared.hide()
                        if pError != nil {
                            PopupManager.shared.displayError(message: "Can not update appliance.", description: pError!.localizedDescription)
                            self.reloadAllView()
                        } else {
                            self.reloadAllView()
                        }
                    }, deviceId: item)
                }
            }
        }
    }
}

extension DashboardController :DrawerControllerDelegate {
    func drawerController(_ pDrawerController: DrawerController, didSelectMenuWithUrc pUrc: String) {
        if pUrc == DrawerController.Menu.OnAppliance.urc {
            RoutingManager.shared.gotoSearchAppliance(controller: self, selectedRoom: nil)
        } else if pUrc == DrawerController.Menu.Locks.urc {
            RoutingManager.shared.gotoSearchLock(controller: self)
        } else if pUrc == DrawerController.Menu.TankRegulators.urc {
            RoutingManager.shared.gotoSearchTankRegulator(controller: self)
#if !APP_WIFINITY
            //   RoutingManager.shared.gotoSearchTankRegulator(controller: self)
#endif
        } else if pUrc == DrawerController.Menu.Schedules.urc {
            RoutingManager.shared.gotoSearchSchedule(controller: self)
        } else if pUrc == DrawerController.Menu.Notifications.urc {
            RoutingManager.shared.gotoSearchAppNotificationType(controller: self)
        } else if pUrc == DrawerController.Menu.Rules.urc {
#if !APP_WIFINITY
            RoutingManager.shared.gotoRulePortal(controller: self)
#endif
        } else if pUrc == DrawerController.Menu.Support.urc {
#if !APP_WIFINITY
            RoutingManager.shared.gotoSupportDetails(controller: self)
#endif
        } else if pUrc == DrawerController.Menu.Logout.urc {
            self.logout()
        } else if pUrc == DrawerController.Menu.Device.urc {
#if APP_WIFINITY
            RoutingManager.shared.gotoNewDevice(controller: self)
#endif
        } else if pUrc == DrawerController.Menu.SearchDevice.urc {
#if !APP_WIFINITY
            RoutingManager.shared.gotoSearchDevice(controller: self)
#endif
        } else if pUrc == DrawerController.Menu.OfferZone.urc {
            RoutingManager.shared.gotoOfferZone(controller: self)
        } else if pUrc == DrawerController.Menu.Core.urc {
            RoutingManager.shared.gotoCore(controller: self)
         }
         //   else if pUrc == DrawerController.Menu.Geofencing.urc {
//            RoutingManager.shared.gotoGeofencing(controller: self)
//        }
            else if pUrc == DrawerController.Menu.Offline.urc {
            RoutingManager.shared.gotoOffline(controller: self)
         }else if pUrc == DrawerController.Menu.Cameras.urc {
            RoutingManager.shared.gotoCameras(controller: self)
        }else if pUrc == DrawerController.Menu.HelpAndSuppor.urc {
            RoutingManager.shared.gotoHelp(controller: self)
        }else if pUrc == DrawerController.Menu.VDP.urc {
//            DataFetchManager.shared.checkInternetConnection { (pError) in
//                if pError == nil{
             RoutingManager.shared.gotoVDPCameras(controller: self)
//                }
//            }
        }else if pUrc == DrawerController.Menu.BuyProduct.urc{
            RoutingManager.shared.gotoBuyProduct(controller: self)
        }
    }
}


extension DashboardController :UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ pCollectionView: UICollectionView, numberOfItemsInSection pSection: Int) -> Int {
        var aReturnVal :Int = 0
        
        if pCollectionView.isEqual(self.applianceCollectionView) {
            aReturnVal = self.appliances.count
        } else if pCollectionView.isEqual(self.roomCollectionView) {
            aReturnVal = self.filteredRooms.count
        }
        
        return aReturnVal
    }
    
    /*
     func collectionView(_ pCollectionView: UICollectionView, viewForSupplementaryElementOfKind pKind: String, at pIndexPath: IndexPath) -> UICollectionReusableView {
     var aReturnVal :UICollectionReusableView = UICollectionReusableView()
     
     if pKind == UICollectionView.elementKindSectionHeader {
     let aSectionHeader = pCollectionView.dequeueReusableSupplementaryView(ofKind: pKind, withReuseIdentifier: "DashboardCollectionHeaderViewId", for: pIndexPath) as! DashboardCollectionHeaderView
     if pCollectionView.isEqual(self.applianceCollectionView) {
     aSectionHeader.titleLabel.text = "Frequently Operated"
     } else if pCollectionView.isEqual(self.roomCollectionView) {
     aSectionHeader.titleLabel.text = "Rooms"
     }
     aReturnVal = aSectionHeader
     }
     
     return aReturnVal
     }
     */
    
    func collectionView(_ pCollectionView: UICollectionView, cellForItemAt pIndexPath: IndexPath) -> UICollectionViewCell {
        var aReturnVal :UICollectionViewCell?
        
        if pCollectionView.isEqual(self.applianceCollectionView) {
            let aCell = pCollectionView.dequeueReusableCell(withReuseIdentifier: "FrequentlyOperatedCollectionCellViewId", for: pIndexPath) as? FrequentlyOperatedCollectionCellView
            if pIndexPath.item < self.appliances.count {
                let anAppliance = self.appliances[pIndexPath.item]
                aCell?.delegate = self
                aCell?.load(appliance: anAppliance)
            }
            aReturnVal = aCell
        } else if pCollectionView.isEqual(self.roomCollectionView) {
            var aCell = pCollectionView.dequeueReusableCell(withReuseIdentifier: "RoomCollectionCellViewId", for: pIndexPath) as? RoomCollectionCellView
            if UtilityManager.shared.screenSizeType == UtilityManager.ScreenSizeType.small {
                aCell = pCollectionView.dequeueReusableCell(withReuseIdentifier: "RoomCollectionCompactCellViewId", for: pIndexPath) as? RoomCollectionCellView
            }
            aCell?.delegate = self
            if pIndexPath.item < self.filteredRooms.count {
                let aRoom = self.filteredRooms[pIndexPath.item]
                aCell?.load(room: aRoom)
            }
            aReturnVal = aCell
        }
        
        return aReturnVal!
    }
    
    /*
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
     let aReturnVal :CGSize = CGSize(width: self.applianceCollectionView.frame.size.width, height: 50.0)
     return aReturnVal
     }
     */
    
    func collectionView(_ pCollectionView: UICollectionView, layout pCollectionViewLayout: UICollectionViewLayout, sizeForItemAt pIndexPath: IndexPath) -> CGSize {
        var aReturnVal :CGSize = CGSize(width: 100.0, height: 100.0)
        
        if pCollectionView.isEqual(self.applianceCollectionView) {
            aReturnVal = CGSize(width: (self.applianceCollectionView.frame.size.width / 3) - self.applianceCollectionView.frame.size.width * 0.02, height: (self.applianceCollectionView.frame.size.height / 2) - self.applianceCollectionView.frame.size.height * 0.03)
        } else if pCollectionView.isEqual(self.roomCollectionView) {
            if UtilityManager.shared.screenSizeType == UtilityManager.ScreenSizeType.small {
                aReturnVal = CGSize(width: self.roomCollectionView.frame.size.width, height: 210.0)
            } else {
                aReturnVal = CGSize(width: self.roomCollectionView.frame.size.width, height: 160.0)
            }
        }
        return aReturnVal
    }
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    //           // set the minimum spacing between cells in the same row here
    //           return 10
    //       }
    
    
    func collectionView(_ pcollectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       if pcollectionView == applianceCollectionView{
            let anAppliance = self.appliances[indexPath.item]
                print("item selected",anAppliance.title)
         //   self.updateAppliancePowerState(appliance: anAppliance, powerState: !anAppliance.isOn)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        // set the minimum spacing between rows of cells here
        return 7
    }
    func collectionView(_ pcollectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        var boolval: Bool = false
        if pcollectionView == self.roomCollectionView{
            boolval = true
        }
            return boolval
    }
    func collectionView(_ pcollectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if pcollectionView.isEqual(self.roomCollectionView) {
            let movedItem = filteredRooms.remove(at: sourceIndexPath.item)
            filteredRooms.insert(movedItem, at: destinationIndexPath.item)
            let rooms = self.filteredRooms
            DataFetchManager.shared.updateRoomSequence(room: rooms, complition: {error in
                if error != nil{
                    PopupManager.shared.displayError(message: "room sequence error", description: error?.localizedDescription)
                }
            })
        }
    }
}


extension DashboardController :FrequentlyOperatedCollectionCellViewDelegate {
    
    func cellView(_ pSender: FrequentlyOperatedCollectionCellView, didChangePowerState pPowerState: Bool) {
        if let anIndexPath = self.applianceCollectionView.indexPathForItem(at: pSender.convert(CGPoint.zero, to: self.applianceCollectionView)), anIndexPath.item < self.appliances.count {
            let anAppliance = self.appliances[anIndexPath.item]
            if anAppliance.type == Appliance.ApplianceType.ledStrip{
                    let aGlowPattern = anAppliance.isOn ? Appliance.GlowPatternType.off: Appliance.GlowPatternType.on
                    self.updateAppliance(appliance: anAppliance, property1: anAppliance.ledStripProperty1!, property2: anAppliance.ledStripProperty2!, property3: anAppliance.ledStripProperty3!, glowPattern: aGlowPattern)
                }else{
                    self.updateAppliancePowerState(appliance: anAppliance, powerState: pPowerState)
                }
        }
    }
    
}

extension DashboardController :RoomCollectionCellViewDelegate {
    func didSelectApplianceButton(_ pSender: RoomCollectionCellView) {
        if let anIndexPath = self.roomCollectionView.indexPathForItem(at: pSender.convert(CGPoint.zero, to: self.roomCollectionView)), anIndexPath.item < self.filteredRooms.count {
            let aSelectedRoom = self.filteredRooms[anIndexPath.item]
            RoutingManager.shared.gotoSearchAppliance(controller: self, selectedRoom: aSelectedRoom)
        }
    }
    
    func didSelectCurtainButton(_ pSender: RoomCollectionCellView) {
        if let anIndexPath = self.roomCollectionView.indexPathForItem(at: pSender.convert(CGPoint.zero, to: self.roomCollectionView)), anIndexPath.item < self.filteredRooms.count {
            let aSelectedRoom = self.filteredRooms[anIndexPath.item]
            RoutingManager.shared.gotoSearchCurtain(controller: self, selectedRoom: aSelectedRoom)
        }
    }
    
    func didSelectControllerSetthingButton() {
        //  let aSelectedRoom = self.filteredRooms[1]
        //  RoutingManager.shared.gotoSearchControllerSetting(controller: self, selectedRoom: aSelectedRoom)
        RoutingManager.shared.gotoSearchControllerSetting(controller: self)
    }
    
    func didSelectRemoteButton(_ pSender: RoomCollectionCellView) {
        if let anIndexPath = self.roomCollectionView.indexPathForItem(at: pSender.convert(CGPoint.zero, to: self.roomCollectionView)), anIndexPath.item < self.filteredRooms.count {
            let aSelectedRoom = self.filteredRooms[anIndexPath.item]
            RoutingManager.shared.gotoSearchRemote(controller: self, selectedRoom: aSelectedRoom)
        }
    }
    
    func didSelectMoodButton(_ pSender: RoomCollectionCellView) {
        if let anIndexPath = self.roomCollectionView.indexPathForItem(at: pSender.convert(CGPoint.zero, to: self.roomCollectionView)), anIndexPath.item < self.filteredRooms.count {
            let aSelectedRoom = self.filteredRooms[anIndexPath.item]
            RoutingManager.shared.gotoSearchMood(controller: self, selectedRoom: aSelectedRoom)
        }
    }
    
    func didSelectSensorButton(_ pSender: RoomCollectionCellView) {
        if let anIndexPath = self.roomCollectionView.indexPathForItem(at: pSender.convert(CGPoint.zero, to: self.roomCollectionView)), anIndexPath.item < self.filteredRooms.count {
            let aSelectedRoom = self.filteredRooms[anIndexPath.item]
            RoutingManager.shared.gotoSearchSensor(controller: self, selectedRoom: aSelectedRoom)
        }
    }
    
    func didSelectEnergyButton(_ pSender: RoomCollectionCellView) {
        if let anIndexPath = self.roomCollectionView.indexPathForItem(at: pSender.convert(CGPoint.zero, to: self.roomCollectionView)), anIndexPath.item < self.filteredRooms.count {
            let aSelectedRoom = self.filteredRooms[anIndexPath.item]
            RoutingManager.shared.gotoEnergyDetails(controller: self, userId: Auth.auth().currentUser?.uid ?? "", roomId: aSelectedRoom.id ?? "")
        }
    }
}



extension DashboardController :UITextFieldDelegate {
    func textFieldShouldReturn(_ pTextField: UITextField) -> Bool {
        if pTextField.isEqual(self.roomFilterTextField) {
            self.reloadAllView()
        }
        return true
    }
    
    func textFieldShouldClear(_ pTextField: UITextField) -> Bool {
        pTextField.text = nil
        self.reloadAllView()
        return false
    }
}



extension DashboardController {
    
    func gestureRecognizerShouldBegin(_ pGestureRecognizer: UIGestureRecognizer) -> Bool {
        var aReturnVal = true
        
        if self.navigationController?.interactivePopGestureRecognizer == pGestureRecognizer {
            aReturnVal = false
            self.drawerController.open()
        }
        return aReturnVal
      }
}
extension DashboardController{
    func loadVdp(){
//        let connection = SocketConnectionPool.shared.getConnection()
//        print("socket connection = \(connection.socket?.status.description)")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5){
//            for _ in 0...5{
//                SocketConnectionPool.shared.releaseConnection(connection)
//            }
//             var dic2 = Dictionary<String, Any>()
//            var dic1 = Dictionary<String, Any>()
//            dic1 = ["whatever-you-want-here" :"stuff"]
//            dic2 = ["channel": "V001681462936392", "userdata": dic1]
//           // connection.socket?.emit("join", dic2)
//        }
        
       if DashboardController.socket != nil{
          if DashboardController.socket?.status.description != "connected"{
              timestamp()
              DashboardController.socket = manager.defaultSocket
              DashboardController.socket?.connect()
              loadvc()
           }
       }else{
           timestamp()
           DashboardController.socket = manager.defaultSocket
           DashboardController.socket?.connect()
           loadvc()
       }
    }
   func loadvc() {

            // Add event listeners
       DashboardController.socket?.on(clientEvent: .connect) {data, ack in
                print("Connected....")
                if CURRENT_VC == "VDPListViewController"{
                    self.delegate?.webrtConnect(data: data)
                }else if CURRENT_VC == "VdpViewController"{
                    self.delegatevdpvc?.webrtConnect(data: data)
                }else if CURRENT_VC == "CallingViewController"{
                    self.delegate?.webrtConnect(data: data)
                }
                self.timer.invalidate()
            }
       DashboardController.socket?.on("addPeer") { (data, ack) in
             //   data = Array<Any>
                // ack = SocketAckEmitter
           print("addpeer Dashboard")
                if CURRENT_VC == "VDPListViewController"{
                    self.delegate?.webrtcAddPeer(data: data)
                }else if CURRENT_VC == "VdpViewController"{
                    self.delegatevdpvc?.webrtcAddPeer(data: data)
                }else if CURRENT_VC == "CallingViewController"{
                    self.delegate?.webrtcAddPeer(data: data)
                }
            }
       DashboardController.socket?.on(clientEvent: .disconnect) {data, ack in
                print("DisConnected")
            //    DispatchQueue.main.async {
                    DashboardController.socket = self.manager.defaultSocket
                    DashboardController.socket?.connect()
            //    }
         //  print("socket status=\(DashboardController.socket?.status)")
            }
            
       DashboardController.socket?.on("error"){(data ,arg)  in
                print(data)
                print(arg)
                if CURRENT_VC == "VDPListViewController"{
                    self.delegate?.webrtcError()
                }else if CURRENT_VC == "VdpViewController"{
                    self.delegatevdpvc?.webrtcError()
                }else if CURRENT_VC == "CallingViewController"{
                    self.delegate?.webrtcError()
                }
            }
            // working
       DashboardController.socket?.on("sessionDescription"){(data ,arg)  in
                print("session discription")
                if CURRENT_VC == "VDPListViewController"{
                    self.delegate?.webrtcSessionDescription(data: data)
                }else if CURRENT_VC == "VdpViewController"{
                    self.delegatevdpvc?.webrtcSessionDescription(data: data)
                }else if CURRENT_VC == "CallingViewController"{
                    self.delegate?.webrtcSessionDescription(data: data)
                }
            }
            // working
       DashboardController.socket?.on("removePeer") { (data, ack) in
                guard let dataInfo = data.first else { return }
                print("remove Peer")
                print("Now this chat has \(dataInfo) users.")
                if CURRENT_VC == "VDPListViewController"{
                    self.delegate?.webrtcRemovePeer(data: data)
                }else if CURRENT_VC == "VdpViewController"{
                    self.delegatevdpvc?.webrtcRemovePeer(data: data)
                }else if CURRENT_VC == "CallingViewController"{
                    self.delegate?.webrtcRemovePeer(data: data)
                }
            }
            
       DashboardController.socket?.on("join") { (data, ack) in
                guard let dataInfo = data.first else { return }
                 print("joined from =\(dataInfo)")
             }
            // working
       DashboardController.socket?.on("iceCandidate") { (data, ack) in
                print(data)
                if CURRENT_VC == "VDPListViewController"{
                    self.delegate?.webrtciceCandidate(data: data)
                }else if CURRENT_VC == "VdpViewController"{
                    self.delegatevdpvc?.webrtciceCandidate(data: data)
                }else if CURRENT_VC == "CallingViewController"{
                    self.delegate?.webrtciceCandidate(data: data)
                }
            }
       DashboardController.socket?.on("full") { (data, ack) in
                guard let dataInfo = data.first else { return }
                 print("full \(dataInfo) stopped typing...")
             }
       DashboardController.socket?.on("joined") { (data, ack) in
                guard let dataInfo = data.first else { return }
                 print("joined \(dataInfo)typing...")
             }
            DashboardController.socket?.on("log") { (data, ack) in
                guard let dataInfo = data.first else { return }
                 print("log \(dataInfo) typing...")
             }
       DashboardController.socket?.on("bye") { (data, ack) in
                guard let dataInfo = data.first else { return }
                 print("bye \(dataInfo) stopped typing...")
             }
       DashboardController.socket?.on("message") { (data, ack) in
                guard let dataInfo = data.first else { return }
                 print("message= \(dataInfo)   typing...")
             }
    }
           
    func mobileNumberVerify(){
        DataFetchManager.shared.verifyMobilenumber(complition: { [self](erro , puser) in
            print(puser?.phoneNumber)
                userverifyy = puser!
            if  userverifyy.numberVerified == "false"{
                PopupManager.shared.displayUpdateAlert(message: "Alert...!", description: "Verify Your Mobile Number Is Not Verified Please Verify It To Continue Useing The App", completion: {
                    // call to profile
                    print("call to profile")
                    RoutingManager.shared.gotoEditProfile(controller: self, user: puser!)
                })
            }
        })
    }
    
}
