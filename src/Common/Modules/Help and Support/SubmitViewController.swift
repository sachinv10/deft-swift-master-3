//
//  SubmitViewController.swift
//  Wifinity
//
//  Created by Apple on 05/11/22.
//

import UIKit

class SubmitViewController: BaseController {

 
    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        subTitle = ""
        uisetup()
        view.backgroundColor = UIColor(named: "PrimaryLightestColor")
    }
    func uisetup()  {
        textviewQuery.layer.borderWidth = 1
        textviewQuery.layer.borderColor = UIColor.gray.cgColor
        textviewQuery.layer.masksToBounds = true
        textviewQuery.layer.cornerRadius = 10
        
        textviewNumber.layer.borderWidth = 1
        textviewNumber.layer.borderColor = UIColor.gray.cgColor
        textviewNumber.layer.masksToBounds = true
        textviewNumber.layer.cornerRadius = 10
    }
 
    @IBOutlet weak var textviewQuery: UITextView!
    @IBOutlet weak var textviewNumber: UIView!
}
