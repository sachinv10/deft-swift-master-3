//
//  SelectRemoteKeySequenceController.swift
//  DEFT
//
//  Created by Rupendra on 4/10/21.
//  Copyright © 2021 Example. All rights reserved.
//

import UIKit

class SelectRemoteKeySequenceController: BaseController {
    @IBOutlet weak var remoteKeyTableView: AppTableView!
    
    var remote :Remote?
    var selectedRemoteKeys :Array<RemoteKey> = Array<RemoteKey>()
    
    weak var delegate :SelectRemoteKeySequenceControllerDelegate?
    
    var sequentialRemoteKeys :Array<RemoteKey> = Array<RemoteKey>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "REMOTE KEY SEQUENCE"
        self.subTitle = nil
        
        self.setup()
    }
    
    
    override func reloadAllData() {
        super.reloadAllData()
        
        self.sequentialRemoteKeys = self.selectedRemoteKeys
        self.reloadAllView()
    }
    
    
    func setup() {
        
    }
    
    
    func reloadAllView() {
        self.remoteKeyTableView.reloadData()
        self.remoteKeyTableView.allowsSelectionDuringEditing = false
        self.remoteKeyTableView.isEditing = true
    }
    
}


extension SelectRemoteKeySequenceController {
    
    @IBAction func didSelectDoneButton(_ pSender: UIButton?) {
        self.delegate?.selectRemoteKeySequenceController(self, didSelectRemoteKeys: self.sequentialRemoteKeys)
    }
    
}



extension SelectRemoteKeySequenceController :UITableViewDataSource, UITableViewDelegate {
    
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
            aReturnVal = self.selectedRemoteKeys.count
        }
        
        return aReturnVal
    }
    
    
    /**
     * Method that will calculate and return height of row at given index path of the table.
     * @return CGFloat. Height of the row at given index path
     */
    func tableView(_ pTableView: UITableView, heightForRowAt pIndexPath: IndexPath) -> CGFloat {
        var aReturnVal :CGFloat = UITableView.automaticDimension
        aReturnVal = SelectRemoteKeyTableCellView.cellHeight()
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
        
        if pTableView.isEqual(self.remoteKeyTableView) {
            if pIndexPath.row < self.selectedRemoteKeys.count {
                let aRemoteKey = self.selectedRemoteKeys[pIndexPath.row]
                
                let aCellView :SelectRemoteKeyTableCellView = pTableView.dequeueReusableCell(withIdentifier: "SelectRemoteKeyTableCellViewId") as! SelectRemoteKeyTableCellView
                aCellView.load(remoteKey: aRemoteKey, isChecked: false)
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
    
    func tableView(_ pTableView: UITableView, editingStyleForRowAt pIndexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ pTableView: UITableView, shouldIndentWhileEditingRowAt pIndexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ pTableView: UITableView, moveRowAt pSourceIndexPath: IndexPath, to pDestinationIndexPath: IndexPath) {
        let aRemoteKey = self.sequentialRemoteKeys[pSourceIndexPath.row]
        self.sequentialRemoteKeys.remove(at: pSourceIndexPath.row)
        self.sequentialRemoteKeys.insert(aRemoteKey, at: pDestinationIndexPath.row)
    }
    
}


protocol SelectRemoteKeySequenceControllerDelegate :AnyObject {
    func selectRemoteKeySequenceController(_ pSender :SelectRemoteKeySequenceController, didSelectRemoteKeys pRemoteKeyArray :Array<RemoteKey>?)
}

