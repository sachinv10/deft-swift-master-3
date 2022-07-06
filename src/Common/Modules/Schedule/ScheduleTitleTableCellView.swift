//
//  ScheduleTitleTableCellView.swift
//  DEFT
//
//  Created by Rupendra on 22/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class ScheduleTitleTableCellView: UITableViewCell {
    @IBOutlet weak var titleTextField: UITextField!
    
    weak var delegate :ScheduleTitleTableCellViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleTextField.delegate = self
        self.titleTextField.addTarget(self, action: #selector(self.titleTextFieldDidChangeValue(_:)), for: UIControl.Event.editingChanged)
    }
    
    
    func load(scheduleTitle pTitle :String) {
        self.titleTextField.text = pTitle
    }
}


extension ScheduleTitleTableCellView :UITextFieldDelegate {
    
    @objc func titleTextFieldDidChangeValue(_ pSender :UITextField) {
        self.delegate?.scheduleTitleTableCellView(self, didChangeValue: self.titleTextField.text)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        return true
    }
    
}


protocol ScheduleTitleTableCellViewDelegate :AnyObject {
    func scheduleTitleTableCellView(_ pSender :ScheduleTitleTableCellView, didChangeValue pValue :String?)
}
