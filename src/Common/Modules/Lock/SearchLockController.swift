//
//  SearchLockController.swift
//  DEFT
//
//  Created by Rupendra on 08/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit
import FirebaseAuth

class SearchLockController: BaseController {
    @IBOutlet weak var lockTableView: AppTableView!
    
    var locks :Array<Lock> = Array<Lock>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "LOCKS"
        self.subTitle = nil
        
        self.lockTableView.tableFooterView = UIView()
        self.lockTableView.delaysContentTouches = false
        if Auth.auth().currentUser?.uid == "PNCl5uSBBEN6zAE7I3vWvGWFdHi1"{
          //  openApp(appName: "")
            checkAndOpenApp()
//            let appURL = URL(string: "https://apps.apple.com/in/app/smart-life-smart-living/id1115101477")
//            if let appURL = appURL, UIApplication.shared.canOpenURL(appURL) {
//                UIApplication.shared.open(appURL, options: [:], completionHandler: { success in
//                    if success {
//                        print("Successfully opened the installed app.")
//                    } else {
//                        print("Failed to open the installed app.")
//                    }
//                })
//            }
        }
    }
    
    func checkAndOpenApp(){
        let app = UIApplication.shared
        let vs = "SmartLife-SmartLiving"
        if let xurl = encodeURL(vs){
        let appScheme = "\(xurl)://app"
        if app.canOpenURL(URL(string: appScheme)!) {
            print("App is install and can be opened")
            let url = URL(string:appScheme)!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            print("App in not installed. Go to AppStore")
            if let url = URL(string: "https://apps.apple.com/in/app/smart-life-smart-living/id1115101477"),
                UIApplication.shared.canOpenURL(url)
            {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        }
    }
      
    func encodeURL(_ urlString: String) -> URL? {
        // Encode the entire URL
        if let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let encodedURL = URL(string: encodedString) {
            return encodedURL
        }
        return nil
    }
    
    override func reloadAllData() {
        self.locks.removeAll()
        
        self.searchLock()
    }
    
    
    func reloadAllView() {
        if self.locks.count <= 0 {
            self.lockTableView.display(message: "No Lock Available")
        } else {
            self.lockTableView.hideMessage()
        }
        self.lockTableView.reloadData()
    }
    
    
    private func searchLock() {
        // ProgressOverlay.shared.show()
        DataFetchManager.shared.searchLock(completion: { (pError, pLockArray) in
            // ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not search locks", description: pError!.localizedDescription)
            } else {
                if pLockArray != nil && pLockArray!.count > 0 {
                    self.locks = pLockArray!
                }
                self.reloadAllView()
                //lock implimentation
            }
        })
    }
    
    
    func updateLockState(lock pLock :Lock, lockState pLockState :Bool) {
        var aLockPassword :String? = nil
        if ConfigurationManager.shared.appType == ConfigurationManager.AppType.wifinity {
            aLockPassword = pLock.password
        } else {
            if pLock.hardwareType != Device.HardwareType.gateLock {
                aLockPassword = DataFetchManager.shared.loggedInUser?.lockPassword
            }
        }
        
        if (aLockPassword?.count ?? 0) > 0 {
            let anAlertController = UIAlertController(title: "Please enter your lock pin", message: nil, preferredStyle: .alert)
            anAlertController.addTextField { textField in
                textField.placeholder = "Pin"
                textField.isSecureTextEntry = true
                textField.keyboardType = UIKeyboardType.phonePad
            }
            
            let anOkAction = UIAlertAction(title: "OK", style: .default) { [weak anAlertController] _ in
                let aPassword = anAlertController?.textFields?.first?.text
                if aPassword == aLockPassword {
                    self._updateLockState(lock: pLock, lockState: pLockState)
                } else {
                    let anErrorAlertController = UIAlertController(title: "Invalid Pin!", message: nil, preferredStyle: .alert)
                    anErrorAlertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
                    self.present(anErrorAlertController, animated: true, completion: nil)
                }
            }
            anAlertController.addAction(anOkAction)
            
            let aCancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
            anAlertController.addAction(aCancelAction)
            self.present(anAlertController, animated: true, completion: {
                self.reloadAllView()
            })
        } else {
            self._updateLockState(lock: pLock, lockState: pLockState)
        }
    }
    
    func _updateLockState(lock pLock :Lock, lockState pLockState :Bool) {
        let aLock = pLock.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateLockState(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update lock.", description: pError!.localizedDescription)
            } else {
                // pLock.isOpen = pLockState // This will refresh automatically after server updates the state
                self.reloadAllView()
            }
        }, lock: aLock)
    }
    
}



extension SearchLockController :UITableViewDataSource, UITableViewDelegate {
    
    // MARK:- UITableView Methods
    
    /**
     * Method that will calculate and return number of section in given table.
     * @return Int. Number of section in given table
     */
    func numberOfSections(in pTableView: UITableView) -> Int {
        return 1
    }
    
    
    /**
     * Method that will calculate and return number of rows in given section of the table.
     * @return Int. Number of rows in given section
     */
    func tableView(_ pTableView: UITableView, numberOfRowsInSection pSection: Int) -> Int {
        var aReturnVal :Int = 0
        
        if pSection == 0 {
            aReturnVal = self.locks.count
        }
        
        return aReturnVal
    }
    
    
    /**
     * Method that will calculate and return height of row at given index path of the table.
     * @return CGFloat. Height of the row at given index path
     */
    func tableView(_ pTableView: UITableView, heightForRowAt pIndexPath: IndexPath) -> CGFloat {
        let aReturnVal :CGFloat = SearchLockTableCellView.cellHeight()
        return aReturnVal
    }
    
    
    /**
     * Method that will calculate and return height of row at given index path of the table.
     * @return CGFloat. Height of the row at given index path
     */
    func tableView(_ pTableView: UITableView, estimatedHeightForRowAt pIndexPath: IndexPath) -> CGFloat {
        let aReturnVal :CGFloat = UITableView.automaticDimension
        return aReturnVal
    }
    
    
    /**
     * Method that will init, set and return the cell view.
     * @return UITableViewCell. View of the cell in given table view.
     */
    func tableView(_ pTableView: UITableView, cellForRowAt pIndexPath: IndexPath) -> UITableViewCell {
        var aReturnVal :UITableViewCell?
        
        if pTableView.isEqual(self.lockTableView) {
            if pIndexPath.row < self.locks.count {
                let aLock = self.locks[pIndexPath.row]
                let aCellView :SearchLockTableCellView = pTableView.dequeueReusableCell(withIdentifier: "SearchLockTableCellViewId") as! SearchLockTableCellView
                aCellView.load(lock: aLock)
                aCellView.delegate = self
                aReturnVal = aCellView
            }
        }
        
        if aReturnVal == nil {
            aReturnVal = UITableViewCell()
        }
        
        return aReturnVal!
    }
    
    
    /**
     * Method that will be called when user selects a table cell.
     */
    func tableView(_ pTableView: UITableView, didSelectRowAt pIndexPath: IndexPath) {
        pTableView.deselectRow(at: pIndexPath, animated: true)
    }
    
}



extension SearchLockController :SearchLockTableCellViewDelegate {
    
    func cellView(_ pSender: SearchLockTableCellView, didChangeLockState pLockState: Bool) {
        if let anIndexPath = self.lockTableView.indexPath(for: pSender), anIndexPath.row < self.locks.count {
            let aLock = self.locks[anIndexPath.row]
            self.updateLockState(lock: aLock, lockState: pLockState)
        }
        
    }
}
