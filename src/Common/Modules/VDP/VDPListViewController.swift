//
//  VDPListViewController.swift
//  Wifinity
//
//  Created by sachin on 30/12/22.
//

import UIKit
import AVFoundation
import SocketIO
import Foundation
import WebRTC
import Starscream
import AVFAudio
import Firebase
import FirebaseDatabase

var CURRENT_VC = ""
let TAG = "ViewController"
let AUDIO_TRACK_ID = "101"
let LOCAL_MEDIA_STREAM_ID =  "102"
protocol WebRTCClientDelegate: AnyObject {
    func webRTCClient( didDiscoverLocalCandidate candidate: RTCIceCandidate)
    func webRTCClient( didChangeConnectionState state: RTCIceConnectionState)
    func webRTCClient( didReceiveData data: Data)
}
extension VDPListViewController{
    
    private func searchVDP() {
        // ProgressOverlay.shared.show()
        DataFetchManager.shared.searchVDPdevices(completion: { (pError, pTankRegulatorArray) in
            // ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not search water level controllers", description: pError!.localizedDescription)
            } else {
                if pTankRegulatorArray != nil && pTankRegulatorArray!.count > 0 {
                    self.vdpListArray = pTankRegulatorArray!
                }
                self.reloadAllView()
                self.activatdatalistner()
            }
        })
    }

    func activatdatalistner()  {
         DispatchQueue.main.asyncAfter(deadline: .now() ){
           let aFilter = Auth.auth().currentUser!.uid
           Database.database().reference().child("vdpDevices") .queryOrdered(byChild: "uid")
                 .queryEqual(toValue: aFilter).observe(.childChanged) { (snapshot, key) in
             print(key as Any)
             print("vdp listner")
                     self.searchVDP()
               }
           }
        }
    
    func reloadAllView(){
        if !vdpListArray.isEmpty{
            listTableview.reloadData()
            listTableview.hideMessage()
        }else{
            // display msg
            listTableview.display(message: "No VDP Available")
        }
    }
}
extension VDPListViewController{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vdpListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as! ListTableViewCell
        cell.load(obj: vdpListArray[indexPath.row])
        cell.delegate = self
        return cell
    }
 
//    func activityIndicatorStart() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [self] in
//            activityIndicators.color = .white
//            activityIndicators.center = remoteRenderer.center
//
//            remoteRenderer.addSubview(activityIndicators)
//            activityIndicators.startAnimating()
//        }
//    }
    func updateFanState(cell: ListTableViewCell)  {
        DataFetchManager.shared.updateVdpFanState(completion: {error in
            do{
                if error != nil{
                    print("error updateing fan mode")
             //   throw ""
            }
            }catch{
                
            }
        }, vdpmodule: cell.vdpmodul!)
     }
    func vdplist(listViewCellplay cell: ListTableViewCell) {
        print("play vdp list")
       // activityIndicatorStart()
            updateFanState(cell: cell)
            DispatchQueue.main.asyncAfter(deadline: .now()){ [self] in
                ProgressOverlay.shared.activityIndicatorStart(view: remoteRenderer)
            }
            timestamp()
            cell.lblName.layer.zPosition = 1
            cell.lblOnline.layer.zPosition = 1
            let vdpmodul = cell.vdpmodul
            vdpId = (vdpmodul?.id)!
            var frames = cell.view.frame
            frames.origin.y = 0.0
            remoteRenderer = RTCMTLVideoView(frame: frames)
            remoteRenderer.contentMode = .scaleToFill
            cell.self.view.addSubview(remoteRenderer)
            remoteRenderer.addSubview(cell.btnSpeaker)
            remoteRenderer.addSubview(cell.btnpause)
            //  remoteRenderer.addSubview(cell.btnExpand)
            button.frame = cell.nextBtn.frame
            remoteRenderer.addSubview(cell.nextBtn)
            cell.view.addSubview(cell.btnSpeaker)
            
            if (DashboardController.socket == nil) {
                icecandidate = false
            }else{
                icecandidate = true
            }
            icecandidate = false
            myconnectfunc()
            initWebRTC();
            self.configureAudioSession()
        localAudioTrack = peerConnectionFactory?.audioTrack(withTrackId: AUDIO_TRACK_ID)
        mediaStream = peerConnectionFactory?.mediaStream(withStreamId: LOCAL_MEDIA_STREAM_ID)
            mediaStream.addAudioTrack(localAudioTrack)
         
    }
    
    func funcportratemode(cell: ListTableViewCell){
        let vdpmodul = cell.vdpmodul
        vdpId = (vdpmodul?.id)!
        var frames = cell.view.frame
        frames.origin.y = 0.0
        remoteRenderer = RTCMTLVideoView(frame: frames)
        remoteRenderer.contentMode = .scaleToFill
        
        cell.self.view.addSubview(remoteRenderer)
        remoteRenderer.addSubview(cell.btnSpeaker)
        remoteRenderer.addSubview(cell.btnpause)
        remoteRenderer.addSubview(cell.btnExpand)
        remoteRenderer.addSubview(cell.nextBtn)
        cell.view.addSubview(cell.btnSpeaker)
    }
    func vdplist(listViewCellplaySpeker cell: ListTableViewCell) {
        print("output valum = \(rtcAudioSession.outputVolume)")
       print(rtcAudioSession.isAudioEnabled)
        if rtcAudioSession.isAudioEnabled == false{
            speakerOff()
            cell.btnSpeaker.setImage(UIImage(systemName: "speaker.slash.fill"), for: .normal)
            rtcAudioSession.isAudioEnabled = true
        }else{
   
            speakerOn()
            cell.btnSpeaker.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
            rtcAudioSession.isAudioEnabled = false
        }
        
        
        //        if cell.btnSpeaker.currentImage == UIImage(systemName: "speaker.wave.2.fill"){
        //            speakerOff()
        //            cell.btnSpeaker.setImage(UIImage(systemName: "speaker.slash.fill"), for: .normal)
        //        }else{
        //            speakerOn()
        //            cell.btnSpeaker.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        //        }
    }
    
    func vdplist(listViewCellplayPause cell: ListTableViewCell) {
        print("pause")
        if remoteVideoTrack != nil{
            if remoteVideoTrack.isEnabled{
                remoteVideoTrack.isEnabled = false
                remoteRenderer.addSubview(cell.btnplay)
                speakerOff()
            }else{
                speakerOn()
                remoteVideoTrack.isEnabled = true
            }
        }
    }
    func vdplist(listViewCellExpand cell: ListTableViewCell) {
        
        //        if viewExpand.isHidden{
        //            // landscape mode
        //             var y = listTableview.frame
        //            y.origin.y = 0.0
        //            let width =  y.size.width
        //            y.size.width = y.size.height
        //            y.size.height = self.view.frame.width
        //            remoteRenderer.frame = y
        //            cell.view.frame = y
        //            remoteRenderer.center = viewExpand.center
        //            viewExpand.isHidden = false
        //       //     remoteRenderer.addSubview(viewExpandBottom)
        //            viewExpand.addSubview(remoteRenderer)
        //            remoteRenderer.addSubview(cell.btnExpand)
        //            remoteRenderer.transform = CGAffineTransform(rotationAngle: .pi / 2)
        //
        //        }else{
        //          //  portrate mode
        //          //  funcportratemode(cell: cell)
        //             viewExpand.isHidden = true
        //            var y = cell.self.view.frame
        //             y.origin.y = -25.0
        //            let width =  y.size.width
        //            y.size.width = y.size.height
        //            y.size.height = width
        //            remoteRenderer.frame = y
        //            remoteRenderer.center = cell.view.center
        //            cell.btnpause.isHidden = true
        //         //   cell.nextBtn.isHidden = true
        //            cell.view.addSubview(remoteRenderer)
        //            cell.nextBtn.frame = button.frame
        //            let btnf = cell.btnExpand.frame
        //            remoteRenderer.addSubview(cell.nextBtn)
        //            remoteRenderer.addSubview(cell.btnExpand)
        //            remoteRenderer.transform = CGAffineTransform(rotationAngle: .pi * 2)
        //
        ////            viewExpand.isHidden = true
        ////            remoteRenderer.addSubview(cell.btnplay)
        ////            cell.view.addSubview(remoteRenderer)
        ////            remoteRenderer.transform = CGAffineTransform(rotationAngle: .pi / 2)
        //            //  listTableview.reloadData()
        //        }
    }
    @objc func handleAudioInterruption(){
        print("screen in background")
      //  connectToPlay()
        DashboardController.socket?.disconnect()
        if peerConnection != nil{
            peerConnection.close()
        }

    }
    func vdplist(listViewToNextpage cell: ListTableViewCell) {
        print("to next page")
        RoutingManager.shared.gotoVDPPlay(controller: self, Obj: cell.vdpmodul!, ice: iiceServer)
    }
}

