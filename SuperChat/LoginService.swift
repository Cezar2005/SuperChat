import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

//The service provides methods for authorization on server.
class LoginService {
    
    /* Class properties.
        'ServerPath' - it's a http path to server.
        'curSession' - it's a string value of current an ID of session.
        'headers' - it's headers for http request that contain an ID of session, accept type and content type.
    */
    let ServerPath: String = ClientAPI().ServerPath
    var curSession: String = ""
    let headers: [String: String]
    
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
    
    /* Public functions.
        'perform()' - the function that takes login and password, checks them and sends them into request.
        'logout()' - the function that makes logout of the user.
    */
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
            completion_request(result: response)
        }
        
        return response
        
    }
    
    func logout(completion_request: (result: Bool) -> Void) -> Void {
        
        make_request_logout(completion_request)
        
    }
    
    /* Private functions.
        'make_request()' - the function that directly performs POST request to server for user login. It uses the Alamofire framework.
        'process_error()' - the function that returns error when login or password are empty. It's UI error.
        'make_request_logout()' - the function that directly performs POST request to server for user logout. It uses the Alamofire framework.
    */
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
                            if jsonData["error"]["code"].stringValue == "user_not_found" {
                                result["error"] = "user_not_found"
                            } else {
                                if !jsonData["session_id"].isEmpty {
                                    result["session_id"] = jsonData["session_id"].stringValue
                                } else {
                                    result["error"] = jsonData["error"]["code"].stringValue
                                    println("Параметр session_id пуст")
                                }
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