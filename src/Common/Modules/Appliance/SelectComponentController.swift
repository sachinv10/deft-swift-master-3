//
//  SelectComponentController.swift
//  DEFT
//
//  Created by Rupendra on 17/11/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class SelectComponentController: BaseController {
    @IBOutlet weak var componentTableView: AppTableView!
    
    var componentTypes :Array<ComponentType>?
    var selectedRoom :Room?
    var appliances :Array<Appliance> = Array<Appliance>()
    var curtains :Array<Curtain> = Array<Curtain>()
    var remotes :Array<Remote> = Array<Remote>()
    var sensors :Array<Sensor> = Array<Sensor>()
    
    var selectedAppliances :Array<Appliance> = Array<Appliance>()
    var selectedCurtains :Array<Curtain> = Array<Curtain>()
    var selectedRemotes :Array<Remote> = Array<Remote>()
    var selectedMoodOnRemotes :Array<Remote> = Array<Remote>()
    var selectedMoodOffRemotes :Array<Remote> = Array<Remote>()
    var selectedSensors :Array<Sensor> = Array<Sensor>()
    
    static var coreSensor: Bool = false
    static var ApplianceType: String?
    func selectedRemoteArray(componentType pComponentType :ComponentType) -> Array<Remote> {
        var aReturnVal = Array<Remote>()
        if pComponentType == .remoteKey {
            aReturnVal = self.selectedRemotes
        } else if pComponentType == .remoteKeyMoodOn {
            aReturnVal = self.selectedMoodOnRemotes
        } else if pComponentType == .remoteKeyMoodOff {
            aReturnVal = self.selectedMoodOffRemotes
        }
        return aReturnVal
    }
    
    weak var delegate :SelectComponentControllerDelegate?
    
    enum ComponentType {
        case appliance
        case curtain
        case remoteKey
        case remoteKeyMoodOn
        case remoteKeyMoodOff
        case sensor
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Select Component"
        self.subTitle = self.selectedRoom?.title
        
        if let aComponentArray = self.selectedRoom?.appliances {
            self.selectedAppliances.append(contentsOf: aComponentArray)
        }
        if let aComponentArray = self.selectedRoom?.curtains {
            self.selectedCurtains.append(contentsOf: aComponentArray)
        }
        if let aComponentArray = self.selectedRoom?.remotes {
            self.selectedRemotes.append(contentsOf: aComponentArray)
        }
        if let aComponentArray = self.selectedRoom?.moodOnRemotes {
            self.selectedMoodOnRemotes.append(contentsOf: aComponentArray)
        }
        if let aComponentArray = self.selectedRoom?.moodOffRemotes {
            self.selectedMoodOffRemotes.append(contentsOf: aComponentArray)
        }
        if let aComponentArray = self.selectedRoom?.sensors {
            self.selectedSensors.append(contentsOf: aComponentArray)
        }
        
        if self.componentTypes?.contains(.appliance) == true {
            self.searchAppliance()
        }
        if self.componentTypes?.contains(.curtain) == true {
            self.searchCurtain()
        }
        if self.componentTypes?.contains(.remoteKey) == true
            || self.componentTypes?.contains(.remoteKeyMoodOn) == true
            || self.componentTypes?.contains(.remoteKeyMoodOff) == true {
            self.searchRemote()
        }
        if self.componentTypes?.contains(.sensor) == true {
            self.searchSensor()
        }
    }
    
    
    func searchAppliance() {
        DataFetchManager.shared.searchAppliance(completion: { [self] (pError, pApplianceArray,pDevicesArray) in
            if pApplianceArray != nil && pApplianceArray!.count > 0 {
                self.appliances = pApplianceArray!
                if SelectComponentController.ApplianceType == "If"{
                    appliances = self.appliances.filter({(pappliance) -> Bool in
                        return  pappliance.stripType != Appliance.StripType.rgb && pappliance.type != Appliance.ApplianceType.ledStrip
                    })
                }
            }
            self.componentTableView.reloadData()
        }, room: self.selectedRoom, includeOnOnly: false)
    }
    
    
    func searchCurtain() {
        DataFetchManager.shared.searchCurtain(completion: { (pError, pCurtainArray) in
            if pCurtainArray != nil && pCurtainArray!.count > 0 {
                self.curtains = pCurtainArray!
            }
            self.componentTableView.reloadData()
        }, room: self.selectedRoom)
    }
    
    
    func searchRemote() {
        DataFetchManager.shared.searchRemote(completion: { (pError, pRemoteArray) in
            if pRemoteArray != nil && pRemoteArray!.count > 0 {
                self.remotes = pRemoteArray!
            }
            self.componentTableView.reloadData()
        }, room: self.selectedRoom)
    }
    
    
    func searchSensor() {
        DataFetchManager.shared.searchSensor(completion: { (pError, pSensorArray) in
            if pSensorArray != nil && pSensorArray!.count > 0 {
               if SelectComponentController.coreSensor{
                   var psensors :Array<Sensor> = Array<Sensor>()
                   for item in pSensorArray!{
                       if item.id!.hasPrefix("S01"){
                        print("smoke remove")
                       }else{
                           psensors.append(item)
                       }
                   }
                   self.sensors = psensors
               }else{
                   self.sensors = pSensorArray!
               }
            }
            self.componentTableView.reloadData()
        }, room: self.selectedRoom)
    }
    
}


