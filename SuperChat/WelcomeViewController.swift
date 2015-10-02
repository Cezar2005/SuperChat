import UIKit
import RealmSwift

class WelcomeViewController: UIViewController {
    
    override func viewDidAppear(animated: Bool) {
        
        InfoUserService().infoAboutUser( {(result: [String: String]) -> Void in
            if result.isEmpty || (result["error"] != nil)  {
                self.performSegueWithIdentifier("WelcomeToLogin", sender: self)
            } else {
                self.performSegueWithIdentifier("WelcomeToChatList", sender: self)
            }
        })
    
    }
}
//|| (result["error"]["code"]! == "unauthorized")
//result["error"]! == "session_not_found"