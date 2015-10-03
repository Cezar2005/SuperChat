import UIKit
import Alamofire
import SwiftWebSocket
import SwiftyJSON
import RealmSwift

//The registration ViewController. It creates a new user and logins him automatically.
class RegViewController: UIViewController {
    
    @IBOutlet weak var LoginField: UITextField!
    @IBOutlet weak var PassField: UITextField!
    @IBOutlet weak var PassRepeatField: UITextField!
    
    /* ViewController properties.
    'session' - it's an entity for current session.
    'realm' - it's an implementation of local data base object.
    */
    var session = currSession2()
    let realm = Realm()
    
    /*  'touchesBegan()' - it's an override of the default function that hides a keyboard after end editing.
        'getResultOperation()' - it's a function for closure. The function argument 'response' contains session ID. If an ID of session is available the regisration will be successful. An ID of session will be written into the object of mobile data base and then app will go to user chat list ViewController (MyChatViewController).
        'Registration()' - it's a start of registration process. It's an UI Action (click on the "Create account" button).
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




