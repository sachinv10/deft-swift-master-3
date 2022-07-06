//
//  SearchAppNotificationController.swift
//  DEFT
//
//  Created by Rupendra on 08/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SearchAppNotificationController: BaseController {
    @IBOutlet weak var appNotificationTableView: AppTableView!
    
    var currentPageNumber :Int = 0
    var isLastPage :Bool = false
    var isReloadedOnce :Bool = false
    var selectedAppNotificationType :AppNotification.AppNotificationType?
    var selectedHardwareId :String?
    var appNotifications :Array<AppNotification> = Array<AppNotification>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "NOTIFICATIONS"
        self.subTitle = self.selectedAppNotificationType?.rawValue
        
        self.appNotificationTableView.tableFooterView = UIView()
        self.appNotificationTableView.delaysContentTouches = false
    }
    
    
    override func reloadAllData() {
        self.appNotifications.removeAll()
        
        if let anAppNotificationType = self.selectedAppNotificationType
           , self.isReloadedOnce == false {
            self.isReloadedOnce = true
            self.isLastPage = false
            self.searchAppNotification(appNotificationType: anAppNotificationType, hardwareId: self.selectedHardwareId)
        }
    }
    
    
    private func searchAppNotification(appNotificationType pAppNotificationType :AppNotification.AppNotificationType, hardwareId pHardwareId :String?) {
        // ProgressOverlay.shared.show()
        DataFetchManager.shared.searchAppNotification(completion: { (pError, pAppNotificationArray) in
            // ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not search notification", description: pError!.localizedDescription)
            } else {
                if pAppNotificationArray != nil && pAppNotificationArray!.count > 0 {
                    self.isLastPage = false
                    if self.currentPageNumber == 0 {
                        self.appNotifications = pAppNotificationArray!
                    } else {
                        self.appNotifications.append(contentsOf: pAppNotificationArray!)
                    }
                } else {
                    self.isLastPage = true
                }
                self.reloadAllView()
            }
        }, appNotificationType: pAppNotificationType, hardwareId: pHardwareId, pageNumber: self.currentPageNumber)
    }
    
    
    func reloadAllView() {
        if self.appNotifications.count <= 0 {
            self.appNotificationTableView.display(message: "No Notifications Available")
        } else {
            self.appNotificationTableView.hideMessage()
        }
        self.appNotificationTableView.reloadData()
    }
    
}



extension SearchAppNotificationController :UITableViewDataSource, UITableViewDelegate {
    
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
            aReturnVal = self.appNotifications.count
        }
        
        return aReturnVal
    }
    
    
    /**
     * Method that will calculate and return height of row at given index path of the table.
     * @return CGFloat. Height of the row at given index path
     */
    func tableView(_ pTableView: UITableView, heightForRowAt pIndexPath: IndexPath) -> CGFloat {
        let aReturnVal :CGFloat = UITableView.automaticDimension
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
        
        if pTableView.isEqual(self.appNotificationTableView) {
            if pIndexPath.row < self.appNotifications.count {
                let aNotification = self.appNotifications[pIndexPath.row]
                let aCellView :SearchAppNotificationTableCellView = pTableView.dequeueReusableCell(withIdentifier: "SearchAppNotificationTableCellViewId") as! SearchAppNotificationTableCellView
                aCellView.load(appNotification: aNotification)
                aReturnVal = aCellView
            }
        }
        
        if aReturnVal == nil {
            aReturnVal = UITableViewCell()
        }
        
        return aReturnVal!
    }
    
    
    /**
     * Method that will be called when a table cell is about to display.
     */
    func tableView(_ pTableView: UITableView, willDisplay pCell: UITableViewCell, forRowAt pIndexPath: IndexPath) {
        if pIndexPath.row == self.appNotifications.count - 1 && self.isLastPage == false {
            if let anAppNotificationType = self.selectedAppNotificationType {
                self.currentPageNumber += 1
                self.searchAppNotification(appNotificationType: anAppNotificationType, hardwareId: self.selectedHardwareId)
            }
        }
    }
    
    
    /**
     * Method that will be called when user selects a table cell.
     */
    func tableView(_ pTableView: UITableView, didSelectRowAt pIndexPath: IndexPath) {
        pTableView.deselectRow(at: pIndexPath, animated: true)
    }
    
}
