import UIKit
import Alamofire
import SwiftWebSocket
import SwiftyJSON

class LogInViewController: UIViewController {
    
    @IBOutlet weak var entryLoginField: UITextField!
    @IBOutlet weak var entryPassField: UITextField!
   
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
                println("Request = \(request)")
                println("Response = \(response)")
                println("Error = \(error)")
                println("Data = \(data)")
                
        SwiftyJSON.
        }
        
    }
    
}

