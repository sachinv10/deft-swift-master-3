//
//  DynamicButtonContainerView.swift
//  DEFT
//
//  Created by Rupendra on 01/10/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit


class DynamicButtonContainerView :UIView {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var customeSlider: AppSlider!
    @IBOutlet weak var buttonCollectionView: UICollectionView!
    
    private var remote :Remote?
    private var appliance :Appliance?

    private var remoteKeys :Array<RemoteKey>?
    
    weak var delegate :DynamicButtonContainerViewDelegate?
    var isForAppliance = false
    var sliderTimer: Timer?

    
    override init(frame pFrame: CGRect) {
        super.init(frame: pFrame)
        self.setup()
    }
    
    
    required init?(coder pDecoder: NSCoder) {
        super.init(coder: pDecoder)
        self.setup()
    }
    
    
    func setup() {
        self.loadFromNib()
        if isForAppliance {
            self.customeSlider.isHidden = false
            self.buttonCollectionView.isHidden = true
        } else {
            self.customeSlider.isHidden = true
            self.buttonCollectionView.isHidden = false
            self.buttonCollectionView.dataSource = self
            self.buttonCollectionView.delegate = self
            self.buttonCollectionView.register(UINib(nibName: "DynamicButtonCollectionCellView", bundle: Bundle.main), forCellWithReuseIdentifier: "DynamicButtonCollectionCellView")
            self.buttonCollectionView.delaysContentTouches = false
        }
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
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.addShadow()
    }
    
    
    func reloadAllView() {
        if isForAppliance {
            self.customeSlider.isHidden = false
            self.buttonCollectionView.isHidden = true
        } else {
            self.customeSlider.isHidden = true
            self.buttonCollectionView.isHidden = false
            self.buttonCollectionView.reloadData()
        }
    }
    
    
    func load(remote pRemote :Remote) {
        self.remote = pRemote
        self.remoteKeys = self.remote?.dynamicKeys
        self.reloadAllView()
    }
    
    
    func addShadow() {
        let aBezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 8, height: 8))
        let aShapeLayer = CAShapeLayer()
        aShapeLayer.path = aBezierPath.cgPath
        self.containerView.layer.mask = aShapeLayer
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowPath = aShapeLayer.path
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 5
    }
    
    
    @IBAction private func didSelectToggleButton(_ pSender: UIButton) {
        self.toggle()
    }
    
    
    func toggle(forceCollpase pShouldForceCollapse :Bool = false) {
        var aBottomConstant :CGFloat = 0.0
        
        if pShouldForceCollapse {
            aBottomConstant = -(self.frame.size.height - 34.0)
        } else {
            if self.containerViewBottomConstraint?.constant == 0 {
                aBottomConstant = -(self.frame.size.height - 34.0)
            } else {
                aBottomConstant = 0
            }
        }
        
        self.containerViewBottomConstraint?.constant = aBottomConstant
        UIView.animate(withDuration: 0.3, animations: {
            self.superview?.layoutIfNeeded()
        }, completion: {(pComplete) in
            self.reloadAllView()
        })
    }
    static var baseslidervalue: Int? = 30
    @IBAction func sliderDidChangeValue(_ pSender: UISlider) {
        let aRoundedValue = round(pSender.value / 1) * 1
        pSender.value = aRoundedValue
        
        self.sliderTimer?.invalidate()
        self.sliderTimer = nil
        self.sliderTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block: { (pTimer) in
                let aSliderValue = Int(self.customeSlider?.value ?? 0)
 
//            let aDimmableValue :Int = UtilityManager.dimmableValueFromCommonSliderValue1(sliderValue: aSliderValue)
                self.delegate?.dynamicButtonContainerView!(didSelectDimmerValue: aSliderValue)
            })
    }

}


@objc protocol DynamicButtonContainerViewDelegate :AnyObject {
    func dynamicButtonContainerView(_ pSender: DynamicButtonContainerView, didSelectRemoteKey pRemoteKey: RemoteKey)
    func dynamicButtonContainerView(_ pSender: DynamicButtonContainerView, didSelectEditRemoteKey pRemoteKey: RemoteKey)
    @objc optional func dynamicButtonContainerView(didSelectDimmerValue pDimmableValue :Int)

}



extension DynamicButtonContainerView :UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ pCollectionView: UICollectionView, numberOfItemsInSection pSection: Int) -> Int {
        return self.remoteKeys?.count ?? 0
    }
    
    func collectionView(_ pCollectionView: UICollectionView, cellForItemAt pIndexPath: IndexPath) -> UICollectionViewCell {
        var aReturnVal :UICollectionViewCell?
        
        if let aCell = pCollectionView.dequeueReusableCell(withReuseIdentifier: "DynamicButtonCollectionCellView", for: pIndexPath) as? DynamicButtonCollectionCellView {
            if let aKeyArray = self.remoteKeys, pIndexPath.item < aKeyArray.count {
                let aRemoteKey = aKeyArray[pIndexPath.item]
                aCell.load(remoteKey: aRemoteKey)
                aCell.delegate = self
            }
            aReturnVal = aCell
        }
        
        return aReturnVal ?? UICollectionViewCell()
    }
    
    func collectionView(_ pCollectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt pIndexPath: IndexPath) -> CGSize {
        return CGSize(width: (pCollectionView.frame.size.width / 2.0) - 20.0, height: 44.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 12.0, bottom: 0.0, right: 12.0)
    }
    
}


extension DynamicButtonContainerView :DynamicButtonCollectionCellViewDelegate {
   func cellView(didChangeDimmableValue pDimmableValue: Int) {
        self.delegate?.dynamicButtonContainerView!(didSelectDimmerValue: pDimmableValue)
    }
    
    func dynamicButtonCollectionCellView(_ pSender: DynamicButtonCollectionCellView, didSelectRemoteKey pRemoteKey: RemoteKey) {
        self.delegate?.dynamicButtonContainerView(self, didSelectRemoteKey: pRemoteKey)
    }
    
    func dynamicButtonCollectionCellView(_ pSender: DynamicButtonCollectionCellView, didSelectEditRemoteKey pRemoteKey: RemoteKey) {
        self.delegate?.dynamicButtonContainerView(self, didSelectEditRemoteKey: pRemoteKey)
    }
    
}

