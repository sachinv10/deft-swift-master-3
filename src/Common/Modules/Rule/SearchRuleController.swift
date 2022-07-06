//
//  SearchRuleController.swift
//  DEFT
//
//  Created by Rupendra on 08/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SearchRuleController: BaseController {
    @IBOutlet weak var ruleTableView: AppTableView!
    
    var rules :Array<Rule> = Array<Rule>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "RULES"
        self.subTitle = nil
        
        self.ruleTableView.tableFooterView = UIView()
        self.ruleTableView.delaysContentTouches = false
    }
    
    override func reloadAllData() {
        self.rules.removeAll()
        
        self.searchRule()
    }
    
    
    func reloadAllView() {
        if self.rules.count <= 0 {
            self.ruleTableView.display(message: "No Rule Available")
        } else {
            self.ruleTableView.hideMessage()
        }
        self.ruleTableView.reloadData()
    }
    
    
    func searchRule() {
        // ProgressOverlay.shared.show()
        DataFetchManager.shared.searchRule(completion: { (pError, pRuleArray) in
            // ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not search rules", description: pError!.localizedDescription)
            } else {
                if pRuleArray != nil && pRuleArray!.count > 0 {
                    self.rules = pRuleArray!
                }
                self.reloadAllView()
            }
        })
    }
    
    
    func updateRuleState(rule pRule :Rule, state pState :Bool) {
        let aRule = pRule.clone()
        
        // ProgressOverlay.shared.show()
        DataFetchManager.shared.updateRuleState(completion: { (pError) in
            // ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update rule.", description: pError!.localizedDescription)
            } else {
                pRule.isOn = pState
            }
            self.reloadAllView()
        }, rule: aRule, state: pState)
    }
    
}



extension SearchRuleController :UITableViewDataSource, UITableViewDelegate {
    
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
            aReturnVal = self.rules.count
        }
        
        return aReturnVal
    }
    
    
    /**
     * Method that will calculate and return height of row at given index path of the table.
     * @return CGFloat. Height of the row at given index path
     */
    func tableView(_ pTableView: UITableView, heightForRowAt pIndexPath: IndexPath) -> CGFloat {
        let aReturnVal :CGFloat = SearchRuleTableCellView.cellHeight()
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
        
        if pTableView.isEqual(self.ruleTableView) {
            if pIndexPath.row < self.rules.count {
                let aRule = self.rules[pIndexPath.row]
                let aCellView :SearchRuleTableCellView = pTableView.dequeueReusableCell(withIdentifier: "SearchRuleTableCellViewId") as! SearchRuleTableCellView
                aCellView.load(rule: aRule)
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


extension SearchRuleController :SearchRuleTableCellViewDelegate {
    
    func cellView(_ pSender: SearchRuleTableCellView, didChangeState pState :Bool) {
        if let anIndexPath = self.ruleTableView.indexPath(for: pSender), anIndexPath.row < self.rules.count {
            let aRule = self.rules[anIndexPath.row]
            self.updateRuleState(rule: aRule, state: pState)
        }
    }
    
}
