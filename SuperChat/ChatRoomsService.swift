import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

class ChatRoomsService {
    
    //Properties
    let ServerPath: String = ClientAPI().ServerPath
    let curSession: String = Realm().objects(currSession2)[0].session_id
    let headers: [String: String]
    struct User {
        var id: Int = 0
        var login: String = ""
    }
    struct Room {
        var id: Int = 0
        var users: [User] = []
    }
    
    //Init function
    init () {
        self.headers = [
            "X-Session-Id": "\(curSession)",
            "Accept": "application/json",
            "Content-type": "application/json"
        ]
    }
    
    //Public functions
    func availableRooms(completion_request: (resilt: [Room]) -> Void) -> [Room] {
        
        var response: [Room] = []
        
        make_request_availableRooms(completion_request)
        
        return response
    }
    
    func createRoom(users: [User], completion_request: (result: Room) -> Void) -> Room {
        
        var response: Room = Room()
        
        make_request_createRoom(users, completion_request: completion_request)
        
        return response
    }
    
    func infoAboutRoom(id_room: String) -> [String: AnyClass] {
        var result: [String: AnyClass] = [:]
        return result
    }
    
    func historyRoom(id_room: String) -> [[String:String]] {
        var result = [[String:String]]()
        return result
    }
    
    //Private functions. Provides performance of public functions.
    private func make_request_availableRooms(completion_request: (result: [Room]) -> Void) -> Void {
        
        var result: [Room] = []
        
        Alamofire.request(.GET, "\(ServerPath)/v1/rooms", headers: headers, encoding: .JSON)
            .responseJSON { request, response, data, error in
                if(error != nil) {
                    println("Error: \(error)")
                    println("Request: \(request)")
                    println("Response: \(response)")
                } else {
                    var jsonData = JSON(data!)
                    if !jsonData.isEmpty {
                        for i in 0...jsonData.count-1 {
                            var room: Room = Room()
                            room.id = jsonData[i]["id"].intValue
                            if !jsonData[i]["users"].isEmpty {
                                for j in 0...jsonData[i]["users"].count-1 {
                                    var user: User = User()
                                    user.id = jsonData[i]["users"][j]["id"].intValue
                                    user.login = jsonData[i]["users"][j]["login"].stringValue
                                    room.users.append(user)
                                }
                            }
                            result.append(room)
                        }
                    } else {
                        println("data_is_empty")
                    }
                }
                completion_request(result: result)
        }
    }
    
    private func make_request_createRoom(users: [User], completion_request: (result: Room) -> Void) -> Void {
        
        var result: Room = Room()
        var arrayOfUsers = [NSDictionary]()
        for i in 0...users.count-1 {
            arrayOfUsers.append(["id": users[i].id, "login": users[i].login])
        }
        
        let parameters = [
            //"users": [["id": users[0].id, "login": users[0].login]]
            "users": arrayOfUsers
        ]
        
        Alamofire.request(.POST, "\(ServerPath)/v1/rooms", parameters: parameters, headers: headers, encoding: .JSON)
            .responseJSON { request, response, data, error in
                if(error != nil) {
                    println("Error: \(error)")
                    println("Request: \(request)")
                    println("Response: \(response)")
                } else {
                    var jsonData = JSON(data!)
                    if !jsonData.isEmpty {
                        for (id_room, users) in jsonData {
                            result.id = jsonData[id_room].intValue
                            for (user_id, user_login) in users {
                                var user: User = User()
                                user.id = users["id"].intValue
                                user.login = users["login"].stringValue
                                result.users.append(user)
                            }
                        }
                        
                    } else {
                        println("data_is_empty")
                    }
                }
                completion_request(result: result)
        }
        
    }
    
    
}