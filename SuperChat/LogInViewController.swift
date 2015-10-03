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
    'session' - it's an entity for current session.
    'realm' - it's an implementation of local data base object.
    */
    var session = currSession2()
    let realm = Realm()
    
    /*  'touchesBegan()' - it's an override of the default function that hides a keyboard after end editing.
    'getResultOperation()' - it's a function for closure. The function argument 'response' contains an ID of session. If an ID of session is available the authorization will be successful. Session will be written into the object of mobile data base and then app will go to user chat list ViewController (MyChatViewController).
    'Login()' - it's a start authorization process. It's an UI Action (click on the "Log in" button).
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