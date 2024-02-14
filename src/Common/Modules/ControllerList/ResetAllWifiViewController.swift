//
//  ResetAllWifiViewController.swift
//  Wifinity
//
//  Created by Apple on 08/09/22.
//

import UIKit
extension UIButton {
    //MARK:- Animate check mark
    func checkboxAnimation(closure: @escaping () -> Void){
        guard let image = self.imageView else {return}
        
        UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveLinear, animations: {
            image.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            
        }) { (success) in
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                self.isSelected = !self.isSelected
                //to-do
                closure()
                image.transform = .identity
            }, completion: nil)
        }
    }
}
protocol ResetControllerTableCellViewDelegate :AnyObject {
     func cellView(_ pSender: ResetAllControllrTCell, btnsender sender: UIButton)
     func cellViewR(_ pSender: ResetAllControllrTCell, btnsender sender: UIButton)
}

class ResetAllControllrTCell: UITableViewCell{
    

    @IBOutlet weak var lblcheckbtn: UIButton!
    @IBOutlet weak var lblSubheding: UILabel!
    @IBOutlet weak var lblheding: UILabel!
    var controllerApp: ControllerAppliance?
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor(named: "PrimaryLightestColor")
//        lblcheckbtn.setImage(UIImage(named:"Checkmarkempty"), for: .normal)
      //   lblcheckbtn.setImage(UIImage(named:"Checkmark"), for: .selected)
        lblcheckbtn.addPadding(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 25)) // Adjust padding as needed
        
        lblcheckbtn.layer.borderWidth = 1
        lblcheckbtn.layer.borderColor = UIColor.gray.cgColor
        lblcheckbtn.setTitle("", for: .normal)
      //  self.isChecked = false
        lblcheckbtn.isHidden = true
    }
    var delegate: ResetControllerTableCellViewDelegate?
    func load(pController: ControllerAppliance) {
        lblheding.text = pController.name
        lblSubheding.text = pController.id
       if controllerApp?.isSelected == true{
          // lblcheckbtn.backgroundColor = UIColor.green
           self.accessoryType = .checkmark
       }else{
        //   lblcheckbtn.backgroundColor = UIColor.clear
           self.accessoryType = .none
       }
    }
    
    @IBAction func didtappedCheckBox(_ sender: UIButton) {
    print("enter in check\(controllerApp)")
        
//        sender.checkboxAnimation {
//                    print("I'm done")
//                    //here you can also track the Checked, UnChecked state with sender.isSelected
//                    print(sender.isSelected)
//
//                }
       //  self.isSelected = !self.isSelected
        if lblcheckbtn.backgroundColor == UIColor.clear{
      //  lblcheckbtn.backgroundColor = UIColor.green
            controllerApp?.isSelected = true
            delegate?.cellView(self, btnsender: sender)
        
        }else{
            controllerApp?.isSelected = false
        //    lblcheckbtn.backgroundColor = UIColor.clear
            delegate?.cellView(self, btnsender: sender)
        }
  }
}
class ResetAllWifiViewController: BaseController{
  
    
    @IBOutlet weak var lblcontinuebtn: UIButton!
    var ControllerId = [String]()
    
    var controllerApplince :[ControllerAppliance]?
    var controllerAction: ControllerAppliance.ControllerChoice = .Reset
    var SelectedcontrollerApp:[ControllerAppliance]? = [ControllerAppliance]()
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        switch controllerAction{
        case .Delete:
            self.title = "Delete Controller"
        case .Reset:
            self.title = "Reset Controller"
        }
      
        self.subTitle = ""
        tableview.delegate = self
        tableview.dataSource = self
        lblcontinuebtn.isHidden = true
        lblcontinuebtn.isHidden = true
    }
    
 
    @IBAction func didtappedContue(_ sender: Any) {
        let uniquePosts = Array(Set(SelectedcontrollerApp!))
        RoutingManager.shared.gotoAllResetControllerSetting(controller: self, controller: uniquePosts,userChoise: controllerAction)
    }
}
extension ResetAllWifiViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controllerApplince!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ResetAllControllrTCell
        let applinceobj = controllerApplince?[indexPath.row]
        cell.delegate = self
        cell.controllerApp = applinceobj
        cell.load(pController: applinceobj!)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ResetAllControllrTCell
        let applinceobj = controllerApplince?[indexPath.row]
        var apl = applinceobj?.id
        var controllerapplinces = applinceobj
        lblcontinuebtn.isHidden = false
     if let indexid = SelectedcontrollerApp?.firstIndex(where: {(pobject) -> Bool in
            return pobject.id == apl && pobject.roomId == controllerapplinces?.roomId
       }){
         controllerapplinces?.isSelected = false
         SelectedcontrollerApp?.remove(at: indexid)
     }else{
         controllerapplinces?.isSelected = true
         SelectedcontrollerApp?.append(controllerapplinces!)
     }
        tableview.reloadRows(at: [indexPath], with: .automatic)
    }
}
extension ResetAllWifiViewController: ResetControllerTableCellViewDelegate{

    func cellView(_ pSender: ResetAllControllrTCell, btnsender sender: UIButton) {
        print(pSender.controllerApp?.name)
        var apl = pSender.controllerApp?.id
        var controllerapplinces = pSender.controllerApp
      //  SelectedcontrollerApp?.append(controllerapplinces!)
        ControllerId.append(apl!)
        lblcontinuebtn.isHidden = false
     if let indexid = SelectedcontrollerApp?.firstIndex(where: {(pobject) -> Bool in
            return pobject.id == apl && pobject.roomId == controllerapplinces?.roomId
       }){
         SelectedcontrollerApp?.remove(at: indexid)
     }else{
         SelectedcontrollerApp?.append(controllerapplinces!)
     }
        tableview.reloadData()
    }
    
    func cellViewR(_ pSender: ResetAllControllrTCell, btnsender sender: UIButton) {
        print(pSender.controllerApp?.name)
        for item in 0..<SelectedcontrollerApp!.count {
            if (pSender.controllerApp?.id)!  == SelectedcontrollerApp![item].id {
                 SelectedcontrollerApp?.remove(at: item)
                 ControllerId.remove(at: item)
                break
             }
        }
     }
}
extension UIButton {
    func addPadding(_ padding: UIEdgeInsets) {
        contentEdgeInsets = padding
    }
}
