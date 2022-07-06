//
//  OfferZoneViewController.swift
//  Wifinity
//
//  Created by akshay patil on 06/05/22.
//


import UIKit
import Kingfisher

class OfferData {
    var topic: String?
    var message: String?
    var product: String?
    var image: String?
    var timestamp: String?
    var expiryDate: String?
    var offerImage : UIImage?

}

class OfferZoneViewController: BaseController {
    
    @IBOutlet var offerTableView: UITableView!
    
    var offerDataArray = [OfferData]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        // Do any additional setup after loading the view.
    }
    @IBAction func backButtonClicked(_ sender: Any) {
            self.navigationController?.popViewController(animated: true)
    }
}

extension OfferZoneViewController {
    
    func setupUI() {
        setUpTopBar()
        getOffersApiCall()
        setupofferTableView()
    }
    
    func setUpTopBar() {
        self.title = "Offer zone"
        self.subTitle = nil
    }
    
    func getOffersApiCall() {
        let session = URLSession.shared
        let url = URL(string: "http://marketing.homeonetechnologies.in/offers")
        var request = URLRequest(url: url! as URL)
   
        request.httpMethod = "GET"
        
        let dataTask = session.dataTask(with: request as URLRequest) { (data:Data?, response:URLResponse?, error:Error?) -> Void in do{
            if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any] {
                for (offerKey, _) in jsonResult {
                    let obj = jsonResult[offerKey] as? [String:Any]
                    
                    let offerObj = OfferData()
                    offerObj.topic = obj?["topic"] as? String
                    offerObj.message = obj?["message"] as? String
                    offerObj.product = obj?["product"] as? String
                    offerObj.image = obj?["image"] as? String
                    offerObj.timestamp = obj?["timestamp"] as? String
                    offerObj.expiryDate = obj?["expiryDate"] as? String
//
//                    "topic": "The smart way to light up your spaces",
//                    "message": "Check out the offer!",
//                    "product": "P0073",
//                    "image": "http://34.68.55.33:3007/1651219185837.30",
//                    "timestamp": "1651219185837",
//                    "expiryDate": "2022-05-04",
                    
                    self.offerDataArray.append(offerObj)
                }
                DispatchQueue.main.sync {
                    self.reloadData()
                }
                
            } else{
                print("No Parsing Correctly")
            }
            
        }catch let error as NSError{
            print(error.localizedDescription)
        }
            print("done, error: \(error)")
        }
        dataTask.resume()
    }
    
    func setupofferTableView() {
        offerTableView.backgroundColor = .clear
        offerTableView.separatorStyle = .none
        offerTableView.bounces = false
        offerTableView.showsVerticalScrollIndicator = false
        offerTableView.delegate = self
        offerTableView.dataSource = self
       // offerTableView.rowHeight = UITableView.automaticDimension
        offerTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
        offerTableView.register(UINib(nibName: "OffersTableViewCell", bundle: nil), forCellReuseIdentifier: "offerTableViewCell")
    }
}
extension OfferZoneViewController {
    func reloadData() {
        offerTableView.reloadData()
    }
}

extension OfferZoneViewController: UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return offerDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "offerTableViewCell",
            for: indexPath
        ) as! OffersTableViewCell
        cell.offerImage.contentMode = .scaleToFill
        cell.configureCell(offerData: offerDataArray[indexPath.row])
        cell.offerImage.contentMode = .scaleToFill
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let offerData = offerDataArray[indexPath.row]
        RoutingManager.shared.goToOfferDetailViewController(controller: self, selectedOffer: offerData)
        
        
    }
}
