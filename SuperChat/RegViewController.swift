import UIKit
import Alamofire
import SwiftWebSocket
import SwiftyJSON
import RealmSwift

//The registration ViewController. It creates a new user and logging him automatically.
class RegViewController: UIViewController {
    
    @IBOutlet weak var LoginField: UITextField!
    @IBOutlet weak var PassField: UITextField!
    @IBOutlet weak var PassRepeatField: UITextField!
    
    /* ViewController properties.
    'session' - it's entity for current session.
    'realm' - it's implementation of local data base object.
    */
    var session = currSession2()
    let realm = Realm()
    
    /*  'touchesBegan()' - it's override of the default function that hides a keyboard after end editing.
        'getResultOperation()' - it's function for closure. The function argument 'response' containts the session ID. Available of session ID is successful of registration. Session will be write into object of mobile data base and then app will go to user chat list ViewController (MyChatViewController).
        'Registration()' - it's starts registration process. It's UI Action (click on the "Create account" button).
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
            self.performSegueWithIdentifier("RegToChatList", sender: self) //Successful registration. Go to Chat list screen.
        } else {
            switch response["error"]! {
            case "data_is_empty":
                println("data_is_empty")
            case "wrong_credentials":
                LoginField.backgroundColor = UIColor.lightGrayColor()
                PassField.backgroundColor = UIColor.lightGrayColor()
                PassRepeatField.backgroundColor = UIColor.lightGrayColor()
            default:
                println(response["error"]!)
            }
        }
    }
    
    @IBAction func Registration() {
        
        LoginField.backgroundColor = UIColor.whiteColor()
        PassField.backgroundColor = UIColor.whiteColor()
        PassRepeatField.backgroundColor = UIColor.whiteColor()
        
        var login: String = LoginField.text
        var password: String = PassField.text
        var passwordRepeat: String = PassRepeatField.text
        
        RegService().perform(login, password: password, passwordRepeat: passwordRepeat, completion_request: getResultOperation)
        
    }
    
}




