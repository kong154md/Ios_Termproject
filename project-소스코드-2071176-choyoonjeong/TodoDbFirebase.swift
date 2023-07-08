//
//  TodoDbFirebase.swift
//  TermProject-2071176-choyoonjeong-TodoList
//
//  Created by ddori on 2023/06/17.
//

import Foundation
import Firebase
import FirebaseFirestore

class TodoDbFirebase: TodoDatabase {
    
    var reference: CollectionReference                    // firestore에서 데이터베이스 위치
    var parentNotification: ((Todo?, TodoDbAction?) -> Void)? // PlanGroupViewController에서 설정
    var existQuery: ListenerRegistration?                 // 이미 설정한 Query의 존재여부

    required init(parentNotification: ((Todo?, TodoDbAction?) -> Void)?) {
        self.parentNotification = parentNotification
        reference = Firestore.firestore().collection("todo") // 첫번째 "plans"라는 Collection
    }
}

extension TodoDbFirebase{
    
    func saveChange(plan: Todo, action: TodoDbAction){
        if action == .Delete{
            reference.document(plan.key).delete()    // key로된 plan을 지운다
            return
        }

        let storeDate: [String : Any] = ["date": plan.date, "data": plan.toDict()]
        reference.document(plan.key).setData(storeDate)
        print(storeDate)
    }
}

extension TodoDbFirebase{
    func queryPlan(fromDate: Date, toDate: Date) {
        
        if let existQuery = existQuery{    // 이미 적용 쿼리가 있으면 제거, 중복 방지
            existQuery.remove()
        }
        let queryReference = reference.whereField("date", isGreaterThanOrEqualTo: fromDate).whereField("date", isLessThanOrEqualTo: toDate)
        // onChangingData는 쿼리를 만족하는 데이터가 있거나 firestore내에서 다른 앱에 의하여
        // 데이터가 변경되어 쿼리를 만족하는 데이터가 발생하면 호출해 달라는 것이다.
        existQuery = queryReference.addSnapshotListener(onChangingData)
    }
}

extension TodoDbFirebase {
    func onChangingData(querySnapshot: QuerySnapshot?, error: Error?) {
        guard let querySnapshot = querySnapshot else{ return }
        // 초기 데이터가 하나도 없는 경우에 count가 0이다
        if(querySnapshot.documentChanges.count <= 0){
            if let parentNotification = parentNotification { parentNotification(nil, nil)} // 부모에게 알림
        }
        
        for documentChange in querySnapshot.documentChanges {
            let data = documentChange.document.data()
            let planData = data["data"] as? [String: Any]
            let plan = Todo()
            plan.toTodo(dict: planData!)
            var action: TodoDbAction?
            switch(documentChange.type){    // 단순히 TodoDbAction으로 설정
                case    .added: action = .Add
                case    .modified: action = .Modify
                case    .removed: action = .Delete
            }
            if let parentNotification = parentNotification {parentNotification(plan, action)} // 부모에게 알림
        }
    }
}


