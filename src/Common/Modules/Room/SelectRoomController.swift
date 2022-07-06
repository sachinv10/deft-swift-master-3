//
//  SelectRoomController.swift
//  DEFT
//
//  Created by Rupendra on 17/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SelectRoomController: BaseController {
    @IBOutlet weak var newRoomView: UIView!
    @IBOutlet weak var roomTitleTextField: UITextField!
    
    @IBOutlet weak var roomTableViewTopLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var roomTableView: AppTableView!
    
    var rooms :Array<Room> = Array<Room>()
    
    weak var delegate :SelectRoomControllerDelegate?
    
    var selectedRooms :Array<Room> = Array<Room>()
    
    var selectionType :SelectionType = SelectionType.components
    
    var shouldAllowAddRoom = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "SELECT ROOM"
        self.subTitle = nil
        
        if self.shouldAllowAddRoom {
            self.roomTableViewTopLayoutConstraint.constant = self.newRoomView.frame.height
        } else {
            self.roomTableViewTopLayoutConstraint.constant = 0.0
        }
        
        self.setup()
    }
    
    
    override func reloadAllData() {
        super.reloadAllData()
        
        self.searchRoom()
    }
    
    
    func setup() {
        self.roomTitleTextField.delegate = self
    }
    
    
    func reloadAllView() {
        self.roomTableView.reloadData()
    }
    
    
    func searchRoom() {
        DataFetchManager.shared.searchRoom(completion: { (pError, pRemoteArray) in
            if pRemoteArray != nil && pRemoteArray!.count > 0 {
                self.rooms = pRemoteArray!
            }
            self.roomTableView.reloadData()
        })
    }
    
    
    func saveRoom(room pRoom :Room) {
        let aRoom = pRoom.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.saveRoom(completion: { (pError, pRoom) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not save room.", description: pError!.localizedDescription)
            } else {
                aRoom.id = pRoom?.id
                self.reloadAllData()
                PopupManager.shared.displaySuccess(message: "Room saved successfully.", description: nil, completion: nil)
            }
        }, room: aRoom)
    }
    
    
    func saveRoom() {
        do {
            let aTitle :String? = self.roomTitleTextField.text
            if (aTitle?.count ?? 0) <= 0 {
                throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Please provide room title."])
            }
            
            let aRoom = Room()
            aRoom.title = aTitle
            self.saveRoom(room: aRoom)
        } catch {
            PopupManager.shared.displayError(message: error.localizedDescription, description: nil)
        }
    }
    
    
    enum SelectionType {
        case room
        case components
    }
    
}


extension SelectRoomController :UITextFieldDelegate {
    
    func textFieldShouldReturn(_ pTextField: UITextField) -> Bool {
        if pTextField.isEqual(self.roomTitleTextField) {
            self.view.endEditing(true)
        }
        return true
    }
    
}


extension SelectRoomController {
    
    @IBAction func didSelectDoneButton(_ pSender: UIButton?) {
        self.delegate?.selectRoomController(self, didSelectRooms: self.selectedRooms.count > 0 ? self.selectedRooms : nil)
    }
    
    @IBAction func didSelectAddRoomButton(_ pSender: UIButton?) {
        self.saveRoom()
    }
    
}



