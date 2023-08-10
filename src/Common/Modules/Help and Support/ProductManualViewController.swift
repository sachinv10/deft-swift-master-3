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

      //  let ref = storage.reference(withPath:"gs://wificontrol-a94cc.appspot.com/Pdf Product Manual")
//        guard let url = URL(string: "Wifinity/Wifinity_Smart_Sensor.pdf")else{return}
//        let downloadTask = ref.write(toFile: url) { url, error in
//            if let error = error {
//                // Uh-oh, an error occurred!
//            } else {
//                // Local file URL for "images/island.jpg" is returned
//            }
//        }
//        downloadTask.resume()
       mydatabase()
     }
    var urlArray = [String]()
    func mydatabase(){
        
        Database.database().reference().child("manualStorage").observe(.childAdded, with: {DataSnapshot in
            print(DataSnapshot.value)
            let data = DataSnapshot.value as! Dictionary<String, Any>
            print(data["title"])
            let titlename = data["title"]
            let urlname = data["url"]
            self.nameArray.append(titlename as! String)
            self.urlArray.append(urlname as! String)
            DispatchQueue.main.async {
                self.tableviewProduct.reloadData()
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
    func downloadFile(){
            let url = "https://www.tutorialspoint.com/swift/swift_tutorial.pdf"
            let fileName = "MyFile"
            savePdf(urlString: url, fileName: fileName)
          // Pdf Product Manual/Wifinity/Wifinity_Smart_Sensor.pdf

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
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! cellproduct
        cell.delegate = self
        cell.tag = indexPath.row
        let obj = nameArray[indexPath.row]
        let url = urlArray[indexPath.row]
        cell.load(obj: obj, urll: url)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = indexPath.row
       // demodownload(index: data)
    }
}
//MARK: - DELEGATE AND PROTOCALL
extension ProductManualViewController: DeveloperEntryDelegate{
    func textDeveloperPlatform(cell: cellproduct) {
        print("yes inter in download btn")
       // dowonloadFile()
      //  download_1()
       
        demodownload(index: cell.tag, url: cell.url)
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
      //  try? FileManager.default.removeItem(at: location)
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
           
            
//            let data = try Data(contentsOf: url) // not NSData !!
//                try data.write(to: destinationpath, options: .atomic)
        }catch let error{
            print("error=\(error)")
         
        }
    }
    
    
}
