//
//  DataFetchManager.swift
//  DEFT
//
//  Created by Rupendra on 21/08/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit


/**
* Class that implements Codable and serializes response of HTTP API objects.
*/

class DataFetchManager: NSObject {
    /**
     * Variable that will hold singleton instance of DataFetchManager.
     */
    static var shared :DataFetchManager = {
        return DataFetchManager()
    }()
    
    
    static let databaseValueChangedNotificationName = "databaseValueChangedNotificationName"
    
    
    private let dataFetchManagerFireBase = DataFetchManagerFireBase()
    
    var loggedInUser :User?
    
    
    func checkInternetConnection(completion pCompletion: @escaping (Error?) -> Void) {
        self.dataFetchManagerFireBase.checkInternetConnection(completion: pCompletion)
    }
    
    func login(completion pCompletion: @escaping (Error?, User?) -> Void, user pUser :User) {
        self.dataFetchManagerFireBase.login(completion: pCompletion, user: pUser)
    }
    
    func logout(completion pCompletion: @escaping (Error?) -> Void) {
        self.dataFetchManagerFireBase.logout(completion: pCompletion)
    }
    
    func resetPassword(completion pCompletion: @escaping (Error?, User?) -> Void, user pUser :User) {
        self.dataFetchManagerFireBase.resetPassword(completion: pCompletion, user: pUser)
    }
    
    func dashboardDetails(completion pCompletion: @escaping (Error?, Array<Appliance>?, Array<Room>?) -> Void) {
        self.dataFetchManagerFireBase.dashboardDetails(completion: pCompletion)
    }
    
    func deviceDetails(completion pCompletion: @escaping (Error?, Array<ControllerAppliance>?) -> Void) {
        self.dataFetchManagerFireBase.devicesDetails(completion: pCompletion)
    }
    
    func saveAppliance(completion pCompletion: @escaping (Error?, Appliance?) -> Void, appliance pAppliance :Appliance) {
        self.dataFetchManagerFireBase.saveAppliance(completion: pCompletion, appliance: pAppliance)
    }
    
    func searchAppliance(completion pCompletion: @escaping (Error?, Array<Appliance>?,Array<String>?) -> Void, room pRoom :Room?, includeOnOnly pIncludeOnOnly :Bool) {
        self.dataFetchManagerFireBase.searchAppliance(completion: pCompletion, room: pRoom, includeOnOnly: pIncludeOnOnly)
    }
    
    func updateAppliancePowerState(completion pCompletion: @escaping (Error?) -> Void, appliance pAppliance :Appliance, powerState pPowerState :Bool) {
        self.dataFetchManagerFireBase.updateAppliancePowerState(completion: pCompletion, appliance: pAppliance, powerState: pPowerState)
    }
    
    func updateApplianceDimmableValue(completion pCompletion: @escaping (Error?) -> Void, appliance pAppliance :Appliance, dimValue pDimValue :Int) {
        self.dataFetchManagerFireBase.updateApplianceDimmableValue(completion: pCompletion, appliance: pAppliance, dimValue: pDimValue)
    }
    
    func updateAppliance(completion pCompletion: @escaping (Error?) -> Void, appliance pAppliance :Appliance, property1 pProperty1 :Int, property2 pProperty2 :Int, property3 pProperty3 :Int, glowPatternValue pGlowPatternValue :Int) {
        self.dataFetchManagerFireBase.updateAppliance(completion: pCompletion, appliance: pAppliance, property1: pProperty1, property2: pProperty2, property3: pProperty3, glowPatternValue: pGlowPatternValue)
    }
    
    func updateDevice(completion pCompletion: @escaping (Error?) -> Void, deviceId: String) {
        self.dataFetchManagerFireBase.updateDevice(completion: pCompletion, deviceId: deviceId)
    }
    
    
    func updateDeviceDimabble(completion pCompletion: @escaping (Error?) -> Void, deviceId: String, dimValue:Int) {
        self.dataFetchManagerFireBase.updateDeviceDimabble(completion: pCompletion, deviceId: deviceId, dimValue: dimValue)
    }
    
