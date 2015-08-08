import UIKit
import Alamofire
import SwiftWebSocket
import SwiftyJSON

class LogInViewController: UIViewController {
    
    func testAlamofire() {

        Alamofire.request(.POST, "http://localhost:8081/v1/register", parameters: ["login":"Pupsik", "password":"qwerty3333"], encoding: .JSON)
            .response { request, response, data, error in
                //println(request)
                //println(response)
                //println(error)
        }
    }
    
    func echoTest(){
        var messageNum = 0
        let ws = WebSocket(url: "wss://echo.websocket.org")
        let send : ()->() = {
            let msg = "\(++messageNum): \(NSDate().description)"
            print("send: \(msg)")
            ws.send(msg)
        }
        ws.event.open = {
            print("opened")
            send()
        }
        ws.event.close = { code, reason, clean in
            print("close")
        }
        ws.event.error = { error in
            print("error \(error)")
        }
        ws.event.message = { message in
            if let text = message as? String {
                print("recv: \(text)")
                if messageNum == 10 {
                    ws.close()
                } else {
                    send()
                }
            }
        }
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
}

