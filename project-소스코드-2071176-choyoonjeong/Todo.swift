//
//  Todo.swift
//  TermProject-2071176-choyoonjeong-TodoList
//
//  Created by ddori on 2023/06/17.
//

import Foundation
import Firebase
import FirebaseFirestore

class Todo: NSObject, NSCoding{
    enum Kind: Int {
        case Todo = 0, Meeting, Study, Etc
        func toString() -> String{
            switch self {
                case .Todo: return "TODO";     case .Meeting: return "MEETING"
                case .Study: return "STUDY";    case .Etc: return "ELSE"
            }
        }
        static var count: Int { return Kind.Etc.rawValue + 1}
    }
    var key: String;        var date: Date
    var owner: String?;     var kind: Kind
    var content: String;    var check: Bool
    //var image: Image
    
    init(date: Date, owner: String?, kind: Kind, content: String, check: Bool){
        self.key = UUID().uuidString   // 거의 unique한 id를 만들어 낸다.
        self.date = Date(timeInterval: 0, since: date)
        self.kind = kind; self.content = content
        self.check = check;
        super.init()
    }
    
    // archiving할때 호출된다
    func encode(with aCoder: NSCoder) {
        aCoder.encode(key, forKey: "key")       // 내부적으로 String의 encode가 호출된다
        aCoder.encode(date, forKey: "date")
        aCoder.encode(owner, forKey: "owner")
        aCoder.encode(kind.rawValue, forKey: "kind")
        aCoder.encode(content, forKey: "content")
        aCoder.encode(check, forKey: "check")
    }
    // unarchiving할때 호출된다
    required init(coder aDecoder: NSCoder) {
        key = aDecoder.decodeObject(forKey: "key") as! String? ?? "" // 내부적으로 String.init가 호출된다
        date = aDecoder.decodeObject(forKey: "date") as! Date
        owner = aDecoder.decodeObject(forKey: "owner") as? String
        let rawValue = aDecoder.decodeInteger(forKey: "kind")
        kind = Kind(rawValue: rawValue)!
        content = aDecoder.decodeObject(forKey: "content") as! String? ?? ""
        check = false
        super.init()
    }

}

extension Todo{
    convenience init(date: Date? = nil, withData: Bool = false){
        if withData == true{
            var index = Int(arc4random_uniform(UInt32(Kind.count)))
            let kind = Kind(rawValue: index)! // 이것의 타입은 옵셔널이다. Option+click해보라
            self.init(date: date ?? Date(), owner: "me", kind: kind, content: "", check: false)
            
        }else{
            self.init(date: date ?? Date(), owner: "me", kind: .Etc, content: "", check: false)

        }
    }
}

extension Todo{
    func clone() -> Todo {
        let clonee = Todo()

        clonee.key = self.key    // key는 String이고 String은 struct이다. 따라서 복제가 된다
        clonee.date = Date(timeInterval: 0, since: self.date) // Date는 struct가 아니라 class이기 때문
        clonee.owner = self.owner
        clonee.kind = self.kind    // enum도 struct처럼 복제가 된다
        clonee.content = self.content
        return clonee
    }
}

extension Todo{
    func toDict() -> [String: Any?]{
        var dict: [String: Any?] = [:]
        dict["key"] = key
        dict["date"] = Timestamp(date: date)
        dict["owner"] = owner
        dict["kind"] = kind.rawValue
        dict["content"] = content
        dict["check"] = check
        return dict
    }
    func toTodo(dict: [String: Any?]) {
        key = dict["key"] as! String
        date = Date()
        if let timestamp = dict["date"] as? Timestamp{
            date = timestamp.dateValue ()
        }
        owner = dict["owner"] as? String
        let rawValue = dict["kind"] as! Int
        kind = Todo.Kind (rawValue: rawValue)!
        content = dict["content"] as! String
        check = dict["check"] as! Bool
    }
}