    func deleteAppliance(completion pCompletion: @escaping (Error?, Appliance?) -> Void, appliance pAppliance :Appliance) {
        self.dataFetchManagerFireBase.deleteAppliance(completion: pCompletion, appliance: pAppliance)
    }
    
    func searchCurtain(completion pCompletion: @escaping (Error?, Array<Curtain>?) -> Void, room pRoom :Room?) {
        self.dataFetchManagerFireBase.searchCurtain(completion: pCompletion, room: pRoom)
    }
    
    func updateCurtainMotionState(completion pCompletion: @escaping (Error?) -> Void, curtain pCurtain :Curtain, motionState pMotionState :Curtain.MotionState) {
        self.dataFetchManagerFireBase.updateCurtainMotionState(completion: pCompletion, curtain: pCurtain, motionState: pMotionState)
    }
    
    
    func updateCurtainDimmableValue(completion pCompletion: @escaping (Error?) -> Void, curtain pCurtain :Curtain, dimValue pDimValue :Int) {
        self.dataFetchManagerFireBase.updateCurtainDimmableValue(completion: pCompletion, curtain: pCurtain, dimValue: pDimValue)
    }
    
    
    func searchRemote(completion pCompletion: @escaping (Error?, Array<Remote>?) -> Void, room pRoom :Room?) {
        self.dataFetchManagerFireBase.searchRemote(completion: pCompletion, room: pRoom)
    }
    
    
    func remoteDetails(completion pCompletion: @escaping (Error?, Remote?) -> Void, remote pRemote :Remote) {
        self.dataFetchManagerFireBase.remoteDetails(completion: pCompletion, remote: pRemote)
    }
    
    
    func updateRemoteKey(completion pCompletion: @escaping (Error?) -> Void, remote pRemote :Remote, remoteKey pRemoteKey :RemoteKey) {
        self.dataFetchManagerFireBase.updateRemoteKey(completion: pCompletion, remote: pRemote, remoteKey: pRemoteKey)
    }
    
    
    func clickRemoteKey(completion pCompletion: @escaping (Error?) -> Void, remote pRemote :Remote, remoteKey pRemoteKey :RemoteKey) {
        self.dataFetchManagerFireBase.clickRemoteKey(completion: pCompletion, remote: pRemote, remoteKey: pRemoteKey)
    }
    
    
    func recordRemoteKey(completion pCompletion: @escaping (Error?) -> Void, remote pRemote :Remote, remoteKey pRemoteKey :RemoteKey) {
        self.dataFetchManagerFireBase.recordRemoteKey(completion: pCompletion, remote: pRemote, remoteKey: pRemoteKey)
    }
    
    
    // MARK:- Sensor
    
    func searchSensor(completion pCompletion: @escaping (Error?, Array<Sensor>?) -> Void, room pRoom :Room?) {
        self.dataFetchManagerFireBase.searchSensor(completion: pCompletion, room: pRoom)
    }
    
    func sensorDetails(completion pCompletion: @escaping (Error?, Sensor?) -> Void, sensor pSensor :Sensor) {
        self.dataFetchManagerFireBase.sensorDetails(completion: pCompletion, sensor: pSensor)
    }
    
    func updateSensorMotionState(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor, motionState pMotionState :Sensor.MotionState) {
        self.dataFetchManagerFireBase.updateSensorMotionState(completion: pCompletion, sensor: pSensor, motionState: pMotionState)
    }
    
    func updateSensorOccupancyState(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor, occupancyState pOccupancyState :Sensor.OccupancyState) {
        self.dataFetchManagerFireBase.updateSensorOccupancyState(completion: pCompletion, sensor: pSensor, occupancyState: pOccupancyState)
    }
    func updateSensorbtncounterReset(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor) {
        self.dataFetchManagerFireBase.updateSensorBtnResetCounter(completion: pCompletion, sensor: pSensor)
    }
    
