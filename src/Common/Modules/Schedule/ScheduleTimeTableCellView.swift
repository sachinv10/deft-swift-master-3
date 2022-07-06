//
//  ScheduleTimeTableCellView.swift
//  DEFT
//
//  Created by Rupendra on 22/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class ScheduleTimeTableCellView: UITableViewCell {
    @IBOutlet weak var scheduleTimeDatePicker: UIDatePicker!
    
    weak var delegate :ScheduleTimeTableCellViewDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.scheduleTimeDatePicker.addTarget(self, action: #selector(self.scheduleTimeDatePickerDidChangeValue(_:)), for: UIControl.Event.valueChanged)
    }
    
    
    func load(scheduleTime pTime :String) {
        let aDateFormatter = DateFormatter()
        aDateFormatter.dateFormat = "HH:mm"
        let aDate = aDateFormatter.date(from: pTime)
        self.scheduleTimeDatePicker.date = aDate ?? Date()
    }
}


extension ScheduleTimeTableCellView {
    
    @objc func scheduleTimeDatePickerDidChangeValue(_ pSender :UIDatePicker) {
        self.delegate?.scheduleTimeTableCellView(self, didChangeValue: self.scheduleTimeDatePicker.date)
    }
    
}


protocol ScheduleTimeTableCellViewDelegate :AnyObject {
    func scheduleTimeTableCellView(_ pSender :ScheduleTimeTableCellView, didChangeValue pValue :Date?)
}
