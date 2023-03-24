//
//  ViewController.swift
//  WebSocket-Tutorial
//
//  Created by omair khan on 05/01/2022.
//

import UIKit
import AVFoundation
import SocketIO
import Foundation
import WebRTC
import Starscream
import AVFAudio
import MetalKit
import Firebase
import FirebaseAuth
import FirebaseDatabase


class CallingViewController: BaseController,URLSessionWebSocketDelegate,RTCPeerConnectionDelegate, RTCDataChannelDelegate, RTCVideoViewDelegate,WebRTCClientDelegate{
    var vdpmodule: VDPModul?
    var mediaStream: RTCMediaStream!
    var remoteAudioTrack: RTCAudioTrack!
    var dataChannel: RTCDataChannel!
    var dataChannelRemote: RTCDataChannel!
    var roomName: String!
    var id = ""
    //MARK: - Properties
    
    var peerConnectionFactory: RTCPeerConnectionFactory! = nil
    var peerConnection: RTCPeerConnection! = nil
    var mediaConstraints: RTCMediaConstraints! = nil
    private let rtcAudioSession =  RTCAudioSession.sharedInstance()
    private let audioQueue = DispatchQueue(label: "audio")
    private var localRenderView: RTCEAGLVideoView!
    private var localView: UIView!
    private var remoteRenderView: RTCMTLVideoView?
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
    
    
    
    @IBOutlet weak var expandFooter: UIView!
    @IBOutlet weak var lblExpand: UIButton!
    @IBOutlet weak var missedcallView: UIView!
    @IBOutlet weak var lblMute: UIButton!
    
    @IBOutlet weak var viewShowvdp: UIView!
    @IBOutlet weak var lblexpandbtn: UIButton!
    @IBOutlet weak var lblspeaker: UIButton!
    //botom line
    
    @IBOutlet weak var custommsgNavigatebtn: UIButton!
    @IBOutlet weak var missedCallNevigatebtn: UIButton!
    
    
    @IBOutlet weak var lblVideo: UIButton!
    @IBOutlet weak var lblScreenShort: UIButton!
    @IBOutlet weak var lblVideoRorate: UIButton!
    var database: DatabaseReference!
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
    
    let buttonMute : UIButton = {
        var btn = UIButton()
        btn.backgroundColor = .red
        btn.setTitle("Mute", for: .normal)
        return btn
    }()
    
    let buttonSpekerOff : UIButton = {
        var btn = UIButton()
        btn.backgroundColor = .red
        btn.setTitle("SpekerOff", for: .normal)
        return btn
    }()
    
    let viewExpand : UIView = {
        var views = UIView()
        views.backgroundColor = .gray
        return views
    }()
    private var webSocket : URLSessionWebSocketTask?
    var icecandidate = Bool()
    
    func setupSocket() {
        self.socket = manager.defaultSocket
    }
    
    func myconnectfunc()  {
        setupSocket()
        setupSocketEvents()
        socket?.connect()
    }
    
    //  let audioSessionn = AVAudioSession.sharedInstance()
    //MARK: - View didload
    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        subTitle = ""
        vdpUisetup()
        myUlsetUp()
        database = Database.database().reference()
        // myconnectfunc()
        initWebRTC();
        self.configureAudioSession()
        localAudioTrack = peerConnectionFactory.audioTrack(withTrackId: AUDIO_TRACK_ID)
        mediaStream = peerConnectionFactory.mediaStream(withStreamId: LOCAL_MEDIA_STREAM_ID)
        mediaStream.addAudioTrack(localAudioTrack)
        
