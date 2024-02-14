//
//  OfflineApplinceViewController.swift
//  Wifinity
//
//  Created by Apple on 01/09/22.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import Firebase
import Starscream
import Foundation


protocol SearchAppliancesTableCellViewDelegate :AnyObject {
    func cellView(_ pSender: applincessCell, didChangePowerState pPowerState :Bool)
    func cellView(_ pSender: applincessCell, didChangeDimmableValue pDimmableValue :Int)
}

class applincessCell: UITableViewCell{
    var delegate: SearchAppliancesTableCellViewDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        isOnlineCell.layer.cornerRadius = 5
        isOnlineCell.layer.masksToBounds = true
        lblImgBackground.layer.cornerRadius = 38
        lblImgBackground.layer.masksToBounds = true
        lblImgBackground.layer.borderColor = UIColor.lightGray.cgColor
        lblImgBackground.layer.borderWidth = 1
        LblSlider.isHidden = true
        backgroundeffectiveView.layer.cornerRadius = 20
        backgroundeffectiveView.layer.masksToBounds = false
        backgroundeffectiveView.dropShadow(color: .gray, opacity: 1, offSet: CGSize(width: 1, height: 1), radius: 5, scale: true)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func loaddata(pApplince: Appliance) {
        self.appliance = pApplince
        self.imageviewApplince.image = pApplince.icon?.resizableImage(withCapInsets: UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0), resizingMode: UIImage.ResizingMode.stretch)
        
        if pApplince.isOnline == true{
            isOnlineCell.backgroundColor = .green
            // dimable value
        }else{
            isOnlineCell.backgroundColor = .red
        }
        
        if pApplince.isOn == true{
            btnSwitch.isOn = true
            LblSlider.value = Float(pApplince.dimmableValue!)
        }else{
            btnSwitch.isOn = false
        }
        if pApplince.type != Appliance.ApplianceType.ledStrip {
            if pApplince.isOn && pApplince.isDimmable {
                LblSlider.isHidden = false
            }else{
                LblSlider.isHidden = true
            }
        }
        
        lblApplinceName.text = pApplince.title
        lblRoomName.text = pApplince.roomTitle
    }
    var appliance: Appliance?
    var sliderTimer: Timer?
    @IBAction func didselectSlidervalue(_ sender: UISlider) {
        
        let aRoundedValue = round(sender.value / 1) * 1
        sender.value = aRoundedValue
        self.sliderTimer?.invalidate()
        self.sliderTimer = nil
        
        self.sliderTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false, block: { (pTimer) in
            let aSliderValue = Int(self.LblSlider?.value ?? 0)
            print("Slider Value = \(aSliderValue)")
            if let anAppliance = self.appliance {
                
                let aDimmableValue :Int = UtilityManager.dimmableValueFromSliderValue(appliance: anAppliance, sliderValue: aSliderValue)
                print(aDimmableValue)
                self.delegate?.cellView(self, didChangeDimmableValue: aDimmableValue)
            }
        })
    }
    
    @IBAction func didselectSwithBtn(_ sender: Any) {
        delegate?.cellView(self, didChangePowerState: btnSwitch.isOn)
    }
    @IBOutlet weak var backgroundeffectiveView: UIView!
    @IBOutlet weak var imageviewApplince: UIImageView!
    @IBOutlet weak var lblApplinceName: UILabel! //
    @IBOutlet weak var lblRoomName: UILabel! //
    @IBOutlet weak var btnSwitch: UISwitch! //
    @IBOutlet weak var LblSlider: UISlider!
    @IBOutlet weak var lblImgBackground: UILabel!
    @IBOutlet weak var isOnlineCell: UILabel! //
}
class OfflineApplinceViewController: UIViewController {
    @IBOutlet weak var pickerTextField : UITextField!
    var updateTimer: Timer?
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    let salutations = ["", "Mr.", "Ms.", "Mrs."]
    var appliances :Array<Appliance> = Array<Appliance>()
    var rooms :Array<Room> = Array<Room>()
    var Applinces = [Appliance]()
    var TempApplinces = [Appliance]()
    var Applince = Appliance()
    var controller_id = [String]()
    var controller_Kid = [String]()
    var cont_Kid = [String]()
    var alldataJson = [String]()
    var socketInstances = [WebSocket?]()
    @IBOutlet weak var lblbackbtn: UIButton!
    @IBOutlet weak var ApplincesTableview: UITableView!
    var countries = ["USA","UK","Spain"]
    var database :DatabaseReference?
    var devicearray = [String]()
    var pickerView = UIPickerView()
    var sliderTimer = Timer()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.database = Database.database().reference()
        ApplincesTableview.delegate = self
        ApplincesTableview.dataSource = self
        ApplincesTableview.estimatedRowHeight = 75.0
        ApplincesTableview.rowHeight = UITableView.automaticDimension
     