class VDPListViewController: BaseController,URLSessionWebSocketDelegate,RTCPeerConnectionDelegate, RTCDataChannelDelegate, RTCVideoViewDelegate,WebRTCClientDelegate, listViewDelegate, UITableViewDelegate, UITableViewDataSource, webrtcDelegate{
    let activityIndicators = UIActivityIndicatorView(style: .white)
    var mediaStream: RTCMediaStream!
    //  var localAudioTrack: RTCAudioTrack!
    var remoteAudioTrack: RTCAudioTrack!
    var dataChannel: RTCDataChannel!
    var dataChannelRemote: RTCDataChannel!
    var vdpId = ""
    var roomName: String!
    
    //MARK: - Properties
    var audioTrack: RTCAudioTrack?
    var peerConnectionFactory: RTCPeerConnectionFactory? = nil
    var peerConnection: RTCPeerConnection! = nil
    var mediaConstraints: RTCMediaConstraints! = nil
    private let rtcAudioSession =  RTCAudioSession.sharedInstance()
    private let audioQueue = DispatchQueue(label: "audio")
    private var localRenderView: RTCEAGLVideoView?
    private var localView: UIView!
    private var remoteRenderView: RTCEAGLVideoView?
    private var remoteView: UIView!
    private var remoteStream: RTCMediaStream?
    private var videoCapturer: RTCVideoCapturer!
    private var localVideoTrack: RTCVideoTrack!
    private var remoteVideoTrack: RTCVideoTrack!
    private var remoteRenderer :RTCMTLVideoView!
    private var localRTcVideoTrack: RTCVideoRenderer!
    
    private var localAudioTrack: RTCAudioTrack!
    //  var webRTCClient: WebRTCClient!
    private var customFrameCapturer: Bool = false
    weak var delegate: WebRTCClientDelegate?
    let manager = SocketManager(socketURL: URL(string: "https://vdp1.homeonetechnologies.in/")!, config: [.log(false), .compress])
    
    var socket: SocketIOClient? = nil
    var wsServerUrl: String! = nil
    var peerStarted: Bool = false
    var icecandidate = Bool()
    
    @IBOutlet weak var listTableview: AppTableView!
    var vdpListArray: Array<VDPModul> = Array<VDPModul>()
    // Button
    let button : UIButton = {
        var btn = UIButton()
        btn.backgroundColor = .red
        btn.setTitle("Disconnect", for: .normal)
        
        return btn
    }()
    
    let buttonconnect : UIButton = {
        var btn = UIButton()
        btn.backgroundColor = .red
        btn.setTitle("connect", for: .normal)
        return btn
    }()
    
    let viewExpand : UIView = {
        var views = UIView()
        views.backgroundColor = .gray
        return views
    }()
    let viewExpandBottom : UIView = {
        var views = UIView()
        views.backgroundColor = .gray
        return views
    }()
    private var webSocket : URLSessionWebSocketTask?
    
    func setupSocket() {
        self.socket = manager.defaultSocket
    }
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var lblDnd: UIButton!
    
