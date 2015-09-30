import UIKit
import Alamofire
import SwiftyJSON

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var LoginLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        InfoUserService().infoAboutUser( {(result: [String: String]) -> Void in
            
            if !result.isEmpty {
                self.LoginLabel.text! = result["login"]!
            } else {
                self.LoginLabel.hidden = false
            }
        })
        
    }
    
    @IBAction func Logout() {
        //Выполнение логаута
        LoginService().logout({(result: Bool) -> Void in
            if result {
                self.performSegueWithIdentifier("SettingsToLogin", sender: self)
            }
        })
    }
    
    
}

