//
//  AddNewMoodViewController.swift
//  Wifinity
//
//  Created by Apple on 23/05/23.
//

import UIKit
import Foundation

class AddNewMoodViewController: BaseController, UITextFieldDelegate {
    var selectedRoom :Room?
    var selectMood: Array<Mood>?
    
    static var selectedMood:Mood? = Mood()
    // remote vc
    static var remoteKey: Array<Array<RemoteKey>>? = Array<Array<RemoteKey>>()
    static var SelectedremoteKey: Array<RemoteKey>? = Array<RemoteKey>()
    
    // select appliances curtan and remote
    static var selectApplianc: Array<MoodAppliances>?

    
    var ResetselectedMood:Mood? = Mood()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add New Mood"
        subTitle = selectedRoom?.title
        moodSetUp()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appmodel = AddNewMoodViewController.selectedMood
        appmodel?.remove()
        let Selectedremotekey = AddNewMoodViewController.SelectedremoteKey
        let selectapplianc = AddNewMoodViewController.selectApplianc
        self.modifyModel()
        uiSetup()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    //MARK: - OUTLATE
    
    
    @IBOutlet weak var lblSave: UIButton!
    
    @IBOutlet weak var viewMoodName: UIView!
    @IBOutlet weak var lbltitleName: UILabel!
    @IBOutlet weak var viewSelectApplinces: UIView!
    
    @IBOutlet weak var btnAppliances: UIButton!
    @IBOutlet weak var btnRemote: UIButton!
    @IBOutlet weak var btnCurtan: UIButton!
    @IBOutlet weak var lblselectAppliances: UILabel!
    @IBOutlet weak var txtfldMoodName: UITextField!
    var newMoodId: String? = String()
    //MARK: - Button Action
    
    @IBAction func didtappedSelectAppliances(_ sender: Any) {
        RoutingManager.shared.SelectApliancesAdd(controller: self, selectMood: selectMood!,room: selectedRoom)
    }
    
    @IBAction func didtappedSavebtn(_ sender: Any) {
        print("Mood name=\(txtfldMoodName.text)")
        
        let x = AddNewMoodViewController.selectedMood
        print(x?.applianceDetails)
        guard let moodName = AddNewMoodViewController.selectedMood?.title else{
            PopupManager.shared.displayError(message: "please enter mood name", description: "")
             return
        }
        if AddNewMoodViewController.selectedMood?.title?.count ?? 0 < 1{
            PopupManager.shared.displayError(message: "please enter mood name", description: "")
        }
        guard let moodName = AddNewMoodViewController.selectedMood?.applianceDetails else{
            PopupManager.shared.displayError(message: "please select appliances", description: "")
             return
        }
        
        let moodss = selectMood?.first
        let id = moodss?.room?.id
        print("room id=\(id)")
        var idmood = Int(newMoodId ?? "")
        idmood! += 1
        x!.id = String(format: "%02d", idmood!)
        let mood = x?.clone()
        createNewMood()
    }
    func createNewMood(){
        print("get moods")
        ProgressOverlay.shared.show()
        DataFetchManager.shared.createNewMood(completion: { (pError, pMoodArray) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not search moods", description: pError!.localizedDescription)
            } else {
                RoutingManager.shared.goToPreviousScreen(self)
                if pMoodArray != nil  {
                    print(pMoodArray)
                }
            }
        },Mood: AddNewMoodViewController.selectedMood)
    }
    func moodSetUp(){
        if ((selectedRoom?.id) != nil), ((selectedRoom?.title) != nil){
            AddNewMoodViewController.selectedMood?.room = selectedRoom
        }
        AddNewMoodViewController.selectedMood =  AddNewMoodViewController.selectedMood?.clone()
    }
    func uiSetup(){
        viewMoodName.layer.cornerRadius = 20
        viewMoodName.layer.borderWidth = 0.5
        viewMoodName.layer.borderColor = UIColor.gray.cgColor
        viewMoodName.layer.masksToBounds = true
        lbltitleName.textColor = .orange
        
        viewSelectApplinces.layer.cornerRadius = 20
        viewSelectApplinces.layer.borderWidth = 0.5
        viewSelectApplinces.layer.borderColor = UIColor.gray.cgColor
        viewSelectApplinces.layer.masksToBounds = true
        lblselectAppliances.textColor = .orange
        btnAppliances.setTitle("", for: .normal)
        btnCurtan.setTitle("", for: .normal)
        btnRemote.setTitle("", for: .normal)
        let moodss = selectMood?.first
        let id = moodss?.room?.id
        let lgtcnttt = String(describing: AddNewMoodViewController.selectedMood?.remoteCount ?? 0)
        let attributedText = setsubtitle(subtitle: lgtcnttt)
        btnRemote.setAttributedTitle(attributedText, for: .normal)
        let lgtcntt = String(describing: AddNewMoodViewController.selectedMood?.curtainCount ?? 0)
        let attributedText2 = setsubtitle(subtitle: lgtcntt)
        btnCurtan.setAttributedTitle(attributedText2, for: .normal)
        let lgtcnt = String(describing: AddNewMoodViewController.selectedMood?.lightCount ?? 0)
        let attributedText1 = setsubtitle(subtitle: lgtcnt)
        btnAppliances.setAttributedTitle(attributedText1, for: .normal)
        txtfldMoodName.delegate = self
        if let texts = AddNewMoodViewController.selectedMood?.title{
            txtfldMoodName.text = texts
        }
    }
    var countstr = "0"
}