    @IBAction func blbDNDfunc(_ sender: Any) {
        if lblDnd.currentImage == UIImage(systemName: "bell"){
            removeTokenFunc()
            lblDnd.setImage(UIImage(systemName: "bell.slash"), for: .normal)
        }else{
            UpdateVdpNotification()
            lblDnd.setImage(UIImage(systemName: "bell"), for: .normal)
        }
    }
    func myconnectfunc() {
        DataFetchManager.shared.checkInternetConnection { (pError) in
            if pError != nil{
                PopupManager.shared.displayError(message: "Opps!", description: "No internet connection")
            }
        }
        var dic2 = Dictionary<String, Any>()
        var dic1 = Dictionary<String, Any>()
        dic1 = ["whatever-you-want-here" :"stuff"]
        dic2 = ["channel": vdpId, "userdata": dic1]
        //V001641534575660
        let jsonData = try! JSONSerialization.data(withJSONObject: dic2, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        let postData =  decoded.data(using: .utf8)
        // working
        
        DashboardController.socket?.emit("join", dic2)
        
       // setupSocket()
       // setupSocketEvents()
      //  socket?.connect()
    }
    //  let audioSessionn = AVAudioSession.sharedInstance()
    //MARK: - View didload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "ListTableViewCell", bundle: nil)
        listTableview.register(nib, forCellReuseIdentifier: "ListTableViewCell")
        listTableview.delegate = self
        listTableview.dataSource = self
        title = "VDP Camera"
        subTitle = ""
        
        self.listTableview.tableFooterView = UIView()
        self.listTableview.delaysContentTouches = false
      //  preSocketConnection()
        
    }
   func preSocketConnection(){
       socket?.connect()

               // Add event listeners
               socket?.on("connect") {data, ack in
                   print("Socket.IO connected")
               }

               socket?.on("disconnect") {data, ack in
                   print("Socket.IO disconnected")
               }
    }
    func uisetup(){
        button.frame = CGRect(x: self.view.frame.width/2 - 100, y: self.view.frame.height/1.4, width: 200, height: 100)
        self.view.addSubview(button)
        self.view.backgroundColor = .blue
        button.addTarget(self, action: #selector(closeSession), for: .touchUpInside)
        
        buttonconnect.frame = CGRect(x: self.view.frame.width/2 - 100, y: self.view.frame.height/1.15, width: 200, height: 100)
        self.view.addSubview(buttonconnect)
        buttonconnect.addTarget(self, action: #selector(connectt), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CURRENT_VC = "VDPListViewController"
        var y = mainView.frame
        y.origin.y = -10.0
        viewExpand.frame = y
        y.origin.x = 0
        y.size.height = 50
        viewExpandBottom.frame = y
        viewExpand.addSubview(viewExpandBottom)
        listTableview.addSubview(viewExpand)
        viewExpand.isHidden = true
        
        appDel.myOrientation = .portrait
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        lblDnd.setTitle("", for: .normal)
        searchVDP()
        checkTokenFunc(complition: { [self]data in
            print("token available =\(data)")
            if data == true{
                lblDnd.setImage(UIImage(systemName: "bell"), for: .normal)
            }else{
                lblDnd.setImage(UIImage(systemName: "bell.slash"), for: .normal)
            }
        })
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioInterruption), name:
                                                        UIApplication.didEnterBackgroundNotification, object: nil)
       vdpdelegate()
    }
    func vdpdelegate(){
       
         print("socket status=\(DashboardController.socket?.status.description == "connected")")
        let myClass = DashboardController()
        myClass.delegate = self
         myClass.loadvc()
        var dic2 = Dictionary<String, Any>()
        var dic1 = Dictionary<String, Any>()
        dic1 = ["whatever-you-want-here" :"stuff"]
        dic2 = ["channel": "V001681462936392", "userdata": dic1]
       // DashboardController.socket.emit("join", dic2)
//        let connection = SocketConnectionPool.shared.getConnection()
//        print("socket connection = \(connection.socket?.status.description)")
//            connection.socket?.emit("join", dic2)
        geticeServer()
    }
    var iiceServer = [IceServer]()
    func geticeServer()  {
       
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("restfulApi").child("vdpIceServers").observeSingleEvent(of: .value, with: {(DataSnapshot) in
            
            print(DataSnapshot.value as Any)
            let jsons = DataSnapshot.value as Any
            let json = jsons as? Array<Dictionary<String, Any>>
            if let aDict = jsons as? Array<Dictionary<String, String>>{
                do{
                    for items in aDict{
          
                        let jsonData = try JSONSerialization.data(withJSONObject: items, options: [])
                        if let jsonString = String(data: jsonData, encoding: .utf8) {
                                print(jsonString)
                             let data = jsonString.data(using: .utf8)
                             let decoder = JSONDecoder()
                             let response = try decoder.decode(IceServer.self, from: jsonData)
                             print(response.credential,"\n url=", response.url)
                            self.iiceServer.append(response)
                         }
                    }
                }catch{
                    
                }
            }
            
//            do{
//                let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
//                if let jsonString = String(data: jsonData, encoding: .utf8) {
//                    print(jsonString)
//                    let data = jsonString.data(using: .utf8)
//                    let response = try decoder.decode(ResponseDemo.self, from: data!)
//             print(response.sensorSensitivity)
//                }
//
//            }catch{
//
//            }
         })
    }
    private func routeChange(_ n: Notification) {
        
        
    }
    let appDel = UIApplication.shared.delegate as! AppDelegate
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // exit
         
        NotificationCenter.default.removeObserver(self)
    }
    
    func myUlsetUp(){
        remoteRenderer = RTCMTLVideoView(frame: self.view.frame)
      //  remoteRenderer = RTCEAGLVideoView(frame: self.view.frame)
        remoteRenderer.contentMode = .scaleAspectFill
        self.view.addSubview(remoteRenderer)
    }
    
    let audioSession = RTCAudioSession.sharedInstance()
    
    func remoteVideoView() -> UIView {
        return remoteView
    }
    
    
    private func setupUI(){
        remoteView = UIView()
        let remoteVideoViewContainter = UIView(frame: CGRect(x: 0, y: 100, width: 640, height: 480))
        remoteVideoViewContainter.backgroundColor = .gray
        self.view.addSubview(remoteVideoViewContainter)
        
        let remoteVideoView = remoteVideoView()
        setupRemoteViewFrame(frame: CGRect(x: 0, y: 100, width: 640, height: 480))
        remoteVideoView.center = remoteVideoViewContainter.center
        remoteVideoViewContainter.addSubview(remoteVideoView)
    }
    func getRoomName() -> String {
        return (roomName == nil || roomName.isEmpty) ? "_defaultroom": roomName;
    }
    
    func stop() {
        if (peerConnection != nil) {
            peerConnection.close()
            peerConnection = nil
            peerStarted = false
        }
    }
    func connect() {
        if (!peerStarted) {
            sendOffer()
            peerStarted = true
        }
    }
    
    func hangUp() {
        sendDisconnect()
        stop()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        var vcc = DashboardController()
      //  vcc.delegate = nil
        CURRENT_VC = ""
       // DashboardController.socket?.disconnect()
        if peerConnection != nil{
            peerConnection.close()
        }
        if remoteStream != nil{
            DashboardController.socket?.leaveNamespace()
        }
    //    socket?.disconnect()
//    DashboardController.socket.disconnect()
//    DashboardController.socket = nil
//    if peerConnection != nil{
//        peerConnection.close()
//    }
    }
    var timer = Timer()
    var responceDetail: ResponceResult!
