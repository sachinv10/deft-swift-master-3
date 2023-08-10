//
//  CoreViewController.swift
//  Wifinity
//
//  Created by Vivek V. Unhale on 26/05/22.
//

import UIKit

//
//class OfferData {
//    var topic: String?
//    var message: String?
//    var product: String?
//    var image: String?
//    var timestamp: String?
//    var expiryDate: String?
//}

class CoreViewController: BaseController {
    
    @IBOutlet weak var coreTableView: AppTableView!
    @IBOutlet weak var addButton: AppFloatingButton!
    var coreDataArray = [Core]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        SelectComponentController.coreSensor = false
        SelectComponentController.ApplianceType = ""
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didtappedAddNewCore(_ sender: Any) {
        var id = Int(newCoreId!)
        if id != nil{
            id = id! + 1
            let formattedValue = String(format: "%03d", id!)
            newCoreId = formattedValue
        }else{
            newCoreId = "000"
        }
        RoutingManager.shared.gotoCreateNewCore(controller: self, shouldAddNavigationController: true, newCoreId: newCoreId, core: nil, pdelegate: self)
    }
    var newCoreId:String? = String()
}

extension CoreViewController {
    
    func setupUI() {
        setUpTopBar()
        getCoreListApiCall()
        setupcoreTableView()
    }
    
    func setUpTopBar() {
        self.title = "C.O.R.E."
        self.subTitle = nil
    }
    
    func getCoreListApiCall() {
        ProgressOverlay.shared.show()
        
        DataFetchManager.shared.coreList(completion: { error, coreArray in
            ProgressOverlay.shared.hide()
            
            if error != nil {
                PopupManager.shared.displayConfirmation(message: "Error", description: error!.localizedDescription, completion: { })
            } else {
                if let data = coreArray {
                    self.coreDataArray = data
                    for item in data{
                        if self.newCoreId != nil{
                            if item.ruleId ?? "" > self.newCoreId ?? ""{
                                self.newCoreId = item.ruleId
                            }else{
                                
                            }
                        }else{
                            self.newCoreId = item.ruleId
                        }
                    }
                    self.reloadAllView()
                }
            }
        })
    }
    
    func setupcoreTableView() {
        coreTableView.backgroundColor = .clear
        coreTableView.separatorStyle = .none
        coreTableView.bounces = false
        coreTableView.showsVerticalScrollIndicator = false
        coreTableView.delegate = self
        coreTableView.dataSource = self
        //coreTableView.rowHeight = UITableView.automaticDimension
        addButton.isHidden = false
    }
    
    func updateCore(anAppliance: Core, status: Bool) {
        ProgressOverlay.shared.show()
        
        DataFetchManager.shared.updateCore(completion: { error in
            ProgressOverlay.shared.hide()
            
            if error != nil {
                PopupManager.shared.displayError(message: "Can not update core.", description: error!.localizedDescription)
                self.reloadAllView()
            } else {
                self.reloadAllView()
            }
        }, pCore: anAppliance)
    }
    
}

extension CoreViewController {
    func reloadAllView() {
        if self.coreDataArray.count <= 0 {
            self.coreTableView.display(message: "No Appliance Available")
        } else {
            self.coreTableView.hideMessage()
        }
        self.coreTableView.reloadData()
    }
}

extension CoreViewController: UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coreDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "CoreTableViewCell",
            for: indexPath
        ) as! CoreTableViewCell
        cell.delegate = self
        cell.configureCell(coreData: coreDataArray[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ pTableView: UITableView, commit pEditingStyle: UITableViewCell.EditingStyle, forRowAt pIndexPath: IndexPath) {
        if pEditingStyle == .delete {
            if pIndexPath.row < self.coreDataArray.count {
                let acore = self.coreDataArray[pIndexPath.row]
                PopupManager.shared.displayConfirmation(message: "Do you want to delete selected CORE?", description: nil, completion: {
                    self.deleteMood(pcore: acore)
                })
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let acore = self.coreDataArray[indexPath.row]
        //        newCoreId = acore.ruleId
        //        RoutingManager.shared.gotoCreateNewCore(controller: self, shouldAddNavigationController: true, newCoreId: newCoreId, core: acore, pdelegate: self)
    }
}

extension CoreViewController: CoreTableViewDelegate, newCoreControllerDelegate {
    func deleteMood(pcore: Core){
        
        DataFetchManager.shared.deleteCore(completion: { error in
            if error != nil{ print(error.debugDescription)
            }else{
                print("core deleted")
            }
        }, pCore: pcore)
    }
    
    func newCoreControllerDidDone() {
        self.reloadAllData()
        self.navigationController?.popToViewController(self, animated: true)
    }
    
    
    
    
    func cellView(_ pSender: CoreTableViewCell, didChangePowerState pState: Bool) {
        if let anIndexPath = self.coreTableView.indexPath(for: pSender), anIndexPath.row < self.coreDataArray.count {
            let anAppliance = self.coreDataArray[anIndexPath.row]
            anAppliance.state = pState
            self.updateCore(anAppliance: anAppliance, status: pState)
        }
    }
    
}
protocol newCoreControllerDelegate: NSObject{
    func newCoreControllerDidDone()
}
