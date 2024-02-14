//
//  NewScheduleController.swift
//  DEFT
//
//  Created by Rupendra on 08/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class NewScheduleController: BaseController {
    @IBOutlet weak var newScheduleTableView: UITableView!
    
    var cellTypes :Array<CellType> = Array<CellType>()
    
    var schedule :Schedule?
    
    weak var delegate :NewScheduleControllerDelegate?
    
    var editedScheduleTitle :String?
    var editedScheduleRooms :Array<Room>?
    var editedScheduleTime :String?
    var editedScheduleRepetitions :Array<Schedule.Day>?
    var repetedOnce: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.schedule != nil ? "SCHEDULE DETAILS" : "NEW SCHEDULE"
        self.subTitle = self.schedule?.title
        
        self.newScheduleTableView.dataSource = self
        self.newScheduleTableView.delegate = self
        self.newScheduleTableView.tableFooterView = UIView()
        self.newScheduleTableView.delaysContentTouches = true
    }
    
    
    override func reloadAllData() {
        self.scheduleDetails()
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
    
    
    func saveSchedule(schedule pSchedule :Schedule) {
        let aSchedule = pSchedule.clone()
         ProgressOverlay.shared.show()
        DataFetchManager.shared.saveSchedule(completion: { (pError, pSchedule) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not save schedule.", description: pError!.localizedDescription)
            } else {
                aSchedule.id = pSchedule?.id
                aSchedule.uuid = pSchedule?.uuid
                self.schedule = aSchedule
                self.reloadAllView()
                PopupManager.shared.displaySuccess(message: "Schedule saved successfully.", description: nil, completion: {
                    self.delegate?.newScheduleControllerDidDone(self)
                })
            }
        }, schedule: aSchedule)
    }
    
    
    func saveSchedule() {
        do {
            let aTitle = self.editedScheduleTitle ?? self.schedule?.title
            if (aTitle?.count ?? 0) <= 0 {
                throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Please provide title."])
            }
            
            let aRooms = self.editedScheduleRooms ?? self.schedule?.rooms
            if aRooms?.count ?? 0 <= 0{
                throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Please select appliances"])
            }
            
            let days = self.editedScheduleRepetitions ?? self.schedule?.repetitions
            if days?.count ?? 0 <= 0{
                throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Please select day"])
            }
            
            var aTime = self.editedScheduleTime ?? self.schedule?.time
            if (aTime?.count ?? 0) <= 0 {
                let aDateFormatter = DateFormatter()
                aDateFormatter.dateFormat = "HH:mm"
                aTime = aDateFormatter.string(from: Date())
            }
            if (aTime?.count ?? 0) <= 0 {
                throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Please provide time."])
            }
            
            let aRepetitions = self.editedScheduleRepetitions ?? self.schedule?.repetitions
            
            let aSchedule = self.schedule?.clone() ?? Schedule()
            aSchedule.title = aTitle
            aSchedule.rooms = aRooms
            aSchedule.time = aTime
            aSchedule.repetitions = aRepetitions
            aSchedule.repeatOnce = repetedOnce
            self.saveSchedule(schedule: aSchedule)
        } catch {
            PopupManager.shared.displayError(message: error.localizedDescription, description: nil)
        }
    }
}



extension NewScheduleController {
    
    @IBAction func didSelectDoneButton(_ pSender: UIButton?) {
        self.saveSchedule()
    }
    
}


extension NewScheduleController :UITableViewDataSource, UITableViewDelegate {
    
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
                    aCellView.selectionStyle = UITableViewCell.SelectionStyle.default
                    aCellView.load(rooms: self.editedScheduleRooms ?? self.schedule?.rooms)
                    aReturnVal = aCellView
                case .time:
                    let aCellView :ScheduleTimeTableCellView = pTableView.dequeueReusableCell(withIdentifier: "ScheduleTimeTableCellViewId") as! ScheduleTimeTableCellView
                    aCellView.delegate = self
                    aCellView.selectionStyle = UITableViewCell.SelectionStyle.none
                    if let aTime = self.editedScheduleTime {
                        aCellView.load(scheduleTime: aTime)
                    } else if let aTime = self.schedule?.time {
                        aCellView.load(scheduleTime: aTime)
                    }
                    aReturnVal = aCellView
                case .repeatDays:
                    let aCellView :ScheduleRepeatTableCellView = pTableView.dequeueReusableCell(withIdentifier: "ScheduleRepeatTableCellViewId") as! ScheduleRepeatTableCellView
                    aCellView.delegate = self
                    aCellView.selectionStyle = UITableViewCell.SelectionStyle.none
                    if let aRepetitionArray = self.editedScheduleRepetitions {
                        aCellView.load(scheduleDays: aRepetitionArray, scheduler: repetedOnce)
                    } else if let aRepetitionArray = self.schedule?.repetitions {
                        aCellView.load(scheduleDays: aRepetitionArray, scheduler: schedule?.repeatOnce ?? false)
                    }
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
            if aCellType == CellType.components {
                RoutingManager.shared.gotoSelectRoom(controller: self, shouldIfConditionAddRoom: false, shouldThenConditionAddRoom: false, roomSelectionType: SelectRoomController.SelectionType.components, delegate: self, shouldAllowAddRoom: false, selectedRooms: self.editedScheduleRooms ?? self.schedule?.rooms)
            }
        }
    }
}



extension NewScheduleController :SelectRoomControllerDelegate {
    
    func selectRoomController(_ pSender: SelectRoomController, didSelectRooms pRoomArray: Array<Room>?) {
        self.editedScheduleRooms = pRoomArray
        self.reloadAllView()
        RoutingManager.shared.goBackToController(self)
    }
}


extension NewScheduleController : ScheduleTitleTableCellViewDelegate {
    func scheduleTitleTableCellView(_ pSender: ScheduleTitleTableCellView, didChangeValue pValue: String?) {
        self.editedScheduleTitle = pValue
    }
}


extension NewScheduleController : ScheduleTimeTableCellViewDelegate {
    
    func scheduleTimeTableCellView(_ pSender: ScheduleTimeTableCellView, didChangeValue pValue: Date?) {
        if let aDate = pValue {
            let aDateFormatter = DateFormatter()
            aDateFormatter.dateFormat = "HH:mm"
            self.editedScheduleTime = aDateFormatter.string(from: aDate)
        } else {
            self.editedScheduleTime = nil
        }
    }
    
}


extension NewScheduleController : ScheduleRepeatTableCellViewDelegate {
    
    func scheduleRepeatTableCellView(_ pSender: ScheduleRepeatTableCellView, didChangeValue pValue: Array<Schedule.Day>?) {
        repetedOnce = pSender.repeatOncebtn.isOn
        self.editedScheduleRepetitions = pValue
    }
    
}


protocol NewScheduleControllerDelegate :AnyObject {
    func newScheduleControllerDidDone(_ pSender :NewScheduleController)
}
