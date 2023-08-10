//
//  ScheduleRepeatTableCellView.swift
//  DEFT
//
//  Created by Rupendra on 22/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class ScheduleRepeatTableCellView: UITableViewCell {
    @IBOutlet weak var sundayButton: UIButton!
    @IBOutlet weak var mondayButton: UIButton!
    @IBOutlet weak var tuesdayButton: UIButton!
    @IBOutlet weak var wednesdayButton: UIButton!
    @IBOutlet weak var thursdayButton: UIButton!
    @IBOutlet weak var fridayButton: UIButton!
    @IBOutlet weak var saturdayButton: UIButton!
    @IBOutlet weak var repeatOncebtn: AppSwitch!
    
    var days :Array<Schedule.Day>?
    
    weak var delegate :ScheduleRepeatTableCellViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        self.reloadAllView()
    }
    
    
    func setNormalState(button pButton :UIButton) {
        pButton.layer.cornerRadius = 4.0
        pButton.layer.borderWidth = 1.0
        pButton.layer.borderColor = UIColor(named: "ControlNormalColor")?.cgColor
        pButton.backgroundColor = UIColor(named: "SecondaryLightestColor")
        pButton.setTitleColor(UIColor(named: "ControlNormalColor"), for: UIControl.State.normal)
    }
    
    
    func setSelectedState(button pButton :UIButton) {
        pButton.layer.cornerRadius = 4.0
        pButton.layer.borderWidth = 1.0
        pButton.layer.borderColor = UIColor(named: "ControlCheckedColor")?.cgColor
        pButton.backgroundColor = UIColor(named: "ControlCheckedColor")
        pButton.setTitleColor(UIColor(named: "SecondaryLightestColor"), for: UIControl.State.normal)
    }
    
    
    func reloadAllView() {
        self.setNormalState(button: self.sundayButton)
        self.setNormalState(button: self.mondayButton)
        self.setNormalState(button: self.tuesdayButton)
        self.setNormalState(button: self.wednesdayButton)
        self.setNormalState(button: self.thursdayButton)
        self.setNormalState(button: self.fridayButton)
        self.setNormalState(button: self.saturdayButton)
        
        if let aDayArray = self.days {
            for aDay in aDayArray {
                switch aDay {
                case .sunday:
                    self.setSelectedState(button: self.sundayButton)
                case .monday:
                    self.setSelectedState(button: self.mondayButton)
                case .tuesday:
                    self.setSelectedState(button: self.tuesdayButton)
                case .wednesday:
                    self.setSelectedState(button: self.wednesdayButton)
                case .thursday:
                    self.setSelectedState(button: self.thursdayButton)
                case .friday:
                    self.setSelectedState(button: self.fridayButton)
                case .saturday:
                    self.setSelectedState(button: self.saturdayButton)
                }
            }
        }
    }
    
    
    func load(scheduleDays pDayArray :Array<Schedule.Day>, scheduler: Bool) {
        self.days = pDayArray
        self.reloadAllView()
        self.repeatOncebtn.isOn = scheduler

    }
    @IBAction func onOffSwitchDidChangeValue(_ pSender: AppSwitch) {
        self.delegate?.scheduleRepeatTableCellView(self, didChangeValue: self.days)
    }
}


extension ScheduleRepeatTableCellView {
    
    @IBAction func didSelectDayButton(_ pSender: UIButton?) {
        var aDay = Schedule.Day.sunday
         if self.sundayButton.isEqual(pSender) {
            aDay = Schedule.Day.sunday
        } else if self.mondayButton.isEqual(pSender) {
            aDay = Schedule.Day.monday
        } else if self.tuesdayButton.isEqual(pSender) {
            aDay = Schedule.Day.tuesday
        } else if self.wednesdayButton.isEqual(pSender) {
            aDay = Schedule.Day.wednesday
        } else if self.thursdayButton.isEqual(pSender) {
            aDay = Schedule.Day.thursday
        } else if self.fridayButton.isEqual(pSender) {
            aDay = Schedule.Day.friday
        } else if self.saturdayButton.isEqual(pSender) {
            aDay = Schedule.Day.saturday
        }
        
        var aDayArray = self.days ?? Array<Schedule.Day>()
        if let anIndex = aDayArray.firstIndex(of: aDay) {
            aDayArray.remove(at: anIndex)
        } else {
            aDayArray.append(aDay)
        }
        self.days = aDayArray
        self.reloadAllView()
        self.delegate?.scheduleRepeatTableCellView(self, didChangeValue: self.days)
    }
    
}


protocol ScheduleRepeatTableCellViewDelegate :AnyObject {
    func scheduleRepeatTableCellView(_ pSender :ScheduleRepeatTableCellView, didChangeValue pValue :Array<Schedule.Day>?)
}
