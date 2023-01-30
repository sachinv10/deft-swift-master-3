//
//  VDPListViewController.swift
//  Wifinity
//
//  Created by Apple on 30/12/22.
//

import UIKit
import AVFoundation
import SocketIO
import Foundation
import WebRTC
import Starscream
import AVFAudio

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
            }
        })
    }
    func reloadAllView(){
        if !vdpListArray.isEmpty{
            listTableview.reloadData()
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
    
    func vdplist(listViewCellplay cell: ListTableViewCell) {
        print("play vdp list")
      let vdpmodul = cell.vdpmodul
        vdpId = (vdpmodul?.id)!
        var frames = cell.view.frame
        frames.origin.y = 0.0
        remoteRenderer = RTCEAGLVideoView(frame: frames)
        remoteRenderer.contentMode = .scaleToFill
     
        cell.self.view.addSubview(remoteRenderer)
        remoteRenderer.addSubview(cell.btnSpeaker)
        remoteRenderer.addSubview(cell.btnpause)
        remoteRenderer.addSubview(cell.btnExpand)
        remoteRenderer.addSubview(cell.nextBtn)
        
        cell.view.addSubview(cell.btnSpeaker)
            myconnectfunc()
            initWebRTC();
        self.configureAudioSession()
        localAudioTrack = peerConnectionFactory.audioTrack(withTrackId: AUDIO_TRACK_ID)
        mediaStream = peerConnectionFactory.mediaStream(withStreamId: LOCAL_MEDIA_STREAM_ID)
        mediaStream.addAudioTrack(localAudioTrack)
     
    }
    
    func vdplist(listViewCellplaySpeker cell: ListTableViewCell) {
       print("output valum = \(rtcAudioSession.outputVolume)")
        if 0.0625 == rtcAudioSession.outputVolume{
            speakerOff()
            cell.btnSpeaker.setImage(UIImage(systemName: "speaker.slash.fill"), for: .normal)
        }else{
            speakerOn()
            cell.btnSpeaker.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
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
        
        if viewExpand.isHidden{
             var y = listTableview.frame
            y.origin.y = 10.0
            let width =  y.size.width
            y.size.width = y.size.height
            y.size.height = width
            remoteRenderer.frame = y
            remoteRenderer.center = viewExpand.center
            viewExpand.isHidden = false
        
            viewExpand.addSubview(remoteRenderer)
            remoteRenderer.addSubview(cell.btnExpand)
            remoteRenderer.transform = CGAffineTransform(rotationAngle: .pi / 2)
        
        }else{
             viewExpand.isHidden = true
            var y = cell.view.frame
             y.origin.y = -15.0
            let width =  y.size.width
            y.size.width = y.size.height
            y.size.height = width
            remoteRenderer.frame = y
            remoteRenderer.center = cell.view.center
            remoteRenderer.addSubview(cell.btnExpand)
            
            cell.btnpause.isHidden = true
            cell.nextBtn.isHidden = true
            cell.view.addSubview(remoteRenderer)
            remoteRenderer.transform = CGAffineTransform(rotationAngle: .pi * 2)
            
//            viewExpand.isHidden = true
//            remoteRenderer.addSubview(cell.btnplay)
//            cell.view.addSubview(remoteRenderer)
//            remoteRenderer.transform = CGAffineTransform(rotationAngle: .pi / 2)
//            listTableview.reloadData()
        }
    }
    
    func vdplist(listViewToNextpage cell: ListTableViewCell) {
        print("to next page")
        RoutingManager.shared.gotoVDPPlay(controller: self, Obj: cell.vdpmodul!)
    }
}
 
class VDPListViewController: BaseController,URLSessionWebSocketDelegate,RTCPeerConnectionDelegate, RTCDataChannelDelegate, RTCVideoViewDelegate,WebRTCClientDelegate, listViewDelegate, UITableViewDelegate, UITableViewDataSource{

    var mediaStream: RTCMediaStream!
  //  var localAudioTrack: RTCAudioTrack!
    var remoteAudioTrack: RTCAudioTrack!
    var dataChannel: RTCDataChannel!
    var dataChannelRemote: RTCDataChannel!
    var vdpId = ""
    var roomName: String!
    
    //MARK: - Properties
    var audioTrack: RTCAudioTrack?
    var peerConnectionFactory: RTCPeerConnectionFactory! = nil
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
    private var remoteRenderer :RTCEAGLVideoView!
    private var localRTcVideoTrack: RTCVideoRenderer!
    
    private var localAudioTrack: RTCAudioTrack!
      //  var webRTCClient: WebRTCClient!
    private var customFrameCapturer: Bool = false
    weak var delegate: WebRTCClientDelegate?
    let manager = SocketManager(socketURL: URL(string: "https://vdp1.homeonetechnologies.in/")!, config: [.log(false), .compress])
    
    var socket: SocketIOClient? = nil
    var wsServerUrl: String! = nil
    var peerStarted: Bool = false
    
    @IBOutlet weak var listTableview: UITableView!
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
       // views.backgroundColor = .gray
        return views
    }()
    private var webSocket : URLSessionWebSocketTask?
    
    func setupSocket() {
        self.socket = manager.defaultSocket
    }
    
    @IBOutlet weak var mainView: UIView!
    
    func myconnectfunc()  {
        setupSocket()
        setupSocketEvents()
        socket?.connect()
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
            var y = mainView.frame
            y.origin.y = -10.0
            viewExpand.frame = y
            
            listTableview.addSubview(viewExpand)
            viewExpand.isHidden = true
            // play button
    //        myUlsetUp()
    //        myconnectfunc()
    //        initWebRTC();
    //        //=========
    //        localAudioTrack = peerConnectionFactory.audioTrack(withTrackId: AUDIO_TRACK_ID)
    //        mediaStream = peerConnectionFactory.mediaStream(withStreamId: LOCAL_MEDIA_STREAM_ID)
    //        mediaStream.addAudioTrack(localAudioTrack)
            
    //        setupView()
    //        setupLocalTracks()
    //        setupUI()
    //
         
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
            appDel.myOrientation = .portrait
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            searchVDP()
        }
    private func routeChange(_ n: Notification) {
     
        

    }
    let appDel = UIApplication.shared.delegate as! AppDelegate
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // exit
        socket?.disconnect()
       if peerConnection != nil{
            peerConnection.close()
        }
    }
    func myUlsetUp(){
        remoteRenderer = RTCEAGLVideoView(frame: self.view.frame)
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
        socket?.disconnect()
    }
    var responceDetail: ResponceResult!
    func setupSocketEvents() {
        
        var dic2 = Dictionary<String, Any>()
        var dic1 = Dictionary<String, Any>()
        dic1 = ["whatever-you-want-here" :"stuff"]
        dic2 = ["channel": vdpId, "userdata": dic1]
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
            
            self.responceDetail = ResponceResult(peer_id: peer_id, should_create_offer: should_create_offer, vdp_id: vdp_id )
            
            print("Now this chat has \(dataInfo) users.")
            if resultNew["should_create_offer"]  as! Bool{
                self.sendOffer()
            }
            //               }
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
            //   let should_create_offer = resultNew["should_create_offer"]  as! Bool
            let session_description = resultNew["session_description"]  as? [String:Any]
            if session_description?["type"] as! String == "answer"{
                print("answer")
                let sdp = RTCSessionDescription(type: RTCSdpType(rawValue: 1 )!, sdp: session_description!["sdp"] as! String)
                self.onAnswer(sdp: sdp)
                
            }else if session_description?["type"] as! String == "offer"{
                print("offer")
                let sdp = RTCSessionDescription(type: RTCSdpType(rawValue: 0 )!, sdp: session_description!["sdp"] as! String)
                // self.sendAnswer()
                self.onOffer(sdp: sdp)
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
            //   let should_create_offer = resultNew["should_create_offer"]  as! Bool
            let json = resultNew["ice_candidate"]  as? [String:Any]
            
            let candidate = RTCIceCandidate(
                sdp: json!["candidate"] as! String,
                sdpMLineIndex: Int32(json?["sdpMLineIndex"] as! Int),
                sdpMid: json?["id"] as? String)
            self.onCandidate(candidate: candidate);
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
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Connected to server")
        self.receive()
        self.send()
    }
    
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Disconnect from Server \(reason)")
    }
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
        icsServers.append(RTCIceServer(urlStrings: ["stun:stun1.l.google.com:19302"]))
        icsServers.append(RTCIceServer(urlStrings: ["turn:34.68.55.33:3478"], username:"test",credential: "test123"))
        
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
        print("Audio media stream=\(mediaStreams.first!.audioTracks)")
        print("Video media stream=\(mediaStreams.first!.videoTracks)")
        print("did add stream")
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
 
