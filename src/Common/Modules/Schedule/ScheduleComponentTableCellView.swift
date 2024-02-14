//
//  ScheduleComponentTableCellView.swift
//  DEFT
//
//  Created by Rupendra on 17/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit
import Foundation
protocol conditioncheckedComponant: AnyObject{
    func conditioncheckedComponant(pValue: String)
}
class ScheduleComponentTableCellView: UITableViewCell {
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var valueTitlelbl: UILabel!
    @IBOutlet weak var lblAllcondbtn: UIButton!
    @IBOutlet weak var lblAnyCondBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        lblAllcondbtn?.isHidden = true
        lblAnyCondBtn?.isHidden = true
    }
    
    
    func load(rooms pRoomArray: Array<Room>?) {
        let aValue = NSMutableAttributedString()
        
        if let aRoomArray = pRoomArray {
           
            for (anIndex, aRoom) in aRoomArray.enumerated() {
                if aRoom.appliances?.count ?? 0 > 0 || aRoom.curtains?.count ?? 0 > 0 || aRoom.sensors?.count ?? 0 > 0 || aRoom.remotes?.count ?? 0 > 0 {
                if anIndex > 0 {
                    aValue.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)]))
                }
                aValue.append(NSAttributedString(string: String(format: "✦ %@:", aRoom.title ?? "Room"), attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: self.valueLabel.font.pointSize)]))
                aValue.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 6)]))
                //
                if valueTitlelbl?.text == "If:"{
                    lblAllcondbtn.isHidden = false
                    lblAnyCondBtn.isHidden = false
                }else if valueTitlelbl?.text == "Then:"{
                    lblAllcondbtn.isHidden = true
                    lblAnyCondBtn.isHidden = true
                }
                // Appliances Csv
                //                aValue.append(NSAttributedString(string: "    - Appliances: ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: self.valueLabel.font.pointSize)]))
                //
                if let anApplianceArray = aRoom.appliances, anApplianceArray.count > 0 {
                    aValue.append(NSAttributedString(string: "    - Appliances: ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: self.valueLabel.font.pointSize)]))
                    
                    var anApplianceTitleArray = anApplianceArray.compactMap({ $0.title })
                    var anApplicanCsv: String = ""
                    if SelectComponentController.coreSensor == true{
                        aValue.append(NSAttributedString(string: "\n\n  ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 6)]))
                        var str:Array<String> = Array<String>()
                        if valueTitlelbl.text == "Then:"{
                            str = anApplianceArray.compactMap({$0.selectedThanType})
                        }else{
                            str = anApplianceArray.compactMap({$0.selectedAppType})}
                        for item in 0..<anApplianceTitleArray.count{
                            let x = "      \(String(describing: anApplianceTitleArray[item] ))(\(str[item]))"
                            anApplianceTitleArray[item] = x
                        }
                        anApplicanCsv = anApplianceTitleArray.joined(separator: "\n ")
                    }else{
                        aValue.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 6)]))
                        var str:Array<String> = Array<String>()
                            str = anApplianceArray.compactMap({$0.selectedScedularType})
                    for item in 0..<anApplianceTitleArray.count{
                        let x = "      \(String(describing: anApplianceTitleArray[item] ))(\(str[item]))"
                        anApplianceTitleArray[item] = x
                    }
                        anApplicanCsv = anApplianceTitleArray.joined(separator: "\n")}
                    aValue.append(NSAttributedString(string: anApplicanCsv, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: self.valueLabel.font.pointSize)]))
                    aValue.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 6)]))
                } else {
                    //   aValue.append(NSAttributedString(string: "None", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: self.valueLabel.font.pointSize)]))
                }
                
                //  aValue.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 6)]))
                
                // Curtain Csv
                //                aValue.append(NSAttributedString(string: "    - Curtains: ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: self.valueLabel.font.pointSize)]))
                if let aCurtaineArray = aRoom.curtains, aCurtaineArray.count > 0 {
                    aValue.append(NSAttributedString(string: "    - Curtains: ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: self.valueLabel.font.pointSize)]))
                    var aCurtaineTitleArray = aCurtaineArray.compactMap({ $0.title })
                    var aCurtaineTitleCsv: String = ""
                    if SelectComponentController.coreSensor == true{
                        aValue.append(NSAttributedString(string: "\n\n  ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 6)]))
                        var str:Array<String> = Array<String>()
                        if valueTitlelbl.text == "Then:"{
                            str = aCurtaineArray.compactMap({$0.selectedcurtainThan})
                        }else{
                            str = aCurtaineArray.compactMap({$0.selectedAppType})
                        }
                        for item in 0..<aCurtaineTitleArray.count{
                            let x = "      \(String(describing: aCurtaineTitleArray[item] ))(\(str[item]))"
                            aCurtaineTitleArray[item] = x
                        }
                        aCurtaineTitleCsv = aCurtaineTitleArray.joined(separator: "\n ")
                    }else{aCurtaineTitleCsv = aCurtaineTitleArray.joined(separator: ", ")}
                    aValue.append(NSAttributedString(string: aCurtaineTitleCsv, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: self.valueLabel.font.pointSize)]))
                    aValue.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 6)]))
                } else {
                    //  aValue.append(NSAttributedString(string: "None", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: self.valueLabel.font.pointSize)]))
                }
                
                //     aValue.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 6)]))
                
                // Remote Csv
                
                if let aRemoteArray = aRoom.remotes, aRemoteArray.count > 0 {
                    aValue.append(NSAttributedString(string: "    - Remotes: ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: self.valueLabel.font.pointSize)]))
                    var aRemoteTitleArray = aRemoteArray.compactMap({ $0.title })
                    var aRemoteTitleCsv: String = ""
                    if SelectComponentController.coreSensor == true{
                        aValue.append(NSAttributedString(string: "\n\n  ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 6)]))
                        for item in 0..<aRemoteTitleArray.count{
                            let xy = aRemoteArray[item].selectedRemoteKeys?.compactMap({$0.tag?.rawValue})
                            let y = xy?.joined(separator: ",")
                            let x = "      \(String(describing: aRemoteTitleArray[item] ))( Set to \(String(describing: y ?? "")))"
                            aRemoteTitleArray[item] = x
                        }
                        aRemoteTitleCsv = aRemoteTitleArray.joined(separator: "\n ")
                    }else{aRemoteTitleCsv = aRemoteTitleArray.joined(separator: ", ")}
                    
                    aValue.append(NSAttributedString(string: aRemoteTitleCsv, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: self.valueLabel.font.pointSize)]))
                    aValue.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 6)]))
                } else {
                    //  aValue.append(NSAttributedString(string: "None", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: self.valueLabel.font.pointSize)]))
                }
                
                //         aValue.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 6)]))
                
                // Sensor Csv
                
                if let aSensorArray = aRoom.sensors, aSensorArray.count > 0 {
                    aValue.append(NSAttributedString(string: "    - Sensor: ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: self.valueLabel.font.pointSize)]))
                    var aSensorTitleArray = aSensorArray.compactMap({ $0.title })
                    var aSensorTitleCsv: String = ""
                    if SelectComponentController.coreSensor == true{
                        aValue.append(NSAttributedString(string: "\n\n  ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 6)]))
                        let str = aSensorArray.compactMap({$0.selectedAppType})
                        for item in 0..<aSensorTitleArray.count{
                            let x = "     \(String(describing: aSensorTitleArray[item] ))(\(str[item]))"
                            aSensorTitleArray[item] = x
                        }
                        aSensorTitleCsv = aSensorTitleArray.joined(separator: "\n ")
                    }else{aSensorTitleCsv = aSensorTitleArray.joined(separator: ", ")}
                    
                    //   let aSensorTitleCsv = aSensorTitleArray.joined(separator: ", ")
                    aValue.append(NSAttributedString(string: aSensorTitleCsv, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: self.valueLabel.font.pointSize)]))
                } else {
                    //   aValue.append(NSAttributedString(string: "None", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: self.valueLabel.font.pointSize)]))
                }
                 self.valueLabel.attributedText = aValue
            }
          }
        }
    }
    var delegate: conditioncheckedComponant? = nil
    @IBAction func didtappedAllConditionbtn(_ sender: Any) {
        lblAllcondbtn.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        lblAnyCondBtn.setImage(UIImage(systemName: "square"), for: .normal)
        delegate!.conditioncheckedComponant(pValue: "AND")
     }
    @IBAction func didtappedAnyConditionbtn(_ sender: Any) {
        lblAnyCondBtn.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        lblAllcondbtn.setImage(UIImage(systemName: "square"), for: .normal)
        delegate!.conditioncheckedComponant(pValue: "OR")
     }
}

