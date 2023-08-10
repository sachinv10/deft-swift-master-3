//
//  DataFetchManagerFireBaseVdp.swift
//  Wifinity
//
//  Created by Apple on 06/04/23.
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


extension DataFetchManagerFireBase{
  static var socket: SocketIOClient? = nil
    func vdpSocketConnection(completion pCompletion: @escaping (SocketIOClient?) -> Void, socket psocket: SocketIOClient?) {
        
            self.requestCount += 1
            
            do {
                if (Auth.auth().currentUser?.uid.count ?? 0) <= 0 {
                    throw NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey : "No user logged in."])
                }
                if DataFetchManagerFireBase.socket != nil{
                    pCompletion(DataFetchManagerFireBase.socket)
                }else if psocket != nil
                {
                   DataFetchManagerFireBase.socket = psocket
                   pCompletion(DataFetchManagerFireBase.socket)
               }else{
                   if DataFetchManagerFireBase.socket != nil{
                       pCompletion(DataFetchManagerFireBase.socket)
                   }else{
                       // create socket connection
                       let manager = SocketManager(socketURL: URL(string: "https://vdp1.homeonetechnologies.in/")!, config: [.log(false), .compress])
                       DataFetchManagerFireBase.socket = manager.defaultSocket
                       
                       
                       
                       
                       // working
                       DataFetchManagerFireBase.socket?.on(clientEvent: .connect) {data, ack in
                           print("Connected")
                           //  self.socket?.emit("join", dic2)
                           pCompletion(DataFetchManagerFireBase.socket)
                       }
                       // working
                       //                    DataFetchManagerFireBase.socket?.on("addPeer") { (data, ack) in
                       //                            print("addpeer")
                       //                            guard let dataInfo = data.first else { return }
                       //                            guard let resultNew = dataInfo as? [String:Any]else{
                       //                                return
                       //                            }
                       //                            let peer_id = resultNew["peer_id"]  as! String
                       //                            let should_create_offer = resultNew["should_create_offer"]  as! Bool
                       //                            let vdp_id = resultNew["vdp_id"]  as! String
                       //
                       //                            print("Now this chat has \(dataInfo) users.")
                       //                            if resultNew["should_create_offer"]  as! Bool{
                       //                                if self.icecandidate == false{
                       //                                    self.icecandidate = true
                       //                                    self.responceDetail = ResponceResult(peer_id: peer_id, should_create_offer: should_create_offer, vdp_id: vdp_id )
                       //                                    self.sendOffer()
                       //                                }
                       //                            }else{
                       //                                self.sendAnswer()
                       //                            }
                       //                        }
                       // working
                       DataFetchManagerFireBase.socket?.on("error"){(data ,arg)  in
                           print(data)
                           print(arg)
                       }
                       // working
                       //                        socket?.on("sessionDescription"){(data ,arg)  in
                       //                            print("session discription")
                       //                            print(data)
                       //                            guard let dataInfo = data.first else { return }
                       //                            guard let resultNew = dataInfo as? [String:Any]else{
                       //                                return
                       //                            }
                       //                            let peer_id = resultNew["peer_id"]  as! String
                       //                            //  let should_create_offer = resultNew["should_create_offer"]  as! Bool
                       //                            let session_description = resultNew["session_description"]  as? [String:Any]
                       //                            if session_description?["type"] as! String == "answer"{
                       //                                print("answer")
                       //                                let sdp = RTCSessionDescription(type: RTCSdpType(rawValue: 1 )!, sdp: session_description!["sdp"] as! String)
                       //                                self.onAnswer(sdp: sdp)
                       //
                       //                            }else if session_description?["type"] as! String == "offer"{
                       //                                print("offer")
                       //                                //                let sdp = RTCSessionDescription(type: RTCSdpType(rawValue: 0 )!, sdp: session_description!["sdp"] as! String)
                       //                                //                self.onOffer(sdp: sdp)
                       //                            }
                       //                            print("error session dis=\(arg.debugDescription)")
                       //                        }
                       // working
                       DataFetchManagerFireBase.socket?.on("removePeer") { (data, ack) in
                           guard let dataInfo = data.first else { return }
                           print("remove Peer")
                           print("Now this chat has \(dataInfo) users.")
                       }
                       
                       DataFetchManagerFireBase.socket?.on("join") { (data, ack) in
                           guard let dataInfo = data.first else { return }
                           //               if let response: SocketMessage = try? SocketParser.convert(data: dataInfo) {
                           print("join from =\(dataInfo)")
                           //               }
                       }
                       // working
                       DataFetchManagerFireBase.socket?.on("iceCandidate") { (data, ack) in
                           //                            print(data)
                           //                            guard let dataInfo = data.first else { return }
                           //                            print("Received ICE candidate= \(dataInfo) is typing...")
                           //                            guard let resultNew = dataInfo as? [String:Any]else{
                           //                                return
                           //                            }
                           //                            let peer_id = resultNew["peer_id"]  as! String
                           //
                           //                            print("icecandidate = \(peer_id)")
                           //                            if peer_id == self.responceDetail.peer_id {
                           //                                //   let should_create_offer = resultNew["should_create_offer"]  as! Bool
                           //                                let json = resultNew["ice_candidate"]  as? [String:Any]
                           //                                let candidate = RTCIceCandidate(
                           //                                    sdp: json!["candidate"] as! String,
                           //                                    sdpMLineIndex: Int32(json?["sdpMLineIndex"] as! Int),
                           //                                    sdpMid: json?["id"] as? String)
                           //                                print("call to ice candidate in \(peer_id)")
                           //                                self.onCandidate(candidate: candidate);
                           //                            }
                       }
                       
                       DataFetchManagerFireBase.socket?.on("full") { (data, ack) in
                           guard let dataInfo = data.first else { return }
                           //               if let response: SocketUserTyping = try? SocketParser.convert(data: dataInfo) {
                           print("full \(dataInfo) stopped typing...")
                           //               }
                       }
                       DataFetchManagerFireBase.socket?.on("joined") { (data, ack) in
                           guard let dataInfo = data.first else { return }
                           //               if let response: SocketUserTyping = try? SocketParser.convert(data: dataInfo) {
                           print("joined \(dataInfo)typing...")
                           //               }
                       }
                       DataFetchManagerFireBase.socket?.on("log") { (data, ack) in
                           guard let dataInfo = data.first else { return }
                           //               if let response: SocketUserTyping = try? SocketParser.convert(data: dataInfo) {
                           print("log \(dataInfo) typing...")
                           //               }
                       }
                       DataFetchManagerFireBase.socket?.on("bye") { (data, ack) in
                           guard let dataInfo = data.first else { return }
                           //               if let response: SocketUserTyping = try? SocketParser.convert(data: dataInfo) {
                           print("bye \(dataInfo) stopped typing...")
                           //               }
                       }
                       DataFetchManagerFireBase.socket?.on("message") { (data, ack) in
                           guard let dataInfo = data.first else { return }
                           //               if let response: SocketUserTyping = try? SocketParser.convert(data: dataInfo) {
                           print("message= \(dataInfo)   typing...")
                           //               }
                       }
                       DataFetchManagerFireBase.socket?.on(clientEvent: .disconnect, callback: { data, ack in
                           print("SocketManager: disconnected\(data)")
                           //   self.sendNotification(event: "DISCONNECTED")
                       })
                       DataFetchManagerFireBase.socket?.connect()
                       
                       
                       //   pCompletion(DataFetchManagerFireBase.socket)
                   }
               }
              
            } catch {
               
            }
            
            DispatchQueue.main.async { [self] in
                self.requestCount -= 1
              //  pCompletion(DataFetchManagerFireBase.socket)
            }
       // }
        
    }
}
