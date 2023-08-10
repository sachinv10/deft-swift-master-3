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
    
    var moodCell = Mood()
    var selectedRoom :Room?
    var moods :Array<Mood> = Array<Mood>()
    var controllerflag: Bool = false
    let viewcell = UIView()
    let btnDelete = UIButton()
    let btnViewApplainces = UIButton()
    
    let viewAppliance = UIView()
    let lbltitle = UILabel()
    let lblAppliance = UITextView()
    @objc let btnOk = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "MOODS"
        self.subTitle = self.selectedRoom?.title
        
        self.moodTableView.tableFooterView = UIView()
        self.moodTableView.delaysContentTouches = false
        
        if ConfigurationManager.shared.appType == ConfigurationManager.AppType.wifinity {
            self.addButton.isHidden = false
        } else {
            self.addButton.isHidden = false
        }
    }
    var ResetselectedMood:Mood? = Mood()
    var resetRemoteKey: Array<Array<RemoteKey>>? = Array<Array<RemoteKey>>()

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AddNewMoodViewController.selectApplianc = nil
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        self.controllerflag = true
        activatdatalistner()
        AddNewMoodViewController.selectedMood = ResetselectedMood
        AddNewMoodViewController.remoteKey = resetRemoteKey
        reloadAllData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
    var newMoodId = String()
    override func reloadAllData() {
        self.moods.removeAll()
        print("get moods")
        ProgressOverlay.shared.show()
        DataFetchManager.shared.searchMood(completion: { (pError, newMoodid, pMoodArray) in
              ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not search moods", description: pError!.localizedDescription)
            } else {
                self.newMoodId = newMoodid ?? ""
                if pMoodArray != nil && pMoodArray!.count > 0 {
                    self.moods = pMoodArray!
                }
                self.reloadAllView()
            }
        }, room: self.selectedRoom)
    }
    //String(format: "%03d", id!)
    
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
            RoutingManager.shared.gotoNewMood(controller: self, selectedRoom: aRoom, VideoCallDelegate: self)
            #endif
            if ConfigurationManager.shared.appType == ConfigurationManager.AppType.wifinity {
                print("add New")
                RoutingManager.shared.newMoodAdd(controller: self, selectMood: moods, room: selectedRoom, pnewmood: newMoodId)
            }
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
        viewcell.isHidden = true
        if pIndexPath.section == 0 {
            if pIndexPath.row < self.moods.count {
                let aMood = self.moods[pIndexPath.row]
                #if !APP_WIFINITY
                    RoutingManager.shared.gotoMoodDetails(controller: self, selectedMood: aMood, VideoCallDelegate: self)
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
  
    func cellView(_ pSender: SearchMoodTableCellView) {
        moodCell = pSender.mood!
           viewcell.isHidden = false
           viewcell.frame = CGRect(x: 0, y: 0, width: view.frame.width - 140, height: 90)
           viewcell.backgroundColor = .gray
        viewcell.layer.cornerRadius = 15
        viewcell.layer.borderWidth = 0.5
        viewcell.layer.borderColor = UIColor.black.cgColor
        btnDelete.frame = CGRect(x: 0, y: 0, width: view.frame.width - 140, height: 45)
        btnViewApplainces.frame =  CGRect(x: 0, y: 45, width: view.frame.width - 140, height: 45)
      
        btnDelete.setTitle("Delete", for: .normal)
        btnDelete.backgroundColor = .clear
        btnDelete.layer.borderColor = UIColor.white.cgColor
        btnDelete.layer.borderWidth = 0.5
        btnDelete.clipsToBounds = true
       // btnDelete.tintColor = .black
        btnDelete.addTarget(self, action:   #selector(deletefunc),   for: .touchUpInside)

        btnViewApplainces.setTitle("View Appliance Detail", for: .normal)
        btnViewApplainces.backgroundColor = .clear
        btnViewApplainces.layer.borderColor = UIColor.white.cgColor
        btnViewApplainces.layer.borderWidth = 0.5
        btnViewApplainces.clipsToBounds = true
       // btnViewApplainces.tintColor = .black
        btnViewApplainces.addTarget(self, action:   #selector(viewAppliances),   for: .touchUpInside)
        viewcell.addSubview(btnDelete)
        viewcell.addSubview(btnViewApplainces)
        pSender.addSubview(viewcell)
      }
  
    
    func cellView(_ pSender: SearchMoodTableCellView, didChangePowerState pPowerState :Bool) {
        if let anIndexPath = self.moodTableView.indexPath(for: pSender), anIndexPath.row < self.moods.count {
            let aMood = self.moods[anIndexPath.row]
            self.updateMoodPowerState(mood: aMood, powerState: pPowerState)
        }
    }
}
extension SearchMoodController{
    @objc func deletefunc(){
        print("delete func=\(String(describing: moodCell.title))")
        self.viewcell.isHidden = true
        DataFetchManager.shared.deleteMood(mood: moodCell, pcomplition: { error in
            print("get back=\(error?.localizedDescription)")
            if let err = error{
                PopupManager.shared.displayError(message: "Can Not Delete Mood", description: err.localizedDescription)
            }else{
                PopupManager.shared.displayError(message: "Mood delete successfully", description: "")
                self.reloadAllData()
            }
        })
    }
    
    @objc func viewAppliances(cell: SearchMoodTableCellView){
        print("Appliances func")
         self.viewcell.isHidden = true
        viewAppliance.isHidden = false
        viewAppliance.frame = CGRect(x: (Int(self.view.frame.width) * 10) / 100, y: Int(self.view.frame.height / 3), width: (Int(self.view.frame.width) * 80) / 100, height: 170)
        viewAppliance.backgroundColor = .white
        viewAppliance.layer.cornerRadius = 20
        viewAppliance.layer.borderColor = UIColor.gray.cgColor
        viewAppliance.layer.borderWidth = 0.5
        
        lbltitle.frame = CGRect(x: 10, y: 2, width: viewAppliance.frame.width, height: 40)
        lbltitle.text = "View Mood"
        lbltitle.font = .systemFont(ofSize: 20)
        
        lblAppliance.frame = CGRect(x: 10, y: 40, width: viewAppliance.frame.width - 20, height: 90)
        lblAppliance.isEditable = false
        lblAppliance.text = moodCell.applianceDetails
      //  lblAppliance.backgroundColor = .clear
        lblAppliance.font = .systemFont(ofSize: 16)
        
        btnOk.frame = CGRect(x: (Int(self.view.frame.width) * 20) / 100, y: 125, width: Int(viewAppliance.frame.width) / 2, height: 30)
        btnOk.setTitle("Ok", for: .normal)
        btnOk.backgroundColor = .red
        btnOk.layer.borderWidth = 0.5
        btnOk.layer.borderColor = UIColor.black.cgColor
        btnOk.layer.cornerRadius = 7
        btnOk.addTarget(self, action: #selector(btbOkfunc), for: .touchUpInside)
        
      
        viewAppliance.addSubview(lblAppliance)
        viewAppliance.addSubview(lbltitle)
        viewAppliance.addSubview(btnOk)
        self.view.addSubview(viewAppliance)
    }
    @objc func btbOkfunc(){
        viewAppliance.isHidden = true
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