//    func setupSocketEvents() {
//        
//        var dic2 = Dictionary<String, Any>()
//        var dic1 = Dictionary<String, Any>()
//        dic1 = ["whatever-you-want-here" :"stuff"]
//        dic2 = ["channel": vdpId, "userdata": dic1]
//        //V001641534575660
//        let jsonData = try! JSONSerialization.data(withJSONObject: dic2, options: [])
//        let decoded = String(data: jsonData, encoding: .utf8)!
//        let postData =  decoded.data(using: .utf8)
//        // working
//        socket?.on(clientEvent: .connect) {data, ack in
//            print("Connected")
//            self.socket?.emit("join", dic2)
//        }
//        // working
//        socket?.on("addPeer") { (data, ack) in
//            print("addpeer..")
//            guard let dataInfo = data.first else { return }
//            guard let resultNew = dataInfo as? [String:Any]else{
//                return
//            }
//            
//            let peer_id = resultNew["peer_id"]  as! String
//            let should_create_offer = resultNew["should_create_offer"]  as! Bool
//            let vdp_id = resultNew["vdp_id"]  as! String
//            
//            print("Now this chat has \(dataInfo) users.")
//            if resultNew["should_create_offer"]  as! Bool{
//                if self.icecandidate == false{
//                    self.icecandidate = true
//                    self.responceDetail = ResponceResult(peer_id: peer_id , should_create_offer: should_create_offer, vdp_id: vdp_id )
//                    self.sendOffer()
//                }
//            }else{
//                self.sendAnswer()
//            }          
//        }
//        // working
//        socket?.on("error"){(data ,arg)  in
//            print(data)
//            print(arg)
//        }
//        // working
//        socket?.on("sessionDescription"){(data ,arg)  in
//            print("session discription")
//            print(data)
//            guard let dataInfo = data.first else { return }
//            guard let resultNew = dataInfo as? [String:Any]else{
//                return
//            }
//            let peer_id = resultNew["peer_id"]  as! String
//            //  let should_create_offer = resultNew["should_create_offer"]  as! Bool
//            let session_description = resultNew["session_description"]  as? [String:Any]
//            if session_description?["type"] as! String == "answer"{
//                print("answer")
//                let sdp = RTCSessionDescription(type: RTCSdpType(rawValue: 1 )!, sdp: session_description!["sdp"] as! String)
//                self.onAnswer(sdp: sdp)
//                
//            }else if session_description?["type"] as! String == "offer"{
//                print("offer")
//                //                let sdp = RTCSessionDescription(type: RTCSdpType(rawValue: 0 )!, sdp: session_description!["sdp"] as! String)
//                //                self.onOffer(sdp: sdp)
//            }
//            print("error session dis=\(arg.debugDescription)")
//        }
//        // working
//        socket?.on("removePeer") { (data, ack) in
//            guard let dataInfo = data.first else { return }
//            print("Now this chat has \(dataInfo) users.")
//        }
//        
//        socket?.on("join") { (data, ack) in
//            guard let dataInfo = data.first else { return }
//            //               if let response: SocketMessage = try? SocketParser.convert(data: dataInfo) {
//            print("join from =\(dataInfo)")
//            //               }
//        }
//        // working
//        socket?.on("iceCandidate") { (data, ack) in
//            print(data)
//            guard let dataInfo = data.first else { return }
//            print("Received ICE candidate= \(dataInfo) is typing...")
//            guard let resultNew = dataInfo as? [String:Any]else{
//                return
//            }
//            let peer_id = resultNew["peer_id"]  as! String
//            
//            print("icecandidate = \(peer_id)")
//            if self.icecandidate == true{
//                    //   let should_create_offer = resultNew["should_create_offer"]  as! Bool
//                    let json = resultNew["ice_candidate"]  as? [String:Any]
//                    let candidate = RTCIceCandidate(
//                        sdp: json!["candidate"] as! String,
//                        sdpMLineIndex: Int32(json?["sdpMLineIndex"] as! Int),
//                        sdpMid: json?["id"] as? String)
//                    print("call to ice candidate in \(peer_id)")
//                    self.onCandidate(candidate: candidate);
//          
//            }
//        }
//        
//        socket?.on("full") { (data, ack) in
//            guard let dataInfo = data.first else { return }
//            //               if let response: SocketUserTyping = try? SocketParser.convert(data: dataInfo) {
//            print("full \(dataInfo) stopped typing...")
//            //               }
//        }
//        socket?.on("joined") { (data, ack) in
//            guard let dataInfo = data.first else { return }
//            //               if let response: SocketUserTyping = try? SocketParser.convert(data: dataInfo) {
//            print("joined \(dataInfo)typing...")
//            //               }
//        }
//        socket?.on("log") { (data, ack) in
//            guard let dataInfo = data.first else { return }
//            //               if let response: SocketUserTyping = try? SocketParser.convert(data: dataInfo) {
//            print("log \(dataInfo) typing...")
//            //               }
//        }
//        socket?.on("bye") { (data, ack) in
//            guard let dataInfo = data.first else { return }
//            //               if let response: SocketUserTyping = try? SocketParser.convert(data: dataInfo) {
//            print("bye \(dataInfo) stopped typing...")
//            //               }
//        }
//        socket?.on("message") { (data, ack) in
//            guard let dataInfo = data.first else { return }
//            //               if let response: SocketUserTyping = try? SocketParser.convert(data: dataInfo) {
//            print("message= \(dataInfo)   typing...")
//            //               }
//        }
//        socket?.on(clientEvent: .disconnect, callback: { data, ack in
//            print("SocketManager: disconnected")
//            
//            //   self.sendNotification(event: "DISCONNECTED")
//        })
//    }
    
    //MARK: Receive
    func receive(){
        /// This Recurring will keep us connected to the server
        /*
         - Create a workItem
         - Add it to the Queue
         */
        
        let workItem = DispatchWorkItem{ [weak self] in
            
            self?.webSocket?.receive(completionHandler: { result in
                
                
                switch result {
                case .success(let message):
                    
                    switch message {
                        
                    case .data(let data):
                        print("Data received \(data)")
                        
                    case .string(let strMessgae):
                        print("String received \(strMessgae)")
                        
                    default:
                        break
                    }
                    
                case .failure(let error):
                    print("Error Receiving \(error)")
                }
                // Creates the Recurrsion
                self?.receive()
            })
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 1 , execute: workItem)
    }
    
    //MARK: Send
    func send(){
        /*
         - Create a workItem
         - Add it to the Queue
         */
        
        let workItem = DispatchWorkItem{
            
            self.webSocket?.send(URLSessionWebSocketTask.Message.string("Hello"), completionHandler: { error in
                
                if error == nil {
                    // if error is nil we will continue to send messages else we will stop
                    self.send()
                }else{
                    print(error)
                }
            })
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: workItem)
    }
    
    //MARK: Close Session
    @objc func closeSession(){
        webSocket?.cancel(with: .goingAway, reason: "You've Closed The Connection".data(using: .utf8))
        socket?.emit("disconnect")
        socket?.disconnect()
       
        
    }
    @objc func connectt(){
        myconnectfunc()
        print("connect")
    }
    private var MicMute: Bool = true
    @objc func btnMute(){
        if !MicMute{
            print(" Audio session is muted")
            //  buttonMute.setTitle("Mute", for: .normal)
            unmuteAudio()
            MicMute = true
        }else{
            print("Audio session is not muted")
            //  buttonMute.setTitle("UnMute", for: .normal)
            muteAudio()
            MicMute = false
        }
    }
    private var speker: Bool = true
    func btnSpekerOff(){
        if !speker{
            print(" Audio session is on")
            //  buttonSpekerOff.setTitle("Speaker Off", for: .normal)
            speakerOn()
            speker = true
        }else{
            print("Audio session is not off")
            //    buttonSpekerOff.setTitle("Speaker On", for: .normal)
            speakerOff()
            speker = false
        }
    }
    //MARK: URLSESSION Protocols
    
    
}
extension VDPListViewController{
    func sendOffer() {
        peerConnection = prepareNewConnection();
        peerConnection.offer(for: mediaConstraints) { (RTCSessionDescription, Error) in
            
            if(Error == nil){
                print("send offer")
                self.peerConnection.setLocalDescription(RTCSessionDescription!, completionHandler: { (Error) in
                    print("Sending: SDP")
                    print(RTCSessionDescription as Any)
                    self.sendSDP(sdp: RTCSessionDescription!)
                })
            } else {
                print("sdp creation error: \(Error)")
            }
        }
    }
    
