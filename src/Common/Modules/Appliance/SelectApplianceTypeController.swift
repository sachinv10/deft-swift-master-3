//
//  SelectApplianceTypeController.swift
//  Wifinity
//
//  Created by Rupendra on 17/01/21.
//

import UIKit

class SelectApplianceTypeController: BaseController {
    @IBOutlet weak var applianceTypeTableView: AppTableView!
    
    var applianceTypeGroups :Array<ApplianceTypeGroup> = Array<ApplianceTypeGroup>()
    
    weak var delegate :SelectApplianceTypeControllerDelegate?
    
    
    class ApplianceTypeGroup {
        var applianceType :Appliance.ApplianceType?
        var ledStripType :Appliance.StripType?
        
        init(applianceType pApplianceType :Appliance.ApplianceType, ledStripType pLedStripType :Appliance.StripType? = nil) {
            self.applianceType = pApplianceType
            self.ledStripType = pLedStripType
        }
        
        var title :String {
            var aReturnVal = self.applianceType?.title ?? ""
            if let aStripTypeTitle = self.ledStripType?.title {
                aReturnVal += " (" + aStripTypeTitle + ")"
            }
            return aReturnVal
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Select Appliance Type"
        self.subTitle = nil
        
        self.searchApplianceType()
    }
    
    
    func searchApplianceType() {
        self.applianceTypeGroups.removeAll()
        
        self.applianceTypeGroups.append(ApplianceTypeGroup(applianceType: Appliance.ApplianceType.light))
        self.applianceTypeGroups.append(ApplianceTypeGroup(applianceType: Appliance.ApplianceType.fan))
        self.applianceTypeGroups.append(ApplianceTypeGroup(applianceType: Appliance.ApplianceType.tv))
        self.applianceTypeGroups.append(ApplianceTypeGroup(applianceType: Appliance.ApplianceType.refrigerator))
        self.applianceTypeGroups.append(ApplianceTypeGroup(applianceType: Appliance.ApplianceType.washingMachine))
        self.applianceTypeGroups.append(ApplianceTypeGroup(applianceType: Appliance.ApplianceType.geyser))
        self.applianceTypeGroups.append(ApplianceTypeGroup(applianceType: Appliance.ApplianceType.musicSystem))
        self.applianceTypeGroups.append(ApplianceTypeGroup(applianceType: Appliance.ApplianceType.sockets))
        self.applianceTypeGroups.append(ApplianceTypeGroup(applianceType: Appliance.ApplianceType.ac))
        self.applianceTypeGroups.append(ApplianceTypeGroup(applianceType: Appliance.ApplianceType.waterPump))
        self.applianceTypeGroups.append(ApplianceTypeGroup(applianceType: Appliance.ApplianceType.projector))
        self.applianceTypeGroups.append(ApplianceTypeGroup(applianceType: Appliance.ApplianceType.dvd))
        self.applianceTypeGroups.append(ApplianceTypeGroup(applianceType: Appliance.ApplianceType.setTopBox))
        self.applianceTypeGroups.append(ApplianceTypeGroup(applianceType: Appliance.ApplianceType.moodLight))
        self.applianceTypeGroups.append(ApplianceTypeGroup(applianceType: Appliance.ApplianceType.dummy))
        self.applianceTypeGroups.append(ApplianceTypeGroup(applianceType: Appliance.ApplianceType.ledStrip, ledStripType: Appliance.StripType.singleStrip))
        self.applianceTypeGroups.append(ApplianceTypeGroup(applianceType: Appliance.ApplianceType.ledStrip, ledStripType: Appliance.StripType.rgb))
        self.applianceTypeGroups.append(ApplianceTypeGroup(applianceType: Appliance.ApplianceType.ledStrip, ledStripType: Appliance.StripType.wc))
    }
    
}



extension SelectApplianceTypeController :UITableViewDataSource, UITableViewDelegate {
    
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
            aReturnVal = self.applianceTypeGroups.count
        }
        
        return aReturnVal
    }
    
    
    /**
     * Method that will calculate and return height of row at given index path of the table.
     * @return CGFloat. Height of the row at given index path
     */
    func tableView(_ pTableView: UITableView, heightForRowAt pIndexPath: IndexPath) -> CGFloat {
        var aReturnVal :CGFloat = UITableView.automaticDimension
        aReturnVal = SelectApplianceTypeTableCellView.cellHeight()
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
        
        if pTableView.isEqual(self.applianceTypeTableView) {
            if pIndexPath.section == 0 {
                if pIndexPath.row < self.applianceTypeGroups.count {
                    let anApplianceTypeGroup = self.applianceTypeGroups[pIndexPath.row]
                    let aCellView :SelectApplianceTypeTableCellView = pTableView.dequeueReusableCell(withIdentifier: "SelectApplianceTypeTableCellViewId") as! SelectApplianceTypeTableCellView
                    aCellView.load(applianceTypeGroup: anApplianceTypeGroup)
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
            if pIndexPath.row < self.applianceTypeGroups.count {
                let anApplianceTypeGroup = self.applianceTypeGroups[pIndexPath.row]
                if let anApplianceType = anApplianceTypeGroup.applianceType {
                    self.delegate?.selectApplianceTypeControllerDidSelect(self, applianceType: anApplianceType, stripType: anApplianceTypeGroup.ledStripType)
                }
            }
        }
    }
    
}



protocol SelectApplianceTypeControllerDelegate :AnyObject {
    func selectApplianceTypeControllerDidSelect(_ pSender :SelectApplianceTypeController, applianceType pApplianceType :Appliance.ApplianceType, stripType pStripType :Appliance.StripType?)
}