        viewExpand.frame = CGRect(x: 0, y: 130, width: self.view.frame.width, height: self.view.frame.height * 0.80)
        viewExpand.isHidden = true
        //  myExpandUlsetUp()
        vdpmodule = VDPModul()
        
        
        if (socket == nil) {
            //  ProgressOverlay.shared.show()
            icecandidate = false
            myconnectfunc()
            timestamp()
            
        }else{
            icecandidate = true
            socket?.disconnect()
            socket = nil
            timer.invalidate()
        }
        self.view.addSubview(viewExpand)
        //        setupView()
        //        setupLocalTracks()
        //        setupUI()
        button.frame = CGRect(x: self.view.frame.width/2.5 - 100, y: self.view.frame.height/1.4, width: 200, height: 100)
        self.view.addSubview(button)
        // self.view.backgroundColor = .blue
        button.addTarget(self, action: #selector(closeSession), for: .touchUpInside)
        
        buttonconnect.frame = CGRect(x: self.view.frame.width/2.5 - 100, y: self.view.frame.height/1.15, width: 200, height: 100)
        self.view.addSubview(buttonconnect)
        buttonconnect.addTarget(self, action: #selector(connectt), for: .touchUpInside)
        
        buttonMute.frame = CGRect(x: self.view.frame.width/1.02 - 100, y: self.view.frame.height/1.15, width: 100, height: 50)
        self.view.addSubview(buttonMute)
        buttonMute.addTarget(self, action: #selector(btnMute), for: .touchUpInside)
        
        buttonSpekerOff.frame = CGRect(x: self.view.frame.width/1.02 - 100, y: self.view.frame.height/1.4, width: 100, height: 50)
        self.view.addSubview(buttonSpekerOff)
        buttonSpekerOff.addTarget(self, action: #selector(btnSpekerOff), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UpdateCallStatus()
        //  ProgressOverlay.shared.show()
    }
    func vdpUisetup(){
        lblMenu.setTitle("", for: .normal)
        lblCallEnd.setTitle("", for: .normal)
        lblLock.setTitle("", for: .normal)
        lblMute.setTitle("", for: .normal)
        lblExpand.setTitle("", for: .normal)
        
        lblspeaker.setTitle("", for: .normal)
        lblScreenShort.setTitle("", for: .normal)
        lblVideo.setTitle("", for: .normal)
        lblVideoRorate.setTitle("", for: .normal)
        lblexpandbtn.setTitle("", for: .normal)
        lblexpandPlaybtn.setTitle("", for: .normal)
        lblexpSpeaker.setTitle("", for: .normal)
        expandFooter.isHidden = true
        
        expandFooter.layer.zPosition = 1
        viewShowvdp.layer.zPosition = 0
        buttonMute.isHidden = true
        button.isHidden = true
        buttonSpekerOff.isHidden = true
        buttonconnect.isHidden = true
        
        
        
        lblnightVision.layer.cornerRadius = 10
        lblnightVision.layer.masksToBounds = true
        lblnightVision.layer.borderColor = UIColor.gray.cgColor
        lblnightVision.layer.borderWidth = 1
        
        lbldefault.layer.cornerRadius = 8
        lbldefault.layer.masksToBounds = true
        lbldefault.layer.borderColor = UIColor.gray.cgColor
        lbldefault.layer.borderWidth = 1
        
        lblblacknWihite.layer.cornerRadius = 10
        lblblacknWihite.layer.masksToBounds = true
        lblblacknWihite.layer.borderColor = UIColor.gray.cgColor
        lblblacknWihite.layer.borderWidth = 1
    }
    
    @IBOutlet weak var lblMenu: UIButton!
    @IBOutlet weak var lblexpandPlaybtn: UIButton!
    @IBOutlet weak var lblexpSpeaker: UIButton!
    @IBAction func didtappedMute(_ sender: Any) {
        muttedTapped()
        print("didtapped Mute")
    }
    
    @IBOutlet weak var expandBottomview: UIView!
    
    @IBAction func didtappedMunubtn(_ sender: Any) {
    }
    @IBAction func didtappedExpand(_ sender: Any) {
        print("didtapped Expand")
        var frame = remoteRenderer.frame
        let w = self.view.frame.width
        let h =  self.view.frame.height * 0.935
        if remoteRenderer.transform == CGAffineTransform(rotationAngle: .pi / 2){
            remoteRenderer.transform = CGAffineTransform(rotationAngle: .pi * 2) //right portrate
            frame.origin.x = 0
            frame.origin.y = 1
            frame.size.height = 270
            remoteRenderer.frame = frame
        }else if remoteRenderer.transform == CGAffineTransform(rotationAngle: .pi * 2){
            remoteRenderer.transform = CGAffineTransform(rotationAngle: .pi / 2)//landscap
            frame.origin.x = 0
            frame.origin.y = 1
            frame.size.height = h
            remoteRenderer.frame = frame
        }else{//right
            remoteRenderer.transform = CGAffineTransform(rotationAngle: .pi / 2)//landscap
            frame.size.height = h
            frame.origin.x = 0
            frame.origin.y = 1
            remoteRenderer.frame = frame
        }
        
        if viewMute.isHidden {
            expandFooter.isHidden = true
            //   expandBottomview.isHidden = true
            viewpause.backgroundColor = .black
            viewMute.isHidden = false
            lblspeaker.isHidden = false
            
            lblExpand.isHidden = false
            remoteRenderer.willRemoveSubview(lblexpandbtn)
            
        }else{
            expandFooter.isHidden = false
            expandFooter.addSubview(lblexpSpeaker)
            expandFooter.addSubview(lblexpandPlaybtn)
            expandFooter.addSubview(lblexpandbtn)
            viewShowvdp.addSubview(expandFooter)
            viewpause.backgroundColor = .clear
            //  viewpause.isHidden = true
            viewMute.isHidden = true
            lblspeaker.isHidden = true
            
            lblExpand.isHidden = true
            let rotation = CGAffineTransform(rotationAngle: .pi / 2)
            lblexpSpeaker.transform = rotation
            lblexpandPlaybtn.transform = rotation
            lblexpandbtn.transform = rotation
            
            
            
        }
        
        //        if  localRenderView.isHidden{
        //            viewExpand.isHidden = true
        //            viewShowvdp.isHidden = true
        //            localRenderView.isHidden = false
        //            localRenderView.addSubview(lblexpandbtn)
        //         //   localRenderView.addSubview(lblexpandPlaybtn)
        ////             var frames = viewbackground.frame
        ////              frames.origin.y = 100
        ////              frames.origin.x = 100
        ////            let w = frames.size.width
        ////            localRenderView.center = viewbackground.center
        ////            frames.size.width =  self.view.frame.height - 139
        ////            frames.size.height = self.view.frame.width - 100
        ////             localRenderView.bounds =  frames
        ////           // localRenderView.contentMode = .scaleToFill
        ////             viewbackground.addSubview(localRenderView)
        ////            //  localRenderView.center = viewExpand.center
        //            localRenderView.transform = CGAffineTransform(rotationAngle: .pi / 2)
        //        }else{
        //            localRenderView.isHidden = true
        //            viewExpand.isHidden = true
        //
        //        }
    }
    
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var viewbackground: UIView!
    @IBAction func didtappedSpeakerOff(_ sender: Any) {
        speakeroffOn()
    }
    
    @IBAction func didtappedRotate(_ sender: Any) {
        
        var frame = remoteRenderer.frame
        let w = frame.size.width
        let h = frame.height
        
        if remoteRenderer.transform == CGAffineTransform(rotationAngle: .pi / 2){
            remoteRenderer.transform = CGAffineTransform(rotationAngle: .pi) //right portrate
            frame.size.height = h
            frame.size.width = w
            remoteRenderer.bounds = frame
        }else if remoteRenderer.transform == CGAffineTransform(rotationAngle: .pi){
            remoteRenderer.transform = CGAffineTransform(rotationAngle: .pi * 1.5)//right landscap
            frame.size.height = w
            frame.size.width = h
            remoteRenderer.bounds = frame
        }else if remoteRenderer.transform == CGAffineTransform(rotationAngle: .pi * 1.5){
            remoteRenderer.transform = CGAffineTransform(rotationAngle: .pi * 2) //portrate mode
            frame.size.height = h
            frame.size.width = w
            remoteRenderer.bounds = frame
        }else if remoteRenderer.transform == CGAffineTransform(rotationAngle: .pi * 2){
            remoteRenderer.transform = CGAffineTransform(rotationAngle: .pi / 2)//landscap
            frame.size.height = w
            frame.size.width = h
            remoteRenderer.bounds = frame
        }else{//right
            remoteRenderer.transform = CGAffineTransform(rotationAngle: .pi / 2)//landscap
            frame.size.height = w
            frame.size.width = h
            remoteRenderer.bounds = frame
        }
    }
    
    
    @IBOutlet weak var lblLock: UIButton!
    @IBOutlet weak var lblCallEnd: UIButton!
    @IBOutlet weak var lblblacknWihite: UIButton!
    @IBOutlet weak var lbldefault: UIButton!
    @IBOutlet weak var lblnightVision: UIButton!
    @IBOutlet weak var viewMute: UIView!
    @IBOutlet weak var viewpause: UIView!
    @IBOutlet weak var demoimageview: UIImageView!
    @IBAction func didtappedScreenShot(_ sender: Any) {
        let renderer = UIGraphicsImageRenderer(size: remoteRenderer.bounds.size)
        print("get screen short")
        // Render the RTCMTLVideoView into an image context
        let image = renderer.image { ctx in
            remoteRenderer.drawHierarchy(in: remoteRenderer.bounds, afterScreenUpdates: true)
        }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func didtappedCallEnd(_ sender: Any) {
        socket?.disconnect()
        DispatchQueue.main.async() {
            RoutingManager.shared.goBackToDashboard()
        }
    }
    
    @IBAction func didtappedBnW(_ sender: Any) {
        vdpEfectBlacknwhite()
    }
    @IBAction func didtappedDefault(_ sender: Any) {
        vdpEfectDefault()
    }
    @IBAction func didtappedNightVision(_ sender: Any) {
        vdpEfectNightVision()
    }
    @IBAction func didtappedLock(_ sender: Any) {
        PopupManager.shared.displayConfirmation(message: "Would you like to unlock door", description: "", completion: {
            self.UpdateLock(cmd: "$L2#")
        })
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // Handle error
        } else {
            // Get the URL of the saved image
            PopupManager.shared.displaySuccess(message: "Image save successfully", description: "")
            let url = (contextInfo as? URL)
            print(url)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // exit
        socket?.disconnect()
        if peerConnection != nil{
            peerConnection.close()
        }
    }
    func myUlsetUp(){
        var y = viewShowvdp.frame
        y.origin.y = 0
        //  270/360
        let view = UIView(frame: CGRect(x: 1, y: 0, width: view.frame.width, height:270))
        remoteRenderer = RTCMTLVideoView(frame: view.frame)
        remoteRenderer.videoContentMode = .scaleToFill
        viewShowvdp.addSubview(remoteRenderer)
    }
    func myExpandUlsetUp(){
        var y = viewExpand.frame
        y.origin.y = 0
        //  270/360
        let view = UIView(frame: CGRect(x: 10, y: 0, width: viewbackground.frame.height, height: viewbackground.frame.width))
        localRenderView = RTCEAGLVideoView(frame: viewbackground.frame)
        //        localRenderView.frame.origin.x = 0
        //        localRenderView.frame.origin.y = 0
        localRenderView.frame.size.width = viewbackground.frame.height
        localRenderView.frame.size.height = viewbackground.frame.width * 1.12
        localRenderView?.contentMode = .scaleToFill
        localRenderView.center = viewbackground.center
        localRenderView.isHidden = true
        self.view.addSubview(localRenderView)
        localRenderView.transform = CGAffineTransform(rotationAngle: .pi / 2)
    }
    let audioSession = RTCAudioSession.sharedInstance()
    var timer = Timer()
    func timestamp(){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            let date = Date()
            let dateString = dateFormatter.string(from: date)
            // print("date\(dateString)")
            // self.lblTime.text = dateString
            // self.lblTime.layer.zPosition = 1
        }
    }
    
    
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
        socket?.disconnect()
    }
    var responceDetail: ResponceResult!
    func setupSocketEvents() {
        
        var dic2 = Dictionary<String, Any>()
        var dic1 = Dictionary<String, Any>()
        dic1 = ["whatever-you-want-here" :"stuff"]
        dic2 = ["channel": id, "userdata": dic1]
        //V001641534575660
        let jsonData = try! JSONSerialization.data(withJSONObject: dic2, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        let postData =  decoded.data(using: .utf8)
        // working
        socket?.on(clientEvent: .connect) {data, ack in
            print("Connected")
            self.socket?.emit("join", dic2)
        }
        // working
        socket?.on("addPeer") { (data, ack) in
            print("addpeer")
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
                    self.responceDetail = ResponceResult(peer_id: peer_id, should_create_offer: should_create_offer, vdp_id: vdp_id )
                    self.sendOffer()
                }
            }else{
                self.sendAnswer()
            }
        }
        // working
        socket?.on("error"){(data ,arg)  in
            print(data)
            print(arg)
        }
        // working
        socket?.on("sessionDescription"){(data ,arg)  in
            print("session discription")
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
            print("error session dis=\(arg.debugDescription)")
        }
        // working
        socket?.on("removePeer") { (data, ack) in
            guard let dataInfo = data.first else { return }
            print("Now this chat has \(dataInfo) users.")
        }
        
        socket?.on("join") { (data, ack) in
            guard let dataInfo = data.first else { return }
            //               if let response: SocketMessage = try? SocketParser.convert(data: dataInfo) {
            print("join from =\(dataInfo)")
            //               }
        }
        // working
        socket?.on("iceCandidate") { (data, ack) in
            print(data)
            guard let dataInfo = data.first else { return }
            print("Received ICE candidate= \(dataInfo) is typing...")
            guard let resultNew = dataInfo as? [String:Any]else{
                return
            }
            let peer_id = resultNew["peer_id"]  as! String
            
            print("icecandidate = \(peer_id)")
            if peer_id == self.responceDetail.peer_id{
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
        
        socket?.on("full") { (data, ack) in
            guard let dataInfo = data.first else { return }
            //               if let response: SocketUserTyping = try? SocketParser.convert(data: dataInfo) {
            print("full \(dataInfo) stopped typing...")
            //               }
        }
        socket?.on("joined") { (data, ack) in
            guard let dataInfo = data.first else { return }
            //               if let response: SocketUserTyping = try? SocketParser.convert(data: dataInfo) {
            print("joined \(dataInfo)typing...")
            //               }
        }
        socket?.on("log") { (data, ack) in
            guard let dataInfo = data.first else { return }
            //               if let response: SocketUserTyping = try? SocketParser.convert(data: dataInfo) {
            print("log \(dataInfo) typing...")
            //               }
        }
        socket?.on("bye") { (data, ack) in
            guard let dataInfo = data.first else { return }
            //               if let response: SocketUserTyping = try? SocketParser.convert(data: dataInfo) {
            print("bye \(dataInfo) stopped typing...")
            //               }
        }
        socket?.on("message") { (data, ack) in
            guard let dataInfo = data.first else { return }
            //               if let response: SocketUserTyping = try? SocketParser.convert(data: dataInfo) {
            print("message= \(dataInfo)   typing...")
            //               }
        }
        socket?.on(clientEvent: .disconnect, callback: { data, ack in
            print("SocketManager: disconnected")
            //   self.sendNotification(event: "DISCONNECTED")
        })
    }
    
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
    private var MicMute: Bool = false
    @objc func btnMute(){
        muttedTapped()
    }
    func muttedTapped(){
        if !MicMute{
            print(" Audio session is muted")
            buttonMute.setTitle("Mute", for: .normal)
            lblMute.setImage(UIImage(systemName: "mic.fill"), for: .normal)
            
            unmuteAudio()
            MicMute = true
        }else{
            print("Audio session is not muted")
            lblMute.setImage(UIImage(systemName: "mic.slash.fill"), for: .normal)
            buttonMute.setTitle("UnMute", for: .normal)
            muteAudio()
            MicMute = false
        }
    }
    private var speker: Bool = true
    @objc func btnSpekerOff(){
        speakeroffOn()
    }
    func speakeroffOn(){
        DispatchQueue.main.async{[self] in
            if !speker{
                print(" Audio session is on")
                DispatchQueue.main.async {
                    self.buttonSpekerOff.setTitle("Speaker Off", for: .normal)
                }
                lblspeaker.setImage(UIImage(systemName: "speaker.fill"), for: .normal)
                lblexpSpeaker.setImage(UIImage(systemName: "speaker.fill"), for: .normal)
                speakerOn()
                speker = true
            }else{
                print("Audio session is not off")
                DispatchQueue.main.async {
                    self.buttonSpekerOff.setTitle("Speaker On", for: .normal)
                }
                lblspeaker.setImage(UIImage(systemName: "speaker.slash.fill"), for: .normal)
                lblexpSpeaker.setImage(UIImage(systemName: "speaker.slash.fill"), for: .normal)
                speakerOff()
                speker = false
            }
        }
    }
}
extension CallingViewController{
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
            "peer_id" : responceDetail.peer_id as String,
            "session_description"  : json]
        sigSend(msg: json1 as NSDictionary);
    }
    
    func onAnswer(sdp:RTCSessionDescription) {
        setAnswer(sdp: sdp)
    }
    
    func onCandidate(candidate:RTCIceCandidate) {
        peerConnection.add(candidate){ error in
            print("error=\(error?.localizedDescription)")
        }
    }
    
    func sigRecoonect() {
        socket?.disconnect();
        socket?.connect();
    }
    
    func sigSend(msg:NSDictionary) {
        print("json= \(msg)")
        socket?.emit("relaySessionDescription", msg)
    }
    
    func sigSendIce(msg:NSDictionary) {
        socket?.emit("relayICECandidate", msg)
    }
    func sigEnter() {
        let roomName = getRoomName();
        print("Entering room: " + roomName);
        socket?.emit("enter", roomName);
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
        var icsServers: [RTCIceServer] = []
        icsServers.append(RTCIceServer(urlStrings: ["stun:relay.metered.ca:80"]))
        icsServers.append(RTCIceServer(urlStrings: ["turn:relay.metered.ca:80"], username:"28a2fa03b765f96252ee363b",credential: "wTEvsXPyGPb+61h9"))
        
        let rtcConfig: RTCConfiguration = RTCConfiguration()
        rtcConfig.tcpCandidatePolicy = RTCTcpCandidatePolicy.disabled
        rtcConfig.bundlePolicy = RTCBundlePolicy.maxBundle
        rtcConfig.rtcpMuxPolicy = RTCRtcpMuxPolicy.require
        rtcConfig.continualGatheringPolicy = RTCContinualGatheringPolicy.gatherContinually
        rtcConfig.keyType = RTCEncryptionKeyType.ECDSA
        rtcConfig.iceServers = icsServers;
        
        peerConnection = peerConnectionFactory.peerConnection(with: rtcConfig, constraints: mediaConstraints, delegate: self)
        //  peerConnection.add(mediaStream);
        peerConnection.add(localAudioTrack, streamIds: ["101"])
        let tt = RTCDataChannelConfiguration();
        tt.isOrdered = false;
        
        self.dataChannel = peerConnection.dataChannel(forLabel: "testt", configuration: tt)
        
        self.dataChannel.delegate = self
        print("Make datachannel")
        
        return peerConnection;
    }
    func setupView(){
        // local
        localRenderView = RTCEAGLVideoView()
        localRenderView!.delegate = self
        localView = UIView()
        localView.addSubview(localRenderView!)
        // remote
        remoteRenderView = RTCMTLVideoView()
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
        let audioSource = self.peerConnectionFactory.audioSource(with: audioConstrains)
        let audioTrack = self.peerConnectionFactory.audioTrack(with: audioSource, trackId: "audio0")
        
        // audioTrack.source.volume = 10
        return audioTrack
    }
    
    private func createVideoTrack() -> RTCVideoTrack {
        let videoSource = self.peerConnectionFactory.videoSource()
        
        if self.customFrameCapturer {
            self.videoCapturer = RTCCustomFrameCapturer(delegate: videoSource)
        }else if TARGET_OS_SIMULATOR != 0 {
            print("now runnnig on simulator...")
            self.videoCapturer = RTCFileVideoCapturer(delegate: videoSource)
        }
        else {
            self.videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
        }
        let videoTrack = self.peerConnectionFactory.videoTrack(with: videoSource, trackId: "video0")
        return videoTrack
    }
    func setupRemoteViewFrame(frame: CGRect){
        remoteView.frame = frame
        remoteRenderView?.frame = remoteView.frame
    }
}
extension CallingViewController{
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
            //  renderView = remoteRenderView
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
extension CallingViewController{
    //media stream
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd rtpReceiver: RTCRtpReceiver, streams mediaStreams: [RTCMediaStream]) {
        DispatchQueue.main.async {
            //   ProgressOverlay.shared.hide()
        }
        guard let tracks = mediaStreams.first?.videoTracks.first else{return}
        let x = tracks
        print("Audio media stream=\(mediaStreams.first?.audioTracks)")
        print("Video media stream=\(mediaStreams.first?.videoTracks)")
        print("did add stream= \(mediaStreams.first)")
        self.remoteStream = mediaStreams.first
        
        if let track = mediaStreams.first!.videoTracks.first {
            remoteVideoTrack = track
            print("video track faund")
            remoteVideoTrack.add(remoteRenderer)
            //  remoteVideoTrack.add(localRenderView!)
        }
        if let track = mediaStreams.first!.audioTracks.first {
            // remoteVideoTrack = track
            print("audio track faund")
            track.source.volume = 8
            localAudioTrack = track
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.speakerOn()
                self.muteAudio()
            }
        }
    }
    
    
    //    public func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer){
    //        print("iets ontvangen\(buffer.debugDescription)");
    //    }
    
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
        