    func sendSDP(sdp:RTCSessionDescription) {
        print("Converting sdp...\(responceDetail.peer_id)")
        var type = ""
        if (sdp.type.rawValue) == 0{
            type = "offer"
        }else if (sdp.type.rawValue) == 2{
            type = "answer"
        }
        print("type=\(sdp.type.rawValue)")
        let json:[String: Any] = [
            "type" : type,
            "sdp"  : sdp.sdp.description as String
        ]
        let json1:[String: Any] = [
            "peer_id" : (responceDetail.peer_id ?? "") as String,
            "session_description"  : json]
        sigSend(msg: json1 as NSDictionary);
    }
    
    func onAnswer(sdp:RTCSessionDescription) {
        setAnswer(sdp: sdp)
    }
    
    func onCandidate(candidate:RTCIceCandidate) {
        peerConnection.add(candidate){ error in
            print("error=\(error?.localizedDescription)")
            self.timer.invalidate()
        }
    }
    
    func sigRecoonect() {
     //   DashboardController.socket.disconnect();
        DashboardController.socket?.connect();
    }
    
    func sigSend(msg:NSDictionary) {
        print("json= \(msg)")
        DashboardController.socket?.emit("relaySessionDescription", msg)
    }
    
    func sigSendIce(msg:NSDictionary) {
        DashboardController.socket?.emit("relayICECandidate", msg)
    }
    func sigEnter() {
        let roomName = getRoomName();
        print("Entering room: " + roomName);
        DashboardController.socket?.emit("enter", roomName);
    }
    
    func sendAnswer() {
        print("sending Answer. Creating remote session description...")
        if (peerConnection == nil) {
            print("peerConnection NOT exist!")
            return
        }
        
        peerConnection.answer(for: mediaConstraints) { (RTCSessionDescription, Error) in
            print("ice shizzle")
            
            if(Error == nil){
                self.peerConnection.setLocalDescription(RTCSessionDescription!, completionHandler: { (Error) in
                    print("Sending: SDP")
                    print(RTCSessionDescription as Any)
                    self.sendSDP(sdp: RTCSessionDescription!)
                })
            } else {
                print("sdp creation error: \(Error)")
            }
        }
    }
    
    func setAnswer(sdp:RTCSessionDescription) {
        if (peerConnection == nil) {
            print("peerConnection NOT exist!")
            return
        }
        
        peerConnection.setRemoteDescription(sdp) { (Error) in
            print("remote description")
        }
    }
    
    
    func sendDisconnect() {
        let json:[String: AnyObject] = [
            "type" : "user disconnected" as AnyObject
        ]
        sigSend(msg: json as NSDictionary);
    }
    func initWebRTC() {
            RTCInitializeSSL()
            let options = RTCPeerConnectionFactoryOptions()
            let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
            peerConnectionFactory = RTCPeerConnectionFactory()
            RTCPeerConnectionFactory.init(encoderFactory: videoEncoderFactory, decoderFactory:  RTCDefaultVideoDecoderFactory(), audioDevice: nil)
            
            let mandatoryConstraints = ["OfferToReceiveAudio": "true", "OfferToReceiveVideo": "true"]
            //  let optionalConstraints = [ "DtlsSrtpKeyAgreement": "true", "RtpDataChannels" : "true", "internalSctpDataChannels" : "true"]
            
            mediaConstraints = RTCMediaConstraints.init(mandatoryConstraints: mandatoryConstraints, optionalConstraints: nil)
    }
    
