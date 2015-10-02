import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift
import SwiftWebSocket

class ChatRoomsService {
    
    //Properties
    let ServerPath: String = ClientAPI().ServerPath
    var curSession: String = ""
    let headers: [String: String]
    
    struct User {
        var id: Int = 0
        var login: String = ""
    }
    
    struct Room {
        var id: Int = 0
        var users: [User] = []
    }
    
    struct Message {
        var text: String = ""
        var userSenderId: Int = 0
        var roomId: Int = 0
        var dateTimeCreated = NSDate()
    }
    
    var formatter = NSDateFormatter()
    
    //Init function
    init () {
        
        if Realm().objects(currSession2).count != 0 {
            curSession = Realm().objects(currSession2)[0].session_id
        }
        
        self.headers = [
            "X-Session-Id": "\(curSession)",
            "Accept": "application/json",
            "Content-type": "application/json"
        ]
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)!
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
    }
    
    //Public functions
    func availableRooms(completion_request: (result: [Room]) -> Void) -> [Room] {
        
        var response: [Room] = []
        
        make_request_availableRooms(completion_request)
        
        return response
    }
    
    func createRoom(users: [User], completion_request: (result: Room) -> Void) -> Room {
        
        var response: Room = Room()
        
        make_request_createRoom(users, completion_request: completion_request)
        
        return response
    }
    
    
    func historyRoom(id_room: Int, completion_request: (result: [Message]) -> Void) -> [Message] {
        
        var response: [Message] = []
        
        make_request_historyRoom(id_room, completion_request: completion_request)
        
        return response
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
    
    private func make_request_historyRoom(id_room: Int, completion_request: (result: [Message]) -> Void) -> Void {
        
        var result: [Message] = []
        
        Alamofire.request(.GET, "\(ServerPath)/v1/rooms/\(id_room)/messages", headers: headers, encoding: .JSON)
            .responseJSON { request, response, data, error in
                if(error != nil) {
                    println("Error: \(error)")
                    println("Request: \(request)")
                    println("Response: \(response)")
                } else {
                    if data != nil {
                    var jsonData = JSON(data!)
                    if !jsonData.isEmpty {
                        for i in 0...jsonData.count-1 {
                            var message: Message = Message()
                            message.text = jsonData[i]["text"].stringValue
                            message.userSenderId = jsonData[i]["user_id"].intValue
                            message.roomId = jsonData[i]["room_id"].intValue
                            if self.formatter.dateFromString(jsonData[i]["created_at"].stringValue) != nil {
                                message.dateTimeCreated = self.formatter.dateFromString(jsonData[i]["created_at"].stringValue)!
                            }
                            result.append(message)
                        }
                    } else {
                        println("data_is_empty")
                    }
                    }
                }
                completion_request(result: result)
        }
        
    }
    
    
    
}