        pickerView.delegate = self
        pickerView.dataSource = self
      //  pickerView.showsSelectionIndicator = true
        pickerTextField.inputView = pickerView
        pickerTextField.delegate = self
//        NotificationCenter.default.addObserver(self,
//           selector: "appDidEnterBackground:",
//                                                       name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    var selectedRooms :Room?
    var selectedRoom :Appliance?
    var devices = [String]()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = .white
        lblbackbtn.setTitle("", for: .normal)
        // GetSocketConnection(applinces: <#Appliance#>)
      dataload()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("memory issue")
        // Dispose of any resources that can be recreated.
    }
    func dataload()  {
        socketInstances.removeAll()
        Applinces.removeAll()
        commandManege()
        scoketConnection()
        reloadAllData()
       // reloadAllDataa()
    }
    func scoketConnection() {
        for stringJson in alldataJson{
            do{
                if let json = stringJson.data(using: String.Encoding.utf8){
                    if let jsonData = try JSONSerialization.jsonObject(with: json, options: .allowFragments) as? [String:AnyObject]{
                        if let ipadd = jsonData["ip_address"] as? String{
                            pingToSocket(ipaddress: ipadd)
                        }
                    }
                }
            }catch{

            }
        }
    }
    func commandManege() {
        cont_Kid.removeAll()
        for items in 0..<controller_id.count{
            
            print("controller id =\(controller_id[items])")
            print("controller K id =\(controller_Kid[items])")
            var kid = controller_Kid[items]
            var kidarray = kid.split(separator: ":").map(String.init)
            kidarray.removeLast()
            var firstid = kidarray[0]
            var i = 0
            var firstcomand = String()
            for character in firstid {
                //Checking to see if the index of the character is the one we're looking for
                if i < 4 {
                    var modified = firstid.removeFirst()
                }else{
                    
                }
                i = i + 1
            }
            kidarray[0] = firstid
            print(kidarray)
            cont_Kid.append(contentsOf: kidarray)
            print(cont_Kid)
        }
         // update appliances state
        TempApplinces.removeAll()
        Applinces.removeAll()
      //  if (pickerTextField.text == ""){
            for item in controller_id {
                getofflineMode(controller_id: item)
                //  getofflineModeChange(controller_id: item)
            }
//        }else{
//            getofflineModeChange(controller_id: responcescontrollerId)
//        }
    }
    var responcescontrollerId = String()
    func pingToSocket(ipaddress: String){
        print("Scoket Connection")
        print("ws://\(ipaddress):81")
        var request = URLRequest(url: URL(string: "ws://\(ipaddress):81")!)
        if ProcessInfo.processInfo.arguments.contains("TESTING") {
            request = URLRequest(url: URL(string: "http://\(ipaddress):81")!)
        }
        request.timeoutInterval = 5
        self.socket = WebSocket(request: request)
        self.socket?.delegate = self
        self.socket?.connect()
     
        socketInstances.append(socket)
    }
 
    func GetSocketConnection(applinces: Appliance)  {
        do{
            for stringJson in 0..<alldataJson.count{
                if let json = alldataJson[stringJson].data(using: String.Encoding.utf8){
                    if let jsonData = try JSONSerialization.jsonObject(with: json, options: .allowFragments) as? [String:AnyObject]{
                        if let ip = jsonData["HardwareID"] as? String,let id = applinces.hardwareId  {
                            if ip == id{
                                if let ipadd = jsonData["ip_address"] as? String{
                                    let obj = socketInstances[stringJson]
                                    self.pingToController(ipaddress: obj, applainces: applinces )
                                }
                            }
                        }
                    }
                }
            }
        }catch{
            
        }
    }
    func getofflineMode(controller_id: String){
        let scoresRef = Database.database().reference(withPath: "applianceDetails/\(controller_id)") //CS091651819470701
        scoresRef.observe(.childAdded) { snapshot in
            print("The \(snapshot.key) dinosaur's score is \(snapshot.value ?? "null")")
            let aDict = snapshot.value as? Dictionary<String,Any>
            
            if let anApplianceDict = aDict, let anAppliance = OfflineApplinceViewController.appliance(dict: anApplianceDict) {
                self.Applinces.append(anAppliance)
                self.TempApplinces.append(anAppliance)
              }
            self.manageState()
            self.manageStatetemp()
            DispatchQueue.main.async {
//                for items in self.Applinces{
//                    self.updateAppliancePowerState(appliance: items, powerState:  items.isOn)
//                }
                DispatchQueue.main.asyncAfter(deadline: .now()){
                    if (self.pickerTextField.text == ""){
                        self.ApplincesTableview.reloadData()
                    }
                }
            }
        }
    }
    func getofflineModeChange(controller_id: String){
        let scoresRef = Database.database().reference(withPath: "applianceDetails/\(controller_id)") //CS091651819470701
        scoresRef.observe(.childChanged) { snapshot in
            print("The \(snapshot.key) dinosaur's score is \(snapshot.value ?? "null")")
            let aDict = snapshot.value as? Dictionary<String,Any>
            
            if let anApplianceDict = aDict, let anAppliance = OfflineApplinceViewController.appliance(dict: anApplianceDict) {
                self.Applinces.append(anAppliance)
            }
          //  self.manageState()
            
            DispatchQueue.main.async {
                self.ApplincesTableview.reloadData()
                print("data changed.......")
            }
            
        }
    }
    private func manageStatetemp(){
        for i in 0..<Applinces.count{
            if Applinces.count == cont_Kid.count{
                var condition = cont_Kid[i]
                let modified = condition.removeLast()
                if modified == "2"{
                    var app = Applinces[i].isOn =  true
                }else{
                    var app = Applinces[i].isOn =  false
                }
             //  self.updateAppliancePowerState(appliance: Applinces[i], powerState:  Applinces[i].isOn)
            }
        }
    }

    private func manageState(){
        for i in 0..<TempApplinces.count{
            if TempApplinces.count == cont_Kid.count{
                var condition = cont_Kid[i]
                let modified = condition.removeLast()
                if modified == "2"{
                    var app = TempApplinces[i].isOn =  true
                }else{
                    var app = TempApplinces[i].isOn =  false
                }
                 self.updateAppliancePowerState(appliance: TempApplinces[i], powerState:  TempApplinces[i].isOn)
            }
        }
        
    }
 
    private static func appliance(dict pDict :Dictionary<String,Any>) -> Appliance? {
        var aReturnVal :Appliance? = nil
        
        if let aName = pDict["applianceName"] as? String
            , aName.count > 0 {
            let anAppliance = Appliance()
            anAppliance.id = pDict["id"] as? String
            anAppliance.title = (pDict["applianceName"] as? String)?.capitalized
            if let anApplianceTypeId = pDict["applianceTypeId"] as? String {
                anAppliance.type = Appliance.ApplianceType(rawValue: anApplianceTypeId)
            }
            
            anAppliance.roomId = pDict["roomId"] as? String
            anAppliance.roomTitle = pDict["roomName"] as? String
            
            anAppliance.slaveId = pDict["slaveId"] as? String
            anAppliance.hardwareId = pDict["hardwareId"] as? String
            
            if let aState = pDict["state"] as? Int, aState == 1 {
                anAppliance.isOn = true
            } else if let aState = pDict["state"] as? String, aState == "1" {
                anAppliance.isOn = true
            }
            
            anAppliance.isOnline = pDict["status"] as? Bool == true
            
            anAppliance.operatedCount = pDict["applianceOperatedCount"] as? Int
            
            if let anIsDimmable = pDict["dimmable"] as? String, anIsDimmable == "1" {
                anAppliance.isDimmable = true
            } else if let anIsDimmable = pDict["dimmable"] as? Int, anIsDimmable == 1 {
                anAppliance.isDimmable = true
            }
            if let aDimType = pDict["dimType"] as? String {
                anAppliance.dimType = Appliance.DimType(rawValue: aDimType)
            }
            if let aValue = pDict["dimableValue"] as? String {
                anAppliance.dimmableValue = Int(aValue)
            } else if let aValue = pDict["dimableValue"] as? Int {
                anAppliance.dimmableValue = aValue
            }
            if let aValue = pDict["triacDimableValue"] as? String {
                anAppliance.dimmableValueTriac = Int(aValue)
            } else if let aValue = pDict["triacDimableValue"] as? Int {
                anAppliance.dimmableValueTriac = aValue
            }
            if let aValue = pDict["minDimming"] as? String {
                anAppliance.dimmableValueMin = Int(aValue)
            } else if let aValue = pDict["minDimming"] as? Int {
                anAppliance.dimmableValueMin = aValue
            }
            if let aValue = pDict["maxDimming"] as? String {
                anAppliance.dimmableValueMax = Int(aValue)
            } else if let aValue = pDict["maxDimming"] as? Int {
                anAppliance.dimmableValueMax = aValue
            }
            
            if let aStripType = pDict["stripType"] as? String {
                anAppliance.stripType = Appliance.StripType(rawValue: aStripType)
            }
            
            if let aValue = pDict["property1"] as? String {
                anAppliance.ledStripProperty1 = Int(aValue)
            } else if let aValue = pDict["property1"] as? Int {
                anAppliance.ledStripProperty1 = aValue
            }
            if let aValue = pDict["property2"] as? String {
                anAppliance.ledStripProperty2 = Int(aValue)
            } else if let aValue = pDict["property2"] as? Int {
                anAppliance.ledStripProperty2 = aValue
            }
            if let aValue = pDict["property3"] as? String {
                anAppliance.ledStripProperty3 = Int(aValue)
            } else if let aValue = pDict["property3"] as? Int {
                anAppliance.ledStripProperty3 = aValue
            }
            
            aReturnVal = anAppliance
        }
        
        return aReturnVal
    }
    
    private var socket: WebSocket?
    @IBAction func didselectBackbtn(_ sender: Any) {
        
        RoutingManager.shared.goBackToDashboard()
    }
    func pingToController(ipaddress: WebSocket?, applainces: Appliance){
        print("ws://\(ipaddress):81")
//        var request = URLRequest(url: URL(string: "ws://\(ipaddress):81")!)
//        if ProcessInfo.processInfo.arguments.contains("TESTING") {
//            request = URLRequest(url: URL(string: "http://\(ipaddress):81")!)
//        }
    //    request.timeoutInterval = 5
//        self.socket = WebSocket(request: request)
//        self.socket?.delegate = self
//        self.socket?.connect()
      
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            var scin = ipaddress
            let msg = self.makecomand(appliances: applainces)
            scin?.write(string: msg)
            print("controllr url=\(String(describing: scin?.request.url))")
            ProgressOverlay.shared.hide()
           // self.socket?.write(string: msg)
        }
        // sleep(UInt32(10.0))
    }
    func makecomand(appliances: Appliance) -> String{
        var msgvalue = ""
         
            if let msgid = appliances.id{
                if appliances.isOn{
                    let dimlevalue = appliances.dimmableValue ?? 5
                    msgvalue += "C023\(msgid)20\(String(describing: dimlevalue))F"
                }else{
                    let dimlevalue = appliances.dimmableValue ?? 5
                    msgvalue += "C023\(msgid)10\(String(describing: dimlevalue))F"
                }
            }else{
                msgvalue = "B2F"
            }
        
        return msgvalue
    }
    
    @IBAction func didtappedGoodbyeAll(_ sender: Any) {
        for item in socketInstances{
            self.pingToController(ipaddress: item, applainces: Applince )
        }
    }
    @IBAction func didtappedGoodbye(_ sender: Any) {
        do{
            if pickerTextField.text != ""{
                
                if Applinces[0].roomTitle == selectedRooms?.title{
                  
                    for ips in 0..<alldataJson.count{
                        
                        if let json = alldataJson[ips].data(using: String.Encoding.utf8){
                            if let jsonData = try JSONSerialization.jsonObject(with: json, options: .allowFragments) as? [String:AnyObject]{
                                if let ipd = jsonData["HardwareID"] as? String{
                                    if  Applinces[0].hardwareId == ipd{
                                        let item = socketInstances[ips]
                                        print(" hard=\(ipd)")
                                          self.pingToController(ipaddress: item, applainces: Applince )
                                    }
                               
                                }
                            }
                        }
                    }
                }
            }else{
                for item in socketInstances{
                    self.pingToController(ipaddress: item, applainces: Applince )
                }
            }
        }catch{
            
        }
    }
    func commandArrengeByJson() {
        for item in Applinces{
            if c_id == item.hardwareId{
                if idds == item.id{
                    if state == "1"{
                        item.isOn = false
                        state = ""
                    }else{
                        item.isOn = true
                        state = ""
                    }
                    if dimmable == "1"{
                        item.dimmableValue = Int(dimval)
                        dimmable = ""
                        //update local database
                        self.updateApplianceDimmableValue(appliance: item, dimmableValue: item.dimmableValue!)
                    }
                    //update local database
                    self.updateAppliancePowerState(appliance: item, powerState:  item.isOn)
                }
            }
        }
        self.ApplincesTableview.reloadData()
    }
    var idds = ""
    var state = ""
    var dimmable = ""
    var dimval = ""
    func sortRoomWiseKcomand(){
        DispatchQueue.main.async { [self] in
     
        var controllr_id = [String]()
        var temp = controller_id
        Applinces.removeAll()
        for item in TempApplinces{
            print("ID=\(item.roomTitle)")
            if selectedRooms?.title == item.roomTitle{
              
                for itm in temp
                {
                    if itm == item.hardwareId{
                         Applinces.append(item)
                    }
                }
            }
        }
        //    reloadAllDataa()
           // if Applinces.count > 0{
                ApplincesTableview.reloadData()
          //  }
        }
      }
    func sortRoomWise(){
        DispatchQueue.main.async { [self] in
     
        var controllr_id = [String]()
        var temp = controller_id
        Applinces.removeAll()
        for item in TempApplinces{
            print("ID=\(item.roomTitle)")
            if selectedRooms?.title == item.roomTitle{
              
                for itm in temp
                {
                    if itm == item.hardwareId{
                         Applinces.append(item)
                    }
                }
            }
        }
        //    reloadAllDataa()
           // if Applinces.count > 0{
                ApplincesTableview.reloadData()
          //  }
        }
      }
    func formatJson(stringJson: String, ip: String)  {
        do{
            if stringJson.starts(with: "C6"){
                
            var d = stringJson.map(String.init)
                d.removeFirst()
                d.removeFirst()
                idds = d.removeFirst()
                state = d.removeFirst()
                dimmable = d.removeFirst() //dimble
                dimval = d.removeFirst() // dimval
                for StringJson in alldataJson{
                    do{
                        if let json = StringJson.data(using: String.Encoding.utf8){
                            if let jsonData = try JSONSerialization.jsonObject(with: json, options: .allowFragments) as? [String:AnyObject]{
                                if let ipadd = jsonData["ip_address"] as? String{
                                
                                  //  pingToSocket(ipaddress: ipadd)
                                }
                            }
                        }
                        for StringJson in 0..<socketInstances.count{
                            var  Json = socketInstances[StringJson]
                            if String(describing: Json?.request.url)  == ip {
                              var alldata = alldataJson[StringJson]
                                if let json = alldata.data(using: String.Encoding.utf8){
                                    if let jsonData = try JSONSerialization.jsonObject(with: json, options: .allowFragments) as? [String:AnyObject]{
                                        if let h_id = jsonData["HardwareID"] as? String{
                                            c_id = h_id
                                        }
                                    }
                                }
                            }
//                                    if let ipadd = jsonData["ip_address"] as? String{
//                                        if ip == ipadd{
//                                            c_id = (jsonData["HardwareID"] as? String)!
////
//                                }
//                            }
                        }
                    }catch{

                    }
                }
                commandArrengeByJson()
             }else if stringJson.starts(with: "K"){
//               let d = stringJson
                for i in 0..<controller_Kid.count{
                   if controller_Kid[i].count == stringJson.count {
                    controller_Kid[i] = stringJson
                       
                       for StringJson in 0..<socketInstances.count{
                           var  Json = socketInstances[StringJson]
                           if String(describing: Json?.request.url)  == ip {
                             var alldata = alldataJson[StringJson]
                               if let json = alldata.data(using: String.Encoding.utf8){
                                   if let jsonData = try JSONSerialization.jsonObject(with: json, options: .allowFragments) as? [String:AnyObject]{
                                       if let h_id = jsonData["HardwareID"] as? String{
                                           responcescontrollerId = h_id
                                       }
                                   }
                               }
                           }
                       }
                       self.commandManege()
                     
                       DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                           if (self.pickerTextField.text != ""){
                             //  self.reloadAllData()
                               DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                                    self.sortRoomWiseKcomand()
                               }
                           }
                       }
                 }
              }
            }
            if stringJson.starts(with: "B2"){
                                 for item in Applinces{
                                    item.isOn = false
                                     self.updateAppliancePowerState(appliance: item, powerState:  item.isOn)
                                     item.clone()
                                 }
                self.ApplincesTableview.reloadData()
            }
            if let json = stringJson.data(using: String.Encoding.utf8){
                if let jsonData = try JSONSerialization.jsonObject(with: json, options: .allowFragments) as? [String:AnyObject]{
                    if let id = jsonData["HardwareID"] as? String{
                        print(id)
                      //  self.commandManege()
                        c_id = id
                    }
                }
            }
           
        }catch {
            print(error.localizedDescription)
        }
       
    }
}
var c_id = ""
extension OfflineApplinceViewController: SearchAppliancesTableCellViewDelegate{
    // Switch togal button
    func cellView(_ pSender: applincessCell, didChangePowerState pPowerState: Bool) {
        if let anIndexPath = self.ApplincesTableview.indexPath(for: pSender), anIndexPath.row < self.Applinces.count {
            print(anIndexPath.row)
            let anAppliance = self.Applinces[anIndexPath.row]
             anAppliance.isOn = pPowerState
             anAppliance.clone()
             ProgressOverlay.shared.show()
             self.updateAppliancePowerState(appliance: anAppliance, powerState: pPowerState)
            GetSocketConnection(applinces: anAppliance)
          //  reloadAllDataa()

        }
    }
    