    func prepareNewConnection() -> RTCPeerConnection {
        do{
        var icsServers: [RTCIceServer] = []
            for item in iiceServer{
              //  icsServers.append(RTCIceServer(urlStrings: ["stun:stun1.l.google.com:19302"]))
                icsServers.append(RTCIceServer(urlStrings: ["\(item.url ?? "")"]
                                               , username: item.username ,credential: item.credential ))
            }
//            icsServers.append(RTCIceServer(urlStrings: ["stun:stun1.l.google.com:19302"]))
//            icsServers.append(RTCIceServer(urlStrings: ["turn:43.204.19.95:3478"], username:"home",credential: "home1234"))
       // icsServers.append(RTCIceServer(urlStrings: ["turn:relay.metered.ca:443"], username:"28a2fa03b765f96252ee363b",credential: "wTEvsXPyGPb+61h9"))
      //  icsServers.append(RTCIceServer(urlStrings: ["turn:relay.metered.ca:443?transport=tcp"], username:"28a2fa03b765f96252ee363b",credential: "wTEvsXPyGPb+61h9"))
        
        let rtcConfig: RTCConfiguration = RTCConfiguration()
        rtcConfig.tcpCandidatePolicy = RTCTcpCandidatePolicy.disabled
        rtcConfig.bundlePolicy = RTCBundlePolicy.maxBundle
        rtcConfig.rtcpMuxPolicy = RTCRtcpMuxPolicy.require
        rtcConfig.continualGatheringPolicy = RTCContinualGatheringPolicy.gatherContinually
        rtcConfig.keyType = RTCEncryptionKeyType.ECDSA
        rtcConfig.iceServers = icsServers;
        
            try peerConnection = peerConnectionFactory?.peerConnection(with: rtcConfig, constraints: mediaConstraints, delegate: self)
        //  peerConnection.add(mediaStream);
       try peerConnection.add(localAudioTrack, streamIds: ["101"])
        let tt = RTCDataChannelConfiguration();
        tt.isOrdered = false;
        self.dataChannel = peerConnection.dataChannel(forLabel: "testt", configuration: tt)
        self.dataChannel.delegate = self
        print("Make datachannel")
    }catch let error{
        print("chrashed reeor=\(error.localizedDescription)")
    }
        return peerConnection;
    }
    func setupView(){
        // local
        localRenderView = RTCEAGLVideoView()
        localRenderView!.delegate = self
        localView = UIView()
        localView.addSubview(localRenderView!)
        // remote
        remoteRenderView = RTCEAGLVideoView()
        remoteRenderView?.delegate = self
        remoteView = UIView()
        remoteView.addSubview(remoteRenderView!)
    }
    func setupLocalTracks(){
        self.localVideoTrack = createVideoTrack()
        self.localAudioTrack = createAudioTrack()
    }
    private func createAudioTrack() -> RTCAudioTrack {
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = self.peerConnectionFactory?.audioSource(with: audioConstrains)
        let audioTrack = self.peerConnectionFactory?.audioTrack(with: audioSource!, trackId: "audio0")
        return audioTrack!
    }
    
    private func createVideoTrack() -> RTCVideoTrack {
        let videoSource = self.peerConnectionFactory?.videoSource()
        
        if self.customFrameCapturer {
            self.videoCapturer = RTCCustomFrameCapturer(delegate: videoSource!)
        }else if TARGET_OS_SIMULATOR != 0 {
            print("now runnnig on simulator...")
            self.videoCapturer = RTCFileVideoCapturer(delegate: videoSource!)
        }
        else {
            self.videoCapturer = RTCCameraVideoCapturer(delegate: videoSource!)
        }
        let videoTrack = self.peerConnectionFactory?.videoTrack(with: videoSource!, trackId: "video0")
        return videoTrack!
    }
    func setupRemoteViewFrame(frame: CGRect){
        remoteView.frame = frame
        remoteRenderView?.frame = remoteView.frame
    }
}
extension VDPListViewController{
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        let isLandScape = size.width < size.height
        var renderView: RTCEAGLVideoView?
        var parentView: UIView?
        if videoView.isEqual(localRenderView){
            print("local video size changed")
            renderView = localRenderView
            parentView = localView
        }
        
        if videoView.isEqual(remoteRenderView!){
            print("remote video size changed to: ", size)
            renderView = remoteRenderView
            parentView = remoteView
        }
        
        guard let _renderView = renderView, let _parentView = parentView else {
            return
        }
        
