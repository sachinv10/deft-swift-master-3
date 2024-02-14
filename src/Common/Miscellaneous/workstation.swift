//
//  workstation.swift
//  Wifinity
//
//  Created by Apple on 24/01/24.
//

import Foundation
// MARK: - Welcome1
struct UserData: Codable{
    let login, name, location, bio: String?
    let twitterUsername: String?
    let publicRepos, publicGists, followers, following: Int?
}

class workstation: NSObject{
    static var shared = workstation()
    private override init(){
        
    }
    var userData: UserData?
    var event: ((Event)-> Void)?
    public func featchData(complition: @escaping(Result<UserData,Error>)-> Void){
       let urls: String? = "https://api.github.com/users/LilithWittmann"
       guard let url = urls else{return}
        var urlrequest = URLRequest(url: URL(string: url)!)
        urlrequest.addValue("application/json", forHTTPHeaderField: "Content-type")
        urlrequest.httpMethod = "GET"
        let dataTask = URLSession.shared.dataTask(with: urlrequest) { [self] pData, pURLResponse, pError in
           guard let data = pData, pError == nil else{return}
           do{
              let datas = try JSONDecoder().decode(UserData.self, from: data)
               print(datas.self)
               event!(.done)
               complition(.success(datas))
             }catch let error{
               print(error.localizedDescription)
               complition(.failure(error))
                 event!(.error(error))
             }
       }
       dataTask.resume()
    }
    
    enum Event{
        case Loding
        case Stop
        case done
        case error(Error?)
    }
}
