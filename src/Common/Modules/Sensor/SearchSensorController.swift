//
//  SearchSensorController.swift
//  DEFT
//
//  Created by Rupendra on 21/08/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
class SearchSensorController: BaseController {
    @IBOutlet weak var sensorTableView: AppTableView!
    
    var selectedRoom :Room?
    var sensors :Array<Sensor> = Array<Sensor>()
    var controllerflag: Bool = false
    static var sensorId = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "SENSORS"
        self.subTitle = self.selectedRoom?.title
        
        self.sensorTableView.tableFooterView = UIView()
        self.sensorTableView.delaysContentTouches = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        self.controllerflag = true
        activatdatalistner()
        reloadAllData()
        // Add devices battery oprated smoke sensor
        //  var reff = Database.database().reference().child("devices").child("S010101676531003").setValue(["adcThreshold": 200, "co2Threshold": 5, "controllerType" :"Battery Smoke Detector", "currentTemp": "NA", "filter": "wXxgF8zjX0bNsaavRCQA5UDIowy1_00_smartsensor", "co2":"00000", "id": "S010101676531003", "lastMotion": "NA", "lightIntensity": "NA", "lpg": "00000",  "lpgThreshold": 187, "motionLightStatus" :false, "name" :"Bt Smoke Detector1003", "online": true, "roomId" :"00", "roomName" :"Demo", "sirenStatus": true, "smoke": "00000", "smokeThreshold": 5, "state": true, "syncToggle" : 0, "timeStamp" : 1676533382000, "uid": "wXxgF8zjX0bNsaavRCQA5UDIowy1", "Batterysevermode": "Low","BatteryPercentage": "50"])
        // S010101676531003
        
