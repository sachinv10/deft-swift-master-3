//
//  ResetAllViewController.swift
//  Wifinity
//
//  Created by Apple on 12/09/22.
//

import UIKit

class ResetAllViewController: BaseController {
  
    var controllerApplince:[ControllerAppliance]? = [ControllerAppliance]()
    var controllerAction: ControllerAppliance.ControllerChoice = .Reset

    override func viewDidLoad() {
        super.viewDidLoad()
        switch controllerAction{
        case .Delete:
            self.title = "Delete Controller"
        case .Reset:
            self.title = "Reset Controller"
        }
         self.subTitle = ""
        tableview.dataSource = self
        tableview.delegate = self
      
       
    }
    
 
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var txtfldPassword: UITextField!
    @IBOutlet weak var txtfldSSID: UITextField!
    
    @IBOutlet weak var lblSubmtbtn: UIButton!
    @IBAction func didpappedSubmitbtn(_ sender: Any) {
        calltoResetFunc()
        lblSubmtbtn.isUserInteractionEnabled = false
    }
        func calltoResetFunc() {
            for item in controllerApplince! {
                print("controller name= \(item.id)")
                ProgressOverlay.shared.show()
            DataFetchManager.shared.resetController(completion: { (pError, pApplianceArray) in
                ProgressOverlay.shared.hide()

                if pError != nil {
                    //  displaySuccess
                    if pError?.localizedDescription == "Success"{
                        self.showToast(message: "update Credential successfully",duration: 2)
                    }
                   // PopupManager.shared.displayError(message: "Can not update Credential", description: pError!.localizedDescription)
                } else {
                    if pApplianceArray != nil && pApplianceArray!.count > 0 {
                        //    self.appliances = pApplianceArray!
                    }
                }
            }, room: txtfldSSID.text, room: txtfldPassword.text, Applinces: item, includeOnOnly: true)
        }
            DispatchQueue.main.asyncAfter(deadline: .now() + 6){
                RoutingManager.shared.gobacktoControllerList()
            }
    }
}
extension ResetAllViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controllerApplince?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let applinceobj = controllerApplince?[indexPath.row]
        cell.textLabel?.text = applinceobj?.name
        return cell
    }
    
    
}
