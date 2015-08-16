import UIKit
import Alamofire
import SwiftWebSocket
import SwiftyJSON
import RealmSwift

class MyChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    override func viewDidLoad() {
        
        let curSession = Realm().objects(currSession2)[0]
        //for i in 0...curSessions.count-1 {
            //let Session = curSessions[0] as currSession2
            println("\(curSession.session_id)")
        //}
        
        
        /*
        //Узнаем кем является текущий залогиненный юзер
        Alamofire.request(.GET, "http://localhost:8081/v1/info")
            .responseJSON { requestInfo, responseInfo, dataInfo, errorInfo in
                if(errorInfo != nil) {
                    println("Error: \(errorInfo)")
                    println("Request: \(requestInfo)")
                    println("Response: \(responseInfo)")
                } else {
                    println("Error: \(errorInfo)")
                    println("Request: \(requestInfo)")
                    println("Response: \(responseInfo)")
                    var jsonDataInfo = JSON(dataInfo!)
                }
        }
        
        //Получим все комнаты, доступные текущему юзеру
        Alamofire.request(.GET, "http://localhost:8081/v1/rooms")
            .responseJSON { requestRooms, responseRooms, dataRooms, errorRooms in
                if(errorRooms != nil) {
                    println("Error: \(errorRooms)")
                    println("Request: \(requestRooms)")
                    println("Response: \(responseRooms)")
                } else {
                    println("Error: \(errorRooms)")
                    println("Request: \(requestRooms)")
                    println("Response: \(responseRooms)")
                    println("Data: \(dataRooms)")
                    var jsonDataRooms = JSON(dataRooms!)
                }
        }
        
        //Ищем в комнатах другогих юзеров, не являющихся текущим залогиненным. Таким образом получаем "список контактов".
        */
        
        
    }
    
    
    //Функция возвращает количество строк, которое надо выводить в таблице
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    //Функция возвращает ячейку таблицы для вывода
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyTestSwiftCell")
        
        cell.textLabel!.text = "Вася \(indexPath.row)"
        cell.detailTextLabel!.text = "Hi, \(indexPath.row)"
        
        return cell
    }
    
}