    func cellView(_ pSender: applincessCell, didChangeDimmableValue pDimmableValue: Int) {
        if let anIndexPath = self.ApplincesTableview.indexPath(for: pSender), anIndexPath.row < self.Applinces.count {
            let anAppliance = self.Applinces[anIndexPath.row]
            anAppliance.dimmableValue = pDimmableValue
            self.updateApplianceDimmableValue(appliance: anAppliance, dimmableValue: pDimmableValue)
            GetSocketConnection(applinces: anAppliance)
        }
    }
    func updateApplianceDimmableValue(appliance pAppliance :Appliance, dimmableValue pDimmableValue :Int) {
        let anAppliance = pAppliance.clone()
        //   ProgressOverlay.shared.show()
        DataFetchManager.shared.updateOfflineApplianceDimmableValue(completion: { (pError) in
            //     ProgressOverlay.shared.hide()
            if pError != nil {
                //  PopupManager.shared.displayError(message: "Can not update appliance.", description: pError!.localizedDescription)
            } else {
                if pAppliance.dimType == Appliance.DimType.rc {
                    pAppliance.dimmableValue = pDimmableValue
                } else if pAppliance.dimType == Appliance.DimType.triac {
                    pAppliance.dimmableValueTriac = pDimmableValue
                } else {
                    pAppliance.dimmableValue = pDimmableValue
                }
              //  self.ApplincesTableview.reloadData()
                // self.reloadAllView()
            }
        }, appliance: anAppliance, dimValue: pDimmableValue)
    }
    
