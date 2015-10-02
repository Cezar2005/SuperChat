import Foundation

//The service provides utility methods.
class UtilityClasses {
    
    //The function convers string value in format '{key: value}' to json object. The json object is Dictionary type.
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            var error: NSError?
            let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as? [String:AnyObject]
            if error != nil {
                println(error)
            }
            return json
        }
        return nil
    }
    
    //The function checks the string for invalid characters.
    func containsOnlyLetters(input: String) -> Bool {
        for chr in input {
            if (!(chr >= "a" && chr <= "z") && !(chr >= "A" && chr <= "Z") ) {
                return false
            }
        }
        return true
    }
    
}