//
//  DynamicButtonCollectionCellView.swift
//  DEFT
//
//  Created by Rupendra on 19/10/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit


class DynamicButtonCollectionCellView: UICollectionViewCell {
    @IBOutlet weak var button: RemoteButton!
    
    weak var delegate :DynamicButtonCollectionCellViewDelegate?
    
    private var remoteKey :RemoteKey?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.button.layer.borderWidth = 1.0
        self.button.layer.borderColor = UIColor(named: "ControlNormalColor")?.cgColor
        self.button.layer.cornerRadius = 8.0
        self.button.backgroundColor = UIColor(named: "SecondaryLightestColor")
        self.button.tintColor = UIColor(named: "ControlNormalColor")
    }
    
    func load(remoteKey pRemoteKey :RemoteKey) {
        self.remoteKey = pRemoteKey
        
        self.button.setTitle(pRemoteKey.title ?? pRemoteKey.id, for: UIControl.State.normal)
    }
    
    @IBAction private func didSelectButton(_ pSender: UIButton) {
        if let aRemoteKey = self.remoteKey {
            self.delegate?.dynamicButtonCollectionCellView(self, didSelectRemoteKey: aRemoteKey)
        }
    }
    
    @IBAction private func didBeginEditingButton(_ pSender: RemoteButton) {
        if let aRemoteKey = self.remoteKey {
            self.delegate?.dynamicButtonCollectionCellView(self, didSelectEditRemoteKey: aRemoteKey)
        }
    }
}


@objc protocol DynamicButtonCollectionCellViewDelegate :AnyObject {
    func dynamicButtonCollectionCellView(_ pSender :DynamicButtonCollectionCellView, didSelectRemoteKey pRemoteKey :RemoteKey)
    func dynamicButtonCollectionCellView(_ pSender :DynamicButtonCollectionCellView, didSelectEditRemoteKey pRemoteKey :RemoteKey)
    @objc optional func cellView(_ appliance: Appliance, didChangeDimmableValue pDimmableValue :Int)
}

