//
//  SearchApplianceController.swift
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
class SearchApplianceController: BaseController, UITextFieldDelegate {
    @IBOutlet weak var applianceTableView: AppTableView!
    @IBOutlet weak var addButton: AppFloatingButton!
    @IBOutlet weak var dynamicButtonContainerView :DynamicButtonContainerView!
    var controllerflag: Bool = true
    var myDict = [String: Any]()
    var selectedRoom :Room?
    var AppOperated: Int = 0
    var appliances :Array<Appliance> = Array<Appliance>()
  //  var devices: Array<String> = Array<String>()
    var devices = [String]()
    var menuItemsForAccepted: [UIAction] {
        return [
            UIAction(title: "Add Appliance", image: nil, handler: { (_) in
                self.addAppliance()
             }),
            UIAction(title: "Goodbye", image: nil, handler: { (_) in
                 self.didSelectGoodbye()
             }),
            UIAction(title: "Delete Room", image: nil, handler: { (_) in
                self.didSelectDeleteRooms()
            }),
            UIAction(title: "Edit Room Name", image: nil, handler: { (_) in
                self.didSelectEditRooms()
            })
        ]
    }
    static var applinceId = [String]() {
        didSet {

               }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SearchApplianceTableCellView.slideflag = false
        self.title = "APPLIANCES"
        self.subTitle = self.selectedRoom?.title ?? "Currently On"
        
        self.dynamicButtonContainerView.isForAppliance = true
        self.dynamicButtonContainerView.delegate = self
        
        self.applianceTableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.applianceTableView.frame.size.width, height: 80.0))
        self.applianceTableView.delaysContentTouches = false
        
        self.addButton.isHidden = true
        appHeaderBarView?.optionButton.isHidden = false
        if #available(iOS 14.0, *) {
            appHeaderBarView?.optionButton.menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItemsForAccepted)
            appHeaderBarView?.optionButton.showsMenuAsPrimaryAction = true
        } else {
            // Fallback on earlier versions
        }

       if self.selectedRoom?.title == nil{
           appHeaderBarView?.optionButton.isHidden = true
        }
        if ConfigurationManager.shared.appType == ConfigurationManager.AppType.wifinity {
            if self.selectedRoom != nil {
                self.addButton.isHidden = true
            }
        }
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        applianceTableView.addGestureRecognizer(longPress)
        applianceTableView.rowHeight = UITableView.automaticDimension
        applianceTableView.estimatedRowHeight = 100
        applianceTableView.contentInsetAdjustmentBehavior = .automatic
       
    }
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: applianceTableView)
            if let indexPath = applianceTableView.indexPathForRow(at: touchPoint) {
                print("indexpath=\(indexPath)")
                
                if self.isDetailsViewAvailable && indexPath.row < self.appliances.count {
                    let aSelectedAppliance = self.appliances[indexPath.row]
                    RoutingManager.shared.gotoApplianceDetails(controller: self, selectedAppliance: aSelectedAppliance,delegate: self)
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        self.controllerflag = true
        SearchApplianceController.celltappedcounter = 0
        activatdatalistner()
        print("im back")
      //  reloadAllData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("did dis appear........")
        self.controllerflag = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("view will disappear")
        if AppOperated != 0{
            print("operated appliances",AppOperated)
            let currentTimeStam = Date().timeIntervalSince1970
            selectedRoom?.lastActivityRoom = String(Int(currentTimeStam * 1000))
           DataFetchManager.shared.updateTimestamp(selectedRoom: selectedRoom, complition: { error in
               if error != nil{
                   print(error?.localizedDescription)
               }
            })
        }
    }
    static var celltappedcounter = 0
    func activatdatalistner()  {
        print("applince id\(SearchApplianceController.applinceId)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            for i in (0 ..< SearchApplianceController.applinceId.count) {
               print(SearchApplianceController.applinceId[i])
              
           Database.database().reference().child("applianceDetails").child( SearchApplianceController.applinceId[i]).observe(.childChanged) { (snapshot, key) in
               print(key as Any)
               if SearchApplianceController.celltappedcounter == 0 {
                   self.calltomyviewfunc()
               }
               if self.controllerflag == true {
                   if  SearchApplianceTableCellView.slideflag == true{
                       if SearchApplianceController.celltappedcounter == 0 && SearchApplianceController.celltappedcounter >= 0{
                     //  DispatchQueue.main.asyncAfter(deadline: .now() + 8){
                           print("button true in data reload...=\(SearchApplianceController.celltappedcounter)")
                       self.reloadAllData()
                           SearchApplianceTableCellView.slideflag = false
                     //  }
                       }else{
                           print("button false in data reload=\(SearchApplianceController.celltappedcounter)")
                           SearchApplianceController.celltappedcounter -= 1
                       }
                   }else{
                self.reloadAllData()
                   }
                  }
               }
           }
        }
    }
    func calltomyviewfunc() {
        
    }
    override func viewDidAppear(_ pAnimated: Bool) {
        super.viewDidAppear(pAnimated)
        self.dynamicButtonContainerView.toggle(forceCollpase: true)
    }
    
    override func reloadAllData() {
        self.appliances.removeAll()
        print("data load applinces")
        // ProgressOverlay.shared.show()
        DataFetchManager.shared.searchAppliance(completion: { (pError, pApplianceArray,pDevicesArray) in
           //  ProgressOverlay.shared.hide()
            do{
                if pError != nil {
                    PopupManager.shared.displayError(message: "Can not search appliances", description: pError!.localizedDescription)
                } else {
                    if pApplianceArray != nil && pApplianceArray!.count > 0 {
                        self.appliances = pApplianceArray!
                    }
                    if pDevicesArray != nil && pDevicesArray!.count > 0 {
                        if let Arrayx = try pDevicesArray{
                             self.devices = Arrayx
                        }
                    }
                    if let selectedRoom = self.selectedRoom {
                        DataFetchManager.shared.checkToShowApplianceDimmable(completion: { dimmable in
                            if dimmable ?? false {
                                let value = self.setSliderInitialValue()
                                self.dynamicButtonContainerView.customeSlider.value = Float(value)
                            }
                            self.setBottomContainerView(hidden: dimmable ?? false)
                        }, room: selectedRoom)
                    } else {
                        self.setBottomContainerView(hidden: false)
                    }
                    self.reloadAllView()
                }
            }catch let error{
                print(error)
                PopupManager.shared.displayError(message: error.localizedDescription, description: nil)
            }
        }, room: self.selectedRoom, includeOnOnly: self.selectedRoom == nil)
        
    }
    
    
    func reloadAllView() {
        if self.appliances.count <= 0 {
            self.applianceTableView.display(message: "No Appliance Available")
        } else {
            self.applianceTableView.hideMessage()
        }
        
        if self.dynamicButtonContainerView.customeSlider.value == 0 {
            let value = setSliderInitialValue()
            self.dynamicButtonContainerView.customeSlider.value = Float(value)
        }
        self.applianceTableView.reloadData()
        if self.appliances.count > 0 {
            print("index=", String(index))
            let indexPathToScroll = IndexPath(row: index, section: 0)
            let scrollPosition: UITableView.ScrollPosition = .top
            applianceTableView.scrollToRow(at: indexPathToScroll, at: scrollPosition, animated: false)
        }
    }
    var index = 0
    func reloadAllViewforupdate() {
        if self.appliances.count <= 0 {
           self.applianceTableView.display(message: "No Appliance Available")
        } else {
            self.applianceTableView.hideMessage()
        }
        
        if self.dynamicButtonContainerView.customeSlider.value == 0 {
            let value = setSliderInitialValue()
            self.dynamicButtonContainerView.customeSlider.value = Float(value)
        }
        let value = setSliderInitialValue()
        self.dynamicButtonContainerView.customeSlider.value = Float(value)
    }
    
    private func deleteAppliance(appliance pAppliance :Appliance) {
        let anAppliance = pAppliance.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.deleteAppliance(completion: { (pError, pAppliance) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not delete appliance.", description: pError!.localizedDescription)
            } else {
                PopupManager.shared.displaySuccess(message: "Appliance deleted successfully.", description: nil, completion: nil)
                self.reloadAllData()
            }
        }, appliance: anAppliance)
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
    
    func updateControllers() {
        for deviceId in devices {
            ProgressOverlay.shared.show()
            DataFetchManager.shared.updateDevice(completion: { (pError) in
                 ProgressOverlay.shared.hide()
                if pError != nil {
                    PopupManager.shared.displayError(message: "Can not update appliance.", description: pError!.localizedDescription)
                    self.reloadAllView()
                } else {
                    self.reloadAllView()
                }
            }, deviceId: deviceId)
        }
    }
    
    func  updateDimableValueControllers(dimValue: Int) {
        for deviceId in devices {
            ProgressOverlay.shared.show()
            DataFetchManager.shared.updateDeviceDimabble(completion: { (pError) in
                ProgressOverlay.shared.hide()
                if pError != nil {
                    PopupManager.shared.displayError(message: "Can not update appliance.", description: pError!.localizedDescription)
                } else {
                    let value = self.setSliderInitialValue()
                    self.dynamicButtonContainerView.customeSlider.value = Float(value)
                    self.reloadAllView()
                  //  self.averageValuesForDimmer()
                }
            }, deviceId: deviceId, dimValue: dimValue)
        }
    }
    
    func averageValuesForDimmer(dimValue:Int) -> Int {

        let aDimmableValueMin :Double = Double(30)
        var aDimmableValue = ((Double(dimValue) * ((99.0 - aDimmableValueMin) / 100.0)) + aDimmableValueMin)
        if aDimmableValue < 10 {
            aDimmableValue = 10
        } else if aDimmableValue > 99 {
            aDimmableValue = 99
        }
        let aReturnVal = Int(aDimmableValue)

        return aReturnVal
    }
    
    func setCommonSliderInitialValue(pslidervalue: Int) -> Int {
        if appliances.count > 0 {
            var averageValue = 0
             var xy = 0
            var xyz = 0
            var cnt = 0
            var totals = 0
            var trackav = false
            for appliance in appliances {
                if let sum = appliance.dimmableValueTriac{
                    if appliance.isDimmable == true{
                        xy += appliance.dimmableValueMin ?? 0
                        xyz += appliance.dimmableValueMax ?? 0
                        cnt += 1
                       totals += sum
                        trackav = true
                    }
                }
            }
            if trackav == true{
            DynamicButtonContainerView.baseslidervalue = xy/cnt
            averageValue = totals/cnt
                let minavrg = xy/cnt
                let maxavrg = xyz/cnt
            let aDimmableValueTriac = Double(averageValue)
            let aDimmableValueMin = Double(xy/cnt)
                let aSliderValue = (aDimmableValueTriac - aDimmableValueMin) * (100.0 / (Double(maxavrg) - aDimmableValueMin))
//
//                self.dynamicButtonContainerView.customeSlider.minimumValue = Float(minavrg)
//                self.dynamicButtonContainerView.customeSlider.maximumValue = Float(maxavrg)
            return Int(aSliderValue)
        }
        }
        return 0
        
    }
    
    func setSliderInitialValue() -> Int {
        if appliances.count > 0 {
            var averageValue = 0
             var xy = 0
            var xyz = 0
            var cnt = 0
            var totals = 0
            var trackav = false
            for appliance in appliances {
                if let sum = appliance.dimmableValueTriac{
                    if appliance.isDimmable == true{
                        xy += appliance.dimmableValueMin ?? 0
                        xyz += appliance.dimmableValueMax ?? 0
                        cnt += 1
                       totals += sum
                        trackav = true
                    }
                }
            }
            if trackav == true{
            DynamicButtonContainerView.baseslidervalue = xy/cnt
            averageValue = totals/cnt
                let minavrg = xy/cnt
                let maxavrg = xyz/cnt
             let aDimmableValueTriac = Double(averageValue)
            let aDimmableValueMin = Double(xy/cnt)
                let aSliderValue = (aDimmableValueTriac - aDimmableValueMin) * (100.0 / (Double(maxavrg) - aDimmableValueMin))
//
//                self.dynamicButtonContainerView.customeSlider.minimumValue = Float(minavrg)
//                self.dynamicButtonContainerView.customeSlider.maximumValue = Float(maxavrg)
            return Int(aSliderValue)
        }
        }
        return 0
        
    }
    
    
    func setBottomContainerView(hidden:Bool) {
        self.dynamicButtonContainerView.isHidden = !hidden
    }
    
    func updateAppliancePowerState(appliance pAppliance :Appliance, powerState pPowerState :Bool) {
        AppOperated += 1
        let anAppliance = pAppliance.clone()
       
         ProgressOverlay.shared.show()
        DataFetchManager.shared.updateAppliancePowerState(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update appliance.", description: pError!.localizedDescription)
                self.reloadAllView()
            } else {
                if self.selectedRoom != nil {
                    pAppliance.isOn = pPowerState
                } else {
                //    self.reloadAllData()
                }
                 self.reloadAllView()
            }
        }, appliance: anAppliance, powerState: pPowerState)
    }
    
    
    func updateApplianceDimmableValue(appliance pAppliance :Appliance, dimmableValue pDimmableValue :Int) {
        AppOperated += 1
        let anAppliance = pAppliance.clone()
     //   ProgressOverlay.shared.show()
        DataFetchManager.shared.updateApplianceDimmableValue(completion: { (pError) in
       //     ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update appliance.", description: pError!.localizedDescription)
            } else {
                if pAppliance.dimType == Appliance.DimType.rc {
                    pAppliance.dimmableValue = pDimmableValue
                } else if pAppliance.dimType == Appliance.DimType.triac {
                    pAppliance.dimmableValueTriac = pDimmableValue
                } else {
                    pAppliance.dimmableValue = pDimmableValue
                }
                self.reloadAllViewforupdate()
               // self.reloadAllView()
            }
        }, appliance: anAppliance, dimValue: pDimmableValue)
    }
    
    func didSelectGoodbye() {
        AppOperated += 1
         self.updateControllers()
    }
    func didSelectDeleteRooms() {
        PopupManager.shared.displayConfirmation(message: "Delete room?", description: "Delete all devices before deleting room", completion: {
            var controllerCount = 0
            if let aRoom = self.selectedRoom {
                if aRoom.devices?.count ?? 0 > 0{ controllerCount += 1}
                if aRoom.curtainId?.count ?? 0 > 0{controllerCount += 1}
                if aRoom.sensors?.count ?? 0 > 0{controllerCount += 1}
                if aRoom.remoteId?.count ?? 0 > 0{controllerCount += 1}
                if controllerCount <= 0{
                    //delete room
                    DataFetchManager.shared.deleteRoom(complition: {error in
                        if error != nil{
                            PopupManager.shared.displayError(message: "EROOR!", description: error?.localizedDescription)
                        }else{
                            PopupManager.shared.displayInformation(message: "Room deleted successfully", description: "", completion: {
                                RoutingManager.shared.goToPreviousScreen(self)
                            })
                        }
                    }, room: self.selectedRoom)
                }
            }
        })
    }
    func didSelectEditRooms() {
        print("Edit room name")
        PopupManager.shared.displayConfirmation(message: "Do you want Edit room Name?", description: "", completion: {
            self.EditeViewCall()
        })
    }
    var myTextField = UITextField()
    var deleteView = UIView()
    var lablehead = UILabel()
    var btnAthontication = UIButton()
    var btnCancel = UIButton()
    
}
extension SearchApplianceController{
    func EditeViewCall(){
        
        self.myTextField.delegate = self
 
        deleteView.isHidden = false
        deleteView.frame = CGRect.init(x: view.frame.width / 20, y: view.frame.height / 3, width: view.frame.width / 1.11, height: view.frame.height / 4)
        deleteView.backgroundColor = UIColor.white
       
        lablehead.frame = CGRect(x: 20, y: 0, width: deleteView.frame.width - 20, height: 50)
        lablehead.text = "Edit Room Name?"
        lablehead.textColor = UIColor.black
        deleteView.addSubview(lablehead)
 
        myTextField.frame = CGRect(x: 15, y: 50, width: deleteView.frame.width - 30, height: 50)
        myTextField.placeholder = "Enter Room Name"
        myTextField.text = self.selectedRoom?.title
        myTextField.layer.cornerRadius = 15.0
        myTextField.layer.borderWidth = 1.0
        myTextField.layer.borderColor = UIColor.gray.cgColor
        myTextField.clipsToBounds = true
        myTextField.textColor = UIColor.blue
        myTextField.textAlignment = .center
        self.deleteView.addSubview(myTextField)
        
        btnAthontication.setTitle("Done", for: .normal)
        btnAthontication.setTitleColor(UIColor.black, for: .normal)
        btnAthontication.frame = CGRect(x: 30, y: 120, width: 130, height: 50)
        btnAthontication.addTarget(self, action: #selector(pressedmenu), for: .touchUpInside)
        btnAthontication.backgroundColor = UIColor.gray
        btnAthontication.layer.cornerRadius = 14
        btnAthontication.layer.borderWidth = 1
        deleteView.addSubview(btnAthontication)

        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.setTitleColor(UIColor.black, for: .normal)
        btnCancel.frame = CGRect(x: 220, y: 120, width: 130, height: 50)
        btnCancel.addTarget(self, action: #selector(pressedCancel), for: .touchUpInside)
        btnCancel.backgroundColor = UIColor.gray
        btnCancel.layer.cornerRadius = 15
        btnCancel.layer.borderWidth = 1
        deleteView.addSubview(btnCancel)

        self.applianceTableView.addSubview(deleteView)

        if deleteView.isHidden{
            deleteView.isHidden = true
        }else{
            deleteView.isHidden = false
        }
    }
    @objc func pressedmenu(){
        self.selectedRoom?.title = myTextField.text
        ProgressOverlay.shared.show()
        DataFetchManager.shared.editRoomName(complition: {error in
            ProgressOverlay.shared.hide()
            self.deleteView.isHidden = true
            if let error = error{
                PopupManager.shared.displayError(message: "", description: error.localizedDescription)
            }else{
                self.subTitle = self.selectedRoom?.title ?? "Currently On"
                self.showToast(message: "Room edited successfully")
            }
        }, room: self.selectedRoom)
    }
    @objc func pressedCancel(){
        deleteView.isHidden = true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           // Dismiss the keyboard
           textField.resignFirstResponder()
           return true
       }
}


extension SearchApplianceController :UITableViewDataSource, UITableViewDelegate {
    
    private var isDetailsViewAvailable :Bool {
        return self.selectedRoom != nil
    }
    
    // MARK:- UITableView Methods
    
    /**
     * Method that will calculate and return number of section in given table.
     * @return Int. Number of section in given table
     */
    func numberOfSections(in pTableView: UITableView) -> Int {
        return 1
    }
    
    
    /**
     * Method that will calculate and return number of rows in given section of the table.
     * @return Int. Number of rows in given section
     */
    func tableView(_ pTableView: UITableView, numberOfRowsInSection pSection: Int) -> Int {
        var aReturnVal :Int = 0
        
        if pSection == 0 {
            aReturnVal = self.appliances.count
        }
        
        return aReturnVal
    }
    
    
    /**
     * Method that will calculate and return height of row at given index path of the table.
     * @return CGFloat. Height of the row at given index path
     */
    func tableView(_ pTableView: UITableView, heightForRowAt pIndexPath: IndexPath) -> CGFloat {
        var aReturnVal :CGFloat = UITableView.automaticDimension
        
        if pIndexPath.row < self.appliances.count {
            let anAppliance = self.appliances[pIndexPath.row]
            if anAppliance.type == Appliance.ApplianceType.ledStrip {
                if aReturnVal > 40{
                   // aReturnVal -= 40
                }
             //   aReturnVal = SearchApplianceLedTableCellView.cellHeight(appliance: anAppliance)
            } else {
                aReturnVal = SearchApplianceTableCellView.cellHeight(appliance: anAppliance)
            }
        }
        
        return aReturnVal
    }
    
    
    /**
     * Method that will calculate and return height of row at given index path of the table.
     * @return CGFloat. Height of the row at given index path
     */
    func tableView(_ pTableView: UITableView, estimatedHeightForRowAt pIndexPath: IndexPath) -> CGFloat {
        var aReturnVal :CGFloat = UITableView.automaticDimension
        
        if pIndexPath.row < self.appliances.count {
            let anAppliance = self.appliances[pIndexPath.row]
            if anAppliance.type == Appliance.ApplianceType.ledStrip {
                if aReturnVal > 40{
                   // aReturnVal -= 40
                }
             //   aReturnVal = SearchApplianceLedTableCellView.cellHeight(appliance: anAppliance)
            } else {
                aReturnVal = SearchApplianceTableCellView.cellHeight(appliance: anAppliance)
            }
        }
        
        return aReturnVal
    }
    
    
    /**
     * Method that will init, set and return the cell view.
     * @return UITableViewCell. View of the cell in given table view.
     */
    func tableView(_ pTableView: UITableView, cellForRowAt pIndexPath: IndexPath) -> UITableViewCell {
        var aReturnVal :UITableViewCell?
        
        if pTableView.isEqual(self.applianceTableView) {
            if pIndexPath.row < self.appliances.count {
                let anAppliance = self.appliances[pIndexPath.row]
                if anAppliance.type == Appliance.ApplianceType.ledStrip {
                    let aCellView :SearchApplianceLedTableCellView = pTableView.dequeueReusableCell(withIdentifier: "SearchApplianceLedTableCellViewId") as! SearchApplianceLedTableCellView
                    aCellView.warmnessSlider.tag = pIndexPath.row
                    aCellView.delegate = self
                    aCellView.load(appliance: anAppliance, shouldShowRoomTitle: self.selectedRoom == nil)
                    aCellView.showDisclosureIndicator = self.isDetailsViewAvailable
                    aReturnVal = aCellView
                } else {
                    let aCellView :SearchApplianceTableCellView = pTableView.dequeueReusableCell(withIdentifier: "SearchApplianceTableCellViewId") as! SearchApplianceTableCellView
                    aCellView.delegate = self
                    aCellView.indepath = pIndexPath.row
                    aCellView.slider.tag = pIndexPath.row
                    aCellView.appliances = self.appliances
                    aCellView.load(appliance: anAppliance, shouldShowRoomTitle: self.selectedRoom == nil)
                    aCellView.showDisclosureIndicator = self.isDetailsViewAvailable
                    aReturnVal = aCellView
                }
            }
        }
        
        if aReturnVal == nil {
            aReturnVal = UITableViewCell()
        }
       
        return aReturnVal!
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let visibleIndexPaths = applianceTableView.indexPathsForVisibleRows {
            for indexPath in visibleIndexPaths {
                print("Visible Cell Index Path: \(indexPath.section), \(indexPath.row)")
                self.index = indexPath.row
                break
            }
        }
    }
    
    /**
     * Method that will be called when user selects a table cell.
     */
    func tableView(_ pTableView: UITableView, didSelectRowAt pIndexPath: IndexPath) {
        pTableView.deselectRow(at: pIndexPath, animated: true)
 
       if self.appliances.count > 0 {
            let anAppliance = self.appliances[pIndexPath.row]
           if anAppliance.type == Appliance.ApplianceType.ledStrip{
               let aGlowPattern = anAppliance.isOn ? Appliance.GlowPatternType.off: Appliance.GlowPatternType.on
               self.updateAppliance(appliance: anAppliance, property1: anAppliance.ledStripProperty1 ?? 255, property2: anAppliance.ledStripProperty2 ?? 255, property3: anAppliance.ledStripProperty3 ?? 255, glowPattern: aGlowPattern)
           }else{
               self.updateAppliancePowerState(appliance: anAppliance, powerState: !anAppliance.isOn)
           }
           
        }
//        if self.isDetailsViewAvailable && pIndexPath.row < self.appliances.count {
//            let aSelectedAppliance = self.appliances[pIndexPath.row]
//            RoutingManager.shared.gotoApplianceDetails(controller: self, selectedAppliance: aSelectedAppliance)
//        }
    }
    
    
    func tableView(_ pTableView: UITableView, canEditRowAt pIndexPath: IndexPath) -> Bool {
        return true
    }
    
//    func tableView(_ pTableView: UITableView, commit pEditingStyle: UITableViewCell.EditingStyle, forRowAt pIndexPath: IndexPath) {
//        if pEditingStyle == .delete {
//            if pIndexPath.row < self.appliances.count {
//                let anAppliance = self.appliances[pIndexPath.row]
//                PopupManager.shared.displayConfirmation(message: "Do you want to delete selected appliance?", description: nil, completion: {
//                    self.deleteAppliance(appliance: anAppliance)
//                })
//            }
//        }
//    }
    
}



extension SearchApplianceController :SearchApplianceTableCellViewDelegate {
    
    func cellView(_ pSender: SearchApplianceTableCellView, didChangePowerState pPowerState :Bool) {
        if let anIndexPath = self.applianceTableView.indexPath(for: pSender), anIndexPath.row < self.appliances.count {
            let anAppliance = self.appliances[anIndexPath.row]
            self.updateAppliancePowerState(appliance: anAppliance, powerState: pPowerState)
        }
    }
    
    func cellView(_ pSender: SearchApplianceTableCellView, didChangeDimmableValue pDimmableValue: Int) {
        if let anIndexPath = self.applianceTableView.indexPath(for: pSender), anIndexPath.row < self.appliances.count {
            let anAppliance = self.appliances[anIndexPath.row]
            self.updateApplianceDimmableValue(appliance: anAppliance, dimmableValue: pDimmableValue)
        }
    }
    
}



extension SearchApplianceController :SearchApplianceLedTableCellViewDelegate {
    func cellViewRefrash(_ pSender: SearchApplianceLedTableCellView) {
        if let aIndexPath = self.applianceTableView.indexPath(for: pSender){
            self.applianceTableView.reloadRows(at: [aIndexPath], with: .automatic)
        }
    }
    
    
    func cellView(_ pSender: SearchApplianceLedTableCellView, didChangeProperty1 pProperty1: Int, property2 pProperty2: Int, property3 pProperty3: Int, glowPattern pGlowPatternValue: Appliance.GlowPatternType) {
        AppOperated += 1
        if let anIndexPath = self.applianceTableView.indexPath(for: pSender), anIndexPath.row < self.appliances.count {
            let anAppliance = self.appliances[anIndexPath.row]
            self.updateAppliance(appliance: anAppliance, property1: pProperty1, property2: pProperty2, property3: pProperty3, glowPattern: pGlowPatternValue)
        }
    }
    
}



extension SearchApplianceController {
    
    @IBAction func didSelectAddButton(_ pSender: AppFloatingButton?) {
        self.addAppliance()
    }
    func addAppliance() {
        if let aRoom = self.selectedRoom {
            RoutingManager.shared.gotoNewAppliance(controller: self, selectedRoom: aRoom,pDelegate: self)
        }
    }
}

extension SearchApplianceController :DynamicButtonContainerViewDelegate {
    func dynamicButtonContainerView(_ pSender: DynamicButtonContainerView, didSelectRemoteKey pRemoteKey: RemoteKey) {
      //  self.clickRemoteKey(pRemoteKey)
    }
    
    func dynamicButtonContainerView(_ pSender: DynamicButtonContainerView, didSelectEditRemoteKey pRemoteKey: RemoteKey) {
//        if let aRemote = self.selectedRemote {
//            RoutingManager.shared.gotoUpdateRemoteButton(controller: self, selectedRemote: aRemote, selectedRemoteKey: pRemoteKey)
//        }
    }
    func dynamicButtonContainerView(didSelectDimmerValue pDimmableValue: Int) {
       // self.updateApplianceDimmableValue(appliance: appliance, dimmableValue: pDimmableValue)
        var aDimmableValues = pDimmableValue
        if appliances.count > 0 {
            var averageValue = 0
            var xy = 0
            var xyz = 0
            var cnt = 0
            var totals = 0
            var trackav = false
            for appliance in appliances {
                if let sum = appliance.dimmableValueTriac{
                    if appliance.isDimmable == true{
                        xy += appliance.dimmableValueMin ?? 0
                        xyz += appliance.dimmableValueMax ?? 0
                        cnt += 1
                        totals += sum
                        trackav = true
                    }
                }
            }
            if trackav == true{
            DynamicButtonContainerView.baseslidervalue = xy/cnt
            averageValue = totals/cnt
                let minavrg = xy/cnt
                let maxavrg = xyz/cnt
             let aDimmableValueTriac = Double(averageValue)
             let aDimmableValueMin = Double(xy/cnt)
                
        var aDimmableValue = ((Double(pDimmableValue) * ((Double(maxavrg) - Double(minavrg)) / 100.0)) + Double(minavrg))
                
                if aDimmableValue < 10 {
                    aDimmableValue = 10
                } else if aDimmableValue > 99 {
                    aDimmableValue = 99
                }
                aDimmableValues = Int(aDimmableValue)
                print(aDimmableValues)
        }
        }
        self.updateDimableValueControllers(dimValue: aDimmableValues)
    }
}
extension SearchApplianceController: SelectedAppliandesDelegate{
    func didtappedBacktoController(obj: Any) {
        let y = obj as? Appliance
         RoutingManager.shared.goToPreviousScreen(self)
         deleteAppliance(appliance: y!)
    }
    func didtappedDonebtn() {
        RoutingManager.shared.goToPreviousScreen(self)
        self.reloadAllData()
    }
}
protocol SelectedAppliandesDelegate:AnyObject{
    func didtappedBacktoController(obj: Any)
    func didtappedDonebtn()
}
