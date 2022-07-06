//
//  SelectRemoteKeyController.swift
//  DEFT
//
//  Created by Rupendra on 17/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SelectRemoteKeyController: BaseController {
    @IBOutlet weak var remoteKeyTableView: AppTableView!
    @IBOutlet weak var setSequenceButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    var remote :Remote?
    // TODO: Remove componentType and maintain selection in remote-list itself
    var componentType :SelectComponentController.ComponentType?
    var remoteKeys :Array<RemoteKey> = Array<RemoteKey>()
    
    weak var delegate :SelectRemoteKeyControllerDelegate?
    
    var selectedRemoteKeys :Array<RemoteKey> = Array<RemoteKey>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "SELECT REMOTE KEY"
        self.subTitle = nil
        
        self.setup()
    }
    
    
    override func reloadAllData() {
        super.reloadAllData()
        
        self.remoteDetails()
    }
    
    
    func setup() {
        
    }
    
    
    func reloadAllView() {
        if ConfigurationManager.shared.appType == .deft {
            self.setSequenceButton.isHidden = false
            self.doneButton.isHidden = true
        } else {
            self.setSequenceButton.isHidden = true
            self.doneButton.isHidden = false
        }
        self.remoteKeyTableView.reloadData()
    }
    
    
    func remoteDetails() {
        if let aRemote = self.remote {
            // ProgressOverlay.shared.show()
            DataFetchManager.shared.remoteDetails(completion: { (pError, pRemote) in
                // ProgressOverlay.shared.hide()
                if pError != nil {
                    PopupManager.shared.displayError(message: "Can not fetch remote details", description: pError!.localizedDescription)
                } else {
                    self.remote = pRemote
                    self.remoteKeys.removeAll()
                    if let aRemoteKeyArray = self.remote?.keys {
                        self.remoteKeys.append(contentsOf: aRemoteKeyArray)
                    }
                    self.reloadAllView()
                }
            }, remote: aRemote)
        }
    }
    
}


extension SelectRemoteKeyController {
    
    @IBAction func didSelectDoneButton(_ pSender: UIButton?) {
        self.delegate?.selectRemoteKeyController(self, didSelectRemoteKeys: self.selectedRemoteKeys, componentType: self.componentType)
    }
    
    @IBAction func didSelectSetSequenceButton(_ pSender: UIButton?) {
        if let aRemote = self.remote {
            #if !APP_WIFINITY
            RoutingManager.shared.gotoSelectRemoteKeySequence(controller: self, remote: aRemote, delegate: self, selectedRemoteKeys: self.selectedRemoteKeys)
            #endif
        }
    }
    
}


#if !APP_WIFINITY

extension SelectRemoteKeyController :SelectRemoteKeySequenceControllerDelegate {
    
    func selectRemoteKeySequenceController(_ pSender: SelectRemoteKeySequenceController, didSelectRemoteKeys pRemoteKeyArray: Array<RemoteKey>?) {
        self.delegate?.selectRemoteKeyController(self, didSelectRemoteKeys: pSender.sequentialRemoteKeys, componentType: self.componentType)
    }
    
}

#endif


extension SelectRemoteKeyController :UITableViewDataSource, UITableViewDelegate {
    
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
            aReturnVal = self.remoteKeys.count
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
            if pIndexPath.row < self.remoteKeys.count {
                let aRemoteKey = self.remoteKeys[pIndexPath.row]
                
                let aCellView :SelectRemoteKeyTableCellView = pTableView.dequeueReusableCell(withIdentifier: "SelectRemoteKeyTableCellViewId") as! SelectRemoteKeyTableCellView
                aCellView.load(remoteKey: aRemoteKey, isChecked: self.selectedRemoteKeys.contains(where: { (pObject) -> Bool in
                    return aRemoteKey.id == pObject.id
                }))
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
        
        if pIndexPath.row < self.remoteKeys.count {
            let aRemoteKey = self.remoteKeys[pIndexPath.row]
            if let anIndex = self.selectedRemoteKeys.firstIndex(where: { (pObject) -> Bool in
                return aRemoteKey.id == pObject.id
            }) {
                self.selectedRemoteKeys.remove(at: anIndex)
            } else {
                self.selectedRemoteKeys.append(aRemoteKey)
            }
            self.remoteKeyTableView.reloadRows(at: [pIndexPath], with: UITableView.RowAnimation.automatic)
        }
    }
    
}


protocol SelectRemoteKeyControllerDelegate :AnyObject {
    func selectRemoteKeyController(_ pSender :SelectRemoteKeyController, didSelectRemoteKeys pRemoteKeyArray :Array<RemoteKey>?, componentType pComponentType :SelectComponentController.ComponentType?)
}
