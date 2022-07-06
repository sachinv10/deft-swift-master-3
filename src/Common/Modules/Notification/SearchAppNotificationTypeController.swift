//
//  SearchAppNotificationTypeController.swift
//  DEFT
//
//  Created by Rupendra on 08/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SearchAppNotificationTypeController: BaseController {
    @IBOutlet weak var appNotificationTypeTableView: AppTableView!
    @IBOutlet weak var settingsButton: AppFloatingButton!
    
    var appNotificationTypes :Array<AppNotification.AppNotificationType> = Array<AppNotification.AppNotificationType>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "NOTIFICATIONS"
        self.subTitle = "Notification Types"
        
        self.appNotificationTypeTableView.tableFooterView = UIView()
        self.appNotificationTypeTableView.delaysContentTouches = false
    }
    
    
    override func reloadAllData() {
        self.appNotificationTypes.removeAll()
        
        if ConfigurationManager.shared.appType == ConfigurationManager.AppType.deft {
            self.appNotificationTypes.append(AppNotification.AppNotificationType.energyNotification)
            self.appNotificationTypes.append(AppNotification.AppNotificationType.globalOffNotification)
            self.appNotificationTypes.append(AppNotification.AppNotificationType.lockNotification)
            self.appNotificationTypes.append(AppNotification.AppNotificationType.schedularNotification)
            self.appNotificationTypes.append(AppNotification.AppNotificationType.informationNotification)
        } else {
            self.appNotificationTypes.append(AppNotification.AppNotificationType.energyNotification)
            self.appNotificationTypes.append(AppNotification.AppNotificationType.schedularNotification)
            self.appNotificationTypes.append(AppNotification.AppNotificationType.deviceOfflineNotification)
        }
        self.appNotificationTypes.sort(by: {(pLhs, pRhs) in
            return pLhs.rawValue <= pRhs.rawValue
        })
        
        self.reloadAllView()
    }
    
    
    func reloadAllView() {
        self.appNotificationTypeTableView.reloadData()
    }
    
}



extension SearchAppNotificationTypeController {
    
    @IBAction func didSelectSettingsButton(_ pSender: AppFloatingButton?) {
        RoutingManager.shared.gotoAppNotificationSettings(controller: self)
    }
    
}



extension SearchAppNotificationTypeController :UITableViewDataSource, UITableViewDelegate {
    
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
            aReturnVal = self.appNotificationTypes.count
        }
        
        return aReturnVal
    }
    
    
    /**
     * Method that will calculate and return height of row at given index path of the table.
     * @return CGFloat. Height of the row at given index path
     */
    func tableView(_ pTableView: UITableView, heightForRowAt pIndexPath: IndexPath) -> CGFloat {
        let aReturnVal :CGFloat = SearchAppNotificationTypeTableCellView.cellHeight()
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
        
        if pTableView.isEqual(self.appNotificationTypeTableView) {
            if pIndexPath.row < self.appNotificationTypes.count {
                let aNotificationTypes = self.appNotificationTypes[pIndexPath.row]
                let aCellView :SearchAppNotificationTypeTableCellView = pTableView.dequeueReusableCell(withIdentifier: "SearchAppNotificationTypeTableCellViewId") as! SearchAppNotificationTypeTableCellView
                aCellView.load(appNotificationType: aNotificationTypes)
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
        
        if pIndexPath.row < self.appNotificationTypes.count {
            let aSelectedAppNotificationType = self.appNotificationTypes[pIndexPath.row]
            RoutingManager.shared.gotoSearchAppNotification(controller: self, selectedAppNotificationType: aSelectedAppNotificationType)
        }
    }
    
}
