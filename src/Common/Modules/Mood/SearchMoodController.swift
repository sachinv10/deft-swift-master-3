//
//  SearchMoodController.swift
//  DEFT
//
//  Created by Rupendra on 08/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
class SearchMoodController: BaseController {
    @IBOutlet weak var moodTableView: AppTableView!
    @IBOutlet weak var addButton: AppFloatingButton!
    
    var selectedRoom :Room?
    var moods :Array<Mood> = Array<Mood>()
    var controllerflag: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "MOODS"
        self.subTitle = self.selectedRoom?.title
        
        self.moodTableView.tableFooterView = UIView()
        self.moodTableView.delaysContentTouches = false
        
        if ConfigurationManager.shared.appType == ConfigurationManager.AppType.wifinity {
            self.addButton.isHidden = true
        } else {
            self.addButton.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        self.controllerflag = true
        activatdatalistner()
        print("im back")
        reloadAllData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("did dis appear........")
        self.controllerflag = false
    }
    
    func activatdatalistner()  {
        print("applince id\(SearchApplianceController.applinceId)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            for i in (0 ..< SearchApplianceController.applinceId.count) {
               print(SearchApplianceController.applinceId[i])
              
           Database.database().reference().child("mood")
                    .child(Auth.auth().currentUser!.uid).observe(.childChanged) { (snapshot, key) in
               print(key as Any)
                        print("mood lisner appear........")
               if self.controllerflag == true {
                   self.reloadAllData()
               }
           }
        }
       }
    }
    
    override func reloadAllData() {
        self.moods.removeAll()
        print("get moods")
        // ProgressOverlay.shared.show()
        DataFetchManager.shared.searchMood(completion: { (pError, pMoodArray) in
            // ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not search moods", description: pError!.localizedDescription)
            } else {
                if pMoodArray != nil && pMoodArray!.count > 0 {
                    self.moods = pMoodArray!
                }
                self.reloadAllView()
            }
        }, room: self.selectedRoom)
    }
    
    
    func reloadAllView() {
        if self.moods.count <= 0 {
            self.moodTableView.display(message: "No Mood Available")
        } else {
            self.moodTableView.hideMessage()
        }
        self.moodTableView.reloadData()
    }
    
    
    func updateMoodPowerState(mood pMood :Mood, powerState pPowerState :Bool) {
        let aMood = pMood.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateMoodPowerState(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update mood.", description: pError!.localizedDescription)
            } else {
                if self.selectedRoom != nil {
                    pMood.isOn = pPowerState
                } else {
                    self.reloadAllData()
                }
            }
            self.reloadAllView()
        }, mood: aMood, powerState: pPowerState)
    }
    
    
    private func deleteMood(mood pMood :Mood) {
        let aMood = pMood.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.deleteMood(completion: { (pError, pMood) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not delete mood.", description: pError!.localizedDescription)
            } else {
                PopupManager.shared.displaySuccess(message: "Mood deleted successfully.", description: nil, completion: nil)
                self.reloadAllData()
            }
        }, mood: aMood)
    }
    
}


extension SearchMoodController {
    
    @IBAction func didSelectAddButton(_ pSender: AppFloatingButton?) {
        if let aRoom = self.selectedRoom {
            #if !APP_WIFINITY
            RoutingManager.shared.gotoNewMood(controller: self, selectedRoom: aRoom, delegate: self)
            #endif
        }
    }
    
}


extension SearchMoodController :UITableViewDataSource, UITableViewDelegate {
    
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
            aReturnVal = self.moods.count
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
        
        if pTableView.isEqual(self.moodTableView) {
            if pIndexPath.row < self.moods.count {
                let aMood = self.moods[pIndexPath.row]
                let aCellView :SearchMoodTableCellView = pTableView.dequeueReusableCell(withIdentifier: "SearchMoodTableCellViewId") as! SearchMoodTableCellView
                aCellView.load(mood: aMood)
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
        
        if pIndexPath.section == 0 {
            if pIndexPath.row < self.moods.count {
                let aMood = self.moods[pIndexPath.row]
                #if !APP_WIFINITY
                    RoutingManager.shared.gotoMoodDetails(controller: self, selectedMood: aMood, delegate: self)
                #endif
            }
        }
    }
    
    
    func tableView(_ pTableView: UITableView, commit pEditingStyle: UITableViewCell.EditingStyle, forRowAt pIndexPath: IndexPath) {
        if pEditingStyle == .delete {
            if pIndexPath.row < self.moods.count {
                let aMood = self.moods[pIndexPath.row]
                #if !APP_WIFINITY
                PopupManager.shared.displayConfirmation(message: "Do you want to delete selected mood?", description: nil, completion: {
                    self.deleteMood(mood: aMood)
                })
                #endif
            }
        }
    }
    
}


extension SearchMoodController :SearchMoodTableCellViewDelegate {
    
    func cellView(_ pSender: SearchMoodTableCellView, didChangePowerState pPowerState :Bool) {
        if let anIndexPath = self.moodTableView.indexPath(for: pSender), anIndexPath.row < self.moods.count {
            let aMood = self.moods[anIndexPath.row]
            self.updateMoodPowerState(mood: aMood, powerState: pPowerState)
        }
    }

}


#if !APP_WIFINITY

extension SearchMoodController :NewMoodControllerDelegate {
    
    func newMoodControllerDidDone(_ pSender: NewMoodController) {
        RoutingManager.shared.goBackToController(self)
        self.reloadAllData()
    }
    
}

#endif
