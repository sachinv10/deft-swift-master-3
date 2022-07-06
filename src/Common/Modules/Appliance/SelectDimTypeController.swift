//
//  SelectDimTypeController.swift
//  Wifinity
//
//  Created by Rupendra on 17/01/21.
//

import UIKit

class SelectDimTypeController: BaseController {
    @IBOutlet private weak var dimTypeTableView: AppTableView!
    
    private var dimTypes :Array<Appliance.DimType> = Array<Appliance.DimType>()
    
    weak var delegate :SelectDimTypeControllerDelegate?
    
    var hardwareType :Device.HardwareType?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Select Dim Type"
        self.subTitle = nil
        
        self.searchDimType()
    }
    
    
    func searchDimType() {
        self.dimTypes.removeAll()
        
        var anIsTriacAvailable = true
        switch self.hardwareType {
        case .oneSwitch
         , .twoSwitch
         , .threeSwitch
         , .fourSwitch
         , .fiveSwitch
         , .sixSwitch
         , .sevenSwitch
         , .eightSwitch
         , .nineSwitch
         , .tenSwitch:
            anIsTriacAvailable = false
        default:
            anIsTriacAvailable = true
        }
        
        self.dimTypes.append(Appliance.DimType.none)
        self.dimTypes.append(Appliance.DimType.rc)
        if anIsTriacAvailable {
            self.dimTypes.append(Appliance.DimType.triac)
        }
    }
    
}



extension SelectDimTypeController :UITableViewDataSource, UITableViewDelegate {
    
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
            aReturnVal = self.dimTypes.count
        }
        
        return aReturnVal
    }
    
    
    /**
     * Method that will calculate and return height of row at given index path of the table.
     * @return CGFloat. Height of the row at given index path
     */
    func tableView(_ pTableView: UITableView, heightForRowAt pIndexPath: IndexPath) -> CGFloat {
        var aReturnVal :CGFloat = UITableView.automaticDimension
        aReturnVal = SelectDimTypeTableCellView.cellHeight()
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
        
        if pTableView.isEqual(self.dimTypeTableView) {
            if pIndexPath.section == 0 {
                if pIndexPath.row < self.dimTypes.count {
                    let aDimType = self.dimTypes[pIndexPath.row]
                    let aCellView :SelectDimTypeTableCellView = pTableView.dequeueReusableCell(withIdentifier: "SelectDimTypeTableCellViewId") as! SelectDimTypeTableCellView
                    aCellView.load(dimType: aDimType)
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
            if pIndexPath.row < self.dimTypes.count {
                let aDimType = self.dimTypes[pIndexPath.row]
                self.delegate?.selectDimTypeControllerDidSelect(self, dimType: aDimType)
            }
        }
    }
    
}



protocol SelectDimTypeControllerDelegate :AnyObject {
    func selectDimTypeControllerDidSelect(_ pSender :SelectDimTypeController, dimType pDimType :Appliance.DimType)
}