extension SelectRoomController :UITableViewDataSource, UITableViewDelegate {
    
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
            aReturnVal = self.rooms.count
        }
        
        return aReturnVal
    }
    
    
    /**
     * Method that will calculate and return height of row at given index path of the table.
     * @return CGFloat. Height of the row at given index path
     */
    func tableView(_ pTableView: UITableView, heightForRowAt pIndexPath: IndexPath) -> CGFloat {
        var aReturnVal :CGFloat = UITableView.automaticDimension
        aReturnVal = SelectRoomTableCellView.cellHeight()
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
        
        if pTableView.isEqual(self.roomTableView) {
            if pIndexPath.row < self.rooms.count {
                let aRoom = self.rooms[pIndexPath.row]
                
                let aSelectedRoom = self.selectedRooms.first { (pRoom) -> Bool in
                    return pRoom.id == aRoom.id
                }
                var aSelectedComponentCount = (aSelectedRoom?.appliances?.count ?? 0)
                aSelectedComponentCount += (aSelectedRoom?.curtains?.count ?? 0)
                if let aRemoteArray = aSelectedRoom?.remotes {
                    for aRemote in aRemoteArray {
                        aSelectedComponentCount += (aRemote.selectedRemoteKeys?.count ?? 0)
                    }
                }
                aSelectedComponentCount += (aSelectedRoom?.sensors?.count ?? 0)
                
                let aCellView :SelectRoomTableCellView = pTableView.dequeueReusableCell(withIdentifier: "SelectRoomTableCellViewId") as! SelectRoomTableCellView
                aCellView.load(room: aRoom, selectedComponentCount: aSelectedComponentCount)
                aCellView.shouldHideDisclosureIndicator = self.selectionType == SelectionType.room
                aReturnVal = aCellView
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
        
        if pIndexPath.row < self.rooms.count {
            if self.selectionType == SelectionType.room {
                if self.rooms.count > pIndexPath.row {
                    let aRoom = self.rooms[pIndexPath.row]
                    self.delegate?.selectRoomController(self, didSelectRooms: [aRoom])
                }
            } else {
                let aRoom = self.rooms[pIndexPath.row]
                var aRoomIndex :Int?
                for (anIndex, anEachRoom) in self.selectedRooms.enumerated() {
                    if anEachRoom.id == aRoom.id {
                        aRoomIndex = anIndex
                    }
                }
                if let aSelectedRoomIndex = aRoomIndex {
                    let aSelectedRoom = self.selectedRooms[aSelectedRoomIndex]
                    aRoom.appliances = aSelectedRoom.appliances
                    aRoom.curtains = aSelectedRoom.curtains
                    aRoom.remotes = aSelectedRoom.remotes
                    aRoom.sensors = aSelectedRoom.sensors
                }
                RoutingManager.shared.gotoSelectComponent(controller: self, componentTypes: [.appliance, .curtain, .remoteKey, .sensor], selectedRoom: aRoom, delegate: self)
            }
        }
    }
    
}


extension SelectRoomController :SelectComponentControllerDelegate {
    
    func selectComponentControllerDidSelect(room pRoom :Room, appliances pApplianceArray :Array<Appliance>?, curtains pCurtaineArray :Array<Curtain>?, remotes pRemoteArray :Array<Remote>?, moodOnRemotes pMoodOnRemoteArray :Array<Remote>?, moodOffRemotes pMoodOffRemoteArray :Array<Remote>?, sensors pSensorArray :Array<Sensor>?) {
        let aRoom = Room()
        aRoom.id = pRoom.id
        aRoom.title = pRoom.title
        aRoom.appliances = pApplianceArray
        aRoom.curtains = pCurtaineArray
        aRoom.remotes = pRemoteArray
        aRoom.moodOnRemotes = pMoodOnRemoteArray
        aRoom.moodOffRemotes = pMoodOffRemoteArray
        aRoom.sensors = pSensorArray
        
        var aRoomIndex :Int?
        for (anIndex, anEachRoom) in self.selectedRooms.enumerated() {
            if anEachRoom.id == pRoom.id {
                aRoomIndex = anIndex
            }
        }
        if let aSelectedRoomIndex = aRoomIndex {
            self.selectedRooms[aSelectedRoomIndex] = aRoom
        } else {
            self.selectedRooms.append(aRoom)
        }
        
        self.reloadAllView()
        
        RoutingManager.shared.goBackToController(self)
    }
    
}

protocol SelectRoomControllerDelegate :AnyObject {
    func selectRoomController(_ pSender :SelectRoomController, didSelectRooms pRoomArray :Array<Room>?)
}
