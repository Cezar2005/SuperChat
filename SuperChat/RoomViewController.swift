import UIKit
import Alamofire
import RealmSwift
import SwiftyJSON
import Starscream

//The viewController of a chat room. It allows to send a message to the interlocutor and see the correspondence history.
class RoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextBottom: NSLayoutConstraint!
    @IBOutlet weak var NavBarItem: UINavigationItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    /* ViewController properties.
    'messagesArray' - it's an array that contains messages from the correspondence history.
    'currentRoom' - it's an implementation of a current room object. It was got from MyChatViewController.
    'currUser' - dictionary contains an information about current user.
    'ServerPath' - it's a path to the server of the mobile app from ClientAPI class.
    'SocketPath' - it's a path to the web socket server from ClientAPI class.
    'curSession' - it's a current user`s session ID from mobile data base of the device.
    'ws' - it's a value for a web socket entity.
    */
    var messagesArray: [ChatRoomsService.Message] = []
    var currentRoom = ChatRoomsService.Room()
    var currUser:[String: String] = [:]
    
    let ServerPath: String = ClientAPI().ServerPath
    let SocketPath: String = ClientAPI().SocketPath
    var curSession: String = Realm().objects(currSession2)[0].session_id
    var ws : WebSocket!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.messageTableView.delegate = self
        self.messageTableView.dataSource = self
        self.messageTextField.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasShown:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tableViewTapped")
        self.messageTableView.addGestureRecognizer(tapGesture)
        
        //The function gets the correspondence history between the current user and his interlocutor.
        ChatRoomsService().historyRoom(self.currentRoom.id, completion_request: {
            (result: [ChatRoomsService.Message]) -> Void in
            self.messagesArray = result
            self.messageTableView.reloadData()
            self.positioningOnLastMessage(false)
        })
        
        //The function gets the information about current user. And then we find the login of the user`s interlocutor. It is used for a screen title.
        InfoUserService().infoAboutUser( {(result: [String: String]) -> Void in
            self.currUser = result
            for user in self.currentRoom.users {
                if String(user.id) != self.currUser["id"] {
                    self.backButton.title! = "← Chat with \(user.login)"
                }
            }
        })
        
        //The send button is disable when message text filed is empty.
        if self.messageTextField.text.isEmpty {
            self.sendButton.enabled = false
        }
        
        //Initialization of the web socket.
        initWebSocket()
    
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    @IBAction func messageTextFieldEditingDidBegin(sender: UITextField) {
        
        if !sender.text.isEmpty {
            self.sendButton.enabled = true
        }
        
    }
    
    @IBAction func messageTextFieldEditingDidEnd(sender: UITextField) {
        
        if !sender.text.isEmpty {
            self.sendButton.enabled = true
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func sendButtonTapped(sender: UIButton) {
        
        var messageSent = ChatRoomsService.Message()
        messageSent.text = self.messageTextField.text
        messageSent.roomId = self.currentRoom.id
        messageSent.userSenderId = self.currUser["id"]!.toInt()!
        messageSent.dateTimeCreated = NSDate()

        sendMessage(messageSent)
        
    }
    
    func tableViewTapped() {
        
        self.messageTextField.endEditing(true)
        
    }
    
    func keyboardWasShown(notification: NSNotification) {

        var info = notification.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        self.messageTextBottom.constant = 8
            
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.messageTextBottom.constant = self.messageTextBottom.constant + keyboardFrame.size.height
        })
        
    }
    
    func keyboardWasHide(notification: NSNotification) {

        var info = notification.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.messageTextBottom.constant = 8
        })
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MessageCell")
        if !self.messagesArray.isEmpty {
            var currMessage = self.messagesArray[indexPath.row]
            cell.textLabel?.text = currMessage.text
            cell.detailTextLabel?.text = "\(currMessage.dateTimeCreated.description)"
            if String(currMessage.userSenderId) == self.currUser["id"] {
                //Messages to me.
                cell.backgroundColor = UIColor(red: 0.222, green: 0.245, blue: 0.216, alpha: 0.1)
                cell.textLabel!.textColor = UIColor(red: 0.020, green: 0.057, blue: 0.014, alpha: 1.0)
            } else {
                //Messages from me.
                cell.backgroundColor = UIColor.whiteColor()
                cell.textLabel!.textColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1.0)
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !self.messagesArray.isEmpty {
            return self.messagesArray.count
        } else {
            return 0
        }
    }
    
    private func sendMessage(message: ChatRoomsService.Message) -> Void {

        var messageJSON: JSON = [
            "created_at":"",
            "text":"",
            "user_id":0,
            "room_id":0
        ]
        
        messageJSON["text"].string = message.text
        messageJSON["user_id"].int = message.userSenderId
        messageJSON["room_id"].int = message.roomId
        messageJSON["created_at"].string = ChatRoomsService().formatter.stringFromDate(message.dateTimeCreated)
        
        self.ws.writeString(messageJSON.rawString()!)
        self.messagesArray.append(message)
        self.messageTableView.reloadData()
        self.positioningOnLastMessage(true)
    }
    
    private func initWebSocket() -> Void {
        
        self.ws = WebSocket(url: NSURL(scheme: "ws", host: "\(self.SocketPath)", path: "/v1/rooms/\(self.currentRoom.id)/chat?session_id=\(self.curSession)")!)
        //websocketDidConnect
        
        self.ws.onConnect = {
            println("websocket is connected")
        }
        //websocketDidDisconnect
        self.ws.onDisconnect = { (error: NSError?) in
            println("websocket is disconnected: \(error?.localizedDescription)")
        }
        //websocketDidReceiveMessage
        self.ws.onText = { (text: String) in
            println("got some text: \(text)")
            if !text.isEmpty {
                var result = ChatRoomsService.Message()
                var textToDictionary = UtilityClasses().convertStringToDictionary(text)
                result.text = textToDictionary!["text"]! as! String
                result.userSenderId = textToDictionary!["user_id"]! as! Int
                result.roomId = textToDictionary!["room_id"]! as! Int
                result.dateTimeCreated = { () -> NSDate in
                    var formatter = ChatRoomsService().formatter
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                    let date = formatter.dateFromString(textToDictionary!["created_at"]! as! String)
                    return date!
                }()
                self.messagesArray.append(result)
                self.messageTableView.reloadData()
                self.positioningOnLastMessage(true)
                
            }
        }
        //websocketDidReceiveData
        self.ws.onData = { (data: NSData) in
            println("got some data: \(data.length)")
        }
        //you could do onPong as well.
        self.ws.connect()
        
    }
    
    private func positioningOnLastMessage(animated: Bool) -> Void {
        let numberOfRows = self.messageTableView.numberOfRowsInSection(self.messageTableView.numberOfSections()-1)
        if numberOfRows > 0 {
            let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (self.messageTableView.numberOfSections()-1))
            self.messageTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
        }
    }
    
}