        // Add devices battery oprated smart sensor
        //   let reff = Database.database().reference().child("devices").child("S0001676628338000").setValue(["alexaMotionEventTimestamp" :1676438026508, "controllerType" : "battery smart sensor", "currentTemp" : "0027",
        //        "filter" : "wXxgF8zjX0bNsaavRCQA5UDIowy1_00_smartsensor",
        //        "id" :"S0001676628338000",
        //        "lastMotion" : "NA",
        //        "lastMotionTimeStamp" : 1676628338000,
        //        "lightIntensity" : "360",
        //        "motionLightStatus" : true,
        //        "name": "Bt Smart Sense8000",
        //        "online" : true,
        //        "roomId": "00",
        //        "roomName" : "Demo",
        //        "sirenStatus" : false,
        //        "state" :false,
        //        "syncToggle" : 0,
        //        "timeStamp": 1676628338000,
        //        "uid":"wXxgF8zjX0bNsaavRCQA5UDIowy1",
        //        "Batterysevermode": "Low",
        //        "BatteryPercentage": "60"
        //        ])
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("mood lisner dissappear........")
        self.controllerflag = false
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now()){
            let aFilter = SearchSensorController.sensorId
            Database.database().reference()
                .child("devices")
                .queryOrdered(byChild: "filter")
                .queryEqual(toValue: aFilter).removeAllObservers()
            print("mood lisner dissappear........")
        }
    }
    
    
    func activatdatalistner()  {
        
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2){
            print("applince id\(SearchSensorController.sensorId)")
            let aFilter = SearchSensorController.sensorId
            Database.database().reference()
                .child("devices")
                .queryOrdered(byChild: "filter")
                .queryEqual(toValue: aFilter).observe(.childChanged) { (snapshot, key) in
                    print(key as Any)
                    print("Sensor lisner appear........")
                    if self.controllerflag == true {
                        self.reloadAllData()
                    }
                }
        }
    }
    
    override func reloadAllData() {
        self.sensors.removeAll()
        print("get sensors")
        // ProgressOverlay.shared.show()
        DataFetchManager.shared.searchSensor(completion: { (pError, pSensorArray) in
            //  ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not search sensors", description: pError!.localizedDescription)
            } else {
                if pSensorArray != nil && pSensorArray!.count > 0 {
                    self.sensors = pSensorArray!
                }
                self.reloadAllView()
            }
        }, room: self.selectedRoom)
    }
    
    
    func reloadAllView() {
        if self.sensors.count <= 0 {
            self.sensorTableView.display(message: "No Sensor Available")
        } else {
            self.sensorTableView.hideMessage()
        }
        self.sensorTableView.reloadData()
    }
    
    
    func updateSensorMotionLightState(sensor pSensor :Sensor, lightState pLightState :Sensor.LightState) {
        let aSensor = pSensor.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateSensorMotionLightState(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update sensor.", description: pError!.localizedDescription)
            } else {
                pSensor.lightState = pLightState
                self.reloadAllView()
            }
        }, sensor: aSensor, motionLightState: pLightState, isSettings: false)
    }
    
    
    func updateSensorMotionState(sensor pSensor :Sensor, motionState pMotionState :Sensor.MotionState) {
        let aSensor = pSensor.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateSensorMotionState(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update sensor.", description: pError!.localizedDescription)
            } else {
                pSensor.motionState = pMotionState
                self.reloadAllView()
            }
        }, sensor: aSensor, motionState: pMotionState)
    }
    
    
    func updateSensorSirenState(sensor pSensor :Sensor, sirenState pSirenState :Sensor.SirenState) {
        let aSensor = pSensor.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateSensorSirenState(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update sensor.", description: pError!.localizedDescription)
            } else {
                pSensor.sirenState = pSirenState
                self.reloadAllView()
            }
        }, sensor: aSensor, sirenState: pSirenState)
    }
    
    
    func updateSensorOccupancyState(sensor pSensor :Sensor, occupancyState pOccupancyState :Sensor.OccupancyState) {
        let aSensor = pSensor.clone()
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateSensorOccupancyState(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update sensor.", description: pError!.localizedDescription)
            } else {
                pSensor.occupancyState = pOccupancyState
                self.reloadAllView()
            }
        }, sensor: aSensor, occupancyState: pOccupancyState)
    }
    
    func updateSensorBtnfixNow(sensor pSensor :Sensor) {
        let aSensor = pSensor.clone()
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateSensorbtnFixNow(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update sensor.", description: pError!.localizedDescription)
            } else {
                //                pSensor.occupancyState = pOccupancyState
                //                self.reloadAllView()
            }
        }, sensor: pSensor)
    }
    
    func updateSensorBtnResetCounter(sensor pSensor :Sensor) {
        let aSensor = pSensor.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateSensorbtncounterReset(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update sensor.", description: pError!.localizedDescription)
            } else {
                //                pSensor.occupancyState = pOccupancyState
                //                self.reloadAllView()
            }
        }, sensor: pSensor)
    }
    
    func updateCalibrate(sensor pSensor :Sensor) {
        let aSensor = pSensor.clone()
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateSensorCalibrate(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update sensor.", description: pError!.localizedDescription)
            } else {
                
            }
        }, sensor: pSensor)
    }
    
    func updateSensorSync(sensor pSensor :Sensor) {
        let aSensor = pSensor.clone()
        
        ProgressOverlay.shared.show()
        DataFetchManager.shared.updateSensorSync(completion: { (pError) in
            ProgressOverlay.shared.hide()
            if pError != nil {
                PopupManager.shared.displayError(message: "Can not update sensor.", description: pError!.localizedDescription)
            } else {
                self.reloadAllView()
            }
        }, sensor: aSensor)
    }
    
}

extension SearchSensorController :UITableViewDataSource, UITableViewDelegate {
    
    // MARK:- UITableView Methods
    
