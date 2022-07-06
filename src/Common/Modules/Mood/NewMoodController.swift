//
//  NewMoodController.swift
//  DEFT
//
//  Created by Rupendra on 08/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class NewMoodController: BaseController {
    @IBOutlet weak var newMoodTableView: UITableView!
    
    var cellTypes :Array<CellType> = Array<CellType>()
    
    var mood :Mood?
    
    var editedMoodTitle :String?
    var editedMoodRoom :Room? // Used for new-mood flow
    
    weak var delegate :NewMoodControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.mood != nil ? "MOOD DETAILS" : "NEW MOOD"
        self.subTitle = self.mood?.title
        
        self.newMoodTableView.dataSource = self
        self.newMoodTableView.delegate = self
        self.newMoodTableView.tableFooterView = UIView()
        self.newMoodTableView.delaysContentTouches = true
    }
    
    
    override func reloadAllData() {
        self.moodDetails()
    }
    
    
    func moodDetails() {
        if let aMood = self.mood {
            // ProgressOverlay.shared.show()
            DataFetchManager.shared.moodDetails(completion: { (pError, pMood) in
                // ProgressOverlay.shared.hide()
                if pError != nil {
                    PopupManager.shared.displayError(message: "Can not fetch mood details.", description: pError!.localizedDescription)
                } else {
                    self.mood = pMood
                    self.reloadAllView()
                }
            }, mood: aMood)
        } else {
            self.reloadAllView()
        }
    }
    
    
    func reloadAllView() {
        self.cellTypes.removeAll()
        
        self.cellTypes.append(.title)
        self.cellTypes.append(.components)
        
        self.newMoodTableView.reloadData()
    }
    
    
    enum CellType :String {
        case title = "Mood Name"
        case components = "Components"
    }
    
    
    func saveMood(mood pMood :Mood) {
        let aMood = pMood.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.saveMood(completion: { (pError, pMood) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not save mood.", description: pError!.localizedDescription)
            } else {
                aMood.id = pMood?.id
                aMood.uuid = pMood?.uuid
                self.mood = aMood
                self.reloadAllView()
                PopupManager.shared.displaySuccess(message: "Mood saved successfully.", description: nil, completion: {
                    self.delegate?.newMoodControllerDidDone(self)
                })
            }
        }, mood: aMood)
    }
    
    
    func saveMood() {
        do {
            let aTitle = self.editedMoodTitle ?? self.mood?.title
            if (aTitle?.count ?? 0) <= 0 {
                throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Please provide title."])
            }
            
            let aRoom = self.editedMoodRoom ?? self.mood?.room
            
            let aMood = self.mood?.clone() ?? Mood()
            aMood.title = aTitle
            aMood.room = aRoom
            self.saveMood(mood: aMood)
        } catch {
            PopupManager.shared.displayError(message: error.localizedDescription, description: nil)
        }
    }
    
}



extension NewMoodController {
    
    @IBAction func didSelectDoneButton(_ pSender: UIButton?) {
        self.saveMood()
    }
    
}


extension NewMoodController :UITableViewDataSource, UITableViewDelegate {
    
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
        
        if pTableView.isEqual(self.newMoodTableView) {
            if pIndexPath.row < self.cellTypes.count {
                let aCellType = self.cellTypes[pIndexPath.row]
                switch aCellType {
                case .title:
                    let aCellView :MoodTitleTableCellView = pTableView.dequeueReusableCell(withIdentifier: "MoodTitleTableCellViewId") as! MoodTitleTableCellView
                    aCellView.delegate = self
                    aCellView.selectionStyle = UITableViewCell.SelectionStyle.none
                    if let aTitle = self.editedMoodTitle {
                        aCellView.load(moodTitle: aTitle)
                    } else if let aTitle = self.mood?.title {
                        aCellView.load(moodTitle: aTitle)
                    }
                    aReturnVal = aCellView
                case .components:
                    let aCellView :MoodComponentTableCellView = pTableView.dequeueReusableCell(withIdentifier: "MoodComponentTableCellViewId") as! MoodComponentTableCellView
                    aCellView.selectionStyle = UITableViewCell.SelectionStyle.default
                    aCellView.load(room: self.editedMoodRoom ?? self.mood?.room)
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
        
        if pTableView.isEqual(self.newMoodTableView)
           , pIndexPath.row < self.cellTypes.count{
            let aCellType = self.cellTypes[pIndexPath.row]
            if aCellType == CellType.components {
                if let aRoom = self.mood?.room {
                    RoutingManager.shared.gotoSelectComponent(controller: self, componentTypes: [.appliance, .curtain, .remoteKeyMoodOn, .remoteKeyMoodOff], selectedRoom: aRoom, delegate: self)
                } else if let aRoom = self.editedMoodRoom {
                    RoutingManager.shared.gotoSelectComponent(controller: self, componentTypes: [.appliance, .curtain, .remoteKeyMoodOn, .remoteKeyMoodOff], selectedRoom: aRoom, delegate: self)
                }
            }
        }
    }
    
}



extension NewMoodController :SelectComponentControllerDelegate {
    func selectComponentControllerDidSelect(room pRoom :Room, appliances pApplianceArray :Array<Appliance>?, curtains pCurtaineArray :Array<Curtain>?, remotes pRemoteArray :Array<Remote>?, moodOnRemotes pMoodOnRemoteArray :Array<Remote>?, moodOffRemotes pMoodOffRemoteArray :Array<Remote>?, sensors pSensorArray :Array<Sensor>?) {
        let aRoom = Room()
        aRoom.id = pRoom.id
        aRoom.title = pRoom.title
        aRoom.appliances = pApplianceArray
        aRoom.curtains = pCurtaineArray
        aRoom.remotes = pRemoteArray
        aRoom.moodOnRemotes = pMoodOnRemoteArray
        aRoom.moodOffRemotes = pMoodOffRemoteArray
        aRoom.sensors = nil
        self.editedMoodRoom = aRoom
        
        self.reloadAllView()
        
        RoutingManager.shared.goBackToController(self)
    }
    
}


extension NewMoodController : MoodTitleTableCellViewDelegate {
    func moodTitleTableCellView(_ pSender: MoodTitleTableCellView, didChangeValue pValue: String?) {
        self.editedMoodTitle = pValue
    }
}


protocol NewMoodControllerDelegate :AnyObject {
    func newMoodControllerDidDone(_ pSender :NewMoodController)
}
