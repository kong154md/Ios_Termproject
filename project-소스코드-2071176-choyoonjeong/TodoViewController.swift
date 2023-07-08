//
//  TodoViewController.swift
//  TermProject-2071176-choyoonjeong-TodoList
//
//  Created by ddori on 2023/06/17.
//

import UIKit
import FSCalendar

class TodoViewController: UIViewController {

    @IBOutlet weak var fsCalendar: FSCalendar!
    @IBOutlet weak var todoGroupTableView: UITableView!
    
    @IBAction func addTodo(_ sender: UIButton) {
        performSegue(withIdentifier: "AddTodo", sender: self)
    }
    
    var items:[String] = []
    var todoGroup: TodoGroup!
    var selectedDate: Date? = Date()     // 나중에 필요하다
    var checkTodo = 0
    var todo: Todo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fsCalendar.dataSource = self                // 캘린더의 데이터소스 등록
        fsCalendar.delegate = self                  // 캘린더의 딜리게이트 등록
        
        todoGroupTableView.dataSource = self        // 테이블뷰의 데이터소스 등록
        todoGroupTableView.delegate = self          // 테이블뷰의 딜리게이트 등록
        

        todoGroup = TodoGroup(parentNotification: receivingNotification)
        todoGroup.queryData(date: Date()) // 이달의 데이터를 가져온다. 데이터가 오면 planGroupListener가 호출된다.
    }

    func receivingNotification(plan: Todo?, action: TodoDbAction?){
        // 데이터가 올때마다 이 함수가 호출되는데 맨 처음에는 기본적으로 add라는 액션으로 데이터가 온다.
        self.todoGroupTableView.reloadData()  // 속도를 증가시키기 위해 action에 따라 개별적 코딩도 가능하다.
        fsCalendar.reloadData()     // 뱃지의 내용을 업데이트 한다
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        if let cell = sender.superview?.superview as? UITableViewCell, let indexPath = todoGroupTableView.indexPath(for: cell) {
            let todo = todoGroup.getPlans(date: selectedDate)[indexPath.row]
            print(indexPath.row)
            
            if todo.check == false {
                todo.check = true
            } else {
                todo.check = false
            }
            
            todoGroup.saveChange(plan: todo, action: .Modify)
            print(todo)
            
            // 현재 선택된 날짜의 버튼 상태를 갱신
            if let selectedDate = selectedDate, selectedDate == fsCalendar.selectedDate {
                todoGroupTableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }

}

extension TodoViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTodo"{
            let addTodoViewController = segue.destination as! AddTodoViewController
            // todo가 수정되면 이 saveChangeDelegate를 호출한다
            addTodoViewController.saveChangeDelegate = saveChange
            
            // 선택된 row가 있어야 한다
            if let row = todoGroupTableView.indexPathForSelectedRow?.row{
                // 수정 후 취소할 경우를 대비하여 todo를 복제한다
                addTodoViewController.todo = todoGroup.getPlans(date:selectedDate)[row].clone()
            }
        }
        
        if segue.identifier == "AddTodo"{
            let addTodoViewController = segue.destination as! AddTodoViewController
            // todo가 추가되면 이 saveChageDelegate를 호출한다.
            addTodoViewController.saveChangeDelegate = saveChange
            
            // 빈 todo을 생성하여 전달한다
            addTodoViewController.todo = Todo(date:selectedDate, withData: false)
            todoGroupTableView.selectRow(at: nil, animated: true, scrollPosition: .none)

        }
    }
    
    // prepare함수에서 PlanDetailViewController에게 전달한다
    func saveChange(plan: Todo){
        // 만약 현재 planGroupTableView에서 선택된 row가 있다면,
        // 즉, planGroupTableView의 row를 클릭하여 PlanDetailViewController로 전이 한다면
        if todoGroupTableView.indexPathForSelectedRow != nil{ // 선택한 row가 있다면
            todoGroup.saveChange(plan: plan, action: .Modify) // 변경
        }else{
            // 이경우는 나중에 사용할 것이다.
            todoGroup.saveChange(plan: plan, action: .Add)
        }
    }

}

extension TodoViewController: FSCalendarDelegate, FSCalendarDataSource{
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 날짜가 선택되면 호출된다
        selectedDate = date.setCurrentTime()
        todoGroup.queryData(date: date)
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        // 스와이프로 월이 변경되면 호출된다
        selectedDate = calendar.currentPage
        todoGroup.queryData(date: calendar.currentPage)
    }
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        //fsCalendar.reloadData()에 의하여 모든 날짜에 대하여 호출된다.
        let plans = todoGroup.getPlans(date: date)
        if plans.count > 0 {
            return "[\(plans.count)]"    // date에 해당한 plans의 갯수를 뱃지로 출력한다
        }
        return nil
    }
}

extension TodoViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let todoGroup = todoGroup{
            return todoGroup.getPlans(date:selectedDate).count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoTableViewCell")! // TodoTableViewCell을 가져온다.
        
        let plan = todoGroup.getPlans(date:selectedDate)[indexPath.row] // 선택된 날짜의 todo를 가져온다
        
        let btn = cell.contentView.subviews[0] as! UIButton
        let category = cell.contentView.subviews[1] as! UILabel
        let todo = cell.contentView.subviews[2] as! UILabel
        btn.tintColor = plan.check ? UIColor.gray : UIColor.systemRed // 완료됐는지 안됐는지 색깔 표시
        btn.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside) // 버튼에 'buttonTapped' 액션을 추가하여 완료 표시를 한다.
        category.text = plan.kind.toString() // 라벨에 플랜의 todo의 카테고리를 표시한다
        todo.text = plan.content //. 라벨에 todo의 내용을 표시한다.
        
        return cell
    }
}

extension TodoViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            
            let plan = self.todoGroup.getPlans(date:selectedDate)[indexPath.row]
            let title = "Delete \(plan.content)"
            let message = "Are you sure you want to delete this item?"

            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action:UIAlertAction) -> Void in
                
                // 선택된 row의 플랜을 가져온다
                let plan = self.todoGroup.getPlans(date:self.selectedDate)[indexPath.row]
                // 단순히 데이터베이스에 지우기만 하면된다. 그러면 꺼꾸로 데이터베이스에서 지워졌음을 알려준다
                self.todoGroup.saveChange(plan: plan, action: .Delete)
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            present(alertController, animated: true, completion: nil) //여기서 waiting 하지 않는다
        }

    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        // 이것은 데이터베이스에 까지 영향을 미치지 않는다. 그래서 planGroup에서만 위치 변경
        let from = todoGroup.getPlans(date:selectedDate)[sourceIndexPath.row]
        let to = todoGroup.getPlans(date:selectedDate)[destinationIndexPath.row]
        todoGroup.changePlan(from: from, to: to)
        tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
    }
}
