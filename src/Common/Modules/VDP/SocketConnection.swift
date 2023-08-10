//
//  SocketConnection.swift
//  Wifinity
//
//  Created by Apple on 19/04/23.
//

import UIKit

import SocketIO
import Foundation

class SocketConnectionPool {
    static let shared = SocketConnectionPool()
    
    private var connections: [SocketConnection] = []
    
    private init() {}
    
    func getConnection() -> SocketConnection {
        if let connection = connections.popLast() {
            return connection
        } else {
            let connection = createNewConnection()
            connections.append(connection)
            return connection
        }
    }
    
    func releaseConnection(_ connection: SocketConnection) {
        connections.append(connection)
    }
   
    private func createNewConnection() -> SocketConnection {
        // Code to create a new socket connection goes here
        let cnx = SocketConnection()
        cnx.socket = cnx.manager.defaultSocket
        cnx.socket?.connect()
        // Add event listeners
        cnx.socket?.on(clientEvent: .connect) {data, ack in
            print("Connected....")
            let cnnection = self.getConnection()
            self.releaseConnection(cnnection)
         //   self.timer.invalidate()
        }
        cnx.socket?.on(clientEvent: .disconnect) {data, ack in
            print("disConnected....")
            cnx.socket?.connect()
         //   self.timer.invalidate()
        }
        cnx.socket?.on("addPeer") { (data, ack) in
              //   data = Array<Any>
                 // ack = SocketAckEmitter
                 if CURRENT_VC == "VDPListViewController"{
                    // self.delegate?.webrtcAddPeer(data: data)
                 }else if CURRENT_VC == "VdpViewController"{
                   //  self.delegatevdpvc?.webrtcAddPeer(data: data)
                 }else if CURRENT_VC == "CallingViewController"{
                   //  self.delegate?.webrtcAddPeer(data: data)
                 }
                
                 print("addpeer socket")
             }
        return cnx
    }
}

class SocketConnection {
    let manager = SocketManager(socketURL: URL(string: "https://vdp1.homeonetechnologies.in/")!, config: [.log(false), .compress])
    var socket: SocketIOClient? = nil
    // Code for socket connection goes here
  
//
//             // Add event listeners
//       socket.on(clientEvent: .connect) {data, ack in
//                 print("Connected....")
//
//              //   self.timer.invalidate()
//             }
//       socket?.on("addPeer") { (data, ack) in
//              //   data = Array<Any>
//                 // ack = SocketAckEmitter
//
//
//                 print("addpeer Dashboard")
//             }
//       socket?.on(clientEvent: .disconnect) {data, ack in
//                 print("DisConnected")
//             //    DispatchQueue.main.async {
//
//          //  print("socket status=\(DashboardController.socket?.status)")
//             }
//
//     socket?.on("error"){(data ,arg)  in
//                 print(data)
//                 print(arg)
//
//
//             }
//             // working
//         socket?.on("sessionDescription"){(data ,arg)  in
//                 print("session discription")
//
//
//
//             }
//             // working
//         socket?.on("removePeer") { (data, ack) in
//                 guard let dataInfo = data.first else { return }
//                 print("remove Peer")
//                 print("Now this chat has \(dataInfo) users.")
//
//
//             }
//
//         socket?.on("join") { (data, ack) in
//                 guard let dataInfo = data.first else { return }
//                  print("joined from =\(dataInfo)")
//              }
//             // working
//        socket?.on("iceCandidate") { (data, ack) in
//                 print(data)
//
//             }
//        socket?.on("full") { (data, ack) in
//                 guard let dataInfo = data.first else { return }
//                  print("full \(dataInfo) stopped typing...")
//              }
//        socket?.on("joined") { (data, ack) in
//                 guard let dataInfo = data.first else { return }
//                  print("joined \(dataInfo)typing...")
//              }
//              socket?.on("log") { (data, ack) in
//                 guard let dataInfo = data.first else { return }
//                  print("log \(dataInfo) typing...")
//              }
//         socket?.on("bye") { (data, ack) in
//                 guard let dataInfo = data.first else { return }
//                  print("bye \(dataInfo) stopped typing...")
//              }
//        socket?.on("message") { (data, ack) in
//                 guard let dataInfo = data.first else { return }
//                  print("message= \(dataInfo)   typing...")
//              }
     }
    
 


//let connection = SocketConnectionPool.shared.getConnection()
//// Use the connection
//SocketConnectionPool.shared.releaseConnection(connection)

