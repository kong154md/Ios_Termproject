//
//  DiaryGroup.swift
//  TermProject-2071176-choyoonjeong-TodoList
//
//  Created by ddori on 2023/06/17.
//

import Foundation

class DiaryGroup: NSObject{
    var diaries = [Diary]()            // var plans: [Plan] = []와 동일, 퀴리를 만족하는 plan들만 저장한다.
    var fromDate, toDate: Date?     // queryPlan 함수에서 주어진다.
    var database: DiaryDatabase!
    var parentNotification: ((Diary?, DiaryDbAction?) -> Void)?
    
    init(parentNotification: ((Diary?, DiaryDbAction?) -> Void)? ){
        super.init()
        self.parentNotification = parentNotification
        database = DiaryDbFirebase(parentNotification: receivingNotification) // 데이터베이스 생성
    }
    func receivingNotification(diary: Diary?, action: DiaryDbAction?){
        // 데이터베이스로부터 메시지를 받고 이를 부모에게 전달한다
        if let diary = diary{
            switch(action){    // 액션에 따라 적절히     plans에 적용한다
                case .Add: addDiary(diary: diary)
                case .Modify: modifyDiary(modifiedDiary: diary)
                case .Delete: removeDiary(removedDiary: diary)
                default: break
            }
        }
        if let parentNotification = parentNotification{
            parentNotification(diary, action) // 역시 부모에게 알림내용을 전달한다.
        }
    }
}
extension DiaryGroup{    // PlanGroup.swift
    
    func queryDiaryData(date: Date){
        diaries.removeAll()    // 새로운 쿼리에 맞는 데이터를 채우기 위해 기존 데이터를 전부 지운다
        
        // date가 속한 1개월 +-알파만큼 가져온다
        fromDate = date.firstOfMonth().firstOfWeek()// 1일이 속한 일요일을 시작시간
        toDate = date.lastOfMonth().lastOfWeek()    // 이달 마지막일이 속한 토요일을 마감시간
        database.queryDiary(fromDate: fromDate!, toDate: toDate!)
    }
    
    func saveChangeDiary(diary: Diary, action: DiaryDbAction){
        // 단순히 데이터베이스에 변경요청을 하고 plans에 대해서는
        // 데이터베이스가 변경알림을 호출하는 receivingNotification에서 적용한다
        database.saveChange(diary: diary, action: action)
    }
}

extension DiaryGroup{     // PlanGroup.swift
    func getDiary(date: Date? = nil) -> [Diary] {
        
        // plans중에서 date날짜에 있는 것만 리턴한다
        if let date = date{
            var diaryForDate: [Diary] = []
            let start = date.firstOfDay()    // yyyy:mm:dd 00:00:00
            let end = date.lastOfDay()    // yyyy:mm”dd 23:59:59
            for diary in diaries{
                if diary.date >= start && diary.date <= end {
                    diaryForDate.append(diary)
                }
            }
            return diaryForDate
        }
        return diaries
    }
}

extension DiaryGroup{     // PlanGroup.swift
    
    private func count() -> Int{ return diaries.count }
    
    func isInDiary(date: Date) -> Bool{
        if let from = fromDate, let to = toDate{
            return (date >= from && date <= to) ? true: false
        }
        return false
    }
    
    private func findDiary(_ key: String) -> Int?{
        for i in 0..<diaries.count{
            if key == diaries[i].key{
                return i
            }
        }
        return nil
    }
}

extension DiaryGroup{         // PlanGroup.swift
    private func addDiary(diary:Diary){ diaries.append(diary) }
    private func modifyDiary(modifiedDiary: Diary){
        if let index = findDiary(modifiedDiary.key){
            diaries[index] = modifiedDiary
        }
    }
    private func removeDiary(removedDiary: Diary){
        if let index = findDiary(removedDiary.key){
            diaries.remove(at: index)
        }
    }
    func changePlan(from: Diary, to: Diary){
        if let fromIndex = findDiary(from.key), let toIndex = findDiary(to.key) {
            diaries[fromIndex] = to
            diaries[toIndex] = from
        }
    }
}
