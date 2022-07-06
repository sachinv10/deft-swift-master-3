//
//  RemoteControl.swift
//  DEFT
//
//  Created by Rupendra on 21/10/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit


class RemoteControl: UIControl {
    
    init() {
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0))
        self.setup()
    }
    
    override init(frame pFrame: CGRect) {
        super.init(frame: pFrame)
        self.setup()
    }
    
    
    required init?(coder pDecoder: NSCoder) {
        super.init(coder: pDecoder)
        self.setup()
    }
    
    
    var remoteKey: RemoteKey? {
        return nil
    }
    
    
    var estimatedSize :CGSize {
        return CGSize(width: 320.0, height: 480.0)
    }
    
    
    func load(remote pRemote :Remote) {
        
    }
    
    
    func setup() {
        self.loadFromNib()
    }
    
    
    func loadFromNib() {
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = false
        
        let aNib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
        if let aView = aNib.instantiate(withOwner: self, options: nil)[0] as? UIView {
            self.addSubview(aView)
            aView.translatesAutoresizingMaskIntoConstraints = false
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[aView]|", options: [], metrics: nil, views: ["aView":aView]))
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[aView]|", options: [], metrics: nil, views: ["aView":aView]))
        }
    }
    
}
