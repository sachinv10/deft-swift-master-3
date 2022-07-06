//
//  MoodTitleTableCellView.swift
//  DEFT
//
//  Created by Rupendra on 22/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class MoodTitleTableCellView: UITableViewCell {
    @IBOutlet weak var titleTextField: UITextField!
    
    weak var delegate :MoodTitleTableCellViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleTextField.delegate = self
        self.titleTextField.addTarget(self, action: #selector(self.titleTextFieldDidChangeValue(_:)), for: UIControl.Event.editingChanged)
    }
    
    
    func load(moodTitle pTitle :String) {
        self.titleTextField.text = pTitle
    }
}


extension MoodTitleTableCellView :UITextFieldDelegate {
    
    @objc func titleTextFieldDidChangeValue(_ pSender :UITextField) {
        self.delegate?.moodTitleTableCellView(self, didChangeValue: self.titleTextField.text)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        return true
    }
    
}


protocol MoodTitleTableCellViewDelegate :AnyObject {
    func moodTitleTableCellView(_ pSender :MoodTitleTableCellView, didChangeValue pValue :String?)
}
