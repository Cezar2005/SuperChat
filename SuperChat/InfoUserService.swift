import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

//The service provides methods for getting information about users.
class InfoUserService {
    
    /* Class properties.
    'ServerPath' - it's a http path to server.
    'curSession' - it's a string value of current an ID of session.
    'headers' - it's headers for http request that contain an ID of session, accept type and content type.
    */
    let ServerPath: String = ClientAPI().ServerPath
    var curSession: String = ""
    let headers: [String: String]
    
    init () {
        
        //Getting the ID of session from local database of the device. See the definition of the class 'currSession2' in mobileDataBase.swift file.
        if Realm().objects(currSession2).count != 0 {
            curSession = Realm().objects(currSession2)[0].session_id
        }
        
        self.headers = [
            "X-Session-Id": "\(curSession)",
            "Accept": "application/json",
            "Content-type": "application/json"
        ]
    }
    
    /* Public functions.
    'infoAboutUser()' - the function that gets id and login of user by ID of session.
    'searchUsers()' - the function that gets search result of users.
    */
    func infoAboutUser(completion_request: (result: [String: String]) -> Void) -> [String: String] {
        var response: [String: String] = [:]
        
        if !curSession.isEmpty {
            make_request_infoAboutUser(completion_request)
        } else {
            response = process_error()
            completion_request(result: response)
        }
        
        return response
        
    }
    
    func searchUsers(searchString: String, completion_request: (result: [ChatRoomsService.User]) -> Void) -> [ChatRoomsService.User] {
        
        var response: [ChatRoomsService.User] = []
        
        make_request_searchUsers(searchString, completion_request: completion_request)
        
        return response
    }
    
    /* Private functions.
    'make_request_infoAboutUser()' - the function that directly performs POST request to server for getting information about user. It uses the Alamofire framework.
    'make_request_searchUsers()' - the function that sends search request to server and takes result of it back.
    'process_error()' - the function that returns error when the mobile database doesn't have an ID of session.
    */
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
                        if !(jsonData["id"].stringValue.isEmpty || jsonData["login"].stringValue.isEmpty) {
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
    
    private func make_request_searchUsers(searchString: String, completion_request: (result: [ChatRoomsService.User]) -> Void) -> Void {
        var result: [ChatRoomsService.User] = []
        
        Alamofire.request(.GET, "\(ServerPath)/v1/users/?q=\(searchString)", headers: headers, encoding: .JSON)
            .responseJSON { request, response, data, error in
                if(error != nil) {
                    println("Error: \(error)")
                    println("Request: \(request)")
                    println("Response: \(response)")
                } else {
                    var jsonData = JSON(data!)
                    if !jsonData.isEmpty {
                        if jsonData["error"]["code"].stringValue != "unauthorized" {
                            for i in 0...jsonData.count-1 {
                                var user: ChatRoomsService.User = ChatRoomsService.User()
                                user.id = jsonData[i]["id"].intValue
                                user.login = jsonData[i]["login"].stringValue
                                result.append(user)
                            }
                        }
                    } else {
                        println("data_is_empty")
                    }
                }
                completion_request(result: result)
        }
        
    }
    
    private func process_error() -> [String: String]  {
        return ["error": "session_not_found"]
    }
    
}