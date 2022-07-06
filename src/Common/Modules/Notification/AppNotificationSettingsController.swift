//
//  AppNotificationSettingsController.swift
//  Wifinity
//
//  Created by Rupendra on 06/03/21.
//

import UIKit


class AppNotificationSettingsController: BaseController {
    @IBOutlet weak var appNotificationSettingsTableView: AppTableView!
    
    var cellTypes :Array<CellType> = Array<CellType>()
    
    var appNotificationSettings :AppNotificationSettings?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "NOTIFICATION SETTINGS"
        self.subTitle = nil
        
        self.appNotificationSettingsTableView.tableFooterView = UIView()
        self.appNotificationSettingsTableView.delaysContentTouches = false
    }
    
    
    override func reloadAllData() {
        self.fetchAppNotificationSettingsDetails()
    }
    
    
    func reloadAllView() {
        self.cellTypes.removeAll()
        
        self.cellTypes.append(.energyNotification)
        self.cellTypes.append(.informationNotification)
        self.cellTypes.append(.globalOffNotification)
        self.cellTypes.append(.lockNotification)
        self.cellTypes.append(.schedularNotification)
        self.cellTypes.sort(by: {(pLhs, pRhs) in
            return pLhs.rawValue <= pRhs.rawValue
        })
        
        self.appNotificationSettingsTableView.reloadData()
    }
    
    
    private func fetchAppNotificationSettingsDetails() {
        if let aNotificationToken = CacheManager.shared.fcmToken {
            // ProgressOverlay.shared.show()
            DataFetchManager.shared.appNotificationSettingsDetails(completion: { (pError, pAppNotificationSettings) in
                // ProgressOverlay.shared.hide()
                if let anAppNotificationSettings = pAppNotificationSettings {
                    self.appNotificationSettings = anAppNotificationSettings
                } else {
                    PopupManager.shared.displayError(message: "Can not fetch notification settings.", description: pError?.localizedDescription)
                }
                self.reloadAllView()
            }, notificationToken: aNotificationToken)
        } else {
            self.reloadAllView()
            PopupManager.shared.displayError(message: "Push notification permission is not available.", description: nil)
        }
    }
    
    
    func saveAppNotificationSettings(appNotificationSettings pAppNotificationSettings :AppNotificationSettings) {
        let anAppNotificationSettings = pAppNotificationSettings.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.saveAppNotificationSettings(completion: { (pError, pAppNotificationSettings) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                self.reloadAllView()
                PopupManager.shared.displayError(message: "Can not save app notification settings.", description: pError!.localizedDescription)
            } else {
                self.appNotificationSettings = anAppNotificationSettings
                self.reloadAllView()
                PopupManager.shared.displaySuccess(message: "App notification settings saved successfully.", description: nil)
            }
        }, appNotificationSettings: anAppNotificationSettings)
    }
    
    
    enum CellType :String {
        case energyNotification = "Energy Notification"
        case informationNotification = "Information Notification"
        case globalOffNotification = "Global Off Notification"
        case lockNotification = "Lock Notification"
        case schedularNotification = "Schedular Notification"
    }
    
}


extension AppNotificationSettingsController :UITableViewDataSource, UITableViewDelegate {
    
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
            aReturnVal = self.cellTypes.count
        }
        
        return aReturnVal
    }
    
    
    /**
     * Method that will calculate and return height of row at given index path of the table.
     * @return CGFloat. Height of the row at given index path
     */
    func tableView(_ pTableView: UITableView, heightForRowAt pIndexPath: IndexPath) -> CGFloat {
        let aReturnVal :CGFloat = AppNotificationSettingsTableCellView.cellHeight()
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
        
        if pTableView.isEqual(self.appNotificationSettingsTableView) {
            if pIndexPath.row < self.cellTypes.count {
                let aCellType = self.cellTypes[pIndexPath.row]
                let aCellView :AppNotificationSettingsTableCellView = pTableView.dequeueReusableCell(withIdentifier: "AppNotificationSettingsTableCellViewId") as! AppNotificationSettingsTableCellView
                var aValue = false
                switch aCellType {
                case .energyNotification:
                    aValue = self.appNotificationSettings?.isEnergyNotificationSubscribed == true
                case .informationNotification:
                    aValue =  self.appNotificationSettings?.isInformationNotificationSubscribed == true
                case .globalOffNotification:
                    aValue =  self.appNotificationSettings?.isGlobalOffNotificationSubscribed == true
                case .lockNotification:
                    aValue =  self.appNotificationSettings?.isLockNotificationSubscribed == true
                case .schedularNotification:
                    aValue =  self.appNotificationSettings?.isSchedularNotificationSubscribed == true
                }
                aCellView.load(title: aCellType.rawValue, value: aValue)
                aCellView.delegate = self
                aReturnVal = aCellView
            }
        }
        
        if aReturnVal == nil {
            aReturnVal = UITableViewCell()
        }
        
        return aReturnVal!
    }
    
}


extension AppNotificationSettingsController :AppNotificationSettingsTableCellViewDelegate {
    func appNotificationSettingsTableCellView(_ pSender: AppNotificationSettingsTableCellView, didChangeValue pValue: Bool) {
        if let anIndexPath = self.appNotificationSettingsTableView.indexPath(for: pSender), anIndexPath.row < self.cellTypes.count {
            let aCellType = self.cellTypes[anIndexPath.row]
            
            let anAppNotificationSettings = self.appNotificationSettings?.clone() ?? AppNotificationSettings()
            anAppNotificationSettings.fcmToken = CacheManager.shared.fcmToken
            switch aCellType {
            case .energyNotification:
                anAppNotificationSettings.isEnergyNotificationSubscribed = pValue
            case .informationNotification:
                anAppNotificationSettings.isInformationNotificationSubscribed = pValue
            case .globalOffNotification:
                anAppNotificationSettings.isGlobalOffNotificationSubscribed = pValue
            case .lockNotification:
                anAppNotificationSettings.isLockNotificationSubscribed = pValue
            case .schedularNotification:
                anAppNotificationSettings.isSchedularNotificationSubscribed = pValue
            }
            self.saveAppNotificationSettings(appNotificationSettings: anAppNotificationSettings)
        }
    }
}
