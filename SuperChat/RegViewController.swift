import UIKit
import Alamofire
import SwiftWebSocket
import SwiftyJSON

class RegViewController: UIViewController {
    
    @IBOutlet weak var LoginField: UITextField!
    @IBOutlet weak var PassField: UITextField!
    @IBOutlet weak var PassRepeatField: UITextField!
    
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
                        println("Request = \(request)")
                        println("Response = \(response)")
                        println("Error = \(error)")
                        println("Data = \(data!)")
                }
            } else {
                PassField.backgroundColor = UIColor.lightGrayColor()
                PassRepeatField.backgroundColor = UIColor.lightGrayColor()
                println("Введеные пароли не совпадают")
            }
        }
        
    }

}