        if(isLandScape){
            let ratio = size.width / size.height
            _renderView.frame = CGRect(x: 0, y: 0, width: _parentView.frame.height * ratio, height: _parentView.frame.height)
            _renderView.center.x = _parentView.frame.width/2
        }else{
            let ratio = size.height / size.width
            _renderView.frame = CGRect(x: 0, y: 0, width: _parentView.frame.width, height: _parentView.frame.width * ratio)
            _renderView.center.y = _parentView.frame.height/2
        }
    }
}
//MARK: - RTCPeerConnectionDelegate - begin
extension VDPListViewController{
    //media stream
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd rtpReceiver: RTCRtpReceiver, streams mediaStreams: [RTCMediaStream]) {
        DispatchQueue.main.async {
            ProgressOverlay.shared.stopAnimation()
        }
      //  timer.invalidate()
        if let valueid = mediaStreams.first?.streamId{
            if valueid == "101"{
                PopupManager.shared.displaySuccess(message: "new devices", description: "")
            }
        }
        print("did add stream")
        guard let tracks = mediaStreams.first?.videoTracks.first else{return}
        let x = tracks
        print("media track id = \(x.trackId)")
        self.remoteStream = mediaStreams.first
        
        if let track = mediaStreams.first!.videoTracks.first {
            remoteVideoTrack = track
            print("video track faund")
            remoteVideoTrack.add(remoteRenderer)
        }
        if let track = mediaStreams.first!.audioTracks.first {
            // remoteVideoTrack = track
            print("audio track faund")
            track.source.volume = 8
            localAudioTrack = track
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.speakerOn()
                self.muteAudio()
            }
        }
    }
    
    
    func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        //   self.delegate?.webRTCClient(didReceiveData: buffer.data)
        delegate?.webRTCClient(didReceiveData: buffer.data)
        print("data chanel Buffer=\(buffer.data)")
    }
    public func dataChannelDidChangeState(_ dataChannel: RTCDataChannel){
        print("channel.state \(dataChannel.readyState.rawValue)");
    }
    
    /** Called when the SignalingState changed. */
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState){
        print("signal state: \(stateChanged.rawValue)")
    }
    
    /** Called when media is received on a new stream from remote peer. */
    public func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream){
        print("add new connection=\(stream.debugDescription)")
        if (peerConnection == nil) {
            return
        }
        
        if let audioTrack = stream.audioTracks.first{
            print("New audio track faund")
            audioTrack.source.volume = 8
        }
        if (stream.videoTracks.count > 1) {
            print("new Weird-looking stream: " + stream.description)
            return
        }
    }
    
    /** Called when a remote peer closes a stream. */
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream){
        print("didRemove=\(stream.audioTracks)")
    }
    
    
    /** Called when negotiation is needed, for example ICE has restarted. */
    public func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection){
        print("example ICE has restarted=\(peerConnection.localDescription)")
    }
    
    
    /** Called any time the IceConnectionState changes. */
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState){
        print("newState=\(newState)")
        
    }
    
    
    /** Called any time the IceGatheringState changes. */
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState){
        print("didChange=\(newState)")
        
    }
    
    
    /** New ice candidate has been found. */
    public func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate){
        
        print("iceCandidate: " + candidate.description)
        let json1:[String: Any] = [ "sdpMLineIndex" : candidate.sdpMLineIndex as Any, "id" : candidate.sdpMid as Any, "candidate" : candidate.sdp as Any]
        let json:[String: Any] = [
            "peer_id": responceDetail.peer_id ,
            "ice_candidate" : json1 as AnyObject
        ]
        sigSendIce(msg: json as NSDictionary)
        
    }
    
    
    /** Called when a group of local Ice candidates have been removed. */
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]){
        print("didremove")
    }
    
    /** New data channel has been opened. */
    public func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel){
        print("Datachannel is open, name: \(dataChannel.label)")
        dataChannel.delegate = self
        self.dataChannelRemote = dataChannel
    }
    
    func sendData(message: String) {
        let newData = message.data(using: String.Encoding.utf8)
        let dataBuff = RTCDataBuffer(data: newData!, isBinary: false)
        self.dataChannel.sendData(dataBuff)
    }
    
    func onOffer(sdp:RTCSessionDescription) {
        print("on offer shizzle")
        
        setOffer(sdp: sdp)
        sendAnswer()
        peerStarted = true;
    }
    func setOffer(sdp:RTCSessionDescription) {
        if (peerConnection != nil) {
            print("peer connection already exists")
        }
        peerConnection = prepareNewConnection();
        peerConnection.setRemoteDescription(sdp) { (Error) in
            
        }
    }
}
// MARK:- Audio control
extension VDPListViewController {
    func muteAudio() {
        self.setAudioEnabled(false)
    }
    
    func unmuteAudio() {
        self.setAudioEnabled(true)
    }
    
    // Fallback to the default playing device: headphones/bluetooth/ear speaker
    func speakerOff() {
        print(rtcAudioSession)
        DispatchQueue.global(qos: .background).async {
            self.audioQueue.async { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.rtcAudioSession.lockForConfiguration()
                do {
                    try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
                    try self.rtcAudioSession.overrideOutputAudioPort(.none)
                     
                } catch let error {
                    debugPrint("Error setting AVAudioSession category: \(error)")
                }
                self.rtcAudioSession.unlockForConfiguration()
            }
        }
    }
    // Force speaker
    func speakerOn() {
        print(rtcAudioSession)
        DispatchQueue.global(qos: .background).async {
            self.audioQueue.async { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.rtcAudioSession.lockForConfiguration()
                do {
                    let audioPlayer = AVAudioPlayer()
                    audioPlayer.stop()
                    try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
                    try self.rtcAudioSession.overrideOutputAudioPort(.speaker)
                    try self.rtcAudioSession.setActive(true)
                } catch let error {
                    debugPrint("Couldn't force audio to speaker: \(error)")
                }
                self.rtcAudioSession.unlockForConfiguration()
            }
        }
    }
    
    private func setAudioEnabled(_ isEnabled: Bool) {
        let audioTracks = self.peerConnection.transceivers.compactMap { return $0.sender.track as? RTCAudioTrack }
        print(audioTracks)
        audioTracks.forEach { $0.isEnabled = isEnabled }
    }
    private func configureAudioSession() {
        self.rtcAudioSession.lockForConfiguration()
        do {
            try self.rtcAudioSession.overrideOutputAudioPort(.none)
            try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
            // try self.rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
            try self.rtcAudioSession.overrideOutputAudioPort(.speaker)
            try self.rtcAudioSession.setActive(true)
            
            //       try rtcAudioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            //  try rtcAudioSession.setMode(.spokenAudio)
            //    try rtcAudioSession.overrideOutputAudioPort(.none)
            //  try rtcAudioSession.setInputGain(5)
        } catch let error {
            debugPrint("Error changeing AVAudioSession category: \(error)")
        }
        self.rtcAudioSession.unlockForConfiguration()
        
    }
}
extension VDPListViewController{
    func webrtConnect(data: Array<Any>) {
        print("list connect")
        DispatchQueue.main.async {
            ProgressOverlay.shared.stopAnimation()
        }
    }