    func updateSensorbtnFixNow(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor) {
        self.dataFetchManagerFireBase.updateSensorBrnFixNow(completion: pCompletion, sensor: pSensor)
    }
    
    func updateSensor(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor) {
        self.dataFetchManagerFireBase.updateSensorBrnFixNow(completion: pCompletion, sensor: pSensor)
    }
    
    func updateSensorSync(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor) {
        self.dataFetchManagerFireBase.updateSensorSync(completion: pCompletion, sensor: pSensor)
    }
    
    func updateSensorThreshold(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor, smokeThreshold pSmokeThreshold :Int, coThreshold pCoThreshold :Int, lpgThreshold pLpgThreshold :Int) {
        self.dataFetchManagerFireBase.updateSensorThreshold(completion: pCompletion, sensor: pSensor, smokeThreshold: pSmokeThreshold, coThreshold: pCoThreshold, lpgThreshold: pLpgThreshold)
    }
    
    func updateSensorMotionLightState(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor, motionLightState pMotionLightState :Sensor.LightState, isSettings pIsSettings :Bool) {
        self.dataFetchManagerFireBase.updateSensorMotionLightState(completion: pCompletion, sensor: pSensor, lightState: pMotionLightState, isSettings: pIsSettings)
    }
    
    func updateSensorMotionLightTimeout(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor, motionLightTimeout pMotionLightTimeout :Int) {
        self.dataFetchManagerFireBase.updateSensorMotionLightTimeout(completion: pCompletion, sensor: pSensor, motionLightTimeout: pMotionLightTimeout)
    }
    
    func updateSensorMotionLightIntensity(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor, motionLightIntensity pMotionLightIntensity :Int) {
        self.dataFetchManagerFireBase.updateSensorMotionLightIntensity(completion: pCompletion, sensor: pSensor, motionLightIntensity: pMotionLightIntensity)
    }
    
    func updateSensorSirenState(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor, sirenState pSirenState :Sensor.SirenState) {
        self.dataFetchManagerFireBase.updateSensorSirenState(completion: pCompletion, sensor: pSensor, sirenState: pSirenState)
    }
    
    func updateSensorSirenSettingsState(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor, sirenState pSirenState :Sensor.SirenState) {
        self.dataFetchManagerFireBase.updateSensorSirenSettingsState(completion: pCompletion, sensor: pSensor, sirenState: pSirenState)
    }
    
    func updateSensorSirenTimeout(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor, sirenTimeout pSirenTimeout :Int) {
        self.dataFetchManagerFireBase.updateSensorSirenTimeout(completion: pCompletion, sensor: pSensor, sirenTimeout: pSirenTimeout)
    }
    
    func updateSensorNotificationSettings(completion pCompletion: @escaping (Error?) -> Void, sensor pSensor :Sensor, fcmToken pFcmToken :String?, notificationSubscriptionState pNotificationSubscriptionState :Bool, notificationSoundState pNotificationSoundState :Bool) {
        self.dataFetchManagerFireBase.updateSensorNotificationSettings(completion: pCompletion, sensor: pSensor, fcmToken: pFcmToken, notificationSubscriptionState: pNotificationSubscriptionState, notificationSoundState: pNotificationSoundState)
    }
    
    
    // MARK:- Schedule
    
    func searchSchedule(completion pCompletion: @escaping (Error?, Array<Schedule>?) -> Void) {
        self.dataFetchManagerFireBase.searchSchedule(completion: pCompletion)
    }
    
    func scheduleDetails(completion pCompletion: @escaping (Error?, Schedule?) -> Void, schedule pSchedule :Schedule) {
        self.dataFetchManagerFireBase.scheduleDetails(completion: pCompletion, schedule: pSchedule)
    }
    