extension AddNewMoodViewController{
    func setsubtitle(subtitle: String) -> NSMutableAttributedString{
        let title = ""
        let subtitle = subtitle
        
        let attributedText = NSMutableAttributedString(string: title, attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ])
        
        attributedText.append(NSAttributedString(string: subtitle, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.gray
        ]))
        return attributedText
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss the keyboard
        if let text = textField.text {
            print("Text entered: \(text)")
            AddNewMoodViewController.selectedMood?.title = text
            AddNewMoodViewController.selectedMood = AddNewMoodViewController.selectedMood?.clone()
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get the updated text by combining the existing text with the replacement string
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            // Use the updatedText as needed
            print(updatedText)
            AddNewMoodViewController.selectedMood?.title = updatedText
            AddNewMoodViewController.selectedMood = AddNewMoodViewController.selectedMood?.clone()
        }
        // Return true to allow the changes to be applied to the text field
        return true
    }
}
extension AddNewMoodViewController{
    func modifyModel(){
        
      
        if let data = AddNewMoodViewController.selectApplianc{
                for appdata in data{
                    if appdata.hederType == "Appliances"{
    
                        for applincesdata in appdata.list{
                            if applincesdata.checked == true
                            { // applincesdata.checked = false
                                if  AddNewMoodViewController.selectedMood?.lightCount != nil{
                                AddNewMoodViewController.selectedMood?.lightCount! += 1
                                }else{
                                AddNewMoodViewController.selectedMood?.lightCount = 1
                                }
    
                                if (AddNewMoodViewController.selectedMood?.applianceDetails != nil){
                                    AddNewMoodViewController.selectedMood?.applianceDetails! += "\(applincesdata.name ?? ""),"
                                }else{
                                    AddNewMoodViewController.selectedMood?.applianceDetails = "\(applincesdata.name ?? ""),"
                                }
                                
                                if AddNewMoodViewController.selectedMood?.applianceSelected.count == 0{
                                    let id = "\(applincesdata.hardwareId ?? "")/\(applincesdata.id ?? "")"
                                    AddNewMoodViewController.selectedMood?.applianceSelected.append(id)
                                }else{
                                    var flag = false
                                    for i in 0..<(AddNewMoodViewController.selectedMood?.applianceSelected.count ?? 0){
                                        let id = "\(applincesdata.hardwareId ?? "")/\(applincesdata.id ?? "")"
                                        if applincesdata.hardwareId?.prefix(10) == AddNewMoodViewController.selectedMood?.applianceSelected[i]!.prefix(10){
                                            print("hardware is match")
                                            flag = true
                                             var x = AddNewMoodViewController.selectedMood?.applianceSelected[i]
                                             x! += "/\(String(describing: applincesdata.id!))"
                                            AddNewMoodViewController.selectedMood?.applianceSelected[i] = x
                                         }
                                    }
                                    if flag == false{
                                        let id = "\(applincesdata.hardwareId ?? "")/\(applincesdata.id ?? "")"
                                        AddNewMoodViewController.selectedMood?.applianceSelected.append(id)
                                     }
                                }
                            }
                        }
                    }else if appdata.hederType == "Curtain"{
                        for applincesdata in appdata.list{
                            if applincesdata.checked == true{
                                print("selected curtain")
                              //  applincesdata.checked = false
                                if  AddNewMoodViewController.selectedMood?.curtainCount != nil{
                                    AddNewMoodViewController.selectedMood?.curtainCount! += 1
                                }else{
                                    AddNewMoodViewController.selectedMood?.curtainCount = 1
                                }
                                let x = AddNewMoodViewController.selectedMood
                                if (AddNewMoodViewController.selectedMood?.applianceDetails != nil){
                                    AddNewMoodViewController.selectedMood?.applianceDetails! += "\(applincesdata.name ?? "")"
                                
                                    if x?.CurtanStatus == .On{
                                        AddNewMoodViewController.selectedMood?.applianceDetails! += " to level 2,"
                                    }else{
                                        AddNewMoodViewController.selectedMood?.applianceDetails! += " to level 1,"
                                    }
                                }else{
                                    AddNewMoodViewController.selectedMood?.applianceDetails = "\(applincesdata.name ?? "")"
                                    if x?.CurtanStatus == .On{
                                        AddNewMoodViewController.selectedMood?.applianceDetails! += " to level 2,"
                                    }else{
                                        AddNewMoodViewController.selectedMood?.applianceDetails! += " to level 1,"
                                    }
                                }
                                
                                if AddNewMoodViewController.selectedMood?.applianceSelected.count == 0{
                                    let id = "\(applincesdata.id ?? "")/\(String(describing: AddNewMoodViewController.selectedMood!.CurtanStatus!.rawValue))"
                                    AddNewMoodViewController.selectedMood?.applianceSelected.append(id)
                                }else{
                                    var flag = false
                                    for i in 0..<(AddNewMoodViewController.selectedMood?.applianceSelected.count ?? 0){
                                        let id = "\(applincesdata.hardwareId ?? "")/\(applincesdata.id ?? "")"
                                        if applincesdata.hardwareId?.prefix(10) == AddNewMoodViewController.selectedMood?.applianceSelected[i]!.prefix(10){
                                            print("hardware is match")
                                            flag = true
                                            let id = "\(applincesdata.id ?? "")/\(String(describing: AddNewMoodViewController.selectedMood!.CurtanStatus!.rawValue))"
                                            AddNewMoodViewController.selectedMood?.applianceSelected[i] = id
                                         }
                                    }
                                    if flag == false{
                                        let id = "\(applincesdata.id ?? "")/\(String(describing: AddNewMoodViewController.selectedMood!.CurtanStatus!.rawValue))"
                                        AddNewMoodViewController.selectedMood?.applianceSelected.append(id)
                                     }
                                }
    
                            }
                        }
                    }else if appdata.hederType == "Remote"{
                        for applincesdata in appdata.list{
                            
                            
                                 
                            if applincesdata.SelectedremoteKey?.count ?? 0 > 0{
                                        if (AddNewMoodViewController.selectedMood?.applianceDetails != nil){
                                            AddNewMoodViewController.selectedMood?.applianceDetails! += "\(String(describing: applincesdata.name!)) Keys:"
                                        }else{
                                            AddNewMoodViewController.selectedMood?.applianceDetails = "\(String(describing: applincesdata.name!)) Keys:"
                                        }
                                    }
                            for i in applincesdata.SelectedremoteKey!{
                                        if i.checked == true{
                                            if  AddNewMoodViewController.selectedMood?.remoteCount != nil{
                                                AddNewMoodViewController.selectedMood?.remoteCount! += 1
                                            }else{
                                                AddNewMoodViewController.selectedMood?.remoteCount = 1
                                            }
                            
                                            AddNewMoodViewController.selectedMood?.applianceDetails! +=  "\(i.tag?.rawValue ?? ""),"
                                            if i.command != "aa"{
                                                AddNewMoodViewController.selectedMood?.moodOnStaticCommand.append("\( applincesdata.remoteId!):\(i.command!)")
                                            }else{
                                                print("\(applincesdata.remoteId!):\(i.command!)")
                                                AddNewMoodViewController.selectedMood?.moodOnStaticCommand.append("\( applincesdata.remoteId!):\(i.command!)")
                                            }
                                        }
                                    }
            
                            
//                            if applincesdata.checked == true{
//                                for item in applincesdata.SelectedremoteKey!{
//
//                                }
//                                if  AddNewMoodViewController.selectedMood?.remoteCount != nil{
//                                    AddNewMoodViewController.selectedMood?.remoteCount! += 1
//                                }else{
//                                    AddNewMoodViewController.selectedMood?.remoteCount = 1
//                                }
//
//                            }
                        }
                    }
              }
                let x = AddNewMoodViewController.selectedMood?.applianceSelected
            }
   
    }
}