extension SelectComponentController {
    
    @IBAction func didSelectDoneButton(_ pSender: UIButton?) {
        if let aRoom = self.selectedRoom {
            self.delegate?.selectComponentControllerDidSelect(
                room: aRoom
                , appliances: self.selectedAppliances
                , curtains: self.selectedCurtains
                , remotes: self.selectedRemotes
                , moodOnRemotes: self.selectedMoodOnRemotes
                , moodOffRemotes: self.selectedMoodOffRemotes
                , sensors: self.selectedSensors
            )
        }
    }
}


extension SelectComponentController :UITableViewDataSource, UITableViewDelegate {
    
    // MARK:- UITableView Methods
    
    /**
     * Method that will calculate and return number of section in given table.
     * @return Int. Number of section in given table
     */
    func numberOfSections(in pTableView: UITableView) -> Int {
        return self.componentTypes?.count ?? 0
    }
    
    
    func tableView(_ pTableView: UITableView, titleForHeaderInSection pSection: Int) -> String? {
        var aReturnVal :String?
        
        if let aComponentTypeArray = self.componentTypes {
            switch aComponentTypeArray[pSection] {
            case .appliance:
                aReturnVal = self.appliances.count > 0 ? "Appliances" : nil
            case .curtain:
                aReturnVal = self.curtains.count > 0 ? "Curtains" : nil
            case .remoteKey:
                aReturnVal = self.remotes.count > 0 ? "Remotes" : nil
            case .remoteKeyMoodOn:
                aReturnVal = self.remotes.count > 0 ? "Remotes (Mood On)" : nil
            case .remoteKeyMoodOff:
                aReturnVal = self.remotes.count > 0 ? "Remotes (Mood Off)" : nil
            case .sensor:
                aReturnVal = self.sensors.count > 0 ? "Sensors" : nil
            }
        }
        
        return aReturnVal
    }
    
    
    
