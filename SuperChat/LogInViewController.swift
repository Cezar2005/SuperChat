import UIKit
import Alamofire
import SwiftWebSocket
import SwiftyJSON
import RealmSwift

//The login ViewController. It allows the user to login.
class LogInViewController: UIViewController {
    
    @IBOutlet weak var entryLoginField: UITextField!
    @IBOutlet weak var entryPassField: UITextField!
    
    /* ViewController properties.
    'session' - it's entity for current session.
    'realm' - it's implementation of local data base object.
    */
    var session = currSession2()
    let realm = Realm()
    
    /*  'touchesBegan()' - it's override of the default function that hides a keyboard after end editing.
    'getResultOperation()' - it's function for closure. The function argument 'response' containts the session ID. Available of session ID is successful of authorization. Session will be write into object of mobile data base and then app will go to user chat list ViewController (MyChatViewController).
    'Login()' - it's starts authorization process. It's UI Action (click on the "Log in" button).
    */
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func getResultOperation(response: [String: String]) -> Void {
        
        if response["error"] == nil {
            self.session.session_id = response["session_id"]!
            self.realm.write {
                self.realm.deleteAll()
                self.realm.add(self.session)
            }
            self.performSegueWithIdentifier("LoginToChatList", sender: self) //Successful authorization. Go to Chat list screen.
            
        } else {
            switch response["error"]! {
            case "data_is_empty":
                println("data_is_empty")
            case "wrong_credentials", "user_not_found":
                entryLoginField.backgroundColor = UIColor.lightGrayColor()
                entryPassField.backgroundColor = UIColor.lightGrayColor()
            default:
                println(response["error"]!)
            }
        }
    }
    
    @IBAction func Login() {
        
        entryLoginField.backgroundColor = UIColor.whiteColor()
        entryPassField.backgroundColor = UIColor.whiteColor()
        
        var login: String = entryLoginField.text
        var password: String = entryPassField.text
        
        LoginService().perform(login, password: password, completion_request: getResultOperation)
        
    }
    
}