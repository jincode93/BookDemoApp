//
//  ViewController.swift
//  BookDemoApp
//
//  Created by Zerom on 4/18/24.
//

import UIKit
import RxSwift

class HomeViewController: UIViewController {
    let disposeBag = DisposeBag()
    let viewModel = HomeViewModel()
    
    let bookTrigger = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        bookTrigger.onNext(())
    }
    
    private func bindViewModel() {
        let input = HomeViewModel.Input(bookTrigger: bookTrigger.asObservable())
        let output = viewModel.transform(input: input)
        
        output.bookResult.bind { result in
            switch result {
            case .success(let bookResult):
                let bestseller = bookResult.bestseller.item
                print("bestseller: \(String(describing: bestseller))")
                print("-----------------------------------------------")
                let editorChoice = bookResult.editorChoice.item
                print("editorChoice: \(String(describing: editorChoice))")
                print("-----------------------------------------------")
                let newSpecial = bookResult.newSpecial.item
                print("newSpecial: \(String(describing: newSpecial))")
                print("-----------------------------------------------")
                let newCategory = bookResult.newCategory.item
                print("newCategory: \(String(describing: newCategory))")
                print("-----------------------------------------------")
                let newAll = bookResult.newAll.item
                print("newAll: \(String(describing: newAll))")
                print("-----------------------------------------------")
            case .failure(let error):
                print(error)
            }
        }.disposed(by: disposeBag)
    }
}