    func timestamp(){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            let date = Date()
            let dateString = dateFormatter.string(from: date)
            print("timer socket= \(dateString)")
        }
    }
    func webrtcAddPeer(data: Array<Any>) {
        print("list Addpeer")
        guard let dataInfo = data.first else { return }
        guard let resultNew = dataInfo as? [String:Any]else{
            return
        }
        
        let peer_id = resultNew["peer_id"]  as! String
        let should_create_offer = resultNew["should_create_offer"]  as! Bool
        let vdp_id = resultNew["vdp_id"]  as! String
        
        print("Now this chat has \(dataInfo) users.")
        if resultNew["should_create_offer"]  as! Bool{
            if self.icecandidate == false{
                self.icecandidate = true
                self.responceDetail = ResponceResult(peer_id: peer_id , should_create_offer: should_create_offer, vdp_id: vdp_id )
                self.sendOffer()
            }
        }else{
            self.sendAnswer()
        }
    }
    
    func webrtcSessionDescription(data: Array<Any>) {
        print("list session discription")
        print(data)
        guard let dataInfo = data.first else { return }
        guard let resultNew = dataInfo as? [String:Any]else{
            return
        }
        let peer_id = resultNew["peer_id"]  as! String
        //  let should_create_offer = resultNew["should_create_offer"]  as! Bool
        let session_description = resultNew["session_description"]  as? [String:Any]
        if session_description?["type"] as! String == "answer"{
            print("answer")
            let sdp = RTCSessionDescription(type: RTCSdpType(rawValue: 1 )!, sdp: session_description!["sdp"] as! String)
            self.onAnswer(sdp: sdp)
            
        }else if session_description?["type"] as! String == "offer"{
            print("offer")
            //                let sdp = RTCSessionDescription(type: RTCSdpType(rawValue: 0 )!, sdp: session_description!["sdp"] as! String)
            //                self.onOffer(sdp: sdp)
        }
    //    print("error session dis=\(arg.debugDescription)")
    }
    
    func webrtcRemovePeer(data: Array<Any>) {
        print("list removepeer")
        guard let dataInfo = data.first else { return }
        print("Now this chat has \(dataInfo) users.")
    }
    
    func webrtciceCandidate(data: Array<Any>) {
        print("list iceCandidate")
        print(data)
        guard let dataInfo = data.first else { return }
        print("Received ICE candidate= \(dataInfo) is typing...")
        guard let resultNew = dataInfo as? [String:Any]else{
            return
        }
        let peer_id = resultNew["peer_id"]  as! String
        
        print("icecandidate = \(peer_id)")
        if self.icecandidate == true{
                //   let should_create_offer = resultNew["should_create_offer"]  as! Bool
                let json = resultNew["ice_candidate"]  as? [String:Any]
                let candidate = RTCIceCandidate(
                    sdp: json!["candidate"] as! String,
                    sdpMLineIndex: Int32(json?["sdpMLineIndex"] as! Int),
                    sdpMid: json?["id"] as? String)
                print("call to ice candidate in \(peer_id)")
                self.onCandidate(candidate: candidate);
            }
    }
    
    func webrtcError() {
        print("list error")
    }
    
    func webrtcDisConnected() {
        print("list Disconnect")
    }

}
extension VDPListViewController{
    func webRTCClient(didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        
    }
    
    func webRTCClient(didChangeConnectionState state: RTCIceConnectionState) {
        
    }
    
    func webRTCClient(didReceiveData data: Data) {
        //        if data == likeStr.data(using: String.Encoding.utf8) {
        //            self.startLikeAnimation()
        //        }
    }
}
extension VDPListViewController{
    //update token
    func UpdateVdpNotification(){
        if let uid = Auth.auth().currentUser?.uid{
            let ref =    Database.database().reference()
                .child("vdpDeviceToken")
                .child(uid)
            
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now()) {
                
                ref.observeSingleEvent(of: DataEventType.value) { [self](pDataSnapshot, error)  in
                    let token = CacheManager.shared.fcmToken
                    let randomNumber = Int(arc4random_uniform(100)) + 1
                    let data: Optional<Any> = pDataSnapshot.value
                    let update = parsefunction(data: data)
                    if update == false
                    {
                        ref.child(String(describing: randomNumber)).setValue(token)
                    }
                }
            }
        }
    }
    
    func parsefunction(data: Optional<Any>)-> Bool{
        var update = false
        if let dataArray = data as? [Any] {
            let token = CacheManager.shared.fcmToken
            for ix in dataArray {
                print(ix)
                if  ix as? String == token {
                    update = true
                }
            }
        }
        return update
    }
    //remove token
    func removeTokenFunc(){
        if let uid = Auth.auth().currentUser?.uid{
            let ref =    Database.database().reference()
                .child("vdpDeviceToken")
                .child(uid)
            
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now()) {
                var key = String()
                ref.observeSingleEvent(of: DataEventType.value) { [self](pDataSnapshot, error)  in
                    let data: Optional<Any> = pDataSnapshot.value
                    let token = CacheManager.shared.fcmToken
                    let update = parsefunction(data: data)
                    let x = data as? [String: Any]
                    if x != nil{
                        var update = false
                        for data in x!{
                            if data.value as! String == token{
                                print(token!)
                                update = true
                                key = data.key as! String
                            }
                        }
                        if update == false{
                            print("not found")
                            //  ref.child(String(describing: randomNumber)).setValue(token)
                        }else{
                            print("found =\(key)")
                            ref.child(key as! String).removeValue()
                        }
                    }
                }
            }
        }
    }
    func checkTokenFunc(complition: @escaping(Bool)-> Void){
        var update = false
        if let uid = Auth.auth().currentUser?.uid{
            let ref =    Database.database().reference()
                .child("vdpDeviceToken")
                .child(uid)
            
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now()) {
                var key = String()
                ref.observeSingleEvent(of: DataEventType.value) { [self](pDataSnapshot, error)  in
                    let data: Optional<Any> = pDataSnapshot.value
                    let token = CacheManager.shared.fcmToken
                    let x = data as? [String: Any]
                    if x != nil{
                        
                        for data in x!{
                            if data.value as! String == token{
                                print(token!)
                                update = true
                                key = data.key as! String
                            }
                        }
                        if update == false{
                            print("not found")
                            complition(update)
                            //  ref.child(String(describing: randomNumber)).setValue(token)
                        }else{
                            print("found =\(key)")
                            complition(update)
                        }
                    }
                }
            }
        }
    }
}
