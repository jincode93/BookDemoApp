//
//  HomeViewModel.swift
//  BookDemoApp
//
//  Created by Zerom on 4/19/24.
//

import Foundation
import RxSwift

enum HomeError: Error {
    case notFoundEditorChoiceData
}

final class HomeViewModel {
    let disposeBag = DisposeBag()
    private let bookNetwork: BookNetworkType
    
    init() {
        let provider = NetworkProvider()
        bookNetwork = provider.makeBookNetwork()
//        bookNetwork = provider.makeStubBookNetwork()
    }
    
    struct Input {
        let bookTrigger: Observable<Void>
    }
    
    struct Output {
        let bookResult: Observable<Result<BookResult, Error>>
    }
    
    func transform(input: Input) -> Output {
        let bestsellerList: Observable<BookListModel> = self.bookNetwork.getBestsellerList()
            .map { bookList in
                let items = bookList.item
                let firstList = items.map { $0.newBook(newId: "1") }
                let lastList = items.map { $0.newBook(newId: "2") }
                return .init(item: firstList + items + lastList)
            }
        
        let editorChoiceList: Observable<BookListModel> = self.bookNetwork.getEditorChoiceList()
            .map { bookList in
                let items = bookList.item
                let firstList = items.map { $0.newBook(newId: "1") }
                let lastList = items.map { $0.newBook(newId: "2") }
                return .init(item: firstList + items + lastList)
            }
        
        let bookResult = input.bookTrigger.flatMapLatest { _ -> Observable<Result<BookResult, Error>> in
            return Observable.combineLatest(
                bestsellerList,
                editorChoiceList
            ) { bestseller, editorChoice -> Result<BookResult, Error> in
                    .success(BookResult(bestseller: bestseller, editorChoice: editorChoice))
            }.catch { error in
                return Observable.just(.failure(error))
            }
        }
        
        return Output(bookResult: bookResult)
    }
}
