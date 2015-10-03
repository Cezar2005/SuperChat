import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift

//The viewController allows to logout for a current user.
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
    
    //The function runs logout of a current user. An application will change a screen to a login screen after logout.
    @IBAction func Logout() {
        LoginService().logout({(result: Bool) -> Void in
            if result {
                self.performSegueWithIdentifier("SettingsToLogin", sender: self)
            }
        })
    }
}