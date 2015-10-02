import UIKit
import RealmSwift

//The starting ViewController. If user is login on server, user chat list will be open. Else login screen (LoginViewController) will be open.
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