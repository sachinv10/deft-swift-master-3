//
//  SearchRemoteController.swift
//  DEFT
//
//  Created by Rupendra on 21/08/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SearchRemoteController: BaseController {
    @IBOutlet weak var remoteTableView: AppTableView!
    @IBOutlet weak var addButton: AppFloatingButton!
    
    var selectedRoom :Room?
    var remotes :Array<Remote> = Array<Remote>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "REMOTES"
        self.subTitle = self.selectedRoom?.title
        
        self.remoteTableView.tableFooterView = UIView()
        self.remoteTableView.delaysContentTouches = false
        
        self.addButton.isHidden = true
    }
    
    
    override func reloadAllData() {
        self.remotes.removeAll()
        
        // ProgressOverlay.shared.show()
        DataFetchManager.shared.searchRemote(completion: { (pError, pRemoteArray) in
            // ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not search remotes", description: pError!.localizedDescription)
            } else {
                if pRemoteArray != nil && pRemoteArray!.count > 0 {
                    self.remotes = pRemoteArray!
                }
                self.reloadAllView()
            }
        }, room: self.selectedRoom)
    }
    
    
    func reloadAllView() {
        if self.remotes.count <= 0 {
            self.remoteTableView.display(message: "No Remote Available")
        } else {
            self.remoteTableView.hideMessage()
        }
        self.remoteTableView.reloadData()
    }
    
}



extension SearchRemoteController {
    @IBAction private func didSelectAddButton(_ pSender: AppFloatingButton) {
        RoutingManager.shared.gotoNewRemote(controller: self)
    }
}



extension SearchRemoteController :UITableViewDataSource, UITableViewDelegate {
    
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
            aReturnVal = self.remotes.count
        }
        
        return aReturnVal
    }
    
    
    /**
     * Method that will calculate and return height of row at given index path of the table.
     * @return CGFloat. Height of the row at given index path
     */
    func tableView(_ pTableView: UITableView, heightForRowAt pIndexPath: IndexPath) -> CGFloat {
        var aReturnVal :CGFloat = UITableView.automaticDimension
        aReturnVal = SearchRemoteTableCellView.cellHeight()
        return aReturnVal
    }
    
    
    /**
     * Method that will calculate and return height of row at given index path of the table.
     * @return CGFloat. Height of the row at given index path
     */
    func tableView(_ pTableView: UITableView, estimatedHeightForRowAt pIndexPath: IndexPath) -> CGFloat {
        var aReturnVal :CGFloat = UITableView.automaticDimension
        aReturnVal = SearchRemoteTableCellView.cellHeight()
        return aReturnVal
    }
    
    
    /**
     * Method that will init, set and return the cell view.
     * @return UITableViewCell. View of the cell in given table view.
     */
    func tableView(_ pTableView: UITableView, cellForRowAt pIndexPath: IndexPath) -> UITableViewCell {
        var aReturnVal :UITableViewCell?
        
        if pTableView.isEqual(self.remoteTableView) {
            if pIndexPath.row < self.remotes.count {
                let aRemote = self.remotes[pIndexPath.row]
                let aCellView :SearchRemoteTableCellView = pTableView.dequeueReusableCell(withIdentifier: "SearchRemoteTableCellViewId") as! SearchRemoteTableCellView
                aCellView.load(remote: aRemote)
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
        
        if pIndexPath.row < self.remotes.count {
            let aSelectedRemote = self.remotes[pIndexPath.row]
            RoutingManager.shared.gotoRemoteDetails(controller: self, selectedRemote: aSelectedRemote)
        }
    }
    
}
