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
    
    @IBAction func Registration() {
        
        var arrayRegFiled = [LoginField, PassField, PassRepeatField]
        var registrationIsAvalible = true
        
        LoginField.backgroundColor = UIColor.whiteColor()
        PassField.backgroundColor = UIColor.whiteColor()
        PassRepeatField.backgroundColor = UIColor.whiteColor()
        
        //Проверка полей на заполненность и выделение незаполненных
        if !arrayRegFiled.isEmpty {
            for Field in arrayRegFiled {
                if Field.text.isEmpty {
                    registrationIsAvalible = false
                    Field.backgroundColor = UIColor.lightGrayColor()
                    println("Поле '\(Field.placeholder!)' пустое")
                }
            }
        }
        
        //Если регистрация возможна, то проверяем совпадение двух паролей
        if registrationIsAvalible {
            if PassRepeatField.text == PassField.text {
                println("Можно регистрироваться!")
                
                Alamofire.request(.POST, "http://localhost:8081/v1/register", parameters: ["login":LoginField.text, "password":PassField.text], encoding: .JSON)
                    .responseJSON { request, response, data, error in
                        if(error != nil) {
                            println("Error: \(error)")
                            println("Request: \(request)")
                            println("Response: \(response)")
                        } else {
                            //Сохраняем полученную сессию
                            self.session.session_id = JSON(data!)["session_id"].stringValue
                            //self.session.login = self.LoginField.text
                            self.realm.write {
                                self.realm.deleteAll()
                                self.realm.add(self.session)
                            }
                            
                            //Переходим в экран "Мои чаты"
                            self.performSegueWithIdentifier("LoginToChatList", sender: self)
                        }
                    }
            } else {
                PassField.backgroundColor = UIColor.lightGrayColor()
                PassRepeatField.backgroundColor = UIColor.lightGrayColor()
                println("Введеные пароли не совпадают")
            }
        }
        
    }
    
}




