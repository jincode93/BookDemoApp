//
//  HomeViewModel.swift
//  BookDemoApp
//
//  Created by Zerom on 4/19/24.
//

import Foundation
import RxSwift

final class HomeViewModel {
    let disposeBag = DisposeBag()
    private let bookNetwork: BookNetworkType
    
    init() {
        let provider = NetworkProvider()
        bookNetwork = provider.makeBookNetwork()
    }
    
    struct Input {
        let bookTrigger: Observable<Void>
    }
    
    struct Output {
        let bookResult: Observable<Result<BookResult, Error>>
    }
    
    func transform(input: Input) -> Output {
        let bookResult = input.bookTrigger.flatMapLatest { [unowned self] _ -> Observable<Result<BookResult, Error>> in
            return Observable.combineLatest(
                self.bookNetwork.getBestsellerList(),
                self.bookNetwork.getEditorChoiceList(),
                self.bookNetwork.getNewSpecialList(),
                self.bookNetwork.getNewCategoryList(),
                self.bookNetwork.getNewAllList()
            ) { bestseller, editorChoice, newSpecial, newCategory, newAll -> Result<BookResult, Error> in
                    .success(BookResult(bestseller: bestseller,
                                        editorChoice: editorChoice,
                                        newSpecial: newSpecial,
                                        newCategory: newCategory,
                                        newAll: newAll))
            }.catch { error in
                return Observable.just(.failure(error))
            }
        }
        
        return Output(bookResult: bookResult)
    }
}
