import UIKit
import RealmSwift

//The starting ViewController. If a user is logged in on server, user chat list will be opened. Otherwise login screen (LoginViewController) will be opened.
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