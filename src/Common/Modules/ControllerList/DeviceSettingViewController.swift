//
//  DeviceSettingViewController.swift
//  Wifinity
//
//  Created by Apple on 30/06/22.
//

import UIKit

class DeviceSettingViewController: UIViewController {
    
    @IBOutlet weak var backgroundview: UIView!
    var controllerApplince :ControllerAppliance?
static var timestamp = Array<Dictionary<String,Any>>()
    override func viewDidLoad() {
        super.viewDidLoad()
        lblbtnback.setTitle("", for: .normal)
        view.backgroundColor = UIColor(named: "PrimaryLightestColor")
        lblHardwareId.text = controllerApplince?.id
        if let x = controllerApplince?.lastOperated{
            let time =  SharedFunction.shared.gotoTimetampTodayConvert(time: Double(x/1000))
         lblLastActivity.text = time
          
        }
        
    }
    
    @IBOutlet weak var lblbtnback: UIButton!
    
    @IBAction func didtappedBackbtn(_ sender: Any) {
        RoutingManager.shared.goToPreviousScreen(self)
    }
    
    @IBOutlet weak var lblHardwareId: UILabel!
    @IBOutlet weak var lblProductionRegistrestion: UILabel!
    @IBOutlet weak var lblwifiSignal: UILabel!
    @IBOutlet weak var lblLastActivity: UILabel!
    
}
