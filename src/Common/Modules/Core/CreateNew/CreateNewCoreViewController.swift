//
//  CreateNewCoreViewController.swift
//  Wifinity
//
//  Created by sachin on 19/06/23.
//

import UIKit
import SwiftUI
import SwiftClockUI


class CreateNewCoreViewController: BaseController {
    
    @IBOutlet weak var lblAllcondbtn: UIButton!
    @IBOutlet weak var lblAnyCondBtn: UIButton!
    
    @IBOutlet weak var lblAddActionsbtn: UIButton!
    @IBOutlet weak var lblAddtriggerbtn: UIButton!
    @IBOutlet weak var viewThen: UIView!
    @IBOutlet weak var viewIf: UIView!
    @IBOutlet weak var lblSavebtn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SelectComponentController.coreSensor = true
    }
    
    @IBAction func didtappedSavebtn(_ sender: Any) {
        
    }
    
    @IBAction func didtappedAddTrigger(_ sender: Any) {
        
    }
    
    @IBAction func didtappedAddAction(_ sender: Any) {
        
    }
    // our coding
    @IBAction func didSelectDoneButton(_ sender: Any) {
        
    }
    
    @IBOutlet weak var newScheduleTableView: UITableView!
    
    var cellTypes :Array<CellType> = Array<CellType>()
    var callType : CellType = CellType.components
    var schedule :Schedule?
    
    weak var delegate :NewScheduleControllerDelegate?
    weak var delegates :newCoreControllerDelegate?
    var editedScheduleTitle :String?
    var editedScheduleRooms :Array<Room>?
    var editedScheduleRoomsThen :Array<Room>?
    var editedScheduleTime :String?
    var editedScheduleRepetitions :Array<Schedule.Day>?
    var NewCore: Core = Core()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Core"
        subTitle = ""
        
        self.title = self.NewCore != nil ? "CORE DETAILS" : "CREATE CORE"
        self.subTitle = self.schedule?.title
        
        self.newScheduleTableView.dataSource = self
        self.newScheduleTableView.delegate = self
        self.newScheduleTableView.tableFooterView = UIView()
        self.newScheduleTableView.delaysContentTouches = true
    }
    
    override func reloadAllData() {
        self.scheduleDetails()
        //   self.editCoreSetUp()
    }
    var newCoreId: String?
    @IBAction func didtappedDonebtn(_ sender: Any) {
        do{
            throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey: "try to thow exeption"])
        }catch{print("error")}
        saveSchedule()
    }
    
    func scheduleDetails() {
        if let aSchedule = self.schedule {
            // ProgressOverlay.shared.show()
            DataFetchManager.shared.scheduleDetails(completion: { (pError, pSchedule) in
                // ProgressOverlay.shared.hide()
                if pError != nil {
                    PopupManager.shared.displayError(message: "Can not fetch schedule details.", description: pError!.localizedDescription)
                } else {
                    self.schedule = pSchedule
                    self.reloadAllView()
                }
            }, schedule: aSchedule)
        } else {
            self.reloadAllView()
        }
    }
    
    
    func reloadAllView() {
        self.cellTypes.removeAll()
        
        self.cellTypes.append(.title)
        self.cellTypes.append(.components)
        self.cellTypes.append(.time)
        self.cellTypes.append(.repeatDays)
        self.newScheduleTableView.reloadData()
    }
    
    
    enum CellType :String {
        case title = "Schedule Name"
        case components = "Components"
        case time = "Time"
        case repeatDays = "Repeat On"
    }
    
    
    func saveSchedule(Core pCore :Core) {
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.saveCore(completion: { (pError, pSchedule) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not save Core.", description: pError!.localizedDescription)
            } else {
                self.reloadAllView()
                PopupManager.shared.displaySuccess(message: "Core saved successfully.", description: nil, completion: {
                    DispatchQueue.main.async {
                        self.delegates?.newCoreControllerDidDone()
                    }
                })
            }
        }, core: pCore)
    }
    
    
    func saveSchedule() {
        do {
            let aTitle = self.editedScheduleTitle ?? self.schedule?.title
            if (aTitle?.count ?? 0) <= 0 {
                throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Please provide title."])
            }
            NewCore.ruleName = aTitle
            NewCore.createdBy = "user"
            NewCore.isCreatedBySensor = false
            
            if editedScheduleRooms == nil {
                throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey: "Please select If Controllers"])
            }
            if editedScheduleRoomsThen == nil{
                throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey: "Please select Than Controllers"])
            }
            
            if (NewCore.duration != nil) && NewCore.duration ?? "00" < "45"{
                throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey: "Time duration must be greater than 45 seconds"])
            }
            
            if let aRoomsIf = self.editedScheduleRooms ?? self.schedule?.rooms{
                ActionIfSectionList()
            }
            if let aRoomsThan = self.editedScheduleRoomsThen ?? self.schedule?.rooms{
                ActionThenSectionList()
            }
            let cr = NewCore
            
            self.saveSchedule(Core: NewCore)
        } catch {
            PopupManager.shared.displayError(message: error.localizedDescription, description: nil)
        }
    }
    
    func ActionIfSectionList(){
        guard let aRoomsIf = self.editedScheduleRooms ?? self.schedule?.rooms else{
            return
        }
        var devicesArray: Array<String> =  Array<String>()
        let coreE: coreEditdata? = coreEditdata()
        coreE?.ruleName = NewCore.ruleName
        // coreE?.ruleId = NewCore?.ruleId
        coreE?.operation = NewCore.Operator
        NewCore.coreEditData?.ruleName = NewCore.ruleName
        NewCore.ruleId = newCoreId
        //Appliances
        var pactionSelectionListt: Array<actionSelectionList> = Array<actionSelectionList>()
        for item in aRoomsIf{
            if let dataAppliances = item.appliances{
                if  NewCore.ifStatement == nil{
                    NewCore.ifStatement = "Appliances "
                }else{
                    NewCore.ifStatement! += "Appliances "
                }
                
                for items in dataAppliances{
                    print(items.title!)
                    let pactionSelectionList = actionSelectionList()
                    NewCore.ifStatement! += "\(items.title ?? "") of \(String(describing: items.roomTitle!)) room \(items.scheduleState ? "ON":"OFF") "
                    pactionSelectionList.appId = items.id
                    pactionSelectionList.appName = items.title
                    pactionSelectionList.hardwareId = items.hardwareId
                    pactionSelectionList.uniqueKey = "\(String(describing: items.hardwareId!)):\(String(describing: items.id!))"
                    pactionSelectionList.state = items.scheduleState != false ? 2 : 1
                    pactionSelectionList.roomName = items.roomTitle
                    pactionSelectionList.roomId = items.roomId
                    pactionSelectionList.currentLevel = 0
                    pactionSelectionList.routineType = "appliance"
                    pactionSelectionList.applianceType = items.type?.title
                    pactionSelectionList.dimmable = items.isDimmable //false
                    pactionSelectionList.minDimming = items.dimmableValueMin ?? 0
                    pactionSelectionList.maxDimming = items.dimmableValueMax ?? 5
                    pactionSelectionList.dimValue = items.scheduleDimmableValue
                    pactionSelectionList.currentState = items.isOn
                    devicesArray.append(pactionSelectionList.uniqueKey!)
                    pactionSelectionListt.append(pactionSelectionList)
                }
            }
            
            if let dataAppliances = item.curtains{
                if dataAppliances.count > 0{
                    if  NewCore.ifStatement == nil{
                        NewCore.ifStatement = "Curtain "
                    }else{
                        NewCore.ifStatement! += "Curtain "
                    }
                }
                for items in dataAppliances{
                    print(items.title!)
                    // Curtain
                    let pactionSelectionList = actionSelectionList()
                    NewCore.ifStatement! += "\(items.title ?? "") of \(String(describing: items.roomTitle!)) room open at level \(items.scheduleLevel != 1 ? "2":"1") "
                    //   pactionSelectionList.appId = items.id
                    pactionSelectionList.appName = items.title
                    pactionSelectionList.hardwareId = items.id
                    pactionSelectionList.uniqueKey = "\(String(describing: items.id!))"
                    pactionSelectionList.routineType = "Curtain"
                    pactionSelectionList.state = items.scheduleLevel != 1 ? 2 : 1
                    pactionSelectionList.roomName = items.roomTitle
                    pactionSelectionList.roomId = items.roomId
                    pactionSelectionList.currentState = items.scheduleLevel != 1 ? true : false
                    pactionSelectionList.currentLevel = items.scheduleLevel
                    devicesArray.append(pactionSelectionList.uniqueKey!)
                    
                    pactionSelectionListt.append(pactionSelectionList)
                }
            }
            // Sensor
            if let dataAppliances = item.sensors{
                if dataAppliances.count > 0{
                    if  NewCore.ifStatement == nil{
                        NewCore.ifStatement = "Sensor "
                    }else{
                        NewCore.ifStatement! += "Sensor "
                    }
                }
                for items in dataAppliances{
                    print(items.title!)
                    NewCore.ifStatement! += "\(items.title ?? "") of \(String(describing: items.roomTitle!)) room \(String(describing: items.scheduleSensorActivatedState?.rawValue != 1 ? "ON":"OFF")) "
                    let pactionSelectionList = actionSelectionList()
                    pactionSelectionList.appId = items.id
                    pactionSelectionList.appName = items.title
                    pactionSelectionList.hardwareId = items.id
                    pactionSelectionList.checked = true
                    pactionSelectionList.currentState = true
                    pactionSelectionList.uniqueKey = "\(String(describing: items.id!))"
                    pactionSelectionList.intensity = items.temperature
                    pactionSelectionList.operators = items.optators
                    pactionSelectionList.routineType = items.routineType
                    pactionSelectionList.sensorTypeId = items.sensorTypeId
                    
                    pactionSelectionList.state = 2
                    pactionSelectionList.roomName = items.roomTitle
                    pactionSelectionList.roomId = items.roomId
                    devicesArray.append(pactionSelectionList.uniqueKey!)
                    pactionSelectionListt.append(pactionSelectionList)
                }
            }
        }
        let s = Optional(pactionSelectionListt)
        coreE?.whenSelectionList = s
        coreE?.ruleId = NewCore.ruleId
        coreE?.duration = NewCore.duration
        coreE?.from = NewCore.from
        coreE?.to = NewCore.to
        NewCore.deviceId = devicesArray
        NewCore.coreEditData = coreE
        
        let xy = NewCore.coreEditData?.whenSelectionList
        print(xy as Any)
        
    }
    func ActionThenSectionList(){
        guard let aRoomsThen = self.editedScheduleRoomsThen ?? self.schedule?.rooms else{
            return
        }
        var devicesArray: Array<String>? =  Array<String>()
        var coreE: coreEditdata? = coreEditdata()
        devicesArray = NewCore.deviceId
        coreE = NewCore.coreEditData
        
        //Appliances
        var pactionSelectionListt: Array<actionSelectionList> = Array<actionSelectionList>()
        for item in aRoomsThen{
            if let dataAppliances = item.appliances{
                if dataAppliances.count > 0{
                    if  NewCore.thenStatement == nil{
                        NewCore.thenStatement = "Appliances "
                    }else{
                        NewCore.thenStatement! += "Appliances "
                    }
                }
                for items in dataAppliances{
                    print(items.title!)
                    let pactionSelectionList = actionSelectionList()
                    NewCore.thenStatement! += "\(items.title ?? "") of \(String(describing: items.roomTitle!)) room \(items.scheduleState ? "ON":"OFF") "
                    pactionSelectionList.appId = items.id
                    pactionSelectionList.appName = items.title
                    pactionSelectionList.hardwareId = items.hardwareId
                    pactionSelectionList.uniqueKey = "\(String(describing: items.hardwareId!)):\(String(describing: items.id!))"
                    pactionSelectionList.state = items.scheduleState != false ? 2 : 1
                    
                    pactionSelectionList.roomName = items.roomTitle
                    pactionSelectionList.roomId = items.roomId
                    pactionSelectionList.currentLevel = 0
                    pactionSelectionList.routineType = "appliance"
                    pactionSelectionList.currentState = items.isOn
                    pactionSelectionList.dimmable = items.isDimmable //false
                    pactionSelectionList.minDimming = items.dimmableValueMin ?? 0
                    pactionSelectionList.maxDimming = items.dimmableValueMax ?? 5
                    pactionSelectionList.dimValue = items.scheduleDimmableValue
                    pactionSelectionList.appliancesStatment = items.selectedAppType
                    pactionSelectionList.stripType  = items.stripType
                  if pactionSelectionList.stripType == Appliance.StripType.rgb{
                        pactionSelectionList.ledStripProperty3 = items.ledStripProperty3
                        pactionSelectionList.ledStripProperty1 = items.ledStripProperty1
                        pactionSelectionList.ledStripProperty2 = items.ledStripProperty2
                      let x = "@02%"
                        pactionSelectionList.stripLightEvent = items.stripLightEvent
                    }
                    //       devicesArray?.append(pactionSelectionList.uniqueKey!)
                    pactionSelectionListt.append(pactionSelectionList)
                }
            }
            
            if let dataAppliances = item.curtains{
                if dataAppliances.count > 0{
                    if  NewCore.thenStatement == nil{
                        NewCore.thenStatement = "Curtain "
                    }else{
                        NewCore.thenStatement! += "Curtain "
                    }
                }
                for items in dataAppliances{
                    print(items.title!)
                    // Curtain
                    let pactionSelectionList = actionSelectionList()
                    NewCore.thenStatement! += "\(items.title ?? "") of \(String(describing: items.roomTitle!)) room open at level \(items.scheduleLevel != 1 ? "2":"1") "
                    //   pactionSelectionList.appId = items.id
                    pactionSelectionList.appName = items.title
                    pactionSelectionList.hardwareId = items.id
                    pactionSelectionList.uniqueKey = "\(String(describing: items.id!))"
                    pactionSelectionList.routineType = "curtain"
                    pactionSelectionList.state = items.scheduleLevel != 1 ? 2 : 1
                    pactionSelectionList.roomName = items.roomTitle
                    pactionSelectionList.roomId = items.roomId
                    pactionSelectionList.currentState = items.scheduleLevel != 1 ? true : false
                    pactionSelectionList.currentLevel = items.scheduleLevel
                    pactionSelectionList.currentType = items.type?.rawValue
                    //        devicesArray?.append(pactionSelectionList.uniqueKey!)
                    pactionSelectionListt.append(pactionSelectionList)
                }
            }
            // Sensor
            if let dataAppliances = item.sensors{
                if dataAppliances.count > 0{
                    if  NewCore.thenStatement == nil{
                        NewCore.thenStatement = "Sensor "
                    }else{
                        NewCore.thenStatement! += "Sensor "
                    }
                }
                for items in dataAppliances{
                    print(items.title!)
                    NewCore.thenStatement! += "\(items.title ?? "") of \(String(describing: items.roomTitle!)) room \(String(describing: items.scheduleSensorActivatedState?.rawValue != 1 ? "ON":"OFF")) "
                    let pactionSelectionList = actionSelectionList()
                    pactionSelectionList.appId = items.id
                    pactionSelectionList.appName = items.title
                    pactionSelectionList.hardwareId = items.id
                    pactionSelectionList.intensity = items.temperature
                    pactionSelectionList.operators = items.optators
                    pactionSelectionList.routineType = items.routineType
                    pactionSelectionList.sensorTypeId = items.sensorTypeId
                    pactionSelectionList.uniqueKey = "\(String(describing: items.id!))\(String(describing: items.sensorTypeId!))"
                    pactionSelectionList.state = 2
                    pactionSelectionList.roomName = items.roomTitle
                    pactionSelectionList.roomId = items.roomId
                    //    devicesArray?.append(pactionSelectionList.uniqueKey!)
                    pactionSelectionListt.append(pactionSelectionList)
                }
            }
            // remote
            if let dataAppliances = item.remotes{
                if dataAppliances.count > 0{
                    if  NewCore.thenStatement == nil{
                        NewCore.thenStatement = "Remote "
                    }else{
                        NewCore.thenStatement! += "Remote "
                    }
                }
                for items in dataAppliances{
                    print(items.title!)
                    NewCore.thenStatement! += "\(items.title ?? "") "
                    let pactionSelectionList = actionSelectionList()
                    pactionSelectionList.appId = items.id
                    pactionSelectionList.appName = items.title
                    pactionSelectionList.hardwareId = items.hardwareId
                    pactionSelectionList.uniqueKey = "\(String(describing: items.hardwareId!)):\(String(describing: items.selectedRemoteKeys!.first!.tag!.rawValue))"
                    pactionSelectionList.state = 0
                    pactionSelectionList.roomName = items.roomTitle
                    pactionSelectionList.roomId = items.roomId
                    pactionSelectionList.currentLevel = 0
                    pactionSelectionList.routineType = "remote"
                    pactionSelectionList.currentState = false
                    pactionSelectionList.dimmable = false
                    pactionSelectionList.minDimming = 0
                    pactionSelectionList.maxDimming = 5
                    pactionSelectionList.dimValue = 0
                    pactionSelectionList.checked = true
                    pactionSelectionList.appId = items.selectedRemoteKeys!.first!.command
                    //       devicesArray?.append(pactionSelectionList.uniqueKey!)
                    pactionSelectionListt.append(pactionSelectionList)
                }
            }
        }
        let s = Optional(pactionSelectionListt)
        coreE?.actionSelectionList = s
        NewCore.deviceId = devicesArray
        NewCore.coreEditData = coreE
        NewCore.state = false
        let xy = NewCore.coreEditData?.whenSelectionList
        print(xy as Any)
    }
}

