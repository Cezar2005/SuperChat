import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

class LoginService {
    
    //Properties
    let ServerPath: String = ClientAPI().ServerPath
    var curSession: String = ""
    let headers: [String: String]
    
    //Init function
    init () {
        
        if Realm().objects(currSession2).count != 0 {
            curSession = Realm().objects(currSession2)[0].session_id
        }
        
        self.headers = [
            "X-Session-Id": "\(self.curSession)",
            "Accept": "application/json",
            "Content-type": "application/json"
        ]

    }
    
    //Public functions
    func perform(login: String, password: String, completion_request: (result: [String: String]) -> Void) -> [String: String] {
        var loginIsAvalible = true
        var response: [String: String] = [:]
        
        if login.isEmpty || password.isEmpty {
            loginIsAvalible = false
        }
        
        if loginIsAvalible {
            make_request(login, password: password, completion_request: completion_request)
        } else {
            response = process_error()
        }
        
        return response
        
    }
    
    func logout(completion_request: (result: Bool) -> Void) -> Void {
        
        make_request_logout(completion_request)
        
    }
    
    //Private functions. Provides performance of public functions.
    private func make_request(login: String, password: String, completion_request: (result: [String: String]) -> Void) -> Void  {
        
        var result: [String: String] = [:]
        
        Alamofire.request(.POST, "\(ServerPath)/v1/login", parameters: ["login":login, "password":password], encoding: .JSON).responseJSON
            { request, response, data, error in
                if(error != nil) {
                    println("Error: \(error)")
                    println("Request: \(request)")
                    println("Response: \(response)")
                } else {
                    var jsonData = JSON(data!)
                    if !jsonData.isEmpty {
                        if !jsonData["session_id"].isEmpty {
                            result["session_id"] = jsonData["session_id"].stringValue
                        } else {
                            result["error"] = jsonData["error"]["code"].stringValue
                            println("Параметр session_id пуст")
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
        return ["error": "wrong_credentials"]
    }
    
    private func make_request_logout(completion_request: (result: Bool) -> Void) -> Void {
        
        var result = false
        
        Alamofire.request(.POST, "\(ServerPath)/v1/logout", headers: headers).responseJSON
            { request, response, data, error in
                if(error != nil) {
                    println("Error: \(error)")
                    println("Request: \(request)")
                    println("Response: \(response)")
                } else {
                    completion_request(result: true)
                }
        }
        
    }
    
}