    func deleteSchedule(completion pCompletion: @escaping (Error?, Schedule?) -> Void, schedule pSchedule :Schedule) {
        self.dataFetchManagerFireBase.deleteSchedule(completion: pCompletion, schedule: pSchedule)
    }
    
    func updateSchedulePowerState(completion pCompletion: @escaping (Error?) -> Void, schedule pSchedule :Schedule, powerState pPowerState :Bool) {
        self.dataFetchManagerFireBase.updateSchedulePowerState(completion: pCompletion, schedule: pSchedule, powerState: pPowerState)
    }
    
    func searchLock(completion pCompletion: @escaping (Error?, Array<Lock>?) -> Void) {
        self.dataFetchManagerFireBase.searchLock(completion: pCompletion)
    }
    
    func checkToShowApplianceDimmable(completion pCompletion: @escaping (Bool?) -> Void, room pRoom :Room?) {
        self.dataFetchManagerFireBase.checkToShowApplianceDimmable(completion: pCompletion, room: pRoom)
    }
    
    func updateLockState(completion pCompletion: @escaping (Error?) -> Void, lock pLock :Lock) {
        self.dataFetchManagerFireBase.updateLockState(completion: pCompletion, lock: pLock)
    }
    
    func searchAppNotification(completion pCompletion: @escaping (Error?, Array<AppNotification>?) -> Void, appNotificationType pAppNotificationType :AppNotification.AppNotificationType, hardwareId pHardwareId :String?, pageNumber pPageNumber :Int) {
        self.dataFetchManagerFireBase.searchAppNotification(completion: pCompletion, appNotificationType: pAppNotificationType, hardwareId: pHardwareId, pageNumber: pPageNumber)
    }
    
    func saveAppNotificationSettings(completion pCompletion: @escaping (Error?, AppNotificationSettings?) -> Void, appNotificationSettings pAppNotificationSettings :AppNotificationSettings) {
        self.dataFetchManagerFireBase.saveAppNotificationSettings(completion: pCompletion, appNotificationSettings: pAppNotificationSettings)
    }
    
    func appNotificationSettingsDetails(completion pCompletion: @escaping (Error?, AppNotificationSettings?) -> Void, notificationToken pNotificationToken :String) {
        self.dataFetchManagerFireBase.appNotificationSettingsDetails(completion: pCompletion, notificationToken: pNotificationToken)
    }
    
    func saveMood(completion pCompletion: @escaping (Error?, Mood?) -> Void, mood pMood :Mood) {
        self.dataFetchManagerFireBase.saveMood(completion: pCompletion, mood: pMood)
    }
    
    func searchMood(completion pCompletion: @escaping (Error?, Array<Mood>?) -> Void, room pRoom :Room?) {
        self.dataFetchManagerFireBase.searchMood(completion: pCompletion, room: pRoom)
    }
    
    func moodDetails(completion pCompletion: @escaping (Error?, Mood?) -> Void, mood pMood :Mood) {
        self.dataFetchManagerFireBase.moodDetails(completion: pCompletion, mood: pMood)
    }
    
    func updateMoodPowerState(completion pCompletion: @escaping (Error?) -> Void, mood pMood :Mood, powerState pPowerState :Bool) {
        self.dataFetchManagerFireBase.updateMoodPowerState(completion: pCompletion, mood: pMood, powerState: pPowerState)
    }
    
    func deleteMood(completion pCompletion: @escaping (Error?, Mood?) -> Void, mood pMood :Mood) {
        self.dataFetchManagerFireBase.deleteMood(completion: pCompletion, mood: pMood)
    }
    
    func saveRoom(completion pCompletion: @escaping (Error?, Room?) -> Void, room pRoom :Room) {
        self.dataFetchManagerFireBase.saveRoom(completion: pCompletion, room: pRoom)
    }
    
