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
            
            if let wifis = controllerApplince?.wifiSignalStrength{
                let wifist =  self.wifistrenthcalulation(wifis: wifis)
                lblwifiSignal.text = "\(String(wifist)) %"
                
            }
        }
        Refrashbtn.setTitle("", for: .normal)
        self.stackviewfunc()
    }
    
    @IBOutlet weak var lblbtnback: UIButton!
    
    @IBAction func didtappedBackbtn(_ sender: Any) {
        RoutingManager.shared.goToPreviousScreen(self)
    }
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var lblHardwareId: UILabel!
    @IBOutlet weak var lblProductionRegistrestion: UILabel!
    @IBOutlet weak var lblwifiSignal: UILabel!
    @IBOutlet weak var lblLastActivity: UILabel!
   
    @IBOutlet weak var Refrashbtn: UIButton!
    let button = UIButton()
    let button4 = UIButton()
    let views = UIStackView()
    let button5 = UIButton()
    var button6 = UIButton()
    func stackviewfunc()  {
       
          button.setTitle("Network Details                          ^", for: .normal)
          button.contentHorizontalAlignment = .left
          button.backgroundColor = UIColor.clear
          button.translatesAutoresizingMaskIntoConstraints = false
         button.addTarget(self, action: #selector(myAction), for: .touchUpInside)
        button.setTitleColor(UIColor.black, for: .normal)
        button6 = UIButton(frame: CGRect(x: button.frame.width / 2, y: 0, width: button.frame.width / 2, height: button.frame.height))
       
        button6.setImage(UIImage(named: "free-arrow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addSubview(button6)
      //  views.backgroundColor = UIColor.placeholderText
        views.translatesAutoresizingMaskIntoConstraints = false
        button4.setTitle("Network Name(SSID):  ", for: .normal)
        if let nwname = controllerApplince?.wifiSsid! {
            button4.setTitle("Network Name(SSID):  \(nwname)", for: .normal)
        }
         button4.translatesAutoresizingMaskIntoConstraints = false
        button4.setTitleColor(UIColor.darkGray, for: .normal)
        button4.contentHorizontalAlignment = .left
//        let tapButton = UIButton()
//        tapButton.setImage(UIImage(named: "free-arrow")?.withRenderingMode(.alwaysOriginal), for: .normal)
//        tapButton.setImage(UIImage(named: "free-arrow")?.withRenderingMode(.alwaysOriginal), for: .normal)
//        button.addSubview(tapButton)
        button5.setTitle("password          : \(controllerApplince?.wifiPassword!)", for: .normal)
        if let nwnames = controllerApplince?.wifiPassword! {
            button5.setTitle("password          : \(nwnames)", for: .normal)
        }
        
         button5.translatesAutoresizingMaskIntoConstraints = false
        button5.setTitleColor(UIColor.darkGray, for: .normal)
        button5.contentHorizontalAlignment = .left
        views.addArrangedSubview(button4)
        views.addArrangedSubview(button5)
        
        views.isHidden = true
        views.axis = .vertical
        views.translatesAutoresizingMaskIntoConstraints = false
            
        
        let button2 = UIButton()
        button2.setTitle("Reset", for: .normal)
        button2.setTitleColor(UIColor.black, for: .normal)
        button2.backgroundColor = UIColor.clear
        button2.translatesAutoresizingMaskIntoConstraints = false
         button2.contentHorizontalAlignment = .left
        
          let button3 = UIButton()
          button3.setTitle("Delete", for: .normal)
          button3.backgroundColor = UIColor.clear
          button3.setTitleColor(UIColor.black, for: .normal)
          button3.translatesAutoresizingMaskIntoConstraints = false
           button3.contentHorizontalAlignment = .left

        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0

        stackView.addArrangedSubview(button)
        stackView.addArrangedSubview(views)
        stackView.spacing = 8.0
        stackView.addArrangedSubview(button2)
        stackView.addArrangedSubview(button3)
    }
    @objc func myAction() {
        
        if views.isHidden {
            views.isHidden = false
            button.setTitle("Network Details                          ^", for: .normal)
        }else{
            views.isHidden = true
            button.setTitle("Network Details                          ⌄", for: .normal)
        }
    }
    
    @IBAction func Refrashwifisignalbtn(_ sender: Any) {
        
    }
    
    func  wifistrenthcalulation(wifis: String)->Int {
        let wifistresnth = Int(wifis)
        if wifistresnth! >= 0{
            if wifistresnth! <= 50 {
                return 100
            }else if wifistresnth! >= 100{
                return 0
                
            }else{
                return 2 * (100 - wifistresnth!)
            }
        }else{
            if wifistresnth! <= -100{
                return 0
            }else if wifistresnth! >= -50{
                return 100
            }else{
                return 2 * (100 + wifistresnth!)
            }
        }
    }
}
