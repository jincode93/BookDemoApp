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
//        bookNetwork = provider.makeBookNetwork()
        bookNetwork = provider.makeStubBookNetwork()
    }
    
    struct Input {
        let bookTrigger: Observable<Void>
        let horizontalPageTrigger: Observable<Int>
        let selectedCategoryTrigger: Observable<Int>
    }
    
    struct Output {
        let bookResult: Observable<Result<BookResult, Error>>
        let horizontalPageResult: Observable<Result<BookListModel, Error>>
        let categoryResult: Observable<Result<BookListModel, Error>>
    }
    
    func transform(input: Input) -> Output {
        let defaultCategorys: CategoryType = .init(categorys: [.economy, .science, .comic, .novel, .social, .travel, .essay, .history, .test, .kids])
        
        let categoryList: Observable<CategoryType> = Observable.just(defaultCategorys)
        
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
        
        let bookResult = input.bookTrigger.flatMapLatest { [unowned self] _ -> Observable<Result<BookResult, Error>> in
            return Observable.combineLatest(
                bestsellerList,
                editorChoiceList,
                self.bookNetwork.getNewSpecialList(1),
                categoryList,
                self.bookNetwork.getNewCategoryList(defaultCategorys.categorys[0].id)
            ) { bestseller, editorChoice, newSpecial, categoryType, category -> Result<BookResult, Error> in
                    .success(BookResult(bestseller: bestseller, editorChoice: editorChoice, newSpecial: newSpecial, categoryType: categoryType, newCategory: category))
            }.catch { error in
                return Observable.just(.failure(error))
            }
        }
        
        let horizontalPageResult: Observable<Result<BookListModel, Error>> = input.horizontalPageTrigger
            .flatMap { [unowned self] pageNum -> Observable<Result<BookListModel, Error>> in
                return self.bookNetwork.getNewSpecialList(pageNum).map { bookList in
                    .success(bookList)
                }.catch { error in
                    return Observable.just(.failure(error))
                }
            }
        
        let categoryResult: Observable<Result<BookListModel, Error>> = input.selectedCategoryTrigger
            .flatMap { [unowned self] cid -> Observable<Result<BookListModel, Error>> in
                return self.bookNetwork.getNewCategoryList(cid).map { bookList in
                    .success(bookList)
                }.catch { error in
                    return Observable.just(.failure(error))
                }
            }
        
        return Output(bookResult: bookResult,
                      horizontalPageResult: horizontalPageResult,
                      categoryResult: categoryResult)
    }
}
