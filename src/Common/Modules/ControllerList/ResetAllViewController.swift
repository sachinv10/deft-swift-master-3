//
//  ResetAllViewController.swift
//  Wifinity
//
//  Created by Apple on 12/09/22.
//

import UIKit

class ResetAllViewController: BaseController {
  
    var controllerApplince:[ControllerAppliance]? = [ControllerAppliance]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Reset Controllers"
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
                    PopupManager.shared.displayError(message: "Can not search appliances", description: pError!.localizedDescription)
                } else {
                    
                    if pApplianceArray != nil && pApplianceArray!.count > 0 {
                        //    self.appliances = pApplianceArray!
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                        //   self.reloadAllView()
                    }
                }
            }, room: txtfldSSID.text, room: txtfldPassword.text, Applinces: item, includeOnOnly: true)
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
