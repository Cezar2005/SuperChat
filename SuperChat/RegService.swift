import Foundation
import Alamofire
import SwiftyJSON

//The service provides methods for registration on server. The registration includes login of user automatically.
class RegService {
    
    /* Class properties.
    'ServerPath' - it's a http path to server.
    */
    let ServerPath: String = ClientAPI().ServerPath
    
    /* Public functions.
    'perform()' - the function that takes new login and password, checks them and sends them into request.
    */
    func perform(login: String, password: String, passwordRepeat: String, completion_request: (result: [String: String]) -> Void) -> [String: String] {
        var regIsAvalible = true
        var response: [String: String] = [:]
        
        if login.isEmpty || password.isEmpty || passwordRepeat.isEmpty {
            regIsAvalible = false
        }
        
        if password != passwordRepeat {
            regIsAvalible = false
        }
        
        if regIsAvalible {
            make_request(login, password: password, completion_request: completion_request)
        } else {
            response = process_error()
        }
        
        return response
        
    }
    
    /* Private functions.
    'make_request()' - the function that directly performs POST request to server for user registration. It uses the Alamofire framework.
    'process_error()' - the function that returns error when login or password are empty. It's UI error.
    */
    private func make_request(login: String, password: String, completion_request: (result: [String: String]) -> Void) -> Void {
        var result: [String: String] = [:]
        
        Alamofire.request(.POST, "\(ServerPath)/v1/register", parameters: ["login":login, "password":password], encoding: .JSON).responseJSON
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
    
}