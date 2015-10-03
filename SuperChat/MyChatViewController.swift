import UIKit
import Alamofire
import SwiftWebSocket
import SwiftyJSON
import RealmSwift

//The ViewController of available chat rooms.
class MyChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /* ViewController properties.
    'currUser' - it's a dictionary for a current session.
    'availableUserRooms' - it's a dictionary for the list of available user room for a current user.
    'selectedRoom' - it's an implementation of chat room object in the list that was selected by the user.
    'tavleView' - it's an UI TableView. It contains the list of chat rooms.
    */
    var currUser:[String: String] = [:]
    var availableUserRooms: [ChatRoomsService.Room] = []
    var selectedRoom = ChatRoomsService.Room()
    
    @IBOutlet weak var tableView: UITableView!
    
    //The function gets information about current user and then gets information about available chat rooms for him.
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        InfoUserService().infoAboutUser( {(result1: [String: String]) -> Void in
            self.currUser = result1
            ChatRoomsService().availableRooms( {(result2: [ChatRoomsService.Room]) -> Void in
                self.availableUserRooms = result2
                self.tableView.reloadData()
            })
        })
    }
    
    //The function sends the entity of selected chat room from the list into the segue between screens.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "MyChatToRoom" {
            let roomVC = segue.destinationViewController as! RoomViewController
            roomVC.currentRoom = self.selectedRoom
        }
    }
    
    //This is a line treatment of choice in tavleView.
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !self.availableUserRooms.isEmpty {
            self.selectedRoom = self.availableUserRooms[indexPath.row]
            self.performSegueWithIdentifier("MyChatToRoom", sender: self)
        }
    }
    
    //The function returns a number of rows in tableView that will be displayed on the screen.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !self.availableUserRooms.isEmpty {
            return self.availableUserRooms.count
        } else {
            return 0
        }
        
    }
    
    //The function returns the cell of tableView. The cells contain the login of the users.
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