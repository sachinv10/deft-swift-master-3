//
//  ProfileViewController.swift
//  Wifinity
//
//  Created by Apple on 28/04/23.
//

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseAuth
class ProfileViewController: BaseController, UITextFieldDelegate {
var userProfile = UserVerify()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
       subTitle = ""
        uiSetup()
        // Do any additional setup after loading the view.
    }
    func uiSetup() {
        txtfldName.text = userProfile.userName
        txtfldEmaillbl.text = userProfile.email
        txtfldMobileNumber.text = userProfile.phoneNumber
        txtfldAddress.text = userProfile.flatNumber
        txtfldBirthDate.text = userProfile.dob
        
        backgroundView.layer.cornerRadius = 70
        backgroundView.layer.masksToBounds = true
        profileImage.layer.cornerRadius = (profileImage.frame.height / 2)
        profileImage.layer.masksToBounds = true
        profileImage.layer.borderWidth = 1
        txtfldName.isEnabled = false
        txtfldName.alpha = 0.2
        txtfldEmaillbl.isEnabled = false
        txtfldEmaillbl.alpha = 0.2
         txtfldMobileNumber.isEnabled = false
        txtfldMobileNumber.alpha = 0.2
        txtfldAddress.isEnabled = false
        txtfldAddress.alpha = 0.2
        
        txtfldBirthDate.isEnabled = false
        txtfldBirthDate.alpha = 0.2
        
        txtfldAddress.delegate = self
        txtfldName.delegate = self
        txtfldMobileNumber.delegate = self
        txtfldBirthDate.delegate = self
        datePicker.frame = CGRect(x: 170, y: -07, width: 80, height: 50)
        datePicker.datePickerMode = .date
        datePicker.accessibilityLabel = "Select date"
         let calendar = Calendar.current
        let maxDate = calendar.date(byAdding: .year, value: 60, to: Date())
        let minDate = calendar.date(byAdding: .year, value: -100, to: Date())
        datePicker.maximumDate = maxDate
        datePicker.minimumDate = minDate
        txtfldBirthDate.addSubview(datePicker)
      //  txtfldBirthDate.inputView = datePicker
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }
    @objc func dateChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "dd/MM/yyyy"
        txtfldBirthDate.text = dateFormatter.string(from: sender.date)
        
        
     }
 

    let datePicker = UIDatePicker()
    //MARK: - OUTLATE
    @IBOutlet weak var backgroundView: UIView!
    
   
    @IBOutlet weak var dataOfbirthlbl: UILabel!
    @IBOutlet weak var txtfldName: UITextField!
    @IBOutlet weak var lbleditName: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var txtfldEmaillbl: UITextField!
    
    @IBOutlet weak var lblDateOfBirth: UIButton!
    @IBOutlet weak var lblAddressbtn: UIButton!
    @IBOutlet weak var txtfldBirthDate: UITextField!
    @IBOutlet weak var txtfldAddress: UITextField!
    @IBOutlet weak var txtfldMobileNumber: UITextField!
    @IBOutlet weak var lblVerify: UIButton!
    // MARK: - Action Method
    var database = Database.database().reference()
    @IBAction func didtappedEditNameButton(_ sender: Any) {
        if txtfldName.isEnabled == false{
            txtfldName.isEnabled = true
            txtfldName.alpha = 1
            lbleditName.setTitle("Save", for: .normal)
        }else{
            txtfldName.isEnabled = false
            txtfldName.alpha = 0.2
            lbleditName.setTitle("Edit", for: .normal)
            //save name
            let name = txtfldName.text
           guard let uid = Auth.auth().currentUser?.uid else{return}
            database.child("standaloneUserDetails").child(uid).updateChildValues(["userName":"\(name ?? "")"], withCompletionBlock:  {error,data in
                if error == nil{
                    DispatchQueue.main.async {
                        PopupManager.shared.displayError(message: "Update Successful", description: error?.localizedDescription)
                    }
                }else{
                    DispatchQueue.main.async {
                        PopupManager.shared.displayError(message: "", description: error?.localizedDescription)
                    }
                }
            })
        }
    }
    
    @IBAction func didtappedMobileNumber(_ sender: Any) {
        if txtfldMobileNumber.isEnabled == false{
            txtfldMobileNumber.isEnabled = true
            txtfldMobileNumber.alpha = 1
          lblVerify.setTitle("Verify", for: .normal)
  
        }else{
            guard let num = txtfldMobileNumber.text else{return}
            guard let url = URL(string: "https://2factor.in/API/V1/eb622b0c-fe8b-11eb-a13b-0200cd936042/SMS/+91\( num)/AUTOGEN/AprovedTemplet")else{return}
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                guard let data = data else { return }
                print(String(data: data, encoding: .utf8)!)
                let datas = String(data: data, encoding: .utf8)
                guard let jsonData = datas?.data(using: .utf8) else {return}
                do {
                    if let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        print(jsonDict)
                        self.detail = jsonDict["Details"] as? String ?? ""
                    }
                } catch {
                   
                }
            }
            task.resume()
            enterOtp()
            txtfldMobileNumber.isEnabled = false
            txtfldMobileNumber.alpha = 0.2
            lblVerify.setTitle("Edit", for: .normal)
        }
    }
  var detail = ""
    @IBAction func didTappedAddressbtn(_ sender: Any) {
        if txtfldAddress.isEnabled == false{
            txtfldAddress.isEnabled = true
            txtfldAddress.alpha = 1
            lblAddressbtn.setTitle("Save", for: .normal)
        }else{
            txtfldAddress.isEnabled = false
            txtfldAddress.alpha = 0.2
            lblAddressbtn.setTitle("Edit", for: .normal)
            //save name
            let name = txtfldAddress.text
           guard let uid = Auth.auth().currentUser?.uid else{return}
            database.child("standaloneUserDetails").child(uid).updateChildValues(["flatNumber":"\(name ?? "")"], withCompletionBlock:  {error,data in
                if error == nil{
                    DispatchQueue.main.async {
                        PopupManager.shared.displayError(message: "Update Successful", description: error?.localizedDescription)
                    }
                    
                }else{
                    DispatchQueue.main.async {
                        PopupManager.shared.displayError(message: "", description: error?.localizedDescription)
                    }
                }
            })
        }
    }
    @IBAction func didtappedDateofBithbtn(_ sender: Any) {
        dateofBirth()
    }
    func dateofBirth(){
        if txtfldBirthDate.isEnabled == false{
            txtfldBirthDate.isEnabled = true
            txtfldBirthDate.alpha = 1
            lblDateOfBirth.setTitle("Save", for: .normal)
        }else{
            txtfldBirthDate.isEnabled = false
            txtfldBirthDate.alpha = 0.2
            lblDateOfBirth.setTitle("Edit", for: .normal)
            //save name
            if let date = txtfldBirthDate.text{
                guard let uid = Auth.auth().currentUser?.uid else{return}
                database.child("standaloneUserDetails").child(uid).updateChildValues(["dob":"\(date)"], withCompletionBlock:  {error,data in
                    if error == nil{
                        DispatchQueue.main.async {
                            PopupManager.shared.displayError(message: "Update Successful", description: error?.localizedDescription)
                        }
                    }else{
                        DispatchQueue.main.async {
                            PopupManager.shared.displayError(message: "", description: error?.localizedDescription)
                        }
                    }
                })
            }
        }
    }
    @IBAction func didtappedChangePassword(_ sender: Any) {
        RoutingManager.shared.gotoChangePassword(controller: self, user: userProfile)
    }
    var deleteView = UIView()
    var lablehead = UILabel()
    var myTextField = UITextField()
    var btnAthontication = UIButton()
    var btnCancel = UIButton()
    
    func enterOtp() {
        self.myTextField.delegate = self
 
        deleteView.isHidden = false
        deleteView.frame = CGRect.init(x: backgroundView.frame.width / 20, y: backgroundView.frame.height / 2, width: backgroundView.frame.width / 1.11, height: 200)
        deleteView.backgroundColor = UIColor.white
       
        lablehead.frame = CGRect(x: 20, y: 0, width: deleteView.frame.width - 20, height: 50)
        lablehead.text = "Enter OTP"
        lablehead.textColor = UIColor.black
        deleteView.addSubview(lablehead)
 
        myTextField.frame = CGRect(x: 15, y: 50, width: deleteView.frame.width - 30, height: 50)
        myTextField.placeholder = "Enter OTP"
      //  myTextField.text = UserDefaults.standard.value(forKey: "emailAddress") as? String
        myTextField.layer.cornerRadius = 15.0
        myTextField.layer.borderWidth = 1.0
        myTextField.layer.borderColor = UIColor.gray.cgColor
        myTextField.clipsToBounds = true
        myTextField.textColor = UIColor.blue
        myTextField.textAlignment = .center
        deleteView.addSubview(myTextField)
        
        btnAthontication.setTitle("Authentication", for: .normal)
        btnAthontication.setTitleColor(UIColor.black, for: .normal)
        btnAthontication.frame = CGRect(x: 30, y: 125, width: 130, height: 50)
        btnAthontication.addTarget(self, action: #selector(pressedmenu), for: .touchUpInside)
        btnAthontication.backgroundColor = UIColor.gray
        btnAthontication.layer.cornerRadius = 14
        btnAthontication.layer.borderWidth = 1
        deleteView.addSubview(btnAthontication)

        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.setTitleColor(UIColor.black, for: .normal)
        btnCancel.frame = CGRect(x: 220, y: 125, width: 130, height: 50)
        btnCancel.addTarget(self, action: #selector(pressedCancel), for: .touchUpInside)
        btnCancel.backgroundColor = UIColor.gray
        btnCancel.layer.cornerRadius = 15
        btnCancel.layer.borderWidth = 1
        deleteView.addSubview(btnCancel)

        self.backgroundView.addSubview(deleteView)

        if deleteView.isHidden{
            deleteView.isHidden = true
        }else{
            deleteView.isHidden = false
        }
    }
    @objc func pressedmenu() {
        deleteView.isHidden = true

        if let otp = myTextField.text{
            let url = URL(string: "https://2factor.in/API/V1/eb622b0c-fe8b-11eb-a13b-0200cd936042/SMS/VERIFY/\(detail)/\(otp)")!
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                guard let data = data else { return }
                print(String(data: data, encoding: .utf8)!)
               let datastring = String(data: data, encoding: .utf8)!
                guard let jsonData = datastring.data(using: .utf8) else {return}
                do{
                    if let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        print(jsonDict)
                        if "Success" == jsonDict["Status"] as? String ?? ""{
                            DispatchQueue.main.async {
                                PopupManager.shared.displayError(message: "Mobile number verified successfully", description: "")
                            }
                        }
                    }
                }catch{
                    
                }
            }
            task.resume()
          //  self.deletecontroller(appliance: controllerApplince!)
        }else{
            let refreshAlert = UIAlertController(title: "Error", message: "Incorrect OTP", preferredStyle: UIAlertController.Style.alert)
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                  print("Handle Ok logic here")
            }))
            present(refreshAlert, animated: true, completion: nil)
        }
    }
    @objc func pressedCancel() {
        deleteView.isHidden = true
    }
    func textFieldShouldReturn(_ pTextField: UITextField) -> Bool {
         if pTextField.isEqual(self.myTextField) {
            self.view.endEditing(true)
        }
            self.view.endEditing(true)
        dateofBirth()
        return true
    }
}
