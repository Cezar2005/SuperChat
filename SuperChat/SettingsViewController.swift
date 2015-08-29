import UIKit
import Alamofire
import SwiftyJSON

class SettingsViewController: UIViewController {
    
    @IBAction func Logout() {
        //Выполнение логаута
        Alamofire.request(.POST, "http://localhost:8081/v1/logout")
            .responseJSON { request, response, data, error in
                if(error != nil) {
                    println("Error: \(error)")
                    println("Request: \(request)")
                    println("Response: \(response)")
                } else {
                    self.performSegueWithIdentifier("SettingsToLogin", sender: self)
                }
            }
    }
    
    
}

