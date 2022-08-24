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

class DashboardController: BaseController {
    var drawerController :DrawerController!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var applianceCollectionView: UICollectionView!
    @IBOutlet weak var applianceCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var roomCollectionView: UICollectionView!
    @IBOutlet weak var roomFilterTextField: UITextField!
    var appliances :Array<Appliance> = Array<Appliance>()
    var rooms :Array<Room> = Array<Room>()
    var filteredRooms :Array<Room> = Array<Room>()
    var controllerflag: Bool = true
    
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
        self.drawerController.emailAddressLabel.text = DataFetchManager.shared.loggedInUser?.emailAddress
        self.applianceCollectionView.clipsToBounds = true
      
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapViewmenu(_:)))
             applianceCollectionView.addGestureRecognizer(tapGestureRecognizer)
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(didTapViewmenu(_:)))
             roomCollectionView.addGestureRecognizer(tapGestureRecognizer1)
      
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        controllerflag = true
        self.reloadAllData()
        activatdatalistner()
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        print("appversion=\(appVersion!)")
        checkApplicationVersion(appversion: appVersion!)
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
    func checkApplicationVersion(appversion: String) {
        if let uid = Auth.auth().currentUser?.uid{
            Database.database().reference().child("appVersion").queryOrdered(byChild: "ios")
            .observe(DataEventType.childAdded) {(pDataSnapshot) in
                print("appversion=\(appversion)")
                print(pDataSnapshot.value!)
                var versioindic = (pDataSnapshot.value as? Array<String>)
                if appversion != pDataSnapshot.value! as! String {
                    print("call to update version")
                    self.UpdateAleart()
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
            if pRoomArray != nil {
                self.rooms = pRoomArray!
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
            DataFetchManager.shared.logout(completion: { (pError) in
                ProgressOverlay.shared.hide()
                if pError == nil {
                    DataFetchManager.shared.loggedInUser = nil
                    KeychainManager.shared.remove(valueForKey: "emailAddress")
                    KeychainManager.shared.remove(valueForKey: "password")
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
        customView.isHidden = false
        customView.frame = CGRect.init(x: 200, y: 50, width: 200, height: 100)
           customView.backgroundColor = UIColor.white     //give color to the view
      //  customView.rightAnchor = self.view.center
        myFirstButton.setTitle("Controller Setting", for: .normal)
        myFirstButton.setTitleColor(UIColor.black, for: .normal)
        myFirstButton.frame = CGRect(x: 10, y: 0, width: 180, height: 50)
        myFirstButton.addTarget(self, action: #selector(pressed), for: .touchUpInside)
        customView.addSubview(myFirstButton)
        
        goodbyButton.setTitle("Good Bye", for: .normal)
        goodbyButton.setTitleColor(UIColor.black, for: .normal)
        goodbyButton.frame = CGRect(x: 10, y: 50, width: 180, height: 50)
        goodbyButton.addTarget(self, action: #selector(pressedGoodbye), for: .touchUpInside)
        customView.addSubview(goodbyButton)
            self.view.addSubview(customView)
    }

    @objc func pressed(sender: UIButton!) {
        customView.isHidden = true
        self.didSelectControllerSetthingButton()
    }
    @objc func pressedGoodbye(sender: UIButton!) {
        customView.isHidden = true
        self.updateControllers()
    }
    
    
    @IBAction func didSelectMenuButton(_ pSender: UIButton?) {
        self.drawerController.toggle()
    }
    
}
extension DashboardController{
    func updateControllers() {
        for i in (0 ..< ControllerListViewController.contollerDeviceId.count) {
            ProgressOverlay.shared.show()
            print("get good bey controller=\(ControllerListViewController.contollerDeviceId.count)")
            DataFetchManager.shared.updateDevice(completion: { (pError) in
                ProgressOverlay.shared.hide()
                if pError != nil {
                    PopupManager.shared.displayError(message: "Can not update appliance.", description: pError!.localizedDescription)
                    self.reloadAllView()
                } else {
                    self.reloadAllView()
                }
            }, deviceId: ControllerListViewController.contollerDeviceId[i])
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
            #if !APP_WIFINITY
            RoutingManager.shared.gotoSearchTankRegulator(controller: self)
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
            aReturnVal = CGSize(width: (self.applianceCollectionView.frame.size.width / 3) - 3, height: (self.applianceCollectionView.frame.size.width / 3) - 2)
        } else if pCollectionView.isEqual(self.roomCollectionView) {
            if UtilityManager.shared.screenSizeType == UtilityManager.ScreenSizeType.small {
                aReturnVal = CGSize(width: self.roomCollectionView.frame.size.width, height: 210.0)
            } else {
                aReturnVal = CGSize(width: self.roomCollectionView.frame.size.width, height: 160.0)
            }
        }
        
        return aReturnVal
    }
}



extension DashboardController :FrequentlyOperatedCollectionCellViewDelegate {
    
    func cellView(_ pSender: FrequentlyOperatedCollectionCellView, didChangePowerState pPowerState: Bool) {
        if let anIndexPath = self.applianceCollectionView.indexPathForItem(at: pSender.convert(CGPoint.zero, to: self.applianceCollectionView)), anIndexPath.item < self.appliances.count {
            let anAppliance = self.appliances[anIndexPath.item]
            self.updateAppliancePowerState(appliance: anAppliance, powerState: pPowerState)
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
            RoutingManager.shared.gotoEnergyDetails(controller: self, userId: DataFetchManager.shared.loggedInUser?.firebaseUserId ?? "", roomId: aSelectedRoom.id ?? "")
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
