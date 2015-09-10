import UIKit
import Alamofire
import SwiftWebSocket
import SwiftyJSON

class SearchViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate, UIAlertViewDelegate {
    
    var searchResult: [ChatRoomsService.User] = []
    var selectedRoom = ChatRoomsService.Room()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate = self
        searchBar.delegate = self
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchResult = []
        self.tableView.reloadData()
        self.searchBar.showsCancelButton = false
        self.view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        InfoUserService().searchUsers(searchBar.text, completion_request:
            {(result: [ChatRoomsService.User]) -> Void in
                self.searchResult = result
                if self.searchResult.count == 0 {
                    let alert = UIAlertView()
                    alert.title = "Пользователь \(searchBar.text) не найден"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                }
                self.tableView.reloadData()
                self.view.endEditing(true)
            }
        )
    }
    
    //переопределение функции подготовки к переходу по идентификатору. Передача значения выбранной комнаты в целевой ViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "SearchToRoom" {
            let roomVC = segue.destinationViewController as! RoomViewController
            roomVC.currentRoom = self.selectedRoom
        }
    }
    
    //Обработка выбора строки tableView
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        // Create the alert controller
        var alertController = UIAlertController(title: "Создать чат с '\(searchResult[indexPath.row].login)'?", message: "", preferredStyle: .Alert)
        
        // Create the actions
        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            var usersForRoom: [ChatRoomsService.User] = []
            usersForRoom.append(self.searchResult[indexPath.row])
            ChatRoomsService().createRoom(usersForRoom, completion_request:
                {(result: ChatRoomsService.Room) -> Void in
                    self.selectedRoom = result
                    self.performSegueWithIdentifier("SearchToRoom", sender: self)
                }
            )
        }
        var cancelAction = UIAlertAction(title: "Отмена", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
            tableView.cellForRowAtIndexPath(indexPath)?.selected = false
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    //Функция возвращает количество строк, которое надо выводить в таблице
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    //Функция возвращает ячейку таблицы для вывода.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "SearchUserCell")
        cell.textLabel!.text = searchResult[indexPath.row].login
        
        return cell
    }
    
}