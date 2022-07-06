//
//  TankRegulator.swift
//  DEFT
//
//  Created by Rupendra on 09/10/21.
//  Copyright © 2021 Example. All rights reserved.
//

import UIKit


class TankRegulator: NSObject {
    var id :String?
    var title :String?
    var tankCount :Int?
    var isAutoModeActivated :Bool = false
    var isMotorOn :Bool = false
    var lowerTankFillPercent :Int?
    var upperTankFillPercent :Int?
    var isOnline :Bool = false
    
    
    func clone() -> TankRegulator {
        let aReturnVal = TankRegulator()
        aReturnVal.id = self.id
        aReturnVal.title = self.title
        aReturnVal.tankCount = self.tankCount
        aReturnVal.isAutoModeActivated = self.isAutoModeActivated
        aReturnVal.isMotorOn = self.isMotorOn
        aReturnVal.lowerTankFillPercent = self.lowerTankFillPercent
        aReturnVal.upperTankFillPercent = self.upperTankFillPercent
        aReturnVal.isOnline = self.isOnline
        return aReturnVal
    }
    
    static func waterLevelImage(waterLevel pWaterLevel :Int?) -> UIImage {
        var aReturnVal = UIImage(named: "TankRegulatorListTankFull")!
        if let aWaterLevel = pWaterLevel {
            if aWaterLevel <= 10 {
                aReturnVal = UIImage(named: "TankRegulatorListTankLow")!
            } else if aWaterLevel > 10 && aWaterLevel <= 50 {
                aReturnVal = UIImage(named: "TankRegulatorListTankMedium")!
            } else if aWaterLevel > 50 && aWaterLevel <= 75 {
                aReturnVal = UIImage(named: "TankRegulatorListTankHigh")!
            } else if aWaterLevel > 75 {
                aReturnVal = UIImage(named: "TankRegulatorListTankFull")!
            }
        }
        return aReturnVal
    }
}
