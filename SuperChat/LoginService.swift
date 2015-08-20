import Foundation
import Alamofire
import SwiftyJSON

class LoginService {
    
    func perform(login: String, password: String) -> [String: String] {
        var loginIsAvalible = true
        var response: [String: String] = [:]
        
        //Проверка полей на заполненность
        if login.isEmpty || password.isEmpty {
            loginIsAvalible = false
        }
        
        if loginIsAvalible {
            response = make_request(login, password: password)
        } else {
            response = process_error()
        }
        
        return response

    }
    
    private func make_request(login: String, password: String) -> [String: String]  {
        
        var result: [String: String] = [:]
        
        
        //Если логин возможен, то выполняем его
        Alamofire.request(.POST, "http://localhost:8081/v1/login", parameters: ["login":login, "password":password], encoding: .JSON)
        .responseJSON { request, response, data, error in
                if(error != nil) {
                    println("Error: \(error)")
                    println("Request: \(request)")
                    println("Response: \(response)")
                } else {
                    var jsonData = JSON(data!)
                    if !jsonData.isEmpty {
                        if !jsonData["session_id"].isEmpty {
                            result["session_id"] = JSON(data!)["session_id"].stringValue
                        } else {
                            result["error"] = JSON(data!)["error"]["code"].stringValue
                            println("Параметр session_id пуст")
                        }
                    } else {
                        result["error"] = "data_is_empty"
                        println("Параметр data в ответе на запрос пуст")
                    }
                }
        }
        return result
        
    }
    
    private func process_error() -> [String: String]  {
        return ["error": "wrong_credentials"]
    }
}