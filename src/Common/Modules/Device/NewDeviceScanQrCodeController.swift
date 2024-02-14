//
//  NewDeviceScanQrCodeController.swift
//  Wifinity
//
//  Created by Rupendra on 11/12/20.
//

import UIKit
import AVFoundation


class NewDeviceScanQrCodeController: BaseController {
    var captureSession: AVCaptureSession?
    @IBOutlet weak var videoPreviewView: UIView!
    
    @IBOutlet weak var deviceIdTextField: UITextField!
    @IBOutlet weak var deviceNameTextField: UITextField!
    
    @IBOutlet weak var rescanButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "ADD DEVICE"
        self.subTitle = "Device Details"
        
        self.deviceIdTextField.text = nil
        self.deviceNameTextField.text = nil
        self.reloadAllViews()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setup()
        
        if (self.captureSession?.isRunning == false) {
            DispatchQueue.global(qos: .background).async {
                    self.captureSession?.startRunning()
            }
               
        }
        
        self.reloadAllViews()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if (self.captureSession?.isRunning == true) {
            self.captureSession?.stopRunning()
        }
    }
    
    
    func setup() {
        self.deviceNameTextField.delegate = self
        
        if self.captureSession == nil {
            self.deviceIdTextField.text = nil
            if UtilityManager.isSimulator {
                self.deviceIdTextField.text = "C0123456789"
            }
            
            let aCaptureSession = AVCaptureSession()
            
            if let aCaptureDevice = AVCaptureDevice.default(for: .video) {
                if let aCaptureDeviceInput = try? AVCaptureDeviceInput(device: aCaptureDevice)
                   , aCaptureSession.canAddInput(aCaptureDeviceInput) {
                    aCaptureSession.addInput(aCaptureDeviceInput)
                }
                
                let aCaptureMetadataOutput = AVCaptureMetadataOutput()
                if aCaptureSession.canAddOutput(aCaptureMetadataOutput) {
                    aCaptureSession.addOutput(aCaptureMetadataOutput)
                    aCaptureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                    aCaptureMetadataOutput.metadataObjectTypes = [.qr]
                }
            }
            
            let aVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: aCaptureSession)
            aVideoPreviewLayer.frame = self.videoPreviewView.layer.bounds
            aVideoPreviewLayer.videoGravity = .resizeAspectFill
            self.videoPreviewView.layer.insertSublayer(aVideoPreviewLayer, at: 0)
            
            self.captureSession = aCaptureSession
        }
    }
    
    
    func reloadAllViews() {
        if (self.deviceIdTextField.text?.count ?? 0) <= 0 {
            self.rescanButton.isEnabled = false
        } else {
            self.rescanButton.isEnabled = true
        }
    }
    
    
    func selectDevice() {
        do {
            let anId :String? = self.deviceIdTextField.text
            if (anId?.count ?? 0) <= 0 {
                throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Please provide device ID by scanning QR code."])
            }
            
            var anIsIdSupported = false
            let aSupportedIdPrefixArray = [
                "CT01", "CT02", "CT03", "CT04", "CT05", "CT06", "CT07", "CT08", "CT09",
                "C01","C02","C03","C04","C05","C06","C07","C08","C09",
                "CL",
                "S00", "S01", "S02", "S03", "S04",
                "S10","S11",
                "L",
                "G",
                "M00", "M01",
                "I",
                "CS01", "CS02","CS03","CS04","CS05","CS06","CS07","CS08","CS09",
                "P00",
                "F01","F02",
                "V00",
               // "S20", // air qulity
            ]
            for aSupportedIdPrefix in aSupportedIdPrefixArray {
                if anId?.starts(with: aSupportedIdPrefix) == true {
                    anIsIdSupported = true
                    break
                }
            }
            if anIsIdSupported == false {
                throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Given device ID is currently not supported."])
            }
            
            let aTitle :String? = self.deviceNameTextField.text
            if (aTitle?.count ?? 0) <= 0 {
                throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Please provide device title."])
            }
            
            let aDevice = Device()
            aDevice.id = anId
            aDevice.title = aTitle
            
            DataFetchManager.shared.deviceDetails(completion: { (pError, pDevice) in
                if (pDevice?.firebaseUserId?.count ?? 0) > 0 && pDevice?.firebaseUserId != DataFetchManager.shared.loggedInUser?.firebaseUserId {
                    PopupManager.shared.displayError(message: "Device is already registered with other user.", description: nil)
                } else {
                    self.gotoNewDeviceConnectDeviceHotspot(device: aDevice)
                }
            }, device: aDevice)
        } catch {
            PopupManager.shared.displayError(message: error.localizedDescription, description: nil)
        }
    }
    
    
    func gotoNewDeviceConnectDeviceHotspot(device pDevice :Device) {
        RoutingManager.shared.gotoNewDeviceConnectDeviceHotspot(controller: self, selectedDevice: pDevice)
    }

}


extension NewDeviceScanQrCodeController {
    
    @IBAction func didSelectRescanButton(_ pSender: UIButton) {
        self.deviceIdTextField.text = nil
        if (self.captureSession?.isRunning == false) {
            DispatchQueue.main.async {
                self.captureSession?.startRunning()
            }
        }
        self.reloadAllViews()
    }
    
    @IBAction func didSelectContinueButton(_ pSender: UIButton) {
        self.selectDevice()
    }
    
}


extension NewDeviceScanQrCodeController :UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}


extension NewDeviceScanQrCodeController :AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        self.captureSession?.stopRunning()
        
        if let aString = (metadataObjects.first as? AVMetadataMachineReadableCodeObject)?.stringValue {
            self.deviceIdTextField.text = aString
            self.reloadAllViews()
        }
    }
    
}