    func updateAppliancePowerState(appliance pAppliance :Appliance, powerState pPowerState :Bool) {
        let anAppliance = pAppliance.clone()
        
      //  ProgressOverlay.shared.show()
        DataFetchManager.shared.updateAppliancePowerStateOffline(completion: { (pError) in
         //   ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update appliance.", description: pError!.localizedDescription)
              //  self.reloadAllView()
            } else {
                if self.selectedRoom != nil {
                   // pAppliance.isOn = pPowerState
                } else {
                //    self.reloadAllData()
                }
              //  self.reloadAllView()
            }
        }, appliance: anAppliance, powerState: pPowerState)
    }
    
    private func updateApplianceProperty(_ pAppliance :Appliance, propertyName pPropertyName :String, propertyValue pPropertyValue :Any) -> Error? {
        var aReturnVal :Error? = nil
        return aReturnVal
    }
    
    
    private func fetchApplianceProperty(_ pAppliance :Appliance, propertyName pPropertyName :String) -> Any? {
        var aReturnVal :Any? = nil
        
        return aReturnVal
    }
    
}
extension OfflineApplinceViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Appliance count=\(Applinces.count)")
        return Applinces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let Cell = ApplincesTableview.dequeueReusableCell(withIdentifier: "Cell")! as! applincessCell
        if Applinces.count > indexPath.row{
            let obj = Applinces[indexPath.row]
            print(obj.roomTitle)
            //        if ((selectedRooms?.title) != nil){
            //            if selectedRooms?.title == obj.roomTitle{
            //                Cell.loaddata(pApplince: obj)
            //            }
            //        }else{
            Cell.loaddata(pApplince: obj)
            // }
            
        }
        Cell.delegate = self
        return Cell
    }
    
    func tableView(_ tableView: UITableView,heightForRowAt indexPath:IndexPath) -> CGFloat
    {
       
        let pAppliance = Applinces[indexPath.row]
        var aReturnVal :CGFloat = UITableView.automaticDimension
        if indexPath.row < Applinces.count{
            if pAppliance.type != Appliance.ApplianceType.ledStrip {
                if pAppliance.isOn && pAppliance.isDimmable {
                    aReturnVal = 145.0
                }
            }
        }
        return aReturnVal
            
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(Applinces[indexPath.row])
    }
}
extension OfflineApplinceViewController: WebSocketDelegate{
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocket) {
        print("didReceive-------yes")
        switch event {
        case .connected(let headers):
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            // this is the data we receive from other users sending data to specific port we use for websockets
            print("responce url\(client.request.url)")
            print("Received text: \(string)")
            //   websocketData.text = string ?? ""
            formatJson(stringJson: string, ip: String(describing: client.request.url))
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
            print("error unknown\(String(describing: error))")
            break
        }
    }
}
extension OfflineApplinceViewController: UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
             print("textFieldShouldBeginEditing")
           //delegate method
           return false // Change here return false it means it won't show keyboard
       }
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("end editing")
      // self.endBackgroundTask()
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
            return 1
        }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return rooms.count
        }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return rooms[row].title
       }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let itemselected = rooms[row].title
        print(itemselected)
        
        pickerTextField.text = itemselected
        pickerView.resignFirstResponder()
        self.sliderTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (pTimer) in
            self.selectedRooms = self.rooms[row]
            self.view.endEditing(true)
            self.sortRoomWise()
        })
     }

      func reloadAllData() {
     
        self.appliances.removeAll()
        self.rooms.removeAll()
//        self.filteredRooms.removeAll()
//        self.roomFilterTextField.text = nil
         
        ProgressOverlay.shared.show()
        DataFetchManager.shared.dashboardDetails(completion: { (pError, pApplianceArray, pRoomArray) in
             ProgressOverlay.shared.hide()
            do
            {
            if pApplianceArray != nil {
              //   self.appliances = try pApplianceArray!
             }
            if pRoomArray != nil {
                self.rooms = pRoomArray!
                for item in self.rooms{
                    self.selectedRooms = item
                    self.reloadAllDataa()
                }
             }
            }catch let error{
                print(error.localizedDescription)
            }
          //  self.reloadAllView()
            })
    }
}
// MARK: - GET APPLIANCES
extension OfflineApplinceViewController{
    

