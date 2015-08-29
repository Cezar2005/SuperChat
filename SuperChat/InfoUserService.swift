import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

class InfoUserService {
    
    let ServerPath: String = ClientAPI().ServerPath
    let curSession: String = Realm().objects(currSession2)[0].session_id
    let headers: [String: String]
    
    init () {
        self.headers = [
            "X-Session-Id": "\(curSession)",
            "Accept": "application/json",
            "Content-type": "application/json"
        ]
    }
    
    func infoAboutUser() -> [String: String] {
        var response: [String: String] = [:]
        
        if !curSession.isEmpty {
            make_request_infoAboutUser({ (result) in response = result })
        } else {
            response = process_error()
        }
        
        return response
        
    }
    
    func searchUsers(searchReq: String) -> [String: String] {
        var response: [String: String] = [:]
        return response
    }
    
    private func make_request_infoAboutUser(completion_request: (result: [String: String]) -> Void) -> Void {
        
        var result: [String: String] = [:]
        
        Alamofire.request(.GET, "\(ServerPath)/v1/info", headers: headers).responseJSON
        { request, response, data, error in
            if(error != nil) {
                println("Error: \(error)")
                println("Request: \(request)")
                println("Response: \(response)")
            } else {
                var jsonData = JSON(data!)
                if !jsonData.isEmpty {
                    if !(jsonData["id"].isEmpty || !jsonData["login"].isEmpty) {
                        result["id"] = jsonData["id"].stringValue
                        result["login"] = jsonData["login"].stringValue
                    } else {
                        result["error"] = jsonData["error"]["code"].stringValue
                        println("Параметры id и логин пусты")
                    }
                } else {
                    result["error"] = "data_is_empty"
                    println("Параметр data в ответе на запрос пуст")
                }
            }
            completion_request(result: result)
        }
        
    }
    
    private func process_error() -> [String: String]  {
        return ["error": "session_not_found"]
    }
    
}