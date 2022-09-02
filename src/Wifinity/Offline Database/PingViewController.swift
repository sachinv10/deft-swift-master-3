//
//  PingViewController.swift
//  Wifinity
//
//  Created by Apple on 30/08/22.
//

import UIKit
import Starscream
import FirebaseAuth
import FirebaseDatabase
import Firebase
class PingViewController: UIViewController {
    private var socket: WebSocket?
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        
        textView.text = ""
        getofflineMode(controller_id: "CS091651819470701")
        //   pingToController(ipaddress: "")
    }
    func pingToController(ipaddress: String){
        var request = URLRequest(url: URL(string: "ws://\(ipaddress):81")!)
        if ProcessInfo.processInfo.arguments.contains("TESTING") {
            request = URLRequest(url: URL(string: "http://\(ipaddress):81")!)
        }
        request.timeoutInterval = 2
        socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
        
    }
    @IBAction func start(_ sender: Any) {
        if  let x = getIPAddress(){
            print("ips =\(x)")
            
            let fullNameArr = x.components(separatedBy: ".")
            let firstName = fullNameArr[0] //First
            let lastName = fullNameArr[1] //Last
            let xs = "\(fullNameArr[0]).\(fullNameArr[1]).\(fullNameArr[2])."
            print(xs)
            startPinging(ips: String(xs), onCompletion: { c_id in
                for item in c_id {
                    print("c_id =\(item)")
                    self.pingToController(ipaddress: item)
                }
            } )
            
        }
        
    }
    var controller_id = [String]()
    @IBAction func stop(_ sender: Any) {
        // ping?.stopPinging()
    //   RoutingManager.shared.goToPreviousScreen(self)
        RoutingManager.shared.gotoOfflineApplinces(controller: self, controllerId: controller_id)
    }
    @IBAction func halt(_ sender: Any) {
        ping?.haltPinging()
    }
    var ping: SwiftyPing?
    var controllerArray = [String]()
    func startPinging(ips: String, onCompletion : @escaping (Array<String>) -> Void)  {
        controllerArray.removeAll()
        for i in 0..<256 {
            do {
                
                let host = "\(ips)\(i)"
                //   print(host)
                ping = try SwiftyPing(host: host, configuration: PingConfiguration(interval: 5.0, with: 1), queue: DispatchQueue.global())
                ping?.observer = { (response) in
                    DispatchQueue.main.async {
                        if ((response.ipHeader) != nil){
                            let idss = response.ipAddress
                            print("ips = \(idss)")
                            self.controllerArray.append(idss ?? "")
                        }
                        if (response.ipAddress != nil) {
                            //  print("ips = \(response.ipAddress)")
                        }
                        var message = "\(response.duration * 1000) ms"
                        if let error = response.error {
                            if error == .requestTimeout {
                                print("time out")
                            }
                            if error == .responseTimeout {
                                message = "Timeout \(message)"
                            } else {
                                print(error)
                                print("sd.........")
                                message = error.localizedDescription
                            }
                        }
                        
                        self.textView.text.append(contentsOf: "\nPing #\(response.trueSequenceNumber): \(message)")
                        self.textView.scrollRangeToVisible(NSRange(location: self.textView.text.count - 1, length: 1))
                    }
                }
                ping?.finished = { (result) in
                    DispatchQueue.main.async {
                        var message = "\n--- \(host) ping statistics ---\n"
                        message += "\(result.packetsTransmitted) transmitted, \(result.packetsReceived) received"
                        if let loss = result.packetLoss {
                            message += String(format: "\n%.1f%% packet loss\n", loss * 100)
                        } else {
                            message += "\n"
                        }
                        if let roundtrip = result.roundtrip {
                            message += String(format: "round-trip min/avg/max/stddev = %.3f/%.3f/%.3f/%.3f ms", roundtrip.minimum * 1000, roundtrip.average * 1000, roundtrip.maximum * 1000, roundtrip.standardDeviation * 1000)
                        }
                        self.textView.text.append(contentsOf: message)
                        self.textView.scrollRangeToVisible(NSRange(location: self.textView.text.count - 1, length: 1))
                    }
                }
                
                ping?.targetCount = 1
                try ping?.startPinging()
            } catch {
                textView.text = error.localizedDescription
            }
            if i == 255 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5){
                    onCompletion(self.controllerArray)
                }
            }
        }
        
        // return controllerArray
    }
    func getIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET)  {
                    
                    if String(cString: (interface?.ifa_name)!) != nil {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                        print(address)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }
    
    @IBOutlet weak var websocketData: UILabel!
}
extension PingViewController{
    
    
    
    @IBAction func sendData(_ sender: Any) {
        socket?.write(string: "Hi Server!")
        
    }
    
    @IBAction func sendData2(_ sender: Any) {
        socket?.write(string: "2nd Send Websocket data")
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            // this is the data we receive from other users sending data to specific port we use for websockets
            print("Received text: \(string)")
            //   websocketData.text = string
            formatJson(stringJson: string)
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            print("error")
        case .error(_):
            break
        }
    }

    func formatJson(stringJson: String)  {
        
        do{
            if let json = stringJson.data(using: String.Encoding.utf8){
                if let jsonData = try JSONSerialization.jsonObject(with: json, options: .allowFragments) as? [String:AnyObject]{
                    if let id = jsonData["HardwareID"] as? String{
                        print(id)
                        controller_id.append(id)
                        getofflineMode(controller_id: id)
                    }
                }
            }
        }catch {
            print(error.localizedDescription)
        }
       
    }
    func getofflineMode(controller_id: String){
        let scoresRef = Database.database().reference(withPath: "applianceDetails/\(controller_id)") //CS091651819470701
        
        scoresRef.queryOrderedByValue().queryLimited(toLast: 10).observe(.childAdded) { snapshot in
          print("The \(snapshot.key) dinosaur's score is \(snapshot.value ?? "null")")
        }
    }
}
extension PingViewController: WebSocketDelegate {
    public func websocketDidConnect(_ socket: Starscream.WebSocket) {
        
    }
    
    public func websocketDidDisconnect(_ socket: Starscream.WebSocket, error: NSError?) {
        
    }
    
    public func websocketDidReceiveMessage(_ socket: Starscream.WebSocket, text: String) {
        guard let data = text.data(using: .utf16),
              let jsonData = try? JSONSerialization.jsonObject(with: data),
              let jsonDict = jsonData as? [String: Any],
              let messageType = jsonDict["type"] as? String else {
            return
        }
        
        // 2
        if messageType == "message",
           let messageData = jsonDict["data"] as? [String: Any],
           let messageText = messageData["text"] as? String {
            
            websocketData.text = messageText
        }
    }
    
    public func websocketDidReceiveData(_ socket: Starscream.WebSocket, data: Data) {
    }
}
