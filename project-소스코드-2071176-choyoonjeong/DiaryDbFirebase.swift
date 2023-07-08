//
//  DiaryDbFirebase.swift
//  TermProject-2071176-choyoonjeong-TodoList
//
//  Created by ddori on 2023/06/17.
//

import Foundation
import Firebase
import FirebaseFirestore

class DiaryDbFirebase: DiaryDatabase {
    
    var reference: CollectionReference                    // firestore에서 데이터베이스 위치
    var parentNotification: ((Diary?, DiaryDbAction?) -> Void)? // PlanGroupViewController에서 설정
    var existQuery: ListenerRegistration?                 // 이미 설정한 Query의 존재여부

    required init(parentNotification: ((Diary?, DiaryDbAction?) -> Void)?) {
        self.parentNotification = parentNotification
        reference = Firestore.firestore().collection("diary") // 첫번째 "plans"라는 Collection
    }
}

extension DiaryDbFirebase{
    
    func saveChange(diary: Diary, action: DiaryDbAction){
        if action == .Delete{
            reference.document(diary.key).delete()    // key로된 plan을 지운다
            return
        }
        
        let storeDate: [String : Any] = ["date": diary.date, "data": diary.toDict()]
        reference.document(diary.key).setData(storeDate)
        print(storeDate)
    }
}

extension DiaryDbFirebase{
    
    func queryDiary(fromDate: Date, toDate: Date) {
        
        if let existQuery = existQuery{    // 이미 적용 쿼리가 있으면 제거, 중복 방지
            existQuery.remove()
        }
        // where plan.date >= fromDate and plan.date <= toDate
        let queryReference = reference.whereField("date", isGreaterThanOrEqualTo: fromDate).whereField("date", isLessThanOrEqualTo: toDate)

        // onChangingData는 쿼리를 만족하는 데이터가 있거나 firestore내에서 다른 앱에 의하여
        // 데이터가 변경되어 쿼리를 만족하는 데이터가 발생하면 호출해 달라는 것이다.
        existQuery = queryReference.addSnapshotListener(onChangingData)
    }
}

extension DiaryDbFirebase {
    func onChangingData(querySnapshot: QuerySnapshot?, error: Error?) {
        guard let querySnapshot = querySnapshot else{ return }
        // 초기 데이터가 하나도 없는 경우에 count가 0이다
        if(querySnapshot.documentChanges.count <= 0){
            if let parentNotification = parentNotification { parentNotification(nil, nil)} // 부모에게 알림
        }
        
        for documentChange in querySnapshot.documentChanges {
            let data = documentChange.document.data()
            
            let diaryData = data["data"] as? [String: Any]
            //print(planData)
            let diary = Diary()
            diary.toPlan(dict: diaryData!)
            var action: DiaryDbAction?
            switch(documentChange.type){    // 단순히 DbAction으로 설정
                case    .added: action = .Add
                case    .modified: action = .Modify
                case    .removed: action = .Delete
            }
            if let parentNotification = parentNotification {parentNotification(diary, action)} // 부모에게 알림
        }
    }
}


