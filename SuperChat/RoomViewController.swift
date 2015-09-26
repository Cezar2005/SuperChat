import UIKit
import Alamofire
import RealmSwift
import SwiftyJSON
import Starscream

class RoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextBottom: NSLayoutConstraint!

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
        
        //Получить историю сообщений
        ChatRoomsService().historyRoom(self.currentRoom.id, completion_request: {
            (result: [ChatRoomsService.Message]) -> Void in
            self.messagesArray = result
            self.messageTableView.reloadData()
            self.positioningOnLastMessage(false)
        })
        
        //Получение информаци о текущем пользователе.
        InfoUserService().infoAboutUser( {(result: [String: String]) -> Void in
            self.currUser = result
        })
        
        //Если поле ввода пустое, то кнопка отпраки не активна
        if self.messageTextField.text.isEmpty {
            self.sendButton.enabled = false
        }
        
        //Инициализируем WebSocket
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
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.messageTextBottom.constant = self.messageTextBottom.constant + keyboardFrame.size.height //БАГ! Поправить! При смене языка клавиатура ползет вверх! )
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
                //Сообщения от меня (т.е. мое), меняем цвет на #5eb964 (rgb(94,185,100)) и делаем выравнивание по правому краю
                cell.backgroundColor = UIColor(red: 0.094, green: 0.185, blue: 0.100, alpha: 0.5)
                cell.textLabel?.textColor = UIColor.whiteColor()
                cell.textLabel?.textAlignment = .Right
                cell.detailTextLabel?.textAlignment = .Right
            } else {
                //Сообщения не от меня (т.е. мне), меняем цвет на #e5e7eb (rgb(229,231,235)) и делаем выравнивание по левому краю
                cell.backgroundColor = UIColor(red: 0.229, green: 0.231, blue: 0.235, alpha: 0.5)
                cell.textLabel?.textAlignment = .Left
                cell.detailTextLabel?.textAlignment = .Left
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