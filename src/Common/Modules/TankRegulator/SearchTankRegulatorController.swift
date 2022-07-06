//
//  SearchTankRegulatorController.swift
//  DEFT
//
//  Created by Rupendra on 08/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SearchTankRegulatorController: BaseController {
    @IBOutlet weak var tankRegulatorTableView: AppTableView!
    
    var tankRegulators :Array<TankRegulator> = Array<TankRegulator>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "WATER LEVEL CONTROLLERS"
        self.subTitle = nil
        
        self.tankRegulatorTableView.tableFooterView = UIView()
        self.tankRegulatorTableView.delaysContentTouches = false
    }
    
    
    override func reloadAllData() {
        self.tankRegulators.removeAll()
        
        self.searchTankRegulator()
    }
    
    
    func reloadAllView() {
        if self.tankRegulators.count <= 0 {
            self.tankRegulatorTableView.display(message: "No Data Available")
        } else {
            self.tankRegulatorTableView.hideMessage()
        }
        self.tankRegulatorTableView.reloadData()
    }
    
    
    private func searchTankRegulator() {
        // ProgressOverlay.shared.show()
        DataFetchManager.shared.searchTankRegulator(completion: { (pError, pTankRegulatorArray) in
            // ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not search water level controllers", description: pError!.localizedDescription)
            } else {
                if pTankRegulatorArray != nil && pTankRegulatorArray!.count > 0 {
                    self.tankRegulators = pTankRegulatorArray!
                }
                self.reloadAllView()
            }
        })
    }
    
    
    func updateTankRegulatorAutoMode(tankRegulator pTankRegulator :TankRegulator, autoMode pAutoMode :Bool) {
        let aTankRegulator = pTankRegulator.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateTankRegulatorAutoMode(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update sensor.", description: pError!.localizedDescription)
            } else {
                self.reloadAllView()
            }
        }, tankRegulator: aTankRegulator, autoMode: pAutoMode)
    }
    
    
    func updateTankRegulatorMotorPowerState(tankRegulator pTankRegulator :TankRegulator, motorPowerState pMotorPowerState :Bool) {
        let aTankRegulator = pTankRegulator.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateTankRegulatorMotorPowerState(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update sensor.", description: pError!.localizedDescription)
            } else {
                self.reloadAllView()
            }
        }, tankRegulator: aTankRegulator, motorPowerState: pMotorPowerState)
    }
    
    
    func updateTankRegulatorSync(tankRegulator pTankRegulator :TankRegulator) {
        let aTankRegulator = pTankRegulator.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateTankRegulatorSync(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not sync tank regulator.", description: pError!.localizedDescription)
            } else {
                self.reloadAllView()
            }
        }, tankRegulator: aTankRegulator)
    }
    
}


extension SearchTankRegulatorController :SearchTankRegulatorTableCellViewDelegate {
    
    func cellView(_ pSender: SearchTankRegulatorTableCellView, didChangeAutoMode pAutoMode: Bool) {
        if let anIndexPath = self.tankRegulatorTableView.indexPath(for: pSender), anIndexPath.row < self.tankRegulators.count {
            let aTankRegulator = self.tankRegulators[anIndexPath.row]
            self.updateTankRegulatorAutoMode(tankRegulator: aTankRegulator, autoMode: pAutoMode)
        }
    }
    
    func cellView(_ pSender: SearchTankRegulatorTableCellView, didChangeMotorState pMotorState: Bool) {
        if let anIndexPath = self.tankRegulatorTableView.indexPath(for: pSender), anIndexPath.row < self.tankRegulators.count {
            let aTankRegulator = self.tankRegulators[anIndexPath.row]
            self.updateTankRegulatorMotorPowerState(tankRegulator: aTankRegulator, motorPowerState: pMotorState)
        }
    }
    
    func cellViewDidSelectSync(_ pSender: SearchTankRegulatorTableCellView) {
        if let anIndexPath = self.tankRegulatorTableView.indexPath(for: pSender), anIndexPath.row < self.tankRegulators.count {
            let aTankRegulator = self.tankRegulators[anIndexPath.row]
            self.updateTankRegulatorSync(tankRegulator: aTankRegulator)
        }
    }
    
}


extension SearchTankRegulatorController :UITableViewDataSource, UITableViewDelegate {
    
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
            aReturnVal = self.tankRegulators.count
        }
        
        return aReturnVal
    }
    
    
    /**
     * Method that will calculate and return height of row at given index path of the table.
     * @return CGFloat. Height of the row at given index path
     */
    func tableView(_ pTableView: UITableView, heightForRowAt pIndexPath: IndexPath) -> CGFloat {
        let aReturnVal :CGFloat = SearchTankRegulatorTableCellView.cellHeight()
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
        
        if pTableView.isEqual(self.tankRegulatorTableView) {
            if pIndexPath.row < self.tankRegulators.count {
                let aTankRegulator = self.tankRegulators[pIndexPath.row]
                let aCellView :SearchTankRegulatorTableCellView = pTableView.dequeueReusableCell(withIdentifier: "SearchTankRegulatorTableCellViewId") as! SearchTankRegulatorTableCellView
                aCellView.delegate = self
                aCellView.load(tankRegulator: aTankRegulator)
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
    }
    
}