        //          if let track = stream.videoTracks.first {
        //              print("video track faund")
        //              track.add(remoteRenderView!)
        //          }
        if (peerConnection == nil) {
            return
        }
        
        if let audioTrack = stream.audioTracks.first{
            print("audio track faund")
            audioTrack.source.volume = 8
        }
        if (stream.videoTracks.count > 1) {
            print("Weird-looking stream: " + stream.description)
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
extension CallingViewController {
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
        if (peerConnection != nil){
            let audioTracks = self.peerConnection.transceivers.compactMap { return $0.sender.track as? RTCAudioTrack }
            print(audioTracks)
            audioTracks.forEach { $0.isEnabled = isEnabled }
        }
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
extension RTCMTLVideoView {
    //    func screenshot() -> UIImage? {
    //        let renderer = UIGraphicsImageRenderer(size: bounds.size)
    //        let image = renderer.image { rendererContext in
    //            layer.render(in: rendererContext.cgContext)
    //        }
    //        return image
    //    }
    //    func takeScreenshot() -> UIImage? {
    //           UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
    //           guard let currentDrawable = self.currentDrawable else { return nil }
    //           let image = currentDrawable.toUIImage()
    //           UIGraphicsEndImageContext()
    //           return image
    //       }
}
extension CallingViewController{
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
extension CallingViewController{
    
    func vdpEfectNightVision(){
        vdpmodule = vdpmodule?.clone()
        var nightVisioncmd = ""
        if vdpmodule!.nightVision{
            nightVisioncmd = "$V10000000000#"
            vdpmodule!.nightVision = false
        }else{
            nightVisioncmd = "$V20000000000#"
            vdpmodule!.nightVision = true
        }
        
        UpdateVisionMode(cmd: nightVisioncmd)
    }
    func vdpEfectDefault(){
        let defaultcmd = "$V01000000000#"
        UpdateVisionMode(cmd: defaultcmd)
    }
    func vdpEfectBlacknwhite(){
        let blacknWhitecmd = "$V02000000000#"
        UpdateVisionMode(cmd: blacknWhitecmd)
    }
    func UpdateVisionMode(cmd: String){
        print(cmd)
        let nodeid =  id
        let ref = self.database
            .child("messages")
            .child(nodeid)
            .child("applianceData")
        
        ref.setValue(["message": cmd as Any], withCompletionBlock: {(error, DataSnapshot) in
            if (error == nil){
                print("update succesfully")
            }
        })
        ref.setValue(["message": "aa" as Any], withCompletionBlock: {(error, DataSnapshot) in
            if (error == nil){
                print("Message update successfully")
            }
        })
    }
    
    func UpdateLock(cmd: String){
        print(cmd)
        let nodeid =  id
        let ref = self.database
            .child("vdpMessages")
            .child(nodeid)
            .child("vdpData")
        
        // let ref = Database.database().reference().child("vdpMessages").child(vdpmodule.id!).child("vdpData")
        ref.setValue(["message": cmd as Any], withCompletionBlock: {(error, DataSnapshot) in
            if (error == nil){
                print("update succesfully")
            }
        })
        ref.setValue(["message": "aa" as Any], withCompletionBlock: {(error, DataSnapshot) in
            if (error == nil){
                print("lock update successfully")
                //  PopupManager.shared.displaySuccess(message: "Message update successfully", description: "")
            }
        })
    }
    func UpdateCallStatus(){
        let nodeid =  id
        let ref = self.database
            .child("vdpDevices")
            .child(nodeid)
        
        ref.updateChildValues(["callStatus":"Received"], withCompletionBlock: { error, datasnapshot in
            print("call status update")
        })
    }
}