extension CreateNewCoreViewController :UITableViewDataSource, UITableViewDelegate {
    
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
        let aReturnVal :Int = self.cellTypes.count
        return aReturnVal
    }
    
    
    /**
     * Method that will calculate and return height of row at given index path of the table.
     * @return CGFloat. Height of the row at given index path
     */
    func tableView(_ pTableView: UITableView, heightForRowAt pIndexPath: IndexPath) -> CGFloat {
        let aReturnVal :CGFloat = UITableView.automaticDimension
        return aReturnVal
    }
    
    
    /**
     * Method that will calculate and return height of row at given index path of the table.
     * @return CGFloat. Height of the row at given index path
     */
    func tableView(_ pTableView: UITableView, estimatedHeightForRowAt pIndexPath: IndexPath) -> CGFloat {
        let aReturnVal :CGFloat = UITableView.automaticDimension
        return aReturnVal
    }
    
    
    /**
     * Method that will init, set and return the cell view.
     * @return UITableViewCell. View of the cell in given table view.
     */
    func tableView(_ pTableView: UITableView, cellForRowAt pIndexPath: IndexPath) -> UITableViewCell {
        var aReturnVal :UITableViewCell?
        
        if pTableView.isEqual(self.newScheduleTableView) {
            if pIndexPath.row < self.cellTypes.count {
                let aCellType = self.cellTypes[pIndexPath.row]
                switch aCellType {
                case .title:
                    let aCellView :ScheduleTitleTableCellView = pTableView.dequeueReusableCell(withIdentifier: "ScheduleTitleTableCellViewId") as! ScheduleTitleTableCellView
                    aCellView.delegate = self
                    aCellView.selectionStyle = UITableViewCell.SelectionStyle.none
                    if let aTitle = self.editedScheduleTitle {
                        aCellView.load(scheduleTitle: aTitle)
                    } else if let aTitle = self.schedule?.title {
                        aCellView.load(scheduleTitle: aTitle)
                    }
                    aReturnVal = aCellView
                case .components:
                    let aCellView :ScheduleComponentTableCellView = pTableView.dequeueReusableCell(withIdentifier: "ScheduleComponentTableCellViewId") as! ScheduleComponentTableCellView
                    aCellView.valueTitlelbl.text = "If:"
                    aCellView.delegate = self
                    aCellView.selectionStyle = UITableViewCell.SelectionStyle.default
                    aCellView.load(rooms: self.editedScheduleRooms ?? self.schedule?.rooms)
                    aReturnVal = aCellView
                case .time:
                    let aCellView :ScheduleComponentTableCellView = pTableView.dequeueReusableCell(withIdentifier: "ScheduleComponentTableCellViewId") as! ScheduleComponentTableCellView
                    aCellView.valueTitlelbl.text = "Then:"
                    aCellView.valueLabel.text = "Please Select"
                    aCellView.lblAllcondbtn.isHidden = true
                    aCellView.lblAnyCondBtn.isHidden = true
                    aCellView.selectionStyle = UITableViewCell.SelectionStyle.default
                    aCellView.load(rooms: self.editedScheduleRoomsThen ?? self.schedule?.rooms)
                    aReturnVal = aCellView
                case .repeatDays:
                    let aCellView :ScheduleTimeerTableCellView = pTableView.dequeueReusableCell(withIdentifier: "ScheduleTimeerTableCellView") as! ScheduleTimeerTableCellView
                    if editedScheduleRoomsThen?.count ?? 0 > 0{
                        aCellView.load(obj: self.editedScheduleRoomsThen ?? self.schedule?.rooms)
                      }
                    aCellView.delegate = self
                    aCellView.selectionStyle = UITableViewCell.SelectionStyle.default
                    aReturnVal = aCellView
                }
            }
        }
        
        if aReturnVal == nil {
            aReturnVal = UITableViewCell()
        }
        return aReturnVal!
    }
    
    
    /**
     * Method that will be called when user selects a table cell.
     */
    func tableView(_ pTableView: UITableView, didSelectRowAt pIndexPath: IndexPath) {
        pTableView.deselectRow(at: pIndexPath, animated: true)
        
        if pTableView.isEqual(self.newScheduleTableView)
            , pIndexPath.row < self.cellTypes.count{
            let aCellType = self.cellTypes[pIndexPath.row]
            if aCellType == CellType.components{
                callType = aCellType
                SelectComponentController.ApplianceType = "If"
                RoutingManager.shared.gotoSelectRoom(controller: self, shouldIfConditionAddRoom: true, shouldThenConditionAddRoom: false, roomSelectionType: SelectRoomController.SelectionType.components, delegate: self, shouldAllowAddRoom: false, selectedRooms: self.editedScheduleRooms ?? self.schedule?.rooms)
            }else if aCellType == CellType.time{
                callType = aCellType
                SelectComponentController.ApplianceType = "Then"
                RoutingManager.shared.gotoSelectRoom(controller: self, shouldIfConditionAddRoom: false, shouldThenConditionAddRoom: true, roomSelectionType: SelectRoomController.SelectionType.components, delegate: self, shouldAllowAddRoom: false, selectedRooms: self.editedScheduleRoomsThen ?? self.schedule?.rooms)
            }else if aCellType == CellType.repeatDays{
                print("Optional setting")
                newScheduleTableView.reloadRows(at: [pIndexPath], with: UITableView.RowAnimation.automatic)
                
            }
        }
    }
}
extension CreateNewCoreViewController : ScheduleTitleTableCellViewDelegate {
    func scheduleTitleTableCellView(_ pSender: ScheduleTitleTableCellView, didChangeValue pValue: String?) {
        self.editedScheduleTitle = pValue
    }
}
extension CreateNewCoreViewController :SelectRoomControllerDelegate {
    
