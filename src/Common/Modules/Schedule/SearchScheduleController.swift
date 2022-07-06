//
//  SearchScheduleController.swift
//  DEFT
//
//  Created by Rupendra on 08/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SearchScheduleController: BaseController {
    @IBOutlet weak var scheduleTableView: AppTableView!
    @IBOutlet weak var addButton: AppFloatingButton!
    
    var schedules :Array<Schedule> = Array<Schedule>()
    var selecedSchedule :Schedule?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "SCHEDULES"
        self.subTitle = nil
        
        self.scheduleTableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.scheduleTableView.frame.size.width, height: 80.0))
        self.scheduleTableView.delaysContentTouches = false
    }
    
    
    override func reloadAllData() {
        self.schedules.removeAll()
        
        self.searchSchedule()
    }
    
    
    func reloadAllView() {
        if self.schedules.count <= 0 {
            self.scheduleTableView.display(message: "No Schedule Available")
        } else {
            self.scheduleTableView.hideMessage()
        }
        self.scheduleTableView.reloadData()
    }
    
    
    private func searchSchedule() {
        // ProgressOverlay.shared.show()
        DataFetchManager.shared.searchSchedule(completion: { (pError, pScheduleArray) in
            // ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not search schedules", description: pError!.localizedDescription)
            } else {
                if pScheduleArray != nil && pScheduleArray!.count > 0 {
                    self.schedules = pScheduleArray!
                }
                self.reloadAllView()
            }
        })
    }
    
    
    func updateSchedulePowerState(schedule pSchedule :Schedule, powerState pPowerState :Bool) {
        let aSchedule = pSchedule.clone()
        aSchedule.isOn = pPowerState
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateSchedulePowerState(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update schedule.", description: pError!.localizedDescription)
            } else {
                pSchedule.isOn = pPowerState
                self.reloadAllView()
            }
        }, schedule: aSchedule, powerState: pPowerState)
    }
    
    
    private func deleteSchedule(schedule pSchedule :Schedule) {
        let aSchedule = pSchedule.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.deleteSchedule(completion: { (pError, pSchedule) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not delete schedule.", description: pError!.localizedDescription)
            } else {
                PopupManager.shared.displaySuccess(message: "Schedule deleted successfully.", description: nil, completion: nil)
                self.reloadAllData()
            }
        }, schedule: aSchedule)
    }
    
}



extension SearchScheduleController {
    
    @IBAction func didSelectAddButton(_ pSender: AppFloatingButton?) {
        RoutingManager.shared.gotoNewSchedule(controller: self, delegate: self)
    }
    
}



extension SearchScheduleController :UITableViewDataSource, UITableViewDelegate {
    
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
            aReturnVal = self.schedules.count
        }
        
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
        
        if pTableView.isEqual(self.scheduleTableView) {
            if pIndexPath.row < self.schedules.count {
                let aSchedule = self.schedules[pIndexPath.row]
                let aCellView :SearchScheduleTableCellView = pTableView.dequeueReusableCell(withIdentifier: "SearchScheduleTableCellViewId") as! SearchScheduleTableCellView
                aCellView.load(schedule: aSchedule)
                aCellView.delegate = self
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
        if pIndexPath.row < self.schedules.count {
            let aSelecedSchedule = self.schedules[pIndexPath.row]
            RoutingManager.shared.gotoScheduleDetails(controller: self, selectedSchedule: aSelecedSchedule, delegate: self)
        }
    }
    
    
    func tableView(_ pTableView: UITableView, commit pEditingStyle: UITableViewCell.EditingStyle, forRowAt pIndexPath: IndexPath) {
        if pEditingStyle == .delete {
            if pIndexPath.row < self.schedules.count {
                let aSchedule = self.schedules[pIndexPath.row]
                PopupManager.shared.displayConfirmation(message: "Do you want to delete selected schedule?", description: nil, completion: {
                    self.deleteSchedule(schedule: aSchedule)
                })
            }
        }
    }
    
}



extension SearchScheduleController :SearchScheduleTableCellViewDelegate {
    
    func cellView(_ pSender: SearchScheduleTableCellView, didChangePowerState pPowerState: Bool) {
        if let anIndexPath = self.scheduleTableView.indexPath(for: pSender), anIndexPath.row < self.schedules.count {
            let aSchedule = self.schedules[anIndexPath.row]
            self.updateSchedulePowerState(schedule: aSchedule, powerState: pPowerState)
        }
    }
    
}


extension SearchScheduleController :NewScheduleControllerDelegate {
    
    func newScheduleControllerDidDone(_ pSender: NewScheduleController) {
        RoutingManager.shared.goBackToController(self)
        self.reloadAllData()
    }
    
}
