//
//  RectangularDirectionButton.swift
//  DEFT
//
//  Created by Rupendra on 03/10/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class RectangularDirectionButton :UIControl {
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var delegate :RectangularDirectionButtonDelegate?
    
    var title :String? {
        set {
            self.titleLabel.text = newValue
        }
        get {
            return self.titleLabel.text
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.tintColor = UIColor(named: "ControlNormalColor")
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(named: "ControlNormalColor")?.cgColor
        self.layer.cornerRadius = 4.0
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
    
    
    @IBAction private func didSelectUpButton(_ pSender: UIButton) {
        self.delegate?.rectangularDirectionButtonDidSelectUp(self)
    }
    
    @IBAction private func didBeginEditingUpButton(_ pSender: RemoteButton) {
        self.delegate?.rectangularDirectionButtonDidBeginEditingUp(self)
    }
    
    
    @IBAction private func didSelectDownButton(_ pSender: UIButton) {
        self.delegate?.rectangularDirectionButtonDidSelectDown(self)
    }
    
    @IBAction private func didBeginEditingDownButton(_ pSender: RemoteButton) {
        self.delegate?.rectangularDirectionButtonDidBeginEditingDown(self)
    }
    
}


protocol RectangularDirectionButtonDelegate :AnyObject {
    func rectangularDirectionButtonDidSelectUp(_ pSender :RectangularDirectionButton)
    func rectangularDirectionButtonDidBeginEditingUp(_ pSender :RectangularDirectionButton)
    func rectangularDirectionButtonDidSelectDown(_ pSender :RectangularDirectionButton)
    func rectangularDirectionButtonDidBeginEditingDown(_ pSender :RectangularDirectionButton)
}

