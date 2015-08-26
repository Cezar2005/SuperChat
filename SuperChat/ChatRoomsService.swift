import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

class ChatRoomsService {
    
    let curSession: String = Realm().objects(currSession2)[0].session_id
    let headers: [String: String]
    
    init () {
        self.headers = [
            "X-Session-Id": "\(curSession)",
            "Accept": "application/json",
            "Content-type": "application/json"
        ]
    }
    
    func availableRooms() -> [String: AnyClass] {
        var result: [String: AnyClass] = [:]
        
        
        /*
        Alamofire.request(.GET, "http://localhost:8081/v1/rooms", headers: headers, encoding: .JSON)
        .responseJSON { requestRooms, responseRooms, dataRooms, errorRooms in
        if(errorRooms != nil) {
        println("Error: \(errorRooms)")
        println("Request: \(requestRooms)")
        println("Response: \(responseRooms)")
        } else {
        println("Error: \(errorRooms)")
        println("Request: \(requestRooms)")
        println("Response: \(responseRooms)")
        println("Data: \(dataRooms!)")
        self.jsonDataRooms = JSON(dataRooms!)
        }
        }
        */
        
        return result
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
    
}