    /**
     * Method that will calculate and return number of rows in given section of the table.
     * @return Int. Number of rows in given section
     */
    func tableView(_ pTableView: UITableView, numberOfRowsInSection pSection: Int) -> Int {
        var aReturnVal :Int = 0
        
        if let aComponentTypeArray = self.componentTypes {
            switch aComponentTypeArray[pSection] {
            case .appliance:
                aReturnVal = self.appliances.count
            case .curtain:
                aReturnVal = self.curtains.count
            case .remoteKey, .remoteKeyMoodOn, .remoteKeyMoodOff:
                aReturnVal = self.remotes.count
            case .sensor:
                aReturnVal = self.sensors.count
            }
        }
        
        return aReturnVal
    }
    
    
    /**
     * Method that will calculate and return height of row at given index path of the table.
     * @return CGFloat. Height of the row at given index path
     */
    func tableView(_ pTableView: UITableView, heightForRowAt pIndexPath: IndexPath) -> CGFloat {
        var aReturnVal :CGFloat = UITableView.automaticDimension
        aReturnVal = SelectComponentTableCellView.cellHeight()
        return aReturnVal
    }
    
    
    /**
     * Method that will calculate and return height of row at given index path of the table.
     * @return CGFloat. Height of the row at given index path
     */
    func tableView(_ pTableView: UITableView, estimatedHeightForRowAt pIndexPath: IndexPath) -> CGFloat {
        let aReturnVal :CGFloat = UITableView.automaticDimension
        return aReturnVal
    }
    
    
    /**
     * Method that will init, set and return the cell view.
     * @return UITableViewCell. View of the cell in given table view.
     */
    func tableView(_ pTableView: UITableView, cellForRowAt pIndexPath: IndexPath) -> UITableViewCell {
        var aReturnVal :UITableViewCell?
        
        if pTableView.isEqual(self.componentTableView) {
            if let aComponentTypeArray = self.componentTypes {
                let aComponentType = aComponentTypeArray[pIndexPath.section]
                switch aComponentType {
                case .appliance:
                    if pIndexPath.row < self.appliances.count {
                        let anAppliance = self.appliances[pIndexPath.row]
                        let aSelectedAppliance = self.selectedAppliances.first(where: { (pObject) -> Bool in
                            var aReturnVal = false
                            switch ConfigurationManager.shared.appType {
                            case .deft:
                                aReturnVal = anAppliance.hardwareId == pObject.hardwareId && anAppliance.roomId == pObject.roomId && anAppliance.id == pObject.id && anAppliance.slaveId == pObject.slaveId
                            case .wifinity:
                                aReturnVal = anAppliance.hardwareId == pObject.hardwareId && anAppliance.id == pObject.id
                            }
                            return aReturnVal
                        })
                        
                        let aCellView :SelectComponentTableCellView = pTableView.dequeueReusableCell(withIdentifier: "SelectComponentTableCellViewId") as! SelectComponentTableCellView
                        aCellView.delegate = self
                        aCellView.load(appliance: anAppliance, isChecked: aSelectedAppliance != nil, powerState: aSelectedAppliance?.scheduleState, dimmableValue: aSelectedAppliance?.scheduleDimmableValue, sripLight: (aSelectedAppliance?.stripType == Appliance.StripType.rgb && aSelectedAppliance?.type == Appliance.ApplianceType.ledStrip))
                        aReturnVal = aCellView
                    }
                case .curtain:
                    if pIndexPath.row < self.curtains.count {
                        let aCurtain = self.curtains[pIndexPath.row]
                        let aSelectedCurtain = self.selectedCurtains.first(where: { (pObject) -> Bool in
                            return aCurtain.id == pObject.id
                        })
                        
                        let aCellView :SelectComponentTableCellView = pTableView.dequeueReusableCell(withIdentifier: "SelectComponentTableCellViewId") as! SelectComponentTableCellView
                        aCellView.delegate = self
                        aCellView.load(curtain: aCurtain, isChecked: aSelectedCurtain != nil, level: aSelectedCurtain?.scheduleLevel ?? Curtain.MotionState.reverse.rawValue)
                        aReturnVal = aCellView
                    }
                case .remoteKey, .remoteKeyMoodOn, .remoteKeyMoodOff:
                    if pIndexPath.row < self.remotes.count {
                        let aRemote = self.remotes[pIndexPath.row]
                        let aSelectedRemoteArray = self.selectedRemoteArray(componentType: aComponentType)
                        let aSelectedRemote = aSelectedRemoteArray.first(where: { (pObject) -> Bool in
                            return aRemote.id == pObject.id
                        })
                        
                        let aCellView :SelectComponentTableCellView = pTableView.dequeueReusableCell(withIdentifier: "SelectComponentTableCellViewId") as! SelectComponentTableCellView
                        aCellView.delegate = self
                        aCellView.load(remote: aRemote, isChecked: aSelectedRemote != nil)
                        aReturnVal = aCellView
                    }
                case .sensor:
                    if pIndexPath.row < self.sensors.count {
                        var aSensor = self.sensors[pIndexPath.row]
                        let aSelectedSensor = self.selectedSensors.first(where: { (pObject) -> Bool in
                            return aSensor.id == pObject.id
                        })
                        
                        let aCellView :SelectComponentTableCellView = pTableView.dequeueReusableCell(withIdentifier: "SelectComponentTableCellViewId") as! SelectComponentTableCellView
                        aCellView.delegate = self
                        if SelectComponentController.coreSensor{
                      if  aSelectedSensor != nil{
                          aSensor = aSelectedSensor!
                      }
                            aCellView.loadx(sensor: aSensor, isChecked: aSelectedSensor != nil, activatedState: aSelectedSensor?.scheduleSensorActivatedState, motionLightState: aSelectedSensor?.scheduleMotionLightActivatedState, sirenState: aSelectedSensor?.scheduleSirenActivatedState)
                        }else{
                            aCellView.load(sensor: aSensor, isChecked: aSelectedSensor != nil, activatedState: aSelectedSensor?.scheduleSensorActivatedState, motionLightState: aSelectedSensor?.scheduleMotionLightActivatedState, sirenState: aSelectedSensor?.scheduleSirenActivatedState)
                        }
                        aReturnVal = aCellView
                    }
                }
            }
        }
        
        if aReturnVal == nil {
            aReturnVal = UITableViewCell()
        }
        
        return aReturnVal!
    }
    
    
    /**
     * Method that will be called when user selects a table cell.
     */
    func tableView(_ pTableView: UITableView, didSelectRowAt pIndexPath: IndexPath) {
        pTableView.deselectRow(at: pIndexPath, animated: true)
        
        if let aComponentTypeArray = self.componentTypes {
            let aComponentType = aComponentTypeArray[pIndexPath.section]
            switch aComponentType {
            case .appliance:
                if pIndexPath.row < self.appliances.count {
                    let anAppliance = self.appliances[pIndexPath.row]
                    if let anIndex = self.selectedAppliances.firstIndex(where: { (pObject) -> Bool in
                        return (anAppliance.id == pObject.id)
                            && (anAppliance.roomId == pObject.roomId)
                            && (anAppliance.hardwareId == pObject.hardwareId)
                    }) {
                        self.selectedAppliances.remove(at: anIndex)
                    } else {
                        self.selectedAppliances.append(anAppliance)
                    }
                    self.componentTableView.reloadRows(at: [pIndexPath], with: UITableView.RowAnimation.automatic)
                }
            case .curtain:
                if pIndexPath.row < self.curtains.count {
                    let aCurtain = self.curtains[pIndexPath.row]
                    if let anIndex = self.selectedCurtains.firstIndex(where: { (pObject) -> Bool in
                        return aCurtain.id == pObject.id
                    }) {
                        self.selectedCurtains.remove(at: anIndex)
                    } else {
                        self.selectedCurtains.append(aCurtain)
                    }
                    self.componentTableView.reloadRows(at: [pIndexPath], with: UITableView.RowAnimation.automatic)
                }
            case .remoteKey, .remoteKeyMoodOn, .remoteKeyMoodOff:
                if pIndexPath.row < self.remotes.count {
                    let aRemote = self.remotes[pIndexPath.row]
                    var aSelectedRemote :Remote?
                    let aSelectedRemoteArray = self.selectedRemoteArray(componentType: aComponentType)
                    if let anIndex = aSelectedRemoteArray.firstIndex(where: { (pObject) -> Bool in
                        return (aRemote.id == pObject.id && aRemote.hardwareId == pObject.hardwareId)
                    }) {
                        aSelectedRemote = aSelectedRemoteArray[anIndex]
                    }
                    RoutingManager.shared.gotoSelectRemoteKey(controller: self, remote: aRemote, delegate: self, componentType: aComponentType, selectedRemoteKeys: aSelectedRemote?.selectedRemoteKeys)
                }
            case .sensor:
                if pIndexPath.row < self.sensors.count {
                    let aSensor = self.sensors[pIndexPath.row]
                    if let anIndex = self.selectedSensors.firstIndex(where: { (pObject) -> Bool in
                        return aSensor.id == pObject.id
                    }) {
                        self.selectedSensors.remove(at: anIndex)
                    } else {
                        self.selectedSensors.append(aSensor)
                    }
                    self.componentTableView.reloadRows(at: [pIndexPath], with: UITableView.RowAnimation.automatic)
                }
            }
        }
    }
    
}


