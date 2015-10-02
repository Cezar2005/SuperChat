import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var LoginLabel: UILabel!
    //let realm = Realm()
    
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
                /*
                self.realm.write {
                    self.realm.deleteAll()
                }
                */
                self.performSegueWithIdentifier("SettingsToLogin", sender: self)
            }
        })
    }
    
    
}

