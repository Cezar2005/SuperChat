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
    
    @IBAction func Login() {
        
        entryLoginField.backgroundColor = UIColor.whiteColor()
        entryPassField.backgroundColor = UIColor.whiteColor()
        
        var login: String = entryLoginField.text
        var password: String = entryPassField.text
        
        var response = LoginService().perform(login, password: password)
        
        
        //Проверка полей на заполненность и выделение незаполненных
        /*
        if !arrayLoginFiled.isEmpty {
            for Field in arrayLoginFiled {
                if Field.text.isEmpty {
                    loginIsAvalible = false
                    Field.backgroundColor = UIColor.lightGrayColor()
                    println("Поле '\(Field.placeholder!)' пустое")
                }
            }
        }
        */
        
        if response["error"] == nil {
            //self.session.session_id = response["session_id"]!
            self.session.session_id = "2e2a55e1-3967-4e75-bfb1-7151b823ca6f"
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
        
        /*
        //Если логин возможен, то выполняем его
        Alamofire.request(.POST, "http://localhost:8081/v1/login", parameters: ["login":entryLoginField.text, "password":entryPassField.text], encoding: .JSON)
            .responseJSON { request, response, data, error in
                if(error != nil) {
                    println("Error: \(error)")
                    println("Request: \(request)")
                    println("Response: \(response)")
                } else {
                    var jsonData = JSON(data!)
                    if !jsonData.isEmpty {
                        if !jsonData["session_id"].isEmpty {
                            //Сохраняем полученную сессию
                            self.session.session_id = JSON(data!)["session_id"].stringValue
                            //self.session.login = self.entryLoginField.text
                            self.realm.write {
                                self.realm.deleteAll()
                                self.realm.add(self.session)
                            }
                            
                            //Переходим в экран "Мои чаты"
                            self.performSegueWithIdentifier("LoginToChatList", sender: self)
                        } else {
                            println("Параметр session_id пуст")
                        }
                    } else {
                        println("Параметр data в ответе на запрос пуст")
                    }
                }
            }
        */
    }
    
}