protocol createCoreProtocols: NSObject{
    func cellView(timer: String,tag: Int)
    func cellView(timerDuration: String)
}

class ScheduleTimeerTableCellView: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var valueTitlelbl: UILabel!
    private var datePicker = UIDatePicker()
    @IBOutlet weak var timepiker: UIDatePicker!
    @IBOutlet weak var txtfldTodate: UITextField!
    @IBOutlet weak var txtfldFrom: UITextField!
    
    @IBOutlet weak var optionalView: UIView!
    
    @IBOutlet weak var txtfldTimeduraton: UITextField!
    private let toolbar = UIToolbar()
    override func awakeFromNib() {
        super.awakeFromNib()
        timepiker.isHidden = true
        txtfldFrom.delegate = self
        txtfldTodate.delegate = self
        txtfldTimeduraton.delegate = self
        datePicker.datePickerMode = .time
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.minuteInterval = 1
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
         
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.tintColor = .systemBlue
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([doneButton], animated: false)
        
        txtfldTodate.inputView = datePicker
        txtfldTodate.inputAccessoryView = toolbar
        txtfldFrom.inputAccessoryView = toolbar
        txtfldFrom.inputView = datePicker
        
    }
    func load(obj: Array<Room>?, pCore: Core?){
        for item in obj!{
            if item.remotes?.count ?? 0 > 0{
              //  optionalView.isHidden = true
            //    txtfldTimeduraton.isEnabled = false
                break
            }else{
               // optionalView.isHidden = false
             //   txtfldTimeduraton.isEnabled = true
            }
        }
        if let data = pCore?.coreEditData{
            txtfldTimeduraton.text = data.duration
            txtfldFrom.text = data.from
            txtfldTodate.text = data.to
        }
    }
    var delegate: createCoreProtocols?
    @objc func doneButtonTapped() {
        // Dismiss the date picker when the Done button is tapped
        if txtfldFrom.tag == 1{
            txtfldFrom.resignFirstResponder()
           // txtfldTodate.becomeFirstResponder()
            txtfldFrom.tag = 0
        }else if txtfldTodate.tag == 1{
            txtfldTodate.resignFirstResponder()
            txtfldTodate.tag = 0
        }
    }
    @objc func datePickerValueChanged() {
 
        let calendar = Calendar.current
                let components = calendar.dateComponents([.hour, .minute, .second], from: datePicker.date)
                
                guard let hours = components.hour, let minutes = components.minute, let seconds = components.second else {
                    return
                }
                
                let timeString = String(format: "%02d:%02d", hours, minutes)
                print(timeString)
        if txtfldFrom.tag == 1{
            delegate?.cellView(timer: timeString, tag: 1)
            txtfldFrom.text = timeString
        }else if txtfldTodate.tag == 1{
            txtfldTodate.text = timeString
            delegate?.cellView(timer: timeString, tag: 2)
        }
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print(textField.tag)
       
        if textField.placeholder == "To"{
            txtfldTodate.tag = 1
        }else{
            txtfldFrom.tag = 1
        }
        return true
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.placeholder == "Time duration in seconds"{
            delegate?.cellView(timerDuration: textField.text ?? "")
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.placeholder == "Time duration in seconds"{
            delegate?.cellView(timerDuration: textField.text ?? "")
         }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Hide the keyboard
        // Perform any other actions you need to do when "Done" is tapped

        return true
    }
}
