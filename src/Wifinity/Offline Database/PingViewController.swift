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
import SystemConfiguration
import Foundation
import Network
import ImageIO

class PingViewController: UIViewController, WebSocketDelegate{
    var timer = Timer()
    public func websocketDidReceiveData(_ socket: Starscream.WebSocket, data: Data) {
        print("websocketDidReceiveData")
    }
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocket) {
        print("didReceive-------yes")
        switch event {
        case .connected(let headers):
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            // this is the data we receive from other users sending data to specific port we use for websockets
            print("Received text: \(string)")
            //   websocketData.text = string ?? ""
            formatJson(stringJson: string)
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            print("viabilityChanged")
            break
        case .reconnectSuggested(_):
            print("reconnectSuggested")
            break
        case .cancelled:
            print("error")
        case .error(let error):
            print("error unknown\(String(describing: error?.localizedDescription))")
            break
        }
    }
  
    private var socket: WebSocket?
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //declare this property where it won't go out of scope relative to your listener
     //   let reachability = try! Reachability()

//        reachability.whenReachable = { reachability in
//            if reachability.connection == .wifi {
//                print("Reachable via WiFi")
//            } else {
//                print("Reachable via Cellular")
//            }
//        }
//        reachability.whenUnreachable = { _ in
//            print("Not reachable")
//        }
//
//        do {
//            try reachability.startNotifier()
//        } catch {
//            print("Unable to start notifier")
//        }
    }
    
    @IBOutlet weak var lblstart: UIButton!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gifload()
    }
    func gifload() {
        conter = 0
        textView.text = ""
        alldata.removeAll()
        controller_id.removeAll()
        controller_KComand.removeAll()
      
      
        //https://www.deskdecode.com/wp-content/uploads/2022/08/d2.gif
          let jeremyGif = UIImage.gifImageWithName("d2")
          let imageView = UIImageView(image: jeremyGif)
          imageView.frame = CGRect(x: 0, y: 105.0, width: self.view.frame.size.width, height: self.view.frame.size.height - 320)
          view.addSubview(imageView)
        getIpaddress()
        lblstart.isHidden = true
        ProgressOverlay.shared.show()
    }
    var c_id = [String]()
    var conter = 0
    @objc func update() {
        print("timer Active")
        
        if c_id.count > conter{
            self.pingToController(ipaddress: c_id[conter])
            self.textView.text.append(contentsOf: "\n Ip address = \(c_id[conter])")
            self.textView.scrollRangeToVisible(NSRange(location: self.textView.text.count - 1, length: 1))
            conter += 1
        }else{
            lblstart.isHidden = false
            self.timer.invalidate()
            self.textView.text.append(contentsOf: "\n Finished")
            self.textView.scrollRangeToVisible(NSRange(location: self.textView.text.count - 1, length: 1))
            print("timer stop")
            if controller_id.count > 0, controller_id.count == controller_KComand.count{
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.GotoApplinceController()
                }
            }
            ProgressOverlay.shared.hide()
            timer.invalidate()
            self.timer.invalidate()
        }
    }
    
    func pingToController(ipaddress: String){
        print("ws://\(ipaddress):81")
        var request = URLRequest(url: URL(string: "ws://\(ipaddress):81")!)
        if ProcessInfo.processInfo.arguments.contains("TESTING") {
            request = URLRequest(url: URL(string: "http://\(ipaddress):81")!)
        }
        request.timeoutInterval = 5
        self.socket = WebSocket(request: request)
        self.socket?.delegate = self
        self.socket?.connect()
                
    }
    @IBAction func start(_ sender: Any) {
        gifload()
       // getIpaddress()
    }
    func getIpaddress()  {
        if  let x = getIPAddress(){
            print("ips =\(x)")
            let fullNameArr = x.components(separatedBy: ".")
            let firstName = fullNameArr[0] //First
            let lastName = fullNameArr[1] //Last
            let xs = "\(fullNameArr[0]).\(fullNameArr[1]).\(fullNameArr[2])."
            print(xs)
            startPinging(ips: String(xs), onCompletion: { c_id in
                self.c_id.removeAll()
                self.c_id = c_id
                self.conter = 0
                self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
                for item in c_id {
                    DispatchQueue.main.asyncAfter(deadline: .now()){
                        print("c_id =\(item)")
                        print(item)
                    }
                }
            } )
            
        }
    }
    var controller_id = [String]()
    var controller_KComand = [String]()
    @IBAction func stop(_ sender: Any) {
        ping?.stopPinging()
        //   RoutingManager.shared.goToPreviousScreen(self)
        
    }
    func GotoApplinceController()  {
        RoutingManager.shared.gotoOfflineApplinces(controller: self, controllerId: controller_id, controller_kId: controller_KComand, alldatajson: alldata)
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
    @IBAction func sendData(_ sender: Any) {
        socket?.write(string: "Hi Server!")
        
    }
    
    @IBAction func sendData2(_ sender: Any) {
        socket?.write(string: "2nd Send Websocket data")
    }

    var alldata = [String]()
    func formatJson(stringJson: String)  {
        do{
            if stringJson.starts(with: "K"){
                let d = stringJson
                controller_KComand.append(d)
                self.textView.text.append(contentsOf: "\n K_Comand= \(d)")
                self.textView.scrollRangeToVisible(NSRange(location: self.textView.text.count - 1, length: 1))
            }
            if let json = stringJson.data(using: String.Encoding.utf8){
                if let jsonData = try JSONSerialization.jsonObject(with: json, options: .allowFragments) as? [String:AnyObject]{
                    if let id = jsonData["HardwareID"] as? String{
                        print(id)
                        alldata.append(stringJson)
                        controller_id.append(id)
                        //  getofflineMode(controller_id: id)
                        self.textView.text.append(contentsOf: "\n \(id)")
                        self.textView.scrollRangeToVisible(NSRange(location: self.textView.text.count - 1, length: 1))
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
    
//    func checkInternetConnection()  {
//        do {
//                    try Network.reachability = Reachability(hostname: "www.google.com")
//                }
//                catch {
//                    switch error as? Network.Error {
//                    case let .failedToCreateWith(hostname)?:
//                        print("Network error:\nFailed to create reachability object With host named:", hostname)
//                    case let .failedToInitializeWith(address)?:
//                        print("Network error:\nFailed to initialize reachability object With address:", address)
//                    case .failedToSetCallout?:
//                        print("Network error:\nFailed to set callout")
//                    case .failedToSetDispatchQueue?:
//                        print("Network error:\nFailed to set DispatchQueue")
//                    case .none:
//                        print(error)
//                    }
//                }
//    }
}


fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}



extension UIImage {
    
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gifImageWithURL(_ gifUrl:String) -> UIImage? {
        guard let bundleURL:URL? = URL(string: gifUrl)
            else {
                print("image named \"\(gifUrl)\" doesn't exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL!) else {
            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    public class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.1 {
            delay = 0.1
        }
        
        return delay
    }
    
    class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if a < b {
            let c = a
            a = b
            b = c
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b
                b = rest
            }
        }
    }
    
    class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames,
            duration: Double(duration) / 1000.0)
        
        return animation
    }
}
