//
//  MoodComponentTableCellView.swift
//  DEFT
//
//  Created by Rupendra on 17/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class MoodComponentTableCellView: UITableViewCell {
    @IBOutlet weak var valueLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func load(room pRoom: Room?) {
        let aValue = NSMutableAttributedString()
        
        if let aRoom = pRoom {
            aValue.append(NSAttributedString(string: String(format: "✦ %@:", aRoom.title ?? "Room"), attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: self.valueLabel.font.pointSize)]))
            aValue.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 6)]))
            
            // Appliances Csv
            aValue.append(NSAttributedString(string: "    - Appliances: ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: self.valueLabel.font.pointSize)]))
            
            if let anApplianceArray = aRoom.appliances, anApplianceArray.count > 0 {
                let anApplianceTitleArray = anApplianceArray.compactMap({ $0.title })
                let anApplicanCsv = anApplianceTitleArray.joined(separator: ", ")
                aValue.append(NSAttributedString(string: anApplicanCsv, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: self.valueLabel.font.pointSize)]))
            } else {
                aValue.append(NSAttributedString(string: "None", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: self.valueLabel.font.pointSize)]))
            }
            
            aValue.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 6)]))
            
            // Curtain Csv
            aValue.append(NSAttributedString(string: "    - Curtains: ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: self.valueLabel.font.pointSize)]))
            if let aCurtaineArray = aRoom.curtains, aCurtaineArray.count > 0 {
                let aCurtaineTitleArray = aCurtaineArray.compactMap({ $0.title })
                let aCurtaineTitleCsv = aCurtaineTitleArray.joined(separator: ", ")
                aValue.append(NSAttributedString(string: aCurtaineTitleCsv, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: self.valueLabel.font.pointSize)]))
            } else {
                aValue.append(NSAttributedString(string: "None", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: self.valueLabel.font.pointSize)]))
            }
            
            aValue.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 6)]))
            
            // Remote Csv
            aValue.append(NSAttributedString(string: "    - Remotes (Mood On): ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: self.valueLabel.font.pointSize)]))
            if let aRemoteArray = aRoom.moodOnRemotes, aRemoteArray.count > 0 {
                let aRemoteTitleArray = aRemoteArray.compactMap({ $0.title })
                let aRemoteTitleCsv = aRemoteTitleArray.joined(separator: ", ")
                aValue.append(NSAttributedString(string: aRemoteTitleCsv, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: self.valueLabel.font.pointSize)]))
            } else {
                aValue.append(NSAttributedString(string: "None", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: self.valueLabel.font.pointSize)]))
            }
            
            aValue.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 6)]))
            
            aValue.append(NSAttributedString(string: "    - Remotes (Mood Off): ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: self.valueLabel.font.pointSize)]))
            if let aRemoteArray = aRoom.moodOffRemotes, aRemoteArray.count > 0 {
                let aRemoteTitleArray = aRemoteArray.compactMap({ $0.title })
                let aRemoteTitleCsv = aRemoteTitleArray.joined(separator: ", ")
                aValue.append(NSAttributedString(string: aRemoteTitleCsv, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: self.valueLabel.font.pointSize)]))
            } else {
                aValue.append(NSAttributedString(string: "None", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: self.valueLabel.font.pointSize)]))
            }
            
            self.valueLabel.attributedText = aValue
        }
    }
    
}