    func searchRoom(completion pCompletion: @escaping (Error?, Array<Room>?) -> Void) {
        self.dataFetchManagerFireBase.searchRoom(completion: pCompletion)
    }
    
    func saveSchedule(completion pCompletion: @escaping (Error?, Schedule?) -> Void, schedule pSchedule :Schedule) {
        self.dataFetchManagerFireBase.saveSchedule(completion: pCompletion, schedule: pSchedule)
    }
    
    func coreList(completion pCompletion: @escaping (Error?, [Core]?) -> Void) {
        self.dataFetchManagerFireBase.coreList(completion: pCompletion)
    }
    
    func updateCore(completion pCompletion: @escaping (Error?) -> Void, pCore core :Core) {
        self.dataFetchManagerFireBase.updateCoreState(completion: pCompletion, pcore: core)
        self.dataFetchManagerFireBase.updateCoreData(completion: pCompletion, pcore: core)
    }
    
    #if APP_WIFINITY
    func configureDevice(completion pCompletion: @escaping (Error?, Device?) -> Void, device pDevice :Device) {
        self.dataFetchManagerFireBase.configureDevice(completion: pCompletion, device: pDevice)
    }
    #endif
    
    #if APP_WIFINITY
    func saveDevice(completion pCompletion: @escaping (Error?, Device?) -> Void, device pDevice :Device) {
        self.dataFetchManagerFireBase.saveDevice(completion: pCompletion, device: pDevice)
    }
    #endif
    
    func searchDevice(completion pCompletion: @escaping (Error?, Array<Device>?) -> Void, room pRoom :Room?, hardwareTypes pHardwareTypeArray :Array<Device.HardwareType>?) {
        self.dataFetchManagerFireBase.searchDevice(completion: pCompletion, room: pRoom, hardwareTypes: pHardwareTypeArray)
    }
    
    #if APP_WIFINITY
    func deviceDetails(completion pCompletion: @escaping (Error?, Device?) -> Void, device pDevice :Device) {
        self.dataFetchManagerFireBase.deviceDetails(completion: pCompletion, device: pDevice)
    }
    #endif
    
    #if !APP_WIFINITY
    func searchTankRegulator(completion pCompletion: @escaping (Error?, Array<TankRegulator>?) -> Void) {
        self.dataFetchManagerFireBase.searchTankRegulator(completion: pCompletion)
    }
    
    func updateTankRegulatorAutoMode(completion pCompletion: @escaping (Error?) -> Void, tankRegulator pTankRegulator :TankRegulator, autoMode pAutoMode :Bool) {
        self.dataFetchManagerFireBase.updateTankRegulatorAutoMode(completion: pCompletion, tankRegulator: pTankRegulator, autoMode: pAutoMode)
    }
    
    func updateTankRegulatorMotorPowerState(completion pCompletion: @escaping (Error?) -> Void, tankRegulator pTankRegulator :TankRegulator, motorPowerState pMotorPowerState :Bool) {
        self.dataFetchManagerFireBase.updateTankRegulatorMotorPowerState(completion: pCompletion, tankRegulator: pTankRegulator, motorPowerState: pMotorPowerState)
    }
    
    func updateTankRegulatorSync(completion pCompletion: @escaping (Error?) -> Void, tankRegulator pTankRegulator :TankRegulator) {
        self.dataFetchManagerFireBase.updateTankRegulatorSync(completion: pCompletion, tankRegulator: pTankRegulator)
    }
    
    #endif
    
    
    func searchRule(completion pCompletion: @escaping (Error?, Array<Rule>?) -> Void) {
        self.dataFetchManagerFireBase.searchRule(completion: pCompletion)
    }
    
    func updateRuleState(completion pCompletion: @escaping (Error?) -> Void, rule pRule :Rule, state pState :Bool) {
        self.dataFetchManagerFireBase.updateRuleState(completion: pCompletion, rule: pRule, state: pState)
    }
    
}
