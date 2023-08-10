//
//  SelectAppliancViewController.swift
//  Wifinity
//
//  Created by Apple on 25/05/23.
//

import UIKit
import SwiftUI
class SelectAppliancViewController: BaseController, UITableViewDelegate, UITableViewDataSource {
   
  
    @IBOutlet weak var appliancestableview: AppTableView!
    var selectMood: Array<Mood>?
    var selectApplianc: Array<MoodAppliances>?
    var moods: Array<Mood>?
    var selectedRoom :Room?
   


    var viewCurtain = UIView()
    var lblcutan = UILabel()
    var btnOpen = UIButton()
    var btnClose = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Appliance"
        subTitle = ""
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
            // Model setup
        AddNewMoodViewController.selectApplianc?.removeAll()
        AddNewMoodViewController.selectApplianc = selectApplianc
//        if let data = selectApplianc{
//            for appdata in data{
//                if appdata.hederType == "Appliances"{
//
//                    for applincesdata in appdata.list{
//                        if applincesdata.checked == true
//                        { // applincesdata.checked = false
//                            if  AddNewMoodViewController.selectedMood?.lightCount != nil{
//                            AddNewMoodViewController.selectedMood?.lightCount! += 1
//                            }else{
//                            AddNewMoodViewController.selectedMood?.lightCount = 1
//                            }
//
//                            if AddNewMoodViewController.selectedMood?.applianceSelected.count == 0{
//                                let id = "\(applincesdata.hardwareId ?? "")/\(applincesdata.id ?? "")"
//                                AddNewMoodViewController.selectedMood?.applianceSelected.append(id)
//                            }else{
//                                var flag = false
//                                for i in 0..<(AddNewMoodViewController.selectedMood?.applianceSelected.count ?? 0){
//                                    let id = "\(applincesdata.hardwareId ?? "")/\(applincesdata.id ?? "")"
//                                    if applincesdata.hardwareId?.prefix(10) == AddNewMoodViewController.selectedMood?.applianceSelected[i]!.prefix(10){
//                                        print("hardware is match")
//                                        flag = true
//                                         var x = AddNewMoodViewController.selectedMood?.applianceSelected[i]
//                                         x! += "/\(String(describing: applincesdata.id!))"
//                                        AddNewMoodViewController.selectedMood?.applianceSelected[i] = x
//                                     }
//                                }
//                                if flag == false{
//                                    let id = "\(applincesdata.hardwareId ?? "")/\(applincesdata.id ?? "")"
//                                    AddNewMoodViewController.selectedMood?.applianceSelected.append(id)
//                                 }
//                            }
//                        }
//                    }
//                }else if appdata.hederType == "Curtain"{
//                    for applincesdata in appdata.list{
//                        if applincesdata.checked == true{
//                            print("selected curtain")
//                          //  applincesdata.checked = false
//                            if  AddNewMoodViewController.selectedMood?.curtainCount != nil{
//                                AddNewMoodViewController.selectedMood?.curtainCount! += 1
//                            }else{
//                                AddNewMoodViewController.selectedMood?.curtainCount = 1
//                            }
//
//                            if AddNewMoodViewController.selectedMood?.applianceSelected.count == 0{
//                                let id = "\(applincesdata.id ?? "")/\(String(describing: AddNewMoodViewController.selectedMood!.CurtanStatus!.rawValue))"
//                                AddNewMoodViewController.selectedMood?.applianceSelected.append(id)
//                            }else{
//                                var flag = false
//                                for i in 0..<(AddNewMoodViewController.selectedMood?.applianceSelected.count ?? 0){
//                                    let id = "\(applincesdata.hardwareId ?? "")/\(applincesdata.id ?? "")"
//                                    if applincesdata.hardwareId?.prefix(10) == AddNewMoodViewController.selectedMood?.applianceSelected[i]!.prefix(10){
//                                        print("hardware is match")
//                                        flag = true
//                                        let id = "\(applincesdata.id ?? "")/\(String(describing: AddNewMoodViewController.selectedMood!.CurtanStatus!.rawValue))"
//                                        AddNewMoodViewController.selectedMood?.applianceSelected[i] = id
//                                     }
//                                }
//                                if flag == false{
//                                    let id = "\(applincesdata.id ?? "")/\(String(describing: AddNewMoodViewController.selectedMood!.CurtanStatus!.rawValue))"
//                                    AddNewMoodViewController.selectedMood?.applianceSelected.append(id)
//                                 }
//                            }
//
//                        }
//                    }
//                }else if appdata.hederType == "Remote"{
//                    for applincesdata in appdata.list{
//                        if applincesdata.checked == true{
////                            if  AddNewMoodViewController.selectedMood?.remoteCount != nil{
////                                AddNewMoodViewController.selectedMood?.remoteCount! += 1
////                            }else{
////                                AddNewMoodViewController.selectedMood?.remoteCount = 1
////                            }
//
//                        }
//                    }
//                }
//            }
//            let x = AddNewMoodViewController.selectedMood?.applianceSelected
//        }
    }
    var setioncount = 0
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      //  appliancestableview.display(message: "no appliances data")
        appliancestableview.delegate = self
        appliancestableview.dataSource = self
        appliancestableview.reloadData()
        //===================================
        
        if AddNewMoodViewController.selectApplianc?.count ?? 0 > 0{
            selectApplianc = AddNewMoodViewController.selectApplianc
        }
        
        
     //===================================
        
