//
//  SelectViewController.swift
//  TermProject-2071176-choyoonjeong-TodoList
//
//  Created by ddori on 2023/06/17.
//

import UIKit

class SelectViewController: UIViewController {

    @IBAction func gotoTodo(_ sender: UIButton) {
        // 버튼을 누르면
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let todoViewController = storyboard.instantiateViewController(withIdentifier: "TodoViewController") as? TodoViewController {
        navigationController?.pushViewController(todoViewController, animated: true)
        }
    }
    
    
    @IBAction func gotoDiary(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let diaryViewController = storyboard.instantiateViewController(withIdentifier: "DiaryViewController") as? DiaryViewController {
        navigationController?.pushViewController(diaryViewController, animated: true)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
