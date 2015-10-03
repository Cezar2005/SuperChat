import UIKit
import Alamofire
import SwiftWebSocket
import SwiftyJSON

//The viewController allows to find a user by login. The result of search is the user list (It's a chat room with these users).
class SearchViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate, UIAlertViewDelegate {
    
    /* ViewController properties.
    'searchResult' - it's a dictionary that contains users.
    'selectedRoom' - it's an implementation of chat room that was selected in the list.
    */
    var searchResult: [ChatRoomsService.User] = []
    var selectedRoom = ChatRoomsService.Room()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate = self
        searchBar.delegate = self
    }
    
    /*  'searchBarTextDidBeginEditing()' - function shows a cancel button after the editing of search field was started.
        'searchBarCancelButtonClicked()' - function clears search result and reloads table view on screen.
        'searchBarSearchButtonClicked()' - function performs search. If the search result is empty the function shows alert with the text "User not found".
        'prepareForSegue()' - function sends the selected room to the viewController class.
    */
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
        
        let alert = UIAlertView()
        alert.addButtonWithTitle("OK")
        
        if UtilityClasses().containsOnlyLetters(searchBar.text) {
            InfoUserService().searchUsers(searchBar.text, completion_request:
                {(result: [ChatRoomsService.User]) -> Void in
                    self.searchResult = result
                    if self.searchResult.count == 0 {
                        alert.title = "User \(searchBar.text) not found"
                        alert.show()
                    }
                    self.tableView.reloadData()
                    self.view.endEditing(true)
                }
            )
        } else {
            alert.title = "The search text '\(searchBar.text)' contains invalid characters."
            alert.show()
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "SearchToRoom" {
            let roomVC = segue.destinationViewController as! RoomViewController
            roomVC.currentRoom = self.selectedRoom
        }
    }
    
    //The function processes the selection table row. It sends a request for creating a chat room with selected user.
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        var alertController = UIAlertController(title: "Create chat with '\(searchResult[indexPath.row].login)'?", message: "", preferredStyle: .Alert)
        
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
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
            tableView.cellForRowAtIndexPath(indexPath)?.selected = false
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    //The function returns a number of rows in the tableView that will be displayed on screen.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    //The function returns the cell of tableView.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "SearchUserCell")
        cell.textLabel!.text = searchResult[indexPath.row].login
        
        return cell
    }
    
}