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
        let carouselIndexTrigger: Observable<Int>
    }
    
    struct Output {
//        let bookResult: Observable<Result<BookResult, Error>>
        let bestsellerList: Observable<Result<BookListModel, Error>>
        let editorChoiceList: Observable<Result<BookListModel, Error>>
        let curEditorChoiceBook: Observable<Result<Book, Error>>
    }
    
    func transform(input: Input) -> Output {
        
        let bestsellerList: Observable<Result<BookListModel, Error>> = input.bookTrigger
            .flatMapLatest { _ -> Observable<Result<BookListModel, Error>> in
                return self.bookNetwork.getBestsellerList()
                    .map { bookList -> Result<BookListModel, Error> in
                        let items = bookList.item
                        let firstList = items.map { $0.newBook(newId: "111") }
                        let lastList = items.map { $0.newBook(newId: "222") }
                        let newBookListModel: BookListModel = .init(item: firstList + items + lastList)
                        return .success(newBookListModel)
                    }.catch { error in
                        return Observable.just(.failure(error))
                    }
            }
        
        var editorChoiceArray = [Book]()
        let editorChoiceList: Observable<Result<BookListModel, Error>> = input.bookTrigger
            .flatMapLatest { _ -> Observable<Result<BookListModel, Error>> in
                return self.bookNetwork.getEditorChoiceList()
                    .map { bookList -> Result<BookListModel, Error> in
                        let items = bookList.item
                        let firstList = items.map { $0.newBook(newId: "111") }
                        let lastList = items.map { $0.newBook(newId: "222") }
                        
//                        editorChoiceArray = firstList + items + lastList
                        
                        let newBookListModel: BookListModel = .init(item: firstList + items + lastList)
                        return .success(newBookListModel)
                    }.catch { error in
                        return Observable.just(.failure(error))
                    }
            }
    
        let curEditorChoiceBook: Observable<Result<Book, Error>> = input.carouselIndexTrigger
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .flatMapLatest { index -> Observable<Result<Book, Error>> in
                let newIndex = index - 1
                if newIndex >= 0 && newIndex < editorChoiceArray.count {
                    return Observable.just(.success(editorChoiceArray[newIndex]))
                } else {
                    return Observable.just(.failure(HomeError.notFoundEditorChoiceData))
                }
            }
        
        return Output(bestsellerList: bestsellerList,
                      editorChoiceList: editorChoiceList,
                      curEditorChoiceBook: curEditorChoiceBook)
    }
}
