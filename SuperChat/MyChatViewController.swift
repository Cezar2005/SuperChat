import UIKit
import Alamofire
import SwiftWebSocket
import SwiftyJSON
import RealmSwift

class MyChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var currUser:[String: String] = [:]
    var availableUserRooms: [ChatRoomsService.Room] = []
    var selectedRoom = ChatRoomsService.Room()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        //Получение информаци о текущем пользователе. Получение информации о доступных комнатах для текущего пользователя.
        InfoUserService().infoAboutUser( {(result1: [String: String]) -> Void in
            self.currUser = result1
            ChatRoomsService().availableRooms( {(result2: [ChatRoomsService.Room]) -> Void in
                self.availableUserRooms = result2
                self.tableView.reloadData()
            })
        })
    }
    
    //переопределение функции подготовки к переходу по идентификатору. Передача значения выбранной комнаты в целевой ViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "MyChatToRoom" {
            let roomVC = segue.destinationViewController as! RoomViewController
            roomVC.currentRoom = self.selectedRoom
        }
    }
    
    //Обработка выбора строки tableView
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !self.availableUserRooms.isEmpty {
            self.selectedRoom = self.availableUserRooms[indexPath.row]
            self.performSegueWithIdentifier("MyChatToRoom", sender: self)
        }
    }
    
    //Функция возвращает количество строк, которое надо выводить в таблице
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !self.availableUserRooms.isEmpty {
            return self.availableUserRooms.count
        } else {
            return 0
        }
        
    }
    
    //Функция возвращает ячейку таблицы для вывода.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyTestSwiftCell")

        if !self.availableUserRooms.isEmpty {
            for user in self.availableUserRooms[indexPath.row].users {
                if String(user.id) != self.currUser["id"] {
                    cell.textLabel!.text = user.login
                    break
                } else {
                    cell.textLabel!.text = "error"
                }
            }
        }
        return cell
    }
    
}