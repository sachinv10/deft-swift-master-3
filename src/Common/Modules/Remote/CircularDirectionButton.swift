//
//  CircularDirectionButton.swift
//  DEFT
//
//  Created by Rupendra on 03/10/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit


class CircularDirectionButton :UIControl {
    weak var delegate :CircularDirectionButtonDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.tintColor = UIColor(named: "ControlNormalColor")
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(named: "ControlNormalColor")?.cgColor
        self.layer.cornerRadius = self.frame.size.height / 2.0
        self.layer.masksToBounds = true
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
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.layer.cornerRadius = self.frame.size.height / 2.0
    }
    
    
    @IBAction private func didSelectUpButton(_ pSender: UIButton) {
        self.delegate?.circularDirectionButtonDidSelectUp(self)
    }
    
    @IBAction private func didBeginEditingUpButton(_ pSender: RemoteButton) {
        self.delegate?.circularDirectionButtonDidBeginEditingUp(self)
    }
    
    
    @IBAction private func didSelectDownButton(_ pSender: UIButton) {
        self.delegate?.circularDirectionButtonDidSelectDown(self)
    }
    
    @IBAction private func didBeginEditingDownButton(_ pSender: RemoteButton) {
        self.delegate?.circularDirectionButtonDidBeginEditingDown(self)
    }
    
    
    @IBAction private func didSelectLeftButton(_ pSender: UIButton) {
        self.delegate?.circularDirectionButtonDidSelectLeft(self)
    }
    
    @IBAction private func didBeginEditingLeftButton(_ pSender: RemoteButton) {
        self.delegate?.circularDirectionButtonDidBeginEditingLeft(self)
    }
    
    
    @IBAction private func didSelectRightButton(_ pSender: UIButton) {
        self.delegate?.circularDirectionButtonDidSelectRight(self)
    }
    
    @IBAction private func didBeginEditingRightButton(_ pSender: RemoteButton) {
        self.delegate?.circularDirectionButtonDidBeginEditingRight(self)
    }
    
    
    @IBAction private func didSelectOkButton(_ pSender: UIButton) {
        self.delegate?.circularDirectionButtonDidSelectOk(self)
    }
    
    @IBAction private func didBeginEditingOkButton(_ pSender: RemoteButton) {
        self.delegate?.circularDirectionButtonDidBeginEditingOk(self)
    }
    
}


protocol CircularDirectionButtonDelegate :AnyObject {
    func circularDirectionButtonDidSelectUp(_ pSender :CircularDirectionButton)
    func circularDirectionButtonDidBeginEditingUp(_ pSender :CircularDirectionButton)
    
    func circularDirectionButtonDidSelectDown(_ pSender :CircularDirectionButton)
    func circularDirectionButtonDidBeginEditingDown(_ pSender :CircularDirectionButton)
    
    func circularDirectionButtonDidSelectLeft(_ pSender :CircularDirectionButton)
    func circularDirectionButtonDidBeginEditingLeft(_ pSender :CircularDirectionButton)
    
    func circularDirectionButtonDidSelectRight(_ pSender :CircularDirectionButton)
    func circularDirectionButtonDidBeginEditingRight(_ pSender :CircularDirectionButton)
    
    func circularDirectionButtonDidSelectOk(_ pSender :CircularDirectionButton)
    func circularDirectionButtonDidBeginEditingOk(_ pSender :CircularDirectionButton)
}

