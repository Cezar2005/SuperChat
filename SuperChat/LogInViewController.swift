import UIKit
import Alamofire
import SwiftWebSocket
import SwiftyJSON
import RealmSwift

class LogInViewController: UIViewController {
    
    @IBOutlet weak var entryLoginField: UITextField!
    @IBOutlet weak var entryPassField: UITextField!
    var session = currSession2()
    let realm = Realm()
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func getResultOperation(response: [String: String]) -> Void {
        
        if response["error"] == nil {
            self.session.session_id = response["session_id"]!
            //Запишем сессию в локальную БД
            self.realm.write {
                self.realm.deleteAll()
                self.realm.add(self.session)
            }
            //Переходим в экран "Мои чаты"
            self.performSegueWithIdentifier("LoginToChatList", sender: self)
            
        } else {
            switch response["error"]! {
            case "data_is_empty":
                println("data_is_empty")
            case "wrong_credentials":
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