    /**
     * Method that will calculate and return number of section in given table.
     * @return Int. Number of section in given table
     */
    func numberOfSections(in pTableView: UITableView) -> Int {
        return 1
    }
    
    
    /**
     * Method that will calculate and return number of rows in given section of the table.
     * @return Int. Number of rows in given section
     */
    func tableView(_ pTableView: UITableView, numberOfRowsInSection pSection: Int) -> Int {
        var aReturnVal :Int = 0
        
        if pSection == 0 {
            aReturnVal = self.sensors.count
        }
        
        return aReturnVal
    }
    
    
    /**
     * Method that will calculate and return height of row at given index path of the table.
     * @return CGFloat. Height of the row at given index path
     */
    func tableView(_ pTableView: UITableView, heightForRowAt pIndexPath: IndexPath) -> CGFloat {
        let aReturnVal :CGFloat = UITableView.automaticDimension
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
        
        if pTableView.isEqual(self.sensorTableView) {
            if pIndexPath.row < self.sensors.count {
                let aSensor = self.sensors[pIndexPath.row]
                let aCellView :SearchSensorTableCellView = pTableView.dequeueReusableCell(withIdentifier: "SearchSensorTableCellViewId") as! SearchSensorTableCellView
                aCellView.delegate = self
                aCellView.btnfixnow.tag = pIndexPath.row
                aCellView.load(sensor: aSensor)
                aReturnVal = aCellView
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
        if pIndexPath.row < self.sensors.count {
            let aSelectedSensor = self.sensors[pIndexPath.row]
            if aSelectedSensor.controllerType != "Lidar Sensor"{
                if aSelectedSensor.hardwareGeneration != Device.HardwareGeneration.deft {
                    RoutingManager.shared.gotoSensorDetails(controller: self, selectedSensor: aSelectedSensor)
                }
              }
        }
    }
}



extension SearchSensorController :SearchSensorTableCellViewDelegate {
    func cellView(_ pSender: SearchSensorTableCellView) {
        print(pSender.sensor?.calibrated)
        if let anIndexPath = self.sensorTableView.indexPath(for: pSender), anIndexPath.row < self.sensors.count {
            let aSensor = self.sensors[anIndexPath.row]
            self.updateCalibrate(sensor: aSensor)
        }
    }
    
    func cellViewResetCount(_ pSender: SearchSensorTableCellView) {
        if let anIndexPath = self.sensorTableView.indexPath(for: pSender), anIndexPath.row < self.sensors.count {
            let aSensor = self.sensors[anIndexPath.row]
            self.updateSensorBtnResetCounter(sensor: aSensor)
        }
    }
    
    func cellViewDidSelectFixnow(_ pindex: Int) {
        let aSensor = self.sensors[pindex]
        self.updateSensorBtnfixNow(sensor: aSensor)
    }
    
    func cellView(_ pSender: SearchSensorTableCellView, didChangeOccupancyState pOccupancyState: Sensor.OccupancyState) {
        if let anIndexPath = self.sensorTableView.indexPath(for: pSender), anIndexPath.row < self.sensors.count {
            let aSensor = self.sensors[anIndexPath.row]
            self.updateSensorOccupancyState(sensor: aSensor, occupancyState: pOccupancyState)
        }
    }
    
    func cellView(_ pSender: SearchSensorTableCellView, didChangeLightState pLightState: Sensor.LightState) {
        if let anIndexPath = self.sensorTableView.indexPath(for: pSender), anIndexPath.row < self.sensors.count {
            let aSensor = self.sensors[anIndexPath.row]
            self.updateSensorMotionLightState(sensor: aSensor, lightState: pLightState)
        }
    }
    
    func cellView(_ pSender: SearchSensorTableCellView, didChangeMotionState pMotionState: Sensor.MotionState) {
        if let anIndexPath = self.sensorTableView.indexPath(for: pSender), anIndexPath.row < self.sensors.count {
            let aSensor = self.sensors[anIndexPath.row]
            self.updateSensorMotionState(sensor: aSensor, motionState: pMotionState)
        }
    }
    
    func cellView(_ pSender: SearchSensorTableCellView, didChangeSirenState pSirenState: Sensor.SirenState) {
        if let anIndexPath = self.sensorTableView.indexPath(for: pSender), anIndexPath.row < self.sensors.count {
            let aSensor = self.sensors[anIndexPath.row]
            self.updateSensorSirenState(sensor: aSensor, sirenState: pSirenState)
        }
    }
    
    func cellViewDidSelectSync(_ pSender: SearchSensorTableCellView) {
        if let anIndexPath = self.sensorTableView.indexPath(for: pSender), anIndexPath.row < self.sensors.count {
            let aSensor = self.sensors[anIndexPath.row]
            self.updateSensorSync(sensor: aSensor)
        }
    }
    
    func cellViewDidSelectAppNotifications(_ pSender: SearchSensorTableCellView) {
        if let anIndexPath = self.sensorTableView.indexPath(for: pSender), anIndexPath.row < self.sensors.count {
            let aSensor = self.sensors[anIndexPath.row]
            RoutingManager.shared.gotoSearchAppNotification(controller: self, selectedAppNotificationType: .sensorNotification, hardwareId: aSensor.id)
        }
    }
    
}
