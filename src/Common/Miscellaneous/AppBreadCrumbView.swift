//
//  AppBreadCrumbView.swift
//  Wifinity
//
//  Created by Rupendra on 09/01/21.
//

import UIKit


@IBDesignable
class AppBreadCrumbView: UIControl {
    
    // MARK: Properties
    
    @IBInspectable
    var steps:Int = 3 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var selectedStepIndex:Int = -1 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var indicatorSize:CGFloat = 14.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var lineWidth:CGFloat = 1.0 {
        didSet {
            self.adjustEdgeInsets()
            self.setNeedsDisplay()
        }
    }
    
    var edgeInsets:UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            self.adjustEdgeInsets()
        }
    }
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.adjustEdgeInsets()
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)!
        self.adjustEdgeInsets()
    }
    
    func adjustEdgeInsets() {
        if (self.edgeInsets.top < self.lineWidth/2) {
            edgeInsets = UIEdgeInsets(top: self.lineWidth/2, left: self.edgeInsets.left, bottom: self.edgeInsets.bottom, right: self.edgeInsets.right)
            self.setNeedsDisplay()
        }
        if (self.edgeInsets.left < self.lineWidth/2) {
            edgeInsets = UIEdgeInsets(top: self.edgeInsets.top, left: self.lineWidth/2, bottom: self.edgeInsets.bottom, right: self.edgeInsets.right)
            self.setNeedsDisplay()
        }
        if (self.edgeInsets.bottom < self.lineWidth/2) {
            edgeInsets = UIEdgeInsets(top: self.edgeInsets.top, left: self.edgeInsets.left, bottom: self.lineWidth/2, right: self.edgeInsets.right)
            self.setNeedsDisplay()
        }
        if (self.edgeInsets.right < self.lineWidth/2) {
            edgeInsets = UIEdgeInsets(top: self.edgeInsets.top, left: self.edgeInsets.left, bottom: self.edgeInsets.bottom, right: self.lineWidth/2)
            self.setNeedsDisplay()
        }
    }
    
    // MARK: Drawing
    
    func pathForStepWithIndex(step: Int) -> (UIBezierPath) {
        let delta = Float(self.frame.size.width - self.edgeInsets.left - self.edgeInsets.right - self.indicatorSize)
        let offset = Float(step) * (delta / Float(self.steps - 1))
        let x = CGFloat( Double(self.edgeInsets.left) + Double(offset))
        
        return UIBezierPath(ovalIn:CGRect(x: x, y: self.edgeInsets.top, width: self.indicatorSize, height: self.indicatorSize))
    }
    
    func linePathForStepWithIndex(step: Int) -> (UIBezierPath) {
        let delta = (Double(self.frame.size.width) - Double(self.edgeInsets.left) - Double(self.edgeInsets.right) - Double(self.indicatorSize)) / Double(self.steps - 1)
        let offset = Double(step) * delta
        let path = UIBezierPath()
        
        var x = Double(self.edgeInsets.left) + Double(self.indicatorSize) + offset
        var y = Double(self.edgeInsets.top) + Double(self.indicatorSize / 2)
        
        path.move(to: CGPoint(x:x, y:y))
        
        x = Double(self.edgeInsets.left) + Double(offset) + Double(delta)
        y = Double(self.edgeInsets.top) + Double(self.indicatorSize / 2)
        
        path.addLine(to: CGPoint(x:x, y:y))
        
        return path
    }
    
    override func draw(_ rect: CGRect) {
        self.tintColor.setStroke()
        
        for i in stride(from: 0, to: self.steps - 1, by: 1) {
            let linePath = self.linePathForStepWithIndex(step: i)
            linePath.lineWidth = self.lineWidth
            linePath.stroke()
        }
        
        for i in stride(from: 0, to: self.steps, by: 1) {
            let path = self.pathForStepWithIndex(step: i)
            
            (i <= self.selectedStepIndex) ? self.tintColor.setFill() : UIColor.clear.setFill()
            path.fill()
            
            path.lineWidth = self.lineWidth
            path.stroke()
        }
    }
}
