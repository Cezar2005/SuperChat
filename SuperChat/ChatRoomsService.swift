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
    func availableRooms() -> [Room] {
        
        var response: [Room] = []
        
        make_request_availableRooms( { (result: [Room]) -> Void in response = result } )
        
        return response
    }
    
    func createRoom(users: [Int: [String: String]]) -> [String: AnyClass] {
        var result: [String: AnyClass] = [:]
        return result
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
                        for (id_room, users) in jsonData {
                            var room: Room = Room()
                            room.id = jsonData[id_room].intValue
                            for (user_id, user_login) in users {
                                var user: User = User()
                                user.id = users["id"].intValue
                                user.login = users["login"].stringValue
                                room.users.append(user)
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
    
}