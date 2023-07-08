//
//  DiaryViewController.swift
//  TermProject-2071176-choyoonjeong-TodoList
//
//  Created by ddori on 2023/06/17.
//

import UIKit
import FSCalendar

class DiaryViewController: UIViewController {
    var diaryGroup: DiaryGroup!
    var selectedDate: Date? = Date()     // 나중에 필요하다
    var isDiaryViewSelected = false
    var diary: Diary?

    @IBOutlet weak var fsCalendar: FSCalendar!
    
    @IBOutlet weak var diaryView: UIView!
    @IBOutlet weak var diaryTextView: UITextView!
    @IBOutlet weak var diaryImage: UIImageView!
    @IBOutlet weak var modifyButton: UIButton!
    
    @IBAction func addDiary(_ sender: UIButton) {
        if(selectedDate! > Date()){ // 미래의 일기는 작성할 수 없음
            let title = "일기 작성 제한"
            let message = "미래의 일기는 작성할 수 없습니다."

            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert) // 알림창 생성
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil) // OK 버튼 생성
            
            alertController.addAction(okAction) // 알림창에 버튼 달기
            present(alertController, animated: true, completion: nil)
        }
        else{
            if(diaryGroup.getDiary(date: selectedDate).count == 0){ // 일기가 없을 경우
                performSegue(withIdentifier: "AddDiary", sender: self) // AddDiary 세그웨이 실행하여 AddDiaryViewcontroller로 이동
            }
            else{ // 일기는 하루에 한번씩만 작성할 수 있도록 함
                let title = "일기 횟수 제한"
                let message = "일기는 하루에 하나만 작성 가능합니다."

                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert) // 알림창 생성
                let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil) // OK 버튼 생성
                
                alertController.addAction(okAction) // 알림창에 버튼 달기
                present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func modifyDiary(_ sender: UIButton) {
        
        if diaryGroup.getDiary(date: selectedDate).count != 0 {
            print("MODIFY")
            performSegue(withIdentifier: "ModifyDiary", sender: self)
        }
        else {
            let title = "수정 불가"
            let message = "수정할 일기가 존재하지 않습니다."

            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert) // 알림창 생성
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil) // OK 버튼 생성
            
            alertController.addAction(okAction) // 알림창에 버튼 달기
            present(alertController, animated: true, completion: nil) //여기서 waiting 하지 않는다
        }
    }
    
    
    @IBAction func deleteDiary(_ sender: UIButton) {
        // 일기가 있으면 삭제 기능이 되도록하고 안되면 삭제 기능이 안되도록 구현
        let diary = self.diaryGroup.getDiary(date:selectedDate).first
        if(diary != nil){ // 삭제할 일기가 있는 경우 삭제 알림 창 생성
            let title = "Delete"
            let message = "일기를 삭제하시겠습니까?"
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert) // 알림창 생성
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // 취소버튼 생성
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action:UIAlertAction) -> Void in
                // 단순히 데이터베이스에 지우기만 하면된다. 그러면 꺼꾸로 데이터베이스에서 지워졌음을 알려준다
                self.diaryGroup.saveChangeDiary(diary: diary!, action: .Delete)
            }) // 삭제 버튼 생성해 클릭시 데이터베이스에서 해당 일기를 삭제한다.
            
            alertController.addAction(cancelAction) // 알림창에 취소버튼 달기
            alertController.addAction(deleteAction) // 알림창에 삭제버튼 달기
            present(alertController, animated: true, completion: nil) //여기서 waiting 하지 않는다
        }
        else{ // 삭제할 일기가 없을 경우 경고알림창 생성
            let title = "Delete Error"
            let message = "삭제할 일기가 없습니다."
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert) // 알림창 생성
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil) // OK 버튼 생성
            
            alertController.addAction(okAction) // 알림창에 버튼 달기
            present(alertController, animated: true, completion: nil) //여기서 waiting 하지 않는다
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fsCalendar.dataSource = self                // 칼렌다의 데이터소스로 등록
        fsCalendar.delegate = self                  // 칼렌다의 딜리게이트로 등록
        
        diaryGroup = DiaryGroup(parentNotification: receivingNotification)
        diaryGroup.queryDiaryData(date: Date())       // 이달의 데이터를 가져온다. 데이터가 오면 planGroupListener가 호출된다.
        
        // textView 탭해도 키보드가 생성되지 않음
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        diaryTextView.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true) // 키보드 사라지도록 함
    }
    
    func receivingNotification(diary: Diary?, action: DiaryDbAction?){
        // 데이터가 올때마다 이 함수가 호출되는데 맨 처음에는 기본적으로 add라는 액션으로 데이터가 온다.
        fsCalendar.reloadData()     // 뱃지의 내용을 업데이트 한다
        
        // 데이터가 있으면 표시하고 아니면 표시하지 않음
        if let selectedDiary = diaryGroup.getDiary(date: selectedDate).first {
            diaryTextView.text = selectedDiary.content
            
            if(selectedDiary.imageUrl == ""){
                self.diaryImage.image = nil
            }
            else{
                guard let urlString = UserDefaults.standard.string(forKey: selectedDiary.imageUrl) else { return }
                FirebaseStorageManager.downloadImage(urlString: urlString) { [weak self] image in
                    self?.diaryImage.image = image
                }
            }
            
        } else {
            diaryTextView.text = ""
            self.diaryImage.image = nil
        }
    }

}

extension DiaryViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "AddDiary"{
            let addDiaryViewController = segue.destination as! AddDiaryViewController
            addDiaryViewController.saveChangeDelegate = saveChangeDiary
            
            // 빈 diary를 생성하여 전달한다
            addDiaryViewController.diary = Diary(date: selectedDate, withData: false)
        }
        if segue.identifier == "ModifyDiary"{
            let addDiaryViewController = segue.destination as! AddDiaryViewController
            addDiaryViewController.saveChangeDelegate = saveChangeDiary
            
            // plan을 복제하여 전달한다. 왜냐하면 수정후 취소를 할 수 있으므로
            addDiaryViewController.diary = diaryGroup.getDiary(date:selectedDate).first?.clone()
        }
        
    }

    
    // prepare함수에서 AddTodoViewController에게 전달한다
    func saveChangeDiary(diary: Diary){
        // 만약 현재 planGroupTableView에서 선택된 row가 있다면,
        // 즉, planGroupTableView의 row를 클릭하여 PlanDetailViewController로 전이 한다면
        if (modifyButton.isSelected == true){
            print("Modify Diary")
            diaryGroup.saveChangeDiary(diary: diary, action: .Modify)
        }else{
            // 이경우는 나중에 사용할 것이다.
            print("Add Diary")
            diaryGroup.saveChangeDiary(diary: diary, action: .Add)
        }
    }

}

extension DiaryViewController: FSCalendarDelegate, FSCalendarDataSource{
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 날짜가 선택되면 호출된다
        selectedDate = date.setCurrentTime()
        diaryGroup.queryDiaryData(date: date)
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        // 스와이프로 월이 변경되면 호출된다
        selectedDate = calendar.currentPage
        diaryGroup.queryDiaryData(date: calendar.currentPage)
    }
    
    // 이함수를 fsCalendar.reloadData()에 의하여 모든 날짜에 대하여 호출된다.
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        
        let diaries = diaryGroup.getDiary(date: date)
        // 작성된 일기가 있으면 해당 날짜 아래에 ✏️ 표시
        if diaries.count > 0 {
            return "✏️"
        }
        return nil
    }
}
