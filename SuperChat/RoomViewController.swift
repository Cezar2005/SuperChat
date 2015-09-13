import UIKit
import Alamofire
import SwiftWebSocket
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
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func sendButtonTapped(sender: UIButton) {
        
        self.messageTextField.endEditing(true)
        
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
                //Сообщения от меня, выравнивание по правому краю
                var bounds = CGRect()
                cell.textLabel?.textRectForBounds(bounds, limitedToNumberOfLines: 0)
            } else {
                //Сообщения не от меня, выравнивание по левому краю
                
            }
        }
        
        //cell.textLabel?.text = self.messagesArray[indexPath.row]
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !self.messagesArray.isEmpty {
            return self.messagesArray.count
        } else {
            return 0
        }
        
    }
    
}