//
//  ListTableViewCell.swift
//  Wifinity
//
//  Created by Apple on 30/12/22.
//

import UIKit
protocol listViewDelegate: AnyObject{
    func vdplist( listViewCellplay cell: ListTableViewCell)
    func vdplist( listViewCellplaySpeker cell: ListTableViewCell)
    func vdplist( listViewCellplayPause cell: ListTableViewCell)
    func vdplist( listViewCellExpand cell: ListTableViewCell)
    func vdplist( listViewToNextpage cell: ListTableViewCell)
//    func webRTCClient( didChangeConnectionState state: RTCIceConnectionState)
//    func webRTCClient( didReceiveData data: Data)
}

class ListTableViewCell: UITableViewCell {
    @IBOutlet var view: UIView!
    @IBOutlet var nextBtn: UIButton!
    @IBOutlet var lblName: UILabel!
    @IBOutlet weak var btnplay: UIButton!
    @IBOutlet weak var btnExpand: UIButton!
    @IBOutlet weak var btnpause: UIButton!
    @IBOutlet weak var btnSpeaker: UIButton!
    @IBOutlet weak var lblOnline: UILabel!
    
    weak var delegate: listViewDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblOnline.layer.cornerRadius = 5
        lblOnline.layer.masksToBounds = true
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        nextBtn.setTitle("", for: .normal)
        nextBtn.backgroundColor = UIColor.clear
        btnplay.setTitle("", for: .normal)
        btnpause.setTitle("", for: .normal)
        btnSpeaker.setTitle("", for: .normal)
        btnExpand.setTitle("", for: .normal)
        btnpause.isHidden = true
        btnSpeaker.isHidden = true
        btnExpand.isHidden = true
     
     }
  
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    var vdpmodul: VDPModul?
    func load(obj: VDPModul){
        vdpmodul = obj
        vdpmodul?.clone()
        lblName.text = obj.name
        if obj.online{
            lblOnline.backgroundColor = .green
        }else{
            lblOnline.backgroundColor = .systemRed
        }
    }
    @IBAction func didTappedPause(_ sender: Any) {
        print("didtapped pause")
        if btnpause.currentImage == UIImage(systemName: "play.fill"){
            btnpause.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }else{
            btnpause.setImage(UIImage(systemName: "play.fill"), for: .normal)
//            btnSpeaker.isHidden = true
//            btnExpand.isHidden = true
//            btnpause.isHidden = true
//            btnplay.isHidden = false
        }
        delegate?.vdplist(listViewCellplayPause: self)
       
    }
    @IBAction func btnNextPage(_ sender: Any) {
        print("next page")
        delegate?.vdplist(listViewToNextpage: self)
    }
    
    @IBAction func btnPlay(_ sender: Any) {
        print("btnPlay")
        btnpause.isHidden = false
        btnSpeaker.isHidden = false
        btnExpand.isHidden = false
        btnplay.isHidden = true
        btnpause.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        delegate?.vdplist(listViewCellplay: self)
    }
    
    @IBAction func didtappedSpeaker(_ sender: Any) {
        print("didtapped speakr")
        if btnSpeaker.currentImage == UIImage(systemName: "speaker.wave.2.fill"){
          //  btnSpeaker.setImage(UIImage(systemName: "speaker.slash.fill"), for: .normal)
        }else{
          //  btnSpeaker.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        }
        delegate?.vdplist(listViewCellplaySpeker: self)
    }
    
    @IBAction func didTappedExpand(_ sender: Any) {
        delegate?.vdplist(listViewCellExpand: self)
    }
}
