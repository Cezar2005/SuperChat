import UIKit
import Alamofire
import SwiftWebSocket
import SwiftyJSON

class RoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var viewHieghtConstraint: NSLayoutConstraint! //высота элемента view, содержащего поле messageTextField и sendButton
    @IBOutlet weak var sendArea: UIView!
    
    
    //текущие размеры экрана
    let screenHeigth = UIScreen.mainScreen().applicationFrame.height
    let screenWidth = UIScreen.mainScreen().applicationFrame.width
    
    var messagesArray: [String] = [String]()
    var currentRoom = ChatRoomsService.Room()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageTableView.delegate = self
        self.messageTableView.dataSource = self
        self.messageTextField.delegate = self
        
        
        //self.sendArea.frame.origin.y
        //Add a tap gesture recognizer to the Table View
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tableViewTapped")
        self.messageTableView.addGestureRecognizer(tapGesture)
        
        //Test
        self.messagesArray.append("Test 1")
        self.messagesArray.append("Test 2")
        self.messagesArray.append("Test 2")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func sendButtonTapped(sender: UIButton) {
        
        //Send button tapped
        
        //Call the end editing method for the text field
        self.messageTextField.endEditing(true)
        
    }
    
    func tableViewTapped() {
        
        //Force the textfield to end editing
        self.messageTextField.endEditing(true)
        
        
    }
    
    //MARK: TextField delegate methods
    func textFieldDidBeginEditing(textField: UITextField) {
        //Perform an animation to grow the view
        /*
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.4, animations: {
            self.viewHieghtConstraint.constant = 500
            self.view.layoutIfNeeded()
            }, completion: nil)
*/
        self.sendArea.frame.origin.y = 300
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        //Perform an animation to grow the view
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.4, animations: {
            self.viewHieghtConstraint.constant = 40
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    //MARK: TableView delegate methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //let cell = self.messageTableView.dequeueReusableCellWithIdentifier("MessageCell") as! UITableViewCell
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MessageCell")
        cell.textLabel?.text = self.messagesArray[indexPath.row]
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }
    
}