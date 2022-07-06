//
//  SearchDeviceController.swift
//  DEFT
//
//  Created by Rupendra on 08/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SearchDeviceController: BaseController {
    @IBOutlet weak var deviceTableView: AppTableView!
    
    var devices :Array<Device> = Array<Device>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ConfigurationManager.shared.appType == ConfigurationManager.AppType.wifinity {
            self.title = "DEVICES"
        } else {
            self.title = "CONTROLLERS"
        }
        self.subTitle = nil
        
        self.deviceTableView.tableFooterView = UIView()
        self.deviceTableView.delaysContentTouches = false
    }
    
    
    override func reloadAllData() {
        self.devices.removeAll()
        
        self.searchDevice()
    }
    
    
    func reloadAllView() {
        if self.devices.count <= 0 {
            self.deviceTableView.display(message: "No Device Available")
        } else {
            self.deviceTableView.hideMessage()
        }
        self.deviceTableView.reloadData()
    }
    
    
    private func searchDevice() {
        // ProgressOverlay.shared.show()
        DataFetchManager.shared.searchDevice(completion: { (pError, pDeviceArray) in
            // ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not search devices", description: pError!.localizedDescription)
            } else {
                if pDeviceArray != nil && pDeviceArray!.count > 0 {
                    self.devices = pDeviceArray!
                }
                self.reloadAllView()
            }
        }, room: nil, hardwareTypes: nil)
    }
    
}



extension SearchDeviceController :UITableViewDataSource, UITableViewDelegate {
    
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
            aReturnVal = self.devices.count
        }
        
        return aReturnVal
    }
    
    
    /**
     * Method that will calculate and return height of row at given index path of the table.
     * @return CGFloat. Height of the row at given index path
     */
    func tableView(_ pTableView: UITableView, heightForRowAt pIndexPath: IndexPath) -> CGFloat {
        let aReturnVal :CGFloat = SearchDeviceTableCellView.cellHeight()
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
        
        if pTableView.isEqual(self.deviceTableView) {
            if pIndexPath.row < self.devices.count {
                let aDevice = self.devices[pIndexPath.row]
                let aCellView :SearchDeviceTableCellView = pTableView.dequeueReusableCell(withIdentifier: "SearchDeviceTableCellViewId") as! SearchDeviceTableCellView
                aCellView.load(device: aDevice)
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
