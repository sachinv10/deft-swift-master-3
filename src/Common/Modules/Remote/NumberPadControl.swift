//
//  NumberPadControl.swift
//  DEFT
//
//  Created by Rupendra on 03/10/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class NumberPadControl: RemoteControl {
    weak var delegate :NumberPadControlDelegate?
    
    override func setup() {
        super.setup()
    }
    
}


// MARK:- Number Button Selectors

extension NumberPadControl {
    
    @IBAction private func didSelectOneButton(_ pSender: RemoteButton) {
        self.delegate?.numberPadControlDidSelectOne(self)
    }
    
    @IBAction private func didBeginEditingOneButton(_ pSender: RemoteButton) {
        self.delegate?.numberPadControlDidBeginEditingOne(self)
    }
    
    @IBAction private func didSelectTwoButton(_ pSender: RemoteButton) {
        self.delegate?.numberPadControlDidSelectTwo(self)
    }
    
    @IBAction private func didBeginEditingTwoButton(_ pSender: RemoteButton) {
        self.delegate?.numberPadControlDidBeginEditingTwo(self)
    }
    
    @IBAction private func didSelectThreeButton(_ pSender: RemoteButton) {
        self.delegate?.numberPadControlDidSelectThree(self)
    }
    
    @IBAction private func didBeginEditingThreeButton(_ pSender: RemoteButton) {
        self.delegate?.numberPadControlDidBeginEditingThree(self)
    }
    
    @IBAction private func didSelectFourButton(_ pSender: RemoteButton) {
        self.delegate?.numberPadControlDidSelectFour(self)
    }
    
    @IBAction private func didBeginEditingFourButton(_ pSender: RemoteButton) {
        self.delegate?.numberPadControlDidBeginEditingFour(self)
    }
    
    @IBAction private func didSelectFiveButton(_ pSender: RemoteButton) {
        self.delegate?.numberPadControlDidSelectFive(self)
    }
    
    @IBAction private func didBeginEditingFiveButton(_ pSender: RemoteButton) {
        self.delegate?.numberPadControlDidBeginEditingFive(self)
    }
    
    @IBAction private func didSelectSixButton(_ pSender: RemoteButton) {
        self.delegate?.numberPadControlDidSelectSix(self)
    }
    
    @IBAction private func didBeginEditingSixButton(_ pSender: RemoteButton) {
        self.delegate?.numberPadControlDidBeginEditingSix(self)
    }
    
    @IBAction private func didSelectSevenButton(_ pSender: RemoteButton) {
        self.delegate?.numberPadControlDidSelectSeven(self)
    }
    
    @IBAction private func didBeginEditingSevenButton(_ pSender: RemoteButton) {
        self.delegate?.numberPadControlDidBeginEditingSeven(self)
    }
    
    @IBAction private func didSelectEightButton(_ pSender: RemoteButton) {
        self.delegate?.numberPadControlDidSelectEight(self)
    }
    
    @IBAction private func didBeginEditingEightButton(_ pSender: RemoteButton) {
        self.delegate?.numberPadControlDidBeginEditingEight(self)
    }
    
    @IBAction private func didSelectNineButton(_ pSender: RemoteButton) {
        self.delegate?.numberPadControlDidSelectNine(self)
    }
    
    @IBAction private func didBeginEditingNineButton(_ pSender: RemoteButton) {
        self.delegate?.numberPadControlDidBeginEditingNine(self)
    }
    
    @IBAction private func didSelectZeroButton(_ pSender: RemoteButton) {
        self.delegate?.numberPadControlDidSelectZero(self)
    }
    
    @IBAction private func didBeginEditingZeroButton(_ pSender: RemoteButton) {
        self.delegate?.numberPadControlDidBeginEditingZero(self)
    }
    
}


protocol NumberPadControlDelegate :AnyObject {
    func numberPadControlDidSelectZero(_ pSender :NumberPadControl)
    func numberPadControlDidBeginEditingZero(_ pSender :NumberPadControl)
    func numberPadControlDidSelectOne(_ pSender :NumberPadControl)
    func numberPadControlDidBeginEditingOne(_ pSender :NumberPadControl)
    func numberPadControlDidSelectTwo(_ pSender :NumberPadControl)
    func numberPadControlDidBeginEditingTwo(_ pSender :NumberPadControl)
    func numberPadControlDidSelectThree(_ pSender :NumberPadControl)
    func numberPadControlDidBeginEditingThree(_ pSender :NumberPadControl)
    func numberPadControlDidSelectFour(_ pSender :NumberPadControl)
    func numberPadControlDidBeginEditingFour(_ pSender :NumberPadControl)
    func numberPadControlDidSelectFive(_ pSender :NumberPadControl)
    func numberPadControlDidBeginEditingFive(_ pSender :NumberPadControl)
    func numberPadControlDidSelectSix(_ pSender :NumberPadControl)
    func numberPadControlDidBeginEditingSix(_ pSender :NumberPadControl)
    func numberPadControlDidSelectSeven(_ pSender :NumberPadControl)
    func numberPadControlDidBeginEditingSeven(_ pSender :NumberPadControl)
    func numberPadControlDidSelectEight(_ pSender :NumberPadControl)
    func numberPadControlDidBeginEditingEight(_ pSender :NumberPadControl)
    func numberPadControlDidSelectNine(_ pSender :NumberPadControl)
    func numberPadControlDidBeginEditingNine(_ pSender :NumberPadControl)
}

