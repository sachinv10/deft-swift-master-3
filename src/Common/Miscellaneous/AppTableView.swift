//
//  AppTableView.swift
//  DEFT
//
//  Created by Rupendra on 10/10/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class AppTableView: UITableView {
    
    func display(message pMessage :String) {
        let aView = UIView(frame: self.bounds)
        let aLabel = UILabel()
        aLabel.font = UIFont.systemFont(ofSize: 17.0)
        aLabel.textColor = UIColor.gray
        aLabel.textAlignment = NSTextAlignment.center
        aLabel.numberOfLines = 0
        aLabel.text = pMessage
        aView.addSubview(aLabel)
        self.tableHeaderView = aView
        
        aLabel.translatesAutoresizingMaskIntoConstraints = false
        let aHorizontalLabelConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[aLabel]-15-|", options: [], metrics: nil, views: ["aLabel":aLabel])
        aView.addConstraints(aHorizontalLabelConstraint)
        self.addConstraint(NSLayoutConstraint(item: aLabel, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: aView, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0))
        
    }
    
    
    func hideMessage() {
        self.tableHeaderView = nil
    }
    
}

class AppCollectionView: UICollectionView {
    
    func display(message pMessage :String) {
        let aView = UIView(frame: self.bounds)
        let aLabel = UILabel()
        aLabel.font = UIFont.systemFont(ofSize: 17.0)
        aLabel.textColor = UIColor.gray
        aLabel.textAlignment = NSTextAlignment.center
        aLabel.numberOfLines = 0
        aLabel.text = pMessage
        aView.addSubview(aLabel)
 
        aLabel.translatesAutoresizingMaskIntoConstraints = false
        let aHorizontalLabelConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[aLabel]-15-|", options: [], metrics: nil, views: ["aLabel":aLabel])
        aView.addConstraints(aHorizontalLabelConstraint)
        self.addConstraint(NSLayoutConstraint(item: aLabel, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: aView, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0))
    }
    
    
    func hideMessage() {
      }
    
}
