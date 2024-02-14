//
//  CreateNewAddressViewController.swift
//  Wifinity
//
//  Created by Apple on 24/11/23.
//

import UIKit
import Foundation

class CreateNewAddressViewController: BaseController {
// MARK: - outlate
    @IBOutlet weak var lblName: UITextField!
    
    @IBOutlet weak var lblEmailtxt: UITextField!
    
    @IBOutlet weak var txtMobileNo: UITextField!
    
    @IBOutlet weak var txtfldAddress1: UITextField!
    
    @IBOutlet weak var txtfldAddress2: UITextField!
    @IBOutlet weak var txtfldPincode: UITextField!
    @IBOutlet weak var txtfldState: UITextField!
    @IBOutlet weak var txtfldCity: UITextField!
    
    @IBOutlet weak var lblTotalAmount: UILabel!
    @IBOutlet weak var lblProductCount: UILabel!
    var orderList: [cartData]? = [cartData]()
    var orderAddress : address?
    var orderAddresss = address()
    var userProfile: UserVerify?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Buy Product"
        self.subTitle = nil
        if orderAddress == nil{
            print("orderAddress nil")
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func reloadAllData() {
        txtfldAddress1.delegate = self
        txtfldAddress2.delegate = self
        txtfldPincode.delegate = self
        txtfldState.delegate = self
        txtfldCity.delegate = self
       if orderAddress != nil{
           txtfldAddress1.text = orderAddress?.flat
           txtfldAddress2.text = orderAddress?.society
           txtfldPincode.text = orderAddress?.pincode
           txtfldState.text = orderAddress?.state
           txtfldCity.text = orderAddress?.city
       } 
      
        DataFetchManager.shared.verifyMobilenumber(complition: { [self](erro , puser) in
            lblName.text = puser?.userName
            lblEmailtxt.text = puser?.email
            txtMobileNo.text = puser?.phoneNumber
            self.lblEmailtxt.isEnabled = false
            self.txtMobileNo.isEnabled = false
            self.userProfile = puser
        })
        if orderList?.count ?? 0 > 0{
            dataValueation()
        }
    }
    func dataValueation(){
        var productCnt = 0
        var productTotal = 0
        for items in orderList!{
            productCnt += items.Quantity ?? 0
            productTotal += (Int(items.price ?? "0") ?? 0) * (items.Quantity ?? 0)
        }
        lblProductCount.text =  "Total Product To Be Delivered : \(String(productCnt))"
        lblTotalAmount.text = "Total Amount To Be Paid :  \(String(productTotal))"
    }
    @IBAction func didtappedPlaceOrder(_ sender: Any) {
        do{
            if (orderAddress == nil){
                addresAssign()
            }
            guard let add = orderAddress, ((orderAddress?.flat?.count ?? 0) > 0), ((orderAddress?.society?.count ?? 0) > 0), ((orderAddress?.city?.count ?? 0) > 0), ((orderAddress?.pincode?.count ?? 0) > 0), ((orderAddress?.state?.count ?? 0) > 0) else{
                throw NSError(domain: "com", code: 1, userInfo: [NSLocalizedDescriptionKey : "Please provide All Address."])
            }
      
        DataFetchManager.shared.orderPlace(complition: { error in
           if error == nil{
               self.reloaddata()
            }
        }, OrderList: orderList, address: orderAddress, user: userProfile)
        }catch {
            PopupManager.shared.displayError(message: error.localizedDescription, description: nil)
        }
    }
    func addresAssign(){
        orderAddresss.flat = txtfldAddress1.text ?? nil
        orderAddresss.society = txtfldAddress2.text ?? nil
        orderAddresss.pincode = txtfldPincode.text ?? nil
        orderAddresss.state = txtfldState.text ?? nil
        orderAddresss.city = txtfldCity.text ?? nil
        orderAddress = orderAddresss
        DataFetchManager.shared.saveNewAddress(complition: { error in
           if error == nil{
             }
        }, address: orderAddress)
    }
    func reloaddata(){
        RoutingManager.shared.goToPreviousScreen(self)
        RoutingManager.shared.gotoProductOrderList(controller: self)
    }
}
extension CreateNewAddressViewController :UITextFieldDelegate {
    func textFieldShouldReturn(_ pTextField: UITextField) -> Bool {
        if pTextField.isEqual(self.txtfldAddress1) {
            self.txtfldAddress2.becomeFirstResponder()
        } else if pTextField.isEqual(self.txtfldAddress2) {
            self.txtfldCity.becomeFirstResponder()
        }else if pTextField.isEqual(self.txtfldCity) {
            self.txtfldState.becomeFirstResponder()
        }else if pTextField.isEqual(self.txtfldState) {
            self.txtfldPincode.becomeFirstResponder()
        }else if pTextField.isEqual(self.txtfldPincode) {
            self.view.endEditing(true)
        }
        return true
    }
        
    @objc func keyboardWillShow(sender: NSNotification) {
         self.view.frame.origin.y = -220 // Move view 150 points upward
    }

    @objc func keyboardWillHide(sender: NSNotification) {
         self.view.frame.origin.y = 0 // Move view to original position
    }
}
