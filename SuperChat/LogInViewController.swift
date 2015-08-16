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
        
        var arrayLoginFiled = [entryLoginField, entryPassField]
        var loginIsAvalible = true
        
        entryLoginField.backgroundColor = UIColor.whiteColor()
        entryPassField.backgroundColor = UIColor.whiteColor()
        
        //Проверка полей на заполненность и выделение незаполненных
        if !arrayLoginFiled.isEmpty {
            for Field in arrayLoginFiled {
                if Field.text.isEmpty {
                    loginIsAvalible = false
                    Field.backgroundColor = UIColor.lightGrayColor()
                    println("Поле '\(Field.placeholder!)' пустое")
                }
            }
        }
        
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
    }
    
}

