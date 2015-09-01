import UIKit
import Alamofire
import SwiftWebSocket
import SwiftyJSON
import RealmSwift

class RegViewController: UIViewController {
    
    @IBOutlet weak var LoginField: UITextField!
    @IBOutlet weak var PassField: UITextField!
    @IBOutlet weak var PassRepeatField: UITextField!
    var session = currSession2()
    let realm = Realm()
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func getResultOperation(response: [String: String]) -> Void {
        if response["error"] == nil {
            self.session.session_id = response["session_id"]!
            //self.session.session_id = "2e2a55e1-3967-4e75-bfb1-7151b823ca6f"
            //Запишем сессию в локальную БД
            self.realm.write {
                self.realm.deleteAll()
                self.realm.add(self.session)
            }
            
            //Переходим в экран "Мои чаты"
            self.performSegueWithIdentifier("RegToChatList", sender: self)
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




