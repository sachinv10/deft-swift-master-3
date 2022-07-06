//
//  SelectDeviceController.swift
//  Wifinity
//
//  Created by Rupendra on 17/01/21.
//

import UIKit

class SelectDeviceController: BaseController {
    @IBOutlet weak var deviceTableView: AppTableView!
    
    var devices :Array<Device> = Array<Device>()
    
    weak var delegate :SelectDeviceControllerDelegate?
    
    var room :Room?
    var hardwareTypes :Array<Device.HardwareType>?
    
    var shouldCheckForAddedApplianceCount :Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "SELECT DEVICE"
        self.subTitle = nil
    }
    
    
    override func reloadAllData() {
        super.reloadAllData()
        
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
    
    
    func searchDevice() {
        DataFetchManager.shared.searchDevice(completion: { (pError, pDeviceArray) in
            if pDeviceArray != nil && pDeviceArray!.count > 0 {
                self.devices = pDeviceArray!
            }
            self.reloadAllView()
        }, room: self.room, hardwareTypes: self.hardwareTypes)
    }
    
}



extension SelectDeviceController :UITableViewDataSource, UITableViewDelegate {
    
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
        var aReturnVal :CGFloat = UITableView.automaticDimension
        aReturnVal = SelectDeviceTableCellView.cellHeight()
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
            if pIndexPath.section == 0 {
                if pIndexPath.row < self.devices.count {
                    let aDevice = self.devices[pIndexPath.row]
                    let aCellView :SelectDeviceTableCellView = pTableView.dequeueReusableCell(withIdentifier: "SelectDeviceTableCellViewId") as! SelectDeviceTableCellView
                    aCellView.shouldCheckForAddedApplianceCount = self.shouldCheckForAddedApplianceCount
                    aCellView.load(device: aDevice)
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
        
        if pIndexPath.section == 0 {
            if pIndexPath.row < self.devices.count {
                let aDevice = self.devices[pIndexPath.row]
                if self.shouldCheckForAddedApplianceCount {
                    if (aDevice.addedAppliances?.count ?? 0) < (aDevice.switchCount ?? 0) {
                        self.delegate?.selectDeviceControllerDidSelect(self, device: aDevice)
                    } else {
                        PopupManager.shared.displayError(message: "This device / hardware is full. No more appliances can be added.", description: nil)
                    }
                } else {
                    self.delegate?.selectDeviceControllerDidSelect(self, device: aDevice)
                }
            }
        }
    }
    
}



protocol SelectDeviceControllerDelegate :AnyObject {
    func selectDeviceControllerDidSelect(_ pSender :SelectDeviceController, device pDevice :Device)
}