    func reloadAllDataa() {
     //  self.appliances.removeAll()
       print("data load applinces")
        ProgressOverlay.shared.show()
       DataFetchManager.shared.searchAppliance(completion: { (pError, pApplianceArray,pDevicesArray) in
            ProgressOverlay.shared.hide()
           if pError != nil {
               PopupManager.shared.displayError(message: "Can not search appliances", description: pError!.localizedDescription)
           } else {
               if pApplianceArray != nil && pApplianceArray!.count > 0 {
                   self.appliances.append(contentsOf: pApplianceArray!)
               }
               if pDevicesArray != nil && pDevicesArray!.count > 0 {
                   if let Arrayx =  pDevicesArray{
                      self.devices = Arrayx
                   }
               }
               if let selectedRoom = self.selectedRoom {
//                DataFetchManager.shared.checkToShowApplianceDimmable(completion: { dimmable in
//                    if dimmable ?? false {
//                        let value = self.setSliderInitialValue()
//                        self.dynamicButtonContainerView.customeSlider.value = Float(value)
//                    }
//                    self.setBottomContainerView(hidden: dimmable ?? false)
//                }, room: selectedRoom)
               } else {
                  // self.setBottomContainerView(hidden: false)
               }
             //  self.ApplincesTableview.reloadData()
             //  self.reloadAllView()
           }
       }, room: self.selectedRooms, includeOnOnly: self.selectedRooms == nil)
       
   }
}
//MARK: - BACKGROUND DELEGATE
//extension OfflineApplinceViewController{
//
//    func reinstateBackgroundTask() {
//        if updateTimer != nil && (backgroundTask == UIBackgroundTaskIdentifier.invalid) {
//            registerBackgroundTask()
//        }
//    }
//    func registerBackgroundTask() {
//        backgroundTask = UIApplication.shared.beginBackgroundTask {
//            [unowned self] in
//            self.endBackgroundTask()
//        }
//        assert(backgroundTask != UIBackgroundTaskIdentifier.invalid)
//    }
//    func endBackgroundTask() {
//        NSLog("Background task ended.")
//        UIApplication.shared.endBackgroundTask(backgroundTask)
//        backgroundTask = UIBackgroundTaskIdentifier.invalid
//    }
//    func calculateNextNumber() {
//        switch UIApplication.shared.applicationState {
//        case .active:
//            break
//        case .background:
//            NSLog("Background time remaining = %.1f seconds", UIApplication.shared.backgroundTimeRemaining)
//        case .inactive:
//            break
//
//        }
//    }
//    func appDidEnterBackground(notification:NSNotification) {
//        updateTimer?.invalidate()
//        updateTimer = nil
//        if backgroundTask != UIBackgroundTaskIdentifier.invalid {
//            endBackgroundTask()
//        }
//    }
//}
extension UIView {
    
    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
