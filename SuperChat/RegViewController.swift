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
                    Field.backgroundColor! = UIColor(red: 0.242, green: 0.206, blue: 0.237, alpha: 0.255)
                    Field.textColor! = UIColor(red: 0.191, green: 0.021, blue: 0.154, alpha: 0.255)
                    Field.layer.borderColor = UIColor(red: 0.191, green: 0.021, blue: 0.154, alpha: 0.255).CGColor
                    println("Поле '\(Field.placeholder!)' пустое")
                }
            }
        }
        
        //Если регистрация возможна, то проверяем совпадение двух паролей
        if registrationIsAvalible {
            if PassRepeatField.text == PassField.text {
                println("Можно регистрироваться!")
                
                Alamofire.request(.POST, "http://localhost:8081/v1/register", parameters: ["login":"Pupsik", "password":"qwerty3333"], encoding: .JSON)
                    .response { request, response, data, error in
                        //println(request)
                        //println(response)
                        //println(error)
                }
            }
        }
        
        
    }
    
}




