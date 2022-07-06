//
//  AppHeaderBarView.swift
//  Wifinity
//
//  Created by Rupendra on 18/01/21.
//

import UIKit

class AppHeaderBarView: UIView {
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var subTitleLabel: UILabel?
    @IBOutlet private weak var subTitleLabelHeightConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var optionButton: UIButton!
    
    weak var delegate :AppHeaderBarViewDelegate?
    
    
    var title :String? {
        didSet {
            self.titleLabel?.text = self.title
        }
    }
    
    var subTitle :String? {
        didSet {
            self.subTitleLabel?.text = self.subTitle
            self.subTitleLabelHeightConstraint?.constant = self.subTitle != nil ? 18.0 : 9.0
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
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
    
    
    @IBAction func didSelectBackButton(_ pSender: UIButton?) {
        self.delegate?.appHeaderBarDidSelectBackButton(self)
    }
 
}


@objc protocol AppHeaderBarViewDelegate :AnyObject {
    func appHeaderBarDidSelectBackButton(_ pSender :AppHeaderBarView)
}
