//
//  ProductManualViewController.swift
//  Wifinity
//
//  Created by Apple on 08/11/22.
//

import UIKit
import PDFKit
import Firebase
import FirebaseDatabase
import FirebaseCore
import FirebaseStorage
import FirebaseAuth
import WebKit

enum ManualType{
    case ProductManual
    case TechnicalSheet
}
protocol DeveloperEntryDelegate: AnyObject {
    func textDeveloperPlatform(cell: cellproduct)
    
}
class cellproduct: UITableViewCell{
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lbldownload.setTitle("", for: .normal)
        self.backgroundColor = UIColor(named: "PrimaryLightestColor")
    }
    
    weak var delegate: DeveloperEntryDelegate?
    @IBOutlet weak var lbldownload: UIButton!
    @IBOutlet weak var lblName: UILabel!
    var url = String()
    func load(obj: String, urll: String){
          lblName.text = obj
        url = urll
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func didtappedDownload(_ sender: Any) {
        delegate?.textDeveloperPlatform(cell: self)
        print("enter in cell class")
    }
    
}
class ProductManualViewController: BaseController {
    var webView: WKWebView!
    var manualType: ManualType?
    var technicalSheet: Array<technicalSheet> =  Array<technicalSheet>()
    @IBOutlet weak var tableviewProduct: UITableView!
    var Urlpath: URL?
    let storage = Storage.storage()
    let storages = Storage.storage().reference()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Product Manual"
        subTitle = ""
        tableviewProduct.delegate = self
        tableviewProduct.dataSource = self
        view.backgroundColor = UIColor(named: "PrimaryLightestColor")

       switch manualType{
       case .TechnicalSheet:
           getTechnicalSheet()
       case .ProductManual:
           mydatabase()
       case .none:
           break
       }
     }
    var urlArray = [String]()
    func mydatabase(){
        
        Database.database().reference().child("manualStorage").observe(.childAdded, with: {DataSnapshot in
            let data = DataSnapshot.value as! Dictionary<String, Any>
            let titlename = data["title"]
            let urlname = data["url"]
            self.nameArray.append(titlename as! String)
            self.urlArray.append(urlname as! String)
            DispatchQueue.main.async {
                self.tableviewProduct.reloadData()
            }
        })
    }
    func getTechnicalSheet(){
        DataFetchManager.shared.getTechnicalSheet(completion:{ data in
            switch data{
            case .success(let data):
                self.technicalSheet = data
                self.tableviewProduct.reloadData()
            case .failure(let error):  print(error.localizedDescription)
            }
        })
    }
    func calltoPdfview(){
        DispatchQueue.main.async { [self] in
            let objdemo = PdfViewController()
            objdemo.pdfUrl = Urlpath
            present(objdemo, animated: true, completion: nil)
        }
    }
     
    func savePdf(urlString:String, fileName:String) {
                DispatchQueue.main.async {
                    let url = URL(string: urlString)
                    let pdfData = try? Data.init(contentsOf: url!)
                    let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
                    let pdfNameFromUrl = "YourAppName-\(fileName).pdf"
                    let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
                    do {
                        try pdfData?.write(to: actualPath, options: .atomic)
                        print("pdf successfully saved!")
        //file is downloaded in app data container, I can find file from x code > devices > MyApp > download Container >This container has the file
                    } catch {
                        print("Pdf could not be saved")
                    }
                }
            }
    var nameArray = [String]()
}
// MARK: - TABLE VIEW
extension ProductManualViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch manualType{
        case .ProductManual:
            return nameArray.count
        case .TechnicalSheet:
            return technicalSheet.count
        case .none:
            return 0
      
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! cellproduct
        cell.delegate = self
        cell.tag = indexPath.row
        switch manualType{
        case .ProductManual:
            let obj = nameArray[indexPath.row]
            let url = urlArray[indexPath.row]
            cell.load(obj: obj, urll: url)
        case .TechnicalSheet:
            cell.load(obj: technicalSheet[indexPath.row].productName, urll: technicalSheet[indexPath.row].downloadUrl)
        case .none:
            break
        }
       
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = indexPath.row
    }
}
//MARK: - DELEGATE AND PROTOCALL
extension ProductManualViewController: DeveloperEntryDelegate{
    func textDeveloperPlatform(cell: cellproduct) {
        print("yes inter in download btn")
        switch manualType{
        case .ProductManual:
            demodownload(index: cell.tag, url: cell.url)
        case .TechnicalSheet:
            webViewSetUp(url: cell.url)
        case .none:
            break
        }
    }

    func demodownload(index: Int, url: String)  {
      var url = URL(string: url)
 
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        let downloadtask = session.downloadTask(with: url!)
        downloadtask.resume()
    }
}
extension ProductManualViewController: URLSessionDownloadDelegate{
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("downloaded location=\(location)")
        guard let url = downloadTask.originalRequest?.url else{ return }
        let docpath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let destinationpath = docpath.appendingPathComponent(url.lastPathComponent)
       
        print("lastpath=\(destinationpath)")
        do{
            let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] as String
                let url = URL(fileURLWithPath: path)

                let filePath = url.appendingPathComponent(destinationpath.lastPathComponent).path
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: filePath) {
                    print("FILE AVAILABLE")
                    Urlpath = destinationpath
                    self.calltoPdfview()
                } else {
                    print("FILE NOT AVAILABLE")
                    try FileManager.default.copyItem(at: location, to: destinationpath)
                    Urlpath = destinationpath
                    self.calltoPdfview()
                }

        }catch let error{
            print("error=\(error)")
         
        }
    }
    
    
}
extension ProductManualViewController:  WKNavigationDelegate{
    func webViewSetUp(url: String?){
     
        guard let Urlpath = url else{return}
        webView = WKWebView(frame: view.bounds)
        view.addSubview(webView)
        webView.navigationDelegate = self
              // Load a URL
        loadURL(url: Urlpath)
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft(_:)))
        swipeLeftGesture.direction = .right
        webView.addGestureRecognizer(swipeLeftGesture)

    }
      func loadURL(url: String) {
           if let url = URL(string: url) {
               let request = URLRequest(url: url)
               webView.load(request)
           }
       }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
          // Called when the web view begins to load content
          print("WebView did start loading")
        ProgressOverlay.shared.show()
      }
      
      func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
          // Called when the web view finishes loading content
          print("WebView did finish loading")
          ProgressOverlay.shared.hide()
      }
    
    @objc func handleSwipeLeft(_ gestureRecognizer: UISwipeGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            webView.removeFromSuperview()
        }
    }

}