//        DispatchQueue.main.asyncAfter(deadline:  .now()) {
//
//            if let data = self.selectApplianc{
//                for appdata in data{
//                    if appdata.hederType == "Appliances"{
//
//                        for applincesdata in appdata.list{
//                            if applincesdata.checked == true{
//                                applincesdata.checked = false
//                            }
//                        }
//                    }
//                    if appdata.hederType == "Curtain"{
//                        for applincesdata in appdata.list{
//                            if applincesdata.checked == true{
//                                applincesdata.checked = false
//                            }
//                        }
//                    }
//
//                }
//
//            }
//        }
    }
    override func reloadAllData() {
        print("get moods")
        if selectApplianc?.count ?? 0 <= 0{
            ProgressOverlay.shared.show()
            DataFetchManager.shared.selectAppliances(completion: { (pError, pMoodArray) in
                ProgressOverlay.shared.hide()
                if pError != nil {
                    PopupManager.shared.displayError(message: "Can not search moods", description: pError!.localizedDescription)
                } else {
                    if pMoodArray != nil && pMoodArray!.count > 0 {
                        print(pMoodArray)
                        self.selectApplianc = pMoodArray
                        self.appliancestableview.reloadData()
                    }
                }
            }, room: selectedRoom)
        }
    }
}
extension SelectAppliancViewController{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return selectApplianc?.count ?? 0 // title.counet
    }
    // title
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return   selectApplianc?[section].hederType
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectApplianc?[section].list.count ?? 0 //sub title count
    }
    
    // sub title
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = appliancestableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text =  selectApplianc?[indexPath.section].list[indexPath.row].name
        if let x = selectApplianc?[indexPath.section].list[indexPath.row]{
           if x.checked == true{
               cell.accessoryType = .checkmark
           }else{
               cell.accessoryType = .none
           }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        if "Appliances" == selectApplianc?[indexPath.section].hederType{
            if cell.accessoryType == .checkmark{
                cell.accessoryType = .none
                if let x = selectApplianc?[indexPath.section].list[indexPath.row]{
                    x.checked = false
                }
                let sentence = AddNewMoodViewController.selectedMood?.applianceDetails
                var indexToRemove = Int()
                var words = sentence?.components(separatedBy: ",") as? [String]
                for i in stride(from: 0, to: words?.count ?? 0, by: 1){
                    let ws = words?[i]
                    if ws == (selectApplianc?[indexPath.section].list[indexPath.row].name)!{
                        indexToRemove = i
                        break
                    }
                }
                // Remove the word at the desired index
                if indexToRemove >= 0 && indexToRemove < words?.count ?? 0 {
                    words?.remove(at: indexToRemove)
                }
                // Join the words back into a string
                let updatedSentence = words?.joined(separator: ",")
                print(updatedSentence)
                AddNewMoodViewController.selectedMood?.applianceDetails = updatedSentence
            }else{
                cell.accessoryType = .checkmark
                if let x = selectApplianc?[indexPath.section].list[indexPath.row]{
                    x.checked = true
                }
                if (AddNewMoodViewController.selectedMood?.applianceDetails != nil){
                    AddNewMoodViewController.selectedMood?.applianceDetails! += "\((selectApplianc?[indexPath.section].list[indexPath.row].name)!),"
                }else{
                    AddNewMoodViewController.selectedMood?.applianceDetails = "\((selectApplianc?[indexPath.section].list[indexPath.row].name)!),"
                }
            }
        }
 
        if "Curtain" == selectApplianc?[indexPath.section].hederType{
   
            
                if cell.accessoryType == .checkmark{
                    cell.accessoryType = .none
                    if let x = selectApplianc?[indexPath.section].list[indexPath.row]{
                        selectApplianc?[indexPath.section].list[indexPath.row].checked = false
                    }
                    
                    let sentence = AddNewMoodViewController.selectedMood?.applianceDetails
                    var indexToRemove = Int()
                    var words = sentence?.components(separatedBy: ",") as? [String]
                    for i in stride(from: 0, to: words?.count ?? 0, by: 1){
                        let ws = words?[i]
                        let x = ws?.components(separatedBy: " to") as? [String]
                       let xy = x?.first
                        if xy == (selectApplianc?[indexPath.section].list[indexPath.row].name)!{
                            indexToRemove = i
                            break
                        }
                    }
                    // Remove the word at the desired index
                    if indexToRemove >= 0 && indexToRemove < words?.count ?? 0 {
                        words?.remove(at: indexToRemove)
                    }
                    // Join the words back into a string
                    let updatedSentence = words?.joined(separator: ",")
                    print(updatedSentence)
                    AddNewMoodViewController.selectedMood?.applianceDetails = updatedSentence
                    // AddNewMoodViewController.selectedMood?.applianceDetails += ""
                }else{
                    cell.accessoryType = .checkmark
                    if curtainState(mood: (selectApplianc?[indexPath.section].list[indexPath.row])!, cell: cell) != nil{
                    if let x = selectApplianc?[indexPath.section].list[indexPath.row]{
                        selectApplianc?[indexPath.section].list[indexPath.row].checked = true
                    }
                        if (AddNewMoodViewController.selectedMood?.applianceDetails != nil){
                        AddNewMoodViewController.selectedMood?.applianceDetails! += "\((selectApplianc?[indexPath.section].list[indexPath.row].name)!)"
                    }else{
                        AddNewMoodViewController.selectedMood?.applianceDetails = "\((selectApplianc?[indexPath.section].list[indexPath.row].name)!)"
                    }
                }
            }
        }
        if "Remote" == selectApplianc?[indexPath.section].hederType{
            RoutingManager.shared.SelectRemoteKeys(controller: self, room: selectedRoom,applist: (selectApplianc?[indexPath.section].list[indexPath.row])!, pindex: indexPath)
            if let x = selectApplianc?[indexPath.section].list[indexPath.row]{
                selectApplianc?[indexPath.section].list[indexPath.row].checked = true
            }
        }
        
    }
