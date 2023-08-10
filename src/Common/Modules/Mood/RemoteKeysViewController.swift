//
//  RemoteKeysViewController.swift
//  Wifinity
//
//  Created by Apple on 01/06/23.
//

import UIKit
import Foundation
protocol DataDelegate: AnyObject {
    func didFinishWithData(data: Any)
}

class RemoteKeysViewController: BaseController, UITableViewDataSource, UITableViewDelegate {
    weak var delegate: DataDelegate?
    var indexpath: IndexPath? = nil

    var selectApplianc: applianeslist?
    var selectedRoom :Room?
    var selectMood: Array<Mood>?
    
    @IBOutlet weak var RemoteKeysDetail: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Remote keys"
        subTitle = ""
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear")
        let remote = remoteKey
        delegate?.didFinishWithData(data: remoteKey)
        
        if let remote = remoteKey{
            if 0 < (AddNewMoodViewController.remoteKey?.count ?? 0){
                var flag = false
                for i in  0..<(AddNewMoodViewController.remoteKey?.count ?? 0){
                if AddNewMoodViewController.remoteKey?[i].first?.remoteId == (remote.first?.remoteId)!{
                    AddNewMoodViewController.remoteKey?.remove(at: i)
                    AddNewMoodViewController.remoteKey?.append(remote)
                    flag = true
                }
            }
               if flag == false{
                   AddNewMoodViewController.remoteKey?.append(remote)
                }
            }else{
                   AddNewMoodViewController.remoteKey?.append(remote)
            }
            for item in remote{
                if item.checked == true{
                    SelectedremoteKey?.append(item)
                }
            }
//            AddNewMoodViewController.remoteKey?.removeAll()
//            AddNewMoodViewController.remoteKey?.append(remote)
        }
        if let appdata = SelectedremoteKey{
          //  AddNewMoodViewController.SelectedremoteKey = appdata
            print("selected data= \(appdata.count)")
            AddNewMoodViewController.selectApplianc?[indexpath!.section].list[indexpath!.row].SelectedremoteKey = SelectedremoteKey
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.didFinishWithData(data: remoteKey)
     
       // selectApplianc?[indexpath.section].list[indexpath.row]
      print("viewWillDisappear")
//
//        if let remote = remoteKey{
//            if 0 < (AddNewMoodViewController.remoteKey?.count ?? 0){
//                var flag = false
//                for i in  0..<(AddNewMoodViewController.remoteKey?.count ?? 0){
//                if AddNewMoodViewController.remoteKey?[i].first?.remoteId == (remote.first?.remoteId)!{
//                    AddNewMoodViewController.remoteKey?.remove(at: i)
//                    AddNewMoodViewController.remoteKey?.append(remote)
//                    flag = true
//                }
//            }
//               if flag == false{
//                   AddNewMoodViewController.remoteKey?.append(remote)
//                }
//            }else{
//                   AddNewMoodViewController.remoteKey?.append(remote)
//            }
//            for item in remote{
//                if item.checked == true{
//                    SelectedremoteKey?.append(item)
//                }
//            }
////            AddNewMoodViewController.remoteKey?.removeAll()
////            AddNewMoodViewController.remoteKey?.append(remote)
//        }
        
//        if let appdata = SelectedremoteKey{
//          //  AddNewMoodViewController.SelectedremoteKey = appdata
//            print("selected data= \(appdata.count)")
//            AddNewMoodViewController.selectApplianc?[indexpath!.section].list[indexpath!.row].SelectedremoteKey = SelectedremoteKey
//        }
//        let appid = selectApplianc
//        let rooms = selectedRoom
//        if SelectedremoteKey?.count ?? 0 > 0{
//            if (AddNewMoodViewController.selectedMood?.applianceDetails != nil){
//                AddNewMoodViewController.selectedMood?.applianceDetails! += "\(String(describing: appid!.name!)) Keys:"
//            }else{
//                AddNewMoodViewController.selectedMood?.applianceDetails = "\(String(describing: appid!.name!)) Keys:"
//            }
//        }
//        for i in SelectedremoteKey!{
//            if i.checked == true{
//                if  AddNewMoodViewController.selectedMood?.remoteCount != nil{
//                    AddNewMoodViewController.selectedMood?.remoteCount! += 1
//                }else{
//                    AddNewMoodViewController.selectedMood?.remoteCount = 1
//                }
//
//                AddNewMoodViewController.selectedMood?.applianceDetails! +=  "\(i.tag?.rawValue ?? ""),"
//                if i.command != "aa"{
//                    AddNewMoodViewController.selectedMood?.moodOnStaticCommand.append("\( appid!.remoteId!):\(i.command!)")
//                }else{
//                    print("\(appid!.remoteId!):\(i.command!)")
//                    AddNewMoodViewController.selectedMood?.moodOnStaticCommand.append("\( appid!.remoteId!):\(i.command!)")
//                }
//            }
//        }
//      let data = AddNewMoodViewController.selectedMood
//        print(data)
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let app = selectApplianc
        for i in AddNewMoodViewController.remoteKey!{

        if app?.id == i.first?.remoteId{
            remoteKey?.append(contentsOf: i)
        }
        }
        if let appdata = AddNewMoodViewController.SelectedremoteKey{
            SelectedremoteKey = appdata
        }
        RemoteKeysDetail.dataSource = self
        RemoteKeysDetail.delegate = self
       // usefull
        let appid = selectApplianc
        let rooms = selectedRoom
        let mood = selectMood
        
    }
    var remoteKey: Array<RemoteKey>? = Array<RemoteKey>()
    var SelectedremoteKey: Array<RemoteKey>? = Array<RemoteKey>()
    override func reloadAllData() {
        if remoteKey?.count ?? 0 <= 0{
            print("get remote keys")
            ProgressOverlay.shared.show()
            DataFetchManager.shared.selectRemoteKeys(completion: { (pError, pMoodArray) in
                ProgressOverlay.shared.hide()
                if pError != nil {
                    PopupManager.shared.displayError(message: "Can not search moods", description: pError!.localizedDescription)
                } else {
                    if pMoodArray != nil && pMoodArray!.count > 0 {
                        print(pMoodArray)
                        self.remoteKey?.append(contentsOf: pMoodArray!)
                        self.RemoteKeysDetail.reloadData()
                    }
                }
            }, room: selectedRoom, applianeslist: selectApplianc!)
        }else{
            RemoteKeysDetail.reloadData()
        }
    }

}
extension RemoteKeysViewController{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return remoteKey?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if ((remoteKey?[indexPath.row].tag?.rawValue) != nil){
            cell.textLabel?.text = remoteKey?[indexPath.row].tag?.rawValue
        }else{
            cell.textLabel?.text = remoteKey?[indexPath.row].title
        }
        let remote = remoteKey?[indexPath.row]
        if remote?.checked == true{
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let remote = remoteKey?[indexPath.row]
        let selected = SelectedremoteKey
        if remote?.checked == true{
            let unSelect = remoteKey?[indexPath.row] 
            unSelect?.checked = false
            unSelect?.clone()
            if let index = SelectedremoteKey?.firstIndex(of: unSelect!) {
                SelectedremoteKey?.remove(at: index)
                print("Removed 'banana' from the array")
            } else {
                print("'banana' not found in the array")
            }
             cell.accessoryType = .none
        }else{
            remoteKey?[indexPath.row].checked = true
           // unSelect?.checked = true
         //   SelectedremoteKey?.append((remoteKey?[indexPath.row])!)
            cell.accessoryType = .checkmark
        }
    }
}
