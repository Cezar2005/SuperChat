import Foundation

//The service provides a path to server. The path can be local or external.
class ClientAPI {
    
    var local = true                //Change that for using local or external server.
    let ServerPath: String          //Path to server of mobile app.
    let SocketPath: String          //Path to web socket server.
    
    init() {
        if local {
            ServerPath = "http://localhost:8081"
            SocketPath = "127.0.0.1:8081"
        } else {
            ServerPath = "http://46.101.136.141"
            SocketPath = "46.101.136.141"
        }
    }
}