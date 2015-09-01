import UIKit
import Alamofire
import SwiftWebSocket
import SwiftyJSON

class SearchViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate {
    
    var searchResult = [ChatRoomsService.User()]
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate = self
        searchBar.delegate = self
        
        /*
        let tapScreen = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tapScreen.cancelsTouchesInView = false
        view.addGestureRecognizer(tapScreen)
        */
        
    }
    
    func dismissKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        InfoUserService().searchUsers(searchBar.text, completion_request: {(result: [ChatRoomsService.User]) -> Void in self.searchResult = result} )
        
        if searchResult.count == 0 {
            let alert = UIAlertView()
            alert.title = "Пользователь \(searchBar.text) не найден"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
        
        self.tableView.reloadData()
        
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