extension SelectComponentController :SelectRemoteKeyControllerDelegate {
    
    func selectRemoteKeyController(_ pSender: SelectRemoteKeyController, didSelectRemoteKeys pRemoteKeyArray: Array<RemoteKey>?, componentType pComponentType: ComponentType?) {
        if let aComponentType = pComponentType {
            var aSelectedRemoteArray = self.selectedRemoteArray(componentType: aComponentType)
            if let aRemote = aSelectedRemoteArray.first(where: { (pRemote) -> Bool in
                return (pRemote.id == pSender.remote?.id && pRemote.hardwareId == pSender.remote?.hardwareId)
            }) {
                 if (pRemoteKeyArray?.count ?? 0 > 0){
                    aRemote.selectedRemoteKeys = pRemoteKeyArray
                }else{
                    selectedRemotes.removeAll { $0 == aRemote }
                 }
            } else if let aRemote = self.remotes.first(where: { (pRemote) -> Bool in
                return pRemote.id == pSender.remote?.id && pRemote.hardwareId == pSender.remote?.hardwareId
            }) {
                let aRemoteToAdd = aRemote.clone()
                aRemoteToAdd.selectedRemoteKeys = pRemoteKeyArray
                switch aComponentType {
                case .appliance:
                    break
                case .curtain:
                    break
                case .remoteKey:
                    self.selectedRemotes.append(aRemoteToAdd)
                case .remoteKeyMoodOn:
                    self.selectedMoodOnRemotes.append(aRemoteToAdd)
                case .remoteKeyMoodOff:
                    self.selectedMoodOffRemotes.append(aRemoteToAdd)
                case .sensor:
                    break
                }
            }
            if let anIndex = self.componentTypes?.firstIndex(of: aComponentType) {
                self.componentTableView.reloadSections(IndexSet(integer: anIndex), with: .fade)
            }
        }
        RoutingManager.shared.goBackToController(self)
    }
    
}