//    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        return view.backgroundColor = .yellow
//    }
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.backgroundColor = .orange
//    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
            headerView.backgroundColor = UIColor.lightGray
            
            let label = UILabel(frame: CGRect(x: 16, y: 0, width: headerView.frame.width - 16, height: headerView.frame.height))
             label.text = selectApplianc?[section].hederType
            label.textColor = UIColor.black
            
            headerView.addSubview(label)
            
            return headerView
        }
}
extension SelectAppliancViewController{
    func curtainState(mood: applianeslist, cell: UITableViewCell)->Bool
    {  if let selectedIndexPath = appliancestableview.indexPath(for: cell) {
        print("cell session=\(selectedIndexPath.section) cell row= \(selectedIndexPath.row)")
    }
//        viewCurtain.frame = CGRect(x: 10, y: view.frame.height / 3, width: view.frame.width * 90 / 100, height: 200)
//        self.view.addSubview(viewCurtain)
        viewCurtain.isHidden = false
        viewCurtain.frame = CGRect(x: 70, y: appliancestableview.frame.height / 3, width: view.frame.width - 140, height: 90)
        viewCurtain.backgroundColor = .gray
        viewCurtain.layer.cornerRadius = 15
        viewCurtain.layer.borderWidth = 0.5
        viewCurtain.layer.borderColor = UIColor.black.cgColor
        var lbl = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.width - 10, height: 45))
        lbl.text = mood.name
        lbl.textColor = .white
        viewCurtain.addSubview(lbl)
        btnOpen.frame = CGRect(x: 0, y: 45, width: viewCurtain.frame.width / 2, height: 45)
        btnClose.frame =  CGRect(x: viewCurtain.frame.width / 2, y: 45, width: viewCurtain.frame.width / 2, height: 45)
   
        btnOpen.setTitle("Open", for: .normal)
        btnOpen.backgroundColor = .clear
        btnOpen.layer.borderColor = UIColor.white.cgColor
        btnOpen.layer.borderWidth = 0.5
        btnOpen.clipsToBounds = true
    // btnDelete.tintColor = .black
        btnOpen.addTarget(self, action:   #selector(deletefunc),   for: .touchUpInside)

        btnClose.setTitle("close", for: .normal)
        btnClose.backgroundColor = .clear
        btnClose.layer.borderColor = UIColor.white.cgColor
        btnClose.layer.borderWidth = 0.5
        btnClose.clipsToBounds = true
    // btnViewApplainces.tintColor = .black
        btnClose.addTarget(self, action:   #selector(viewAppliances),   for: .touchUpInside)
        viewCurtain.addSubview(btnOpen)
        viewCurtain.addSubview(btnClose)
        appliancestableview.addSubview(viewCurtain)
        return true
    }
    @objc func deletefunc(){
        viewCurtain.isHidden = true
        AddNewMoodViewController.selectedMood?.CurtanStatus = .On
        AddNewMoodViewController.selectedMood?.applianceDetails! += " to level 2,"
    }
    @objc func viewAppliances(){
        viewCurtain.isHidden = true
        AddNewMoodViewController.selectedMood?.CurtanStatus = .Off
        AddNewMoodViewController.selectedMood?.applianceDetails! += " to level 1,"

    }
   
}
extension SelectAppliancViewController: DataDelegate{
    func didFinishWithData(data: Any) {
           // Process the received data here
        print("Process the received data here")
           print(data)
       }
}
