import UIKit
import Alamofire
import SwiftWebSocket
import SwiftyJSON
import RealmSwift

class MyChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var currUser = [String: String]()
    var availableUserRooms = [ChatRoomsService.Room()]
    
    override func viewDidLoad() {
        
        //текущий юзер
        InfoUserService().infoAboutUser( {(result: [String: String]) -> Void in self.currUser = result} )
        //доступные комнаты текущего юзера
        ChatRoomsService().availableRooms( {(result: [ChatRoomsService.Room]) -> Void in
            self.availableUserRooms = result} )
    }
    
    //Функция возвращает количество строк, которое надо выводить в таблице
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableUserRooms.count
    }
    
    //Функция возвращает ячейку таблицы для вывода.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "ContactCell")
        
        var contactName: String {
            get {
                var name: String = ""
                for user in availableUserRooms[indexPath.row].users {
                    if String(user.id) != currUser["id"] {
                        name = user.login
                    }
                }
                return name
            }
        }
        
        cell.textLabel!.text = contactName
        
        return cell
    }
    
}