//
//  SearchCurtainController.swift
//  DEFT
//
//  Created by Rupendra on 21/08/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore

class SearchCurtainController: BaseController {
    @IBOutlet weak var curtainTableView: AppTableView!
    
    var selectedRoom :Room?
    var selectedCurtain :Curtain?
    var curtains :Array<Curtain> = Array<Curtain>()
    var controllerflag: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        controllerflag = true
        self.title = "CURTAINS"
        self.subTitle = self.selectedRoom?.title
        
        self.curtainTableView.tableFooterView = UIView()
        self.curtainTableView.delaysContentTouches = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        controllerflag = true
        
    }
    
    override func viewDidAppear(_ pAnimated: Bool) {
        super.viewDidAppear(pAnimated)
        
        self.selectedCurtain = nil
    }
    
    
    override func reloadAllData() {
        self.curtains.removeAll()
        print("Enter in curtun vc")
         ProgressOverlay.shared.show()
        DataFetchManager.shared.searchCurtain(completion: { (pError, pCurtainArray) in
             ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not search curtains", description: pError!.localizedDescription)
            } else {
                if pCurtainArray != nil && pCurtainArray!.count > 0 {
                    self.curtains = pCurtainArray!
                }
                print("Data fetch curtun vc")
                self.reloadAllView()
            }
        }, room: self.selectedRoom)
    }
    
    
    func reloadAllView() {
        if self.curtains.count <= 0 {
            self.curtainTableView.display(message: "No Curtain Available")
        } else {
            self.curtainTableView.hideMessage()
        }
        self.curtainTableView.reloadData()
    }
    
    
    func updateCurtainMotionState(curtain pCurtain :Curtain, motionState pMotionState :Curtain.MotionState) {
        let aCurtain = pCurtain.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateCurtainMotionState(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update curtain.", description: pError!.localizedDescription)
            } else {
                self.reloadAllView()
            }
        }, curtain: aCurtain, motionState: pMotionState)
    }
    
    
    func updateCurtainDimmableValue(curtain pCurtain :Curtain, dimmableValue pDimmableValue :Int) {
        let aCurtain = pCurtain.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateCurtainDimmableValue(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update curtain.", description: pError!.localizedDescription)
            } else {
                self.reloadAllView()
            }
        }, curtain: aCurtain, dimValue: pDimmableValue)
    }
    
}



extension SearchCurtainController :UITableViewDataSource, UITableViewDelegate {
    
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
            aReturnVal = self.curtains.count
        }
        
        return aReturnVal
    }
    
    
    /**
     * Method that will calculate and return height of row at given index path of the table.
     * @return CGFloat. Height of the row at given index path
     */
    func tableView(_ pTableView: UITableView, heightForRowAt pIndexPath: IndexPath) -> CGFloat {
        var aReturnVal :CGFloat = UITableView.automaticDimension
        
        if pIndexPath.row < self.curtains.count {
            let aCurtain = self.curtains[pIndexPath.row]
            if aCurtain.type == Curtain.CurtainType.rolling {
                aReturnVal = SearchCurtainTableCellView.cellHeight(curtain: aCurtain)
            } else {
                aReturnVal = SearchCurtainTableCellView.cellHeight(curtain: aCurtain)
            }
        }
        
        return aReturnVal
    }
    
    
    /**
     * Method that will calculate and return height of row at given index path of the table.
     * @return CGFloat. Height of the row at given index path
     */
    func tableView(_ pTableView: UITableView, estimatedHeightForRowAt pIndexPath: IndexPath) -> CGFloat {
        var aReturnVal :CGFloat = UITableView.automaticDimension
        
        if pIndexPath.row < self.curtains.count {
            let aCurtain = self.curtains[pIndexPath.row]
            if aCurtain.type == Curtain.CurtainType.rolling {
                aReturnVal = SearchCurtainTableCellView.cellHeight(curtain: aCurtain)
            } else {
                aReturnVal = SearchCurtainTableCellView.cellHeight(curtain: aCurtain)
            }
        }
        
        return aReturnVal
    }
    
    
    /**
     * Method that will init, set and return the cell view.
     * @return UITableViewCell. View of the cell in given table view.
     */
    func tableView(_ pTableView: UITableView, cellForRowAt pIndexPath: IndexPath) -> UITableViewCell {
        var aReturnVal :UITableViewCell?
        
        if pTableView.isEqual(self.curtainTableView) {
            if pIndexPath.row < self.curtains.count {
                let aCurtain = self.curtains[pIndexPath.row]
                let aCellView :SearchCurtainTableCellView = pTableView.dequeueReusableCell(withIdentifier: "SearchCurtainTableCellViewId") as! SearchCurtainTableCellView
                aCellView.delegate = self
                aCellView.load(curtain: aCurtain)
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



extension SearchCurtainController :SearchCurtainTableCellViewDelegate {
    
    func cellViewDidSelectOpenCurtain(_ pSender: SearchCurtainTableCellView) {
        if let anIndexPath = self.curtainTableView.indexPath(for: pSender), anIndexPath.row < self.curtains.count {
            let aCurtain = self.curtains[anIndexPath.row]
            self.updateCurtainMotionState(curtain: aCurtain, motionState: Curtain.MotionState.forward)
        }
    }
    
    func cellViewDidSelectStopCurtain(_ pSender: SearchCurtainTableCellView) {
        if let anIndexPath = self.curtainTableView.indexPath(for: pSender), anIndexPath.row < self.curtains.count {
            let aCurtain = self.curtains[anIndexPath.row]
            self.updateCurtainMotionState(curtain: aCurtain, motionState: Curtain.MotionState.stop)
        }
    }
    
    func cellViewDidSelectCloseCurtain(_ pSender: SearchCurtainTableCellView) {
        if let anIndexPath = self.curtainTableView.indexPath(for: pSender), anIndexPath.row < self.curtains.count {
            let aCurtain = self.curtains[anIndexPath.row]
            self.updateCurtainMotionState(curtain: aCurtain, motionState: Curtain.MotionState.reverse)
        }
    }
    
    func cellView(_ pSender: SearchCurtainTableCellView, didChangeDimmableValue pDimmableValue: Int) {
        if let anIndexPath = self.curtainTableView.indexPath(for: pSender), anIndexPath.row < self.curtains.count {
            let aCurtain = self.curtains[anIndexPath.row]
            self.updateCurtainDimmableValue(curtain: aCurtain, dimmableValue: pDimmableValue)
        }
    }
    
}
