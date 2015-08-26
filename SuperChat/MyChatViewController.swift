import UIKit
import Alamofire
import SwiftWebSocket
import SwiftyJSON
import RealmSwift

class MyChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var jsonDataInfo:JSON =  nil
    var jsonDataRooms:JSON =  nil
    var contactsDictionary = [Int: [String: String]]()
    
    override func viewDidLoad() {
        
        //Узнаем кем является текущий залогиненный юзер
        var currUser = InfoUserService().infoAboutUser()
        
        //Получим все комнаты, доступные текущему юзеру
        var availableUserRooms = ChatRoomsService().availableRooms()
        
        //Ищем в комнатах других юзеров, не являющихся текущим. Таким образом словарь "список контактов". Если ничего не находим, оборажаем информацию о необходимости поиска юзера для общения.
        if jsonDataRooms.isEmpty && jsonDataInfo.isEmpty {
            println("Контактов нет")
        } else {
            var i=0
            for (idroom, users) in jsonDataRooms {
                for (iduser, user) in users {
                    if user != jsonDataInfo {
                        var contactUser: [String: String] = [idroom: user.stringValue]
                        contactsDictionary[i] = contactUser
                        i += 1
                    }
                }
            }
        }
        
    }
    
    
    //Функция возвращает количество строк, которое надо выводить в таблице
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.jsonDataRooms.count != 0 {
            return self.jsonDataRooms.count
        } else {
            return 0
        }
    }
    
    //Функция возвращает ячейку таблицы для вывода. Выводим в нее список контактов, полученный в запросе GET /v1/rooms.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "ContactCell")
        if !contactsDictionary.isEmpty {
            cell.textLabel!.text = contactsDictionary[indexPath.row]?.values.first
            cell.detailTextLabel!.text = "\(contactsDictionary[indexPath.row]?.keys.first)"
        }
        
        return cell
    }
    
}
