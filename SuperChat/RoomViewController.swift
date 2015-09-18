import UIKit
import Alamofire
import SwiftWebSocket
import RealmSwift
import SwiftyJSON

class RoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextBottom: NSLayoutConstraint!

    //текущие размеры экрана
    var messagesArray: [ChatRoomsService.Message] = []
    var currentRoom = ChatRoomsService.Room()
    var currUser:[String: String] = [:]
    
    let ServerPath: String = ClientAPI().ServerPath
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
        
        })
        
        //Получение информаци о текущем пользователе. Получение информации о доступных комнатах для текущего пользователя.
        InfoUserService().infoAboutUser( {(result: [String: String]) -> Void in
            self.currUser = result
            self.messageTableView.reloadData()
        })
        
        //Если поле ввода пустое, то кнопка отпраки не активна
        if self.messageTextField.text.isEmpty {
            self.sendButton.enabled = false
        }
        
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
        //вызвать send message и передать в него sendingMessage
        
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
        //сформировать json из message
        var messageJSON: JSON = [
            "text":"",
            "user_id":"",
            "room_id":"",
            "created_at":""
        ]
        
        messageJSON["text"].string = message.text
        messageJSON["user_id"].int = message.userSenderId
        messageJSON["room_id"].int = message.roomId
        messageJSON["created_at"].string = ChatRoomsService().formatter.stringFromDate(message.dateTimeCreated)
        
        
        /*
        var messageJSON:JSON = [
            "text":message.text,
            "user_id":message.userSenderId,
            "room_id":message.roomId,
            "created_at":ChatRoomsService().formatter.stringFromDate(message.dateTimeCreated)
        ]*/

        let str: String = "{\"text\":\"И тебе привет\",\"user_id\":1,\"room_id\":10,\"created_at\":\"2015-08-06T13:44:07\"}"
        
        //'{"text":"И тебе привет","user_id":1,"room_id":10,"created_at":"2015-08-06T13:44:07"}'
        //self.ws.send(messageJSON.rawString()!)
        self.ws.send(str)
        self.messagesArray.append(message)
        self.messageTableView.reloadData()
    }
    
    private func initWebSocket(message: ChatRoomsService.Message) -> Void {
        
        self.ws = WebSocket(url: "wss://\(ServerPath)/v1/rooms/\(currentRoom.id)/chat?session_id=\(curSession)")
        
        ws.event.open = {
            print("opened")
        }
        ws.event.close = { code, reason, clean in
            print("close")
        }
        ws.event.error = { error in
            print("error \(error)")
        }
        ws.event.message = { message in
            //result = распарсить message {"text":"И тебе привет","user_id":1,"room_id":10,"created_at":"2015-08-06T13:44:07"}
            var result = ChatRoomsService.Message()
            if var messageJSON = message as? NSDictionary {
                result.text = messageJSON["text"]!.stringValue
                result.userSenderId = Int(messageJSON["user_id"]!.intValue)
                result.roomId = Int(messageJSON["room_id"]!.intValue)
                result.dateTimeCreated = ChatRoomsService().formatter.dateFromString(messageJSON["created_at"]!.stringValue)!
            }
                self.messagesArray.append(result)
                self.messageTableView.reloadData()
        }
        
    }
    
    
    
}