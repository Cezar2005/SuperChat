import UIKit
import Alamofire
import RealmSwift
import SwiftyJSON
import Starscream

class Room2ViewController: UIViewController {
    
    var sampleText = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    var paragraphStyle = NSMutableParagraphStyle()
    
    
    override func viewDidLoad() {
        
        paragraphStyle.alignment = NSTextAlignment.Justified
        
        var attributedString = NSAttributedString(string: sampleText,
        attributes: [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSBaselineOffsetAttributeName: NSNumber(float: 0)
        ])
        var label = UILabel()
        label.attributedText = attributedString
        label.numberOfLines = 0
        label.frame = CGRectMake(0, 0, 400, 400)

        var view = UIView()
        view.frame = CGRectMake(0, 0, 400, 400)
        view.addSubview(label)
    }
    
}