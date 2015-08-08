import Foundation
import UIKit

class Check: UIViewController {
    
    func FieldsAreNotEmpty(arrayField: [UITextField]) -> Bool {
        if arrayField.isEmpty {
            return false
        } else {
            for Field in arrayField {
                if Field.text.isEmpty {
                    Field.backgroundColor = UIColor.purpleColor();
                    return false
                }
            }
        }
        return true
    }
    
}