    func selectRoomController(_ pSender: SelectRoomController, didSelectRooms pRoomArray: Array<Room>?) {
        if callType == CellType.components{
            self.editedScheduleRooms = pRoomArray
        }else if callType == CellType.time{
            self.editedScheduleRoomsThen = pRoomArray
        }
        self.reloadAllView()
        
        RoutingManager.shared.goBackToController(self)
    }
    
}
extension CreateNewCoreViewController: conditioncheckedComponant, createCoreProtocols{
    func cellView(timer: String, tag: Int) {
        if tag == 1{
            NewCore.from = timer
        }else{
            NewCore.to = timer
        }
    }
    
    func cellView(timerDuration: String) {
        NewCore.duration = timerDuration
    }
    
    func conditioncheckedComponant(pValue: String) {
        NewCore.Operator = pValue
    }
}
// MARK: - EDIT CORE SETUP
extension CreateNewCoreViewController{
    //    func editCoreSetUp(){
    //        if NewCore != nil{
    //            var editedRooms :Room?
    //            self.editedScheduleTitle = NewCore?.ruleName
    //            editedRooms?.title = NewCore?.coreEditData?.whenSelectionList?.first?.roomName
    //            editedRooms?.id = NewCore?.coreEditData?.whenSelectionList?.first?.roomId
    //            var aAppliances :Array<applianeslist>? = Array<applianeslist>()
    //             if let ifdata = NewCore?.coreEditData?.whenSelectionList{
    //                var pAppliances :Array<applianeslist> = Array<applianeslist>()
    //                for item in ifdata{
    //                    var pAppliance :Appliance?
    //                    if item.routineType == "switch"{
    //                        pAppliance?.id = item.appId
    //                //        pAppliance?.name = item.appName
    //                //        pAppliance?.checked = item.checked!
    //
    //
    //
    //                    }
    //                  //  pAppliances.append(pAppliance!)
    //                //    editedRooms?.appliances = pAppliances
    //
    //          }
    //
    //             //    editedScheduleRooms = pAppliance
    //            }
    //            if let thendata = NewCore?.coreEditData?.actionSelectionList{
    //              //  editedScheduleRooms = ifdata
    //            }
    //        }
    //        self.reloadAllView()
    //    }
}
//clock

struct ContentView: View {
    @State private var clockStyle: ClockStyle = .classic
    
    var body: some View {
        ClockView().environment(\.clockStyle, clockStyle)
    }
}
