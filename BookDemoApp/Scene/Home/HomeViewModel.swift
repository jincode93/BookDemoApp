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
//        bookNetwork = provider.makeBookNetwork()
        bookNetwork = provider.makeStubBookNetwork()
    }
    
    struct Input {
        let bookTrigger: Observable<Void>
    }
    
    struct Output {
//        let bookResult: Observable<Result<BookResult, Error>>
        let bestsellerList: Observable<Result<BookListModel, Error>>
        let editorChoiceList: Observable<Result<BookListModel, Error>>
    }
    
    func transform(input: Input) -> Output {
//        let bookResult = input.bookTrigger.flatMapLatest { [unowned self] _ -> Observable<Result<BookResult, Error>> in
//            return Observable.combineLatest(
//                self.bookNetwork.getBestsellerList(),
//                self.bookNetwork.getEditorChoiceList(),
//                self.bookNetwork.getNewSpecialList(),
//                self.bookNetwork.getNewCategoryList(),
//                self.bookNetwork.getNewAllList()
//            ) { bestseller, editorChoice, newSpecial, newCategory, newAll -> Result<BookResult, Error> in
//                    .success(BookResult(bestseller: bestseller,
//                                        editorChoice: editorChoice,
//                                        newSpecial: newSpecial,
//                                        newCategory: newCategory,
//                                        newAll: newAll))
//            }.catch { error in
//                return Observable.just(.failure(error))
//            }
//        }
        
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
        
        let editorChoiceList: Observable<Result<BookListModel, Error>> = input.bookTrigger
            .flatMapLatest { _ -> Observable<Result<BookListModel, Error>> in
                return self.bookNetwork.getEditorChoiceList()
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
        
//        let editorChoiceList: Observable<Result<BookListModel, Error>> = self.bookNetwork.getEditorChoiceList()
//            .map { bookList -> Result<BookListModel, Error> in
//                return .success(bookList)
//            }.catch { error in
//                return Observable.just(.failure(error))
//            }
        
//        let bookResult = input.bookTrigger.flatMapLatest { [unowned self] _ -> Observable<Result<BookResult, Error>> in
//                    return Observable.combineLatest(
//                        self.bookNetwork.getBestsellerList(),
//                        self.bookNetwork.getEditorChoiceList()
//                    ) { bestseller, editorChoice -> Result<BookResult, Error> in
//                            .success(BookResult(bestseller: bestseller,
//                                                editorChoice: editorChoice))
//                    }.catch { error in
//                        return Observable.just(.failure(error))
//                    }
//                }
        
        return Output(bestsellerList: bestsellerList,
                      editorChoiceList: editorChoiceList)
    }
}
