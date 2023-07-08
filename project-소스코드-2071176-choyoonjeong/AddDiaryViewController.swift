//
//  AddDiaryViewController.swift
//  TermProject-2071176-choyoonjeong-TodoList
//
//  Created by ddori on 2023/06/17.
//

import UIKit
import FirebaseStorage

class AddDiaryViewController: UIViewController {
    @IBOutlet weak var today: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var diaryImage: UIImageView!
    
    @IBAction func gotoCamera(_ sender: UIButton) {
        print("카메라 눌림")
        // 컨트로러를 생성한다
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self // 이 딜리게이터를 설정하면 사진을 찍은후 호출된다

        imagePickerController.sourceType = .camera

        // UIImagePickerController이 활성화 된다, 11장을 보라
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func gotoAlbum(_ sender: UIButton) {
        print("앨범 눌림")
        // 컨트로러를 생성한다
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self // 이 딜리게이터를 설정하면 사진을 찍은후 호출된다

        imagePickerController.sourceType = .photoLibrary

        // UIImagePickerController이 활성화 된다, 11장을 보라
        present(imagePickerController, animated: true, completion: nil)
    }
    
    var diary: Diary?
    var saveChangeDelegate: ((Diary)->Void)?
    var imageUrl: String!
    var when : Date!
    //let storage = Storage.storage() //인스턴스 생성
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        diary = diary ?? Diary(date: Date(), withData: true)
        when = diary?.date ?? Date()
        today.text = when.toStringDateKo()
        
        // diary 데이터가 있으면 표시하고 아니면 표시
        if (diary!.content != "") {
            contentTextView.text = diary!.content       // contextTextView의 text를 diary의 content로 지정
            contentTextView.textColor = UIColor.black   // textColor를 검정색으로 지정
            if(diary!.imageUrl != ""){                  // diary의 imageUrl이 존재할 경우
                self.imageUrl = diary!.imageUrl         // imageUrl로 지정
                // Storage에서 사진 가져와서 보여줌
                guard let urlString = UserDefaults.standard.string(forKey: diary!.imageUrl) else { return }
                FirebaseStorageManager.downloadImage(urlString: urlString) { [weak self] image in
                    self?.diaryImage.image = image
                }
            }
        }
        else { // diary 데이터가 없을 시
            contentTextView.text = "내용을 입력하세요"           // textView의 text를 "내용을 입력하세요"로 지정
            contentTextView.textColor = UIColor.lightGray   // textColor를 회색으로 지정
            contentTextView.delegate = self                 // textVeiw 딜리게이트 등록
        }
        
        // 카메라 버튼 눌렀을 경우, 카메라로 이동할 수 있도록 탭 재스쳐 등록
        let tap1 = UITapGestureRecognizer (target: self, action: #selector (gotoCamera))
        diaryImage.addGestureRecognizer(tap1)
        diaryImage.isUserInteractionEnabled = true
        
        // 앨범 버튼 눌렀을 경우, 앨범으로 이동할 수 있도록 탭 재스쳐 등록
        let tap2 = UITapGestureRecognizer (target: self, action: #selector (gotoAlbum))
        diaryImage.addGestureRecognizer(tap2)
        diaryImage.isUserInteractionEnabled = true
        
        // 화면 탭하면 키보드 사라짐
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if(contentTextView.text != "내용을 입력하세요" && contentTextView.text != ""){
            // 내용이 있을 경우 diary에 저장
            diary!.date = when
            diary!.owner = "kong"
            diary!.content = contentTextView.text
            diary!.imageUrl = self.imageUrl ?? ""
            saveChangeDelegate?(diary!)
        }
    }

    @objc func dismissKeyboard() {
        view.endEditing(true) // 키보드 사라지도록 함
    }
}

extension AddDiaryViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        // 텍스트를 입력하려할 시 textView의 내용을 없애고, text의 색깔을 검정색으로 한다.
        if textView.text == "내용을 입력하세요" {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        // textView가 비어있다면 textView의 내용을 "내용을 입력하세요"로 하고 text의 색깔을 회색으로 한다.
        if textView.text.isEmpty {
            textView.text = "내용을 입력하세요"
            textView.textColor = UIColor.lightGray
        }
    }
}

extension AddDiaryViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    // 사진을 찍은 경우 호출되는 함수
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if(picker.sourceType == .camera){ // 카메라 사용시 imagePickerController 죽인다.
            picker.dismiss(animated: true, completion: nil)
        }
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            diaryImage.image = image // 이미지 선택시 imageView의 image로 지정
            
            // Storage에 이미지 업로드
            guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            FirebaseStorageManager.uploadImage(image: selectedImage) { url in
                if let url = url {
                    UserDefaults.standard.set(url.absoluteString, forKey: url.absoluteString)
                    self.imageUrl = url.absoluteString // imageUrl로 url 지정
                }
            }
            
        }
        
    }

    // 사진 캡쳐를 취소하는 경우 호출 함수
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // imagePickerController을 죽인다
        picker.dismiss(animated: true, completion: nil)
    }
}
