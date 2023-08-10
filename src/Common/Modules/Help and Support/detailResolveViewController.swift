//
//  detailResolveViewController.swift
//  Wifinity
//
//  Created by Apple on 16/11/22.
//

import UIKit

class detailResolveViewController: BaseController {

    
    @IBOutlet weak var lblIssueRaisedTime: UILabel!
    
    @IBOutlet weak var lblIssueResolvedTime: UILabel!
    @IBOutlet weak var lblIssueType: UILabel!
    @IBOutlet weak var lblTecketId: UILabel!
    @IBOutlet weak var lblIssueResolveBy: UILabel!
    @IBOutlet weak var lblDiscreption: UILabel!
    @IBOutlet weak var lblHardwareName: UILabel!
    @IBOutlet weak var lblhardwareandRoom: UILabel!
    var pcomplent = Complents()
    override func viewDidLoad() {
        super.viewDidLoad()
     title = "Resolved issue"
     subTitle = ""
        print(pcomplent.issueType)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func reloadAllData() {
        let time = Double(pcomplent.issueRaisedTime ?? 0)
       let x = SharedFunction.shared.gotoTimetampTodayConvert(time: time / 1000)
        lblIssueRaisedTime.text = x
        
        let time1 = Double(pcomplent.issueResolvedTime ?? 0)
       let xy = SharedFunction.shared.gotoTimetampTodayConvert(time: time1 / 1000)
        lblIssueResolvedTime.text = xy
        
        lblIssueType.text = pcomplent.issueType
        lblTecketId.text = pcomplent.ticketId
        lblIssueResolveBy.text = pcomplent.resolvedBy
        lblDiscreption.text = pcomplent.descriptionn
        lblHardwareName.text = pcomplent.controllerName 
        lblhardwareandRoom.text = ""
    }
}
