//
//  AddTodoViewController.swift
//  TermProject-2071176-choyoonjeong-TodoList
//
//  Created by ddori on 2023/06/17.
//

import UIKit

class AddTodoViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var contentTextField: UITextField!
    
    var todo: Todo?
    var saveChangeDelegate: ((Todo)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        categoryPicker.dataSource = self    // PickerView의 데이터소스 등록
        categoryPicker.delegate = self      // PickerView의 딜리게이트 등록
        
        todo = todo ?? Todo(date: Date(), withData: true) // todo 객체 생성
        datePicker.date = todo?.date ?? Date() // 날짜는 todo의 날짜 사용
        // typePickerView 초기화
        if let todo = todo{
            categoryPicker.selectRow(todo.kind.rawValue, inComponent: 0, animated: false) // todo 값이 존재할 경우, categoryPicker의 row 값 지정
        }
        contentTextField.text = todo?.content // todo의 content 값이 존재할 경우 contentTextField 값으로 지정
        
        // 화면 탭하면 키보드 사라짐
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if(contentTextField.text != ""){ // todo 내용이 있을 경우 저장
            todo!.date = datePicker.date                                                    // 날짜 지정
            todo!.owner = "kong"                                                            // owner 지정
            todo!.kind = Todo.Kind(rawValue: categoryPicker.selectedRow(inComponent: 0))!   // 카테고리 지정
            todo!.content = contentTextField.text!                                          // todo 내용 지정
            
            saveChangeDelegate?(todo!) // todo 값 저장
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true) // 키보드 사라지도록 함
    }
}

extension AddTodoViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Todo.Kind.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let type = Todo.Kind.init(rawValue: row)
        return type?.toString()
    }
}
