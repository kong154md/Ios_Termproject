//
//  Diary.swift
//  TermProject-2071176-choyoonjeong-TodoList
//
//  Created by ddori on 2023/06/17.
//

import Foundation
import Firebase
import FirebaseFirestore
import SwiftUI

class Diary: NSObject, NSCoding{
    var key: String
    var date: Date
    var owner: String?
    var content: String
    //var image: UIImage?
    var imageUrl: String
    
    init(date: Date, owner: String?, content: String, imageUrl: String){
        self.key = UUID().uuidString   // 거의 unique한 id를 만들어 낸다.
        self.date = Date(timeInterval: 0, since: date)
        self.owner = "kong"
        self.content = content
        self.imageUrl = imageUrl
        super.init()
    }
    
    // archiving할때 호출된다
    func encode(with aCoder: NSCoder) {
        aCoder.encode(key, forKey: "key")       // 내부적으로 String의 encode가 호출된다
        aCoder.encode(date, forKey: "date")
        aCoder.encode(owner, forKey: "owner")
        aCoder.encode(content, forKey: "content")
        aCoder.encode(imageUrl, forKey: "imageUrl")
        
    }
    // unarchiving할때 호출된다
    required init(coder aDecoder: NSCoder) {
        key = aDecoder.decodeObject(forKey: "key") as! String? ?? "" // 내부적으로 String.init가 호출된다
        date = aDecoder.decodeObject(forKey: "date") as! Date
        owner = aDecoder.decodeObject(forKey: "owner") as? String
        content = aDecoder.decodeObject(forKey: "content") as! String? ?? ""
        imageUrl = aDecoder.decodeObject(forKey: "imageUrl") as! String? ?? ""
        super.init()
    }

}

extension Diary{
    convenience init(date: Date? = nil, withData: Bool = false){
        if withData == true{
            self.init(date: date ?? Date(), owner: "kong", content: "", imageUrl: "")
            
        }else{
            self.init(date: date ?? Date(), owner: "kong", content: "", imageUrl: "")

        }
    }
}

extension Diary{        // Plan.swift
    func clone() -> Diary {
        let clonee = Diary()

        clonee.key = self.key    // key는 String이고 String은 struct이다. 따라서 복제가 된다
        clonee.date = Date(timeInterval: 0, since: self.date) // Date는 struct가 아니라 class이기 때문
        clonee.owner = self.owner
        clonee.content = self.content
        clonee.imageUrl = self.imageUrl
        //clonee.image = self.image
        return clonee
    }
}

extension Diary{
    func toDict() -> [String: Any?]{
        var dict: [String: Any?] = [:]
        dict["key"] = key
        dict["date"] = Timestamp(date: date)
        dict["owner"] = owner
        dict["content"] = content
        dict["imageUrl"] = imageUrl
        return dict
    }
    func toPlan(dict: [String: Any?]) {
        key = dict["key"] as! String
        date = Date()
        if let timestamp = dict["date"] as? Timestamp{
            date = timestamp.dateValue ()
        }
        owner = dict["owner"] as? String
        content = dict["content"] as! String
        imageUrl = dict["imageUrl"] as? String ?? ""

    }
}