extension SelectComponentController :SelectComponentTableCellViewDelegate {
    func cellView(_ pSender: SelectComponentTableCellView, didChangeProperty1 pProperty1: Int, property2 pProperty2: Int, property3 pProperty3: Int, glowPattern pGlowPatternValue: String? ) {
         if let anIndexPath = self.componentTableView.indexPath(for: pSender), anIndexPath.row < self.appliances.count {
            let anAppliance = self.appliances[anIndexPath.row]
             anAppliance.ledStripProperty1 = pProperty1
             anAppliance.ledStripProperty2 = pProperty2
             anAppliance.ledStripProperty3 = pProperty3
             anAppliance.stripLightEvent = pGlowPatternValue
             self.appliances[anIndexPath.row] = anAppliance
             self.componentTableView.reloadRows(at: [anIndexPath], with: UITableView.RowAnimation.automatic)
         }
    }
    
    func selectComponentSensorTableCellView(_ pSender: SelectComponentTableCellView) {
        if let anIndexPath = self.componentTableView.indexPath(for: pSender){
            self.componentTableView.reloadRows(at: [anIndexPath], with: UITableView.RowAnimation.automatic)
        }
    }
    
    func selectComponentTableCellViewDidUpdate(_ pSender: SelectComponentTableCellView) {
        if let anAppliance = pSender.appliance {
            if let aSelectedAppliance = self.selectedAppliances.first(where: { (pObject) -> Bool in
                return anAppliance.id == pObject.id && anAppliance.hardwareId == pObject.hardwareId
            }) {
                aSelectedAppliance.scheduleState = anAppliance.scheduleState
                aSelectedAppliance.scheduleCommand = anAppliance.scheduleCommand
                aSelectedAppliance.scheduleDimmableValue = anAppliance.scheduleDimmableValue
            }
        } else if let aCurtain = pSender.curtain {
            if let aSelectedCurtain = self.selectedCurtains.first(where: { (pObject) -> Bool in
                return aCurtain.id == pObject.id
            }) {
                aSelectedCurtain.scheduleCommand = aCurtain.scheduleCommand
                aSelectedCurtain.scheduleLevel = aCurtain.scheduleLevel
            }
        } else if let aRemote = pSender.remote {
            if let aSelectedRemote = self.selectedRemotes.first(where: { (pObject) -> Bool in
                return aRemote.id == pObject.id && aRemote.hardwareId == pObject.hardwareId
            }) {
                aSelectedRemote.selectedRemoteKeys = aRemote.selectedRemoteKeys
            }
        } else if let aSensor = pSender.sensor {
            if let aSelectedSensor = self.selectedSensors.first(where: { (pObject) -> Bool in
                return aSensor.id == pObject.id
            }) {
                aSelectedSensor.scheduleCommands = aSensor.scheduleCommands
                aSelectedSensor.scheduleSensorActivatedState = aSensor.scheduleSensorActivatedState
                aSelectedSensor.scheduleMotionLightActivatedState = aSensor.scheduleMotionLightActivatedState
                aSelectedSensor.scheduleSirenActivatedState = aSensor.scheduleSirenActivatedState
                aSelectedSensor.temperature = aSensor.temperature
                aSelectedSensor.routineType = aSensor.routineType
                aSelectedSensor.optators = aSensor.optators
                aSelectedSensor.sensorTypeId = aSensor.sensorTypeId
            }
        }
    }
    
}


protocol SelectComponentControllerDelegate :AnyObject {
    func selectComponentControllerDidSelect(room pRoom :Room, appliances pApplianceArray :Array<Appliance>?, curtains pCurtaineArray :Array<Curtain>?, remotes pRemoteArray :Array<Remote>?, moodOnRemotes pMoodOnRemoteArray :Array<Remote>?, moodOffRemotes pMoodOffRemoteArray :Array<Remote>?, sensors pSensorArray :Array<Sensor>?)
}
