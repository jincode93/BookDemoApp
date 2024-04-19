//
//  BookNetwork.swift
//  BookDemoApp
//
//  Created by Zerom on 4/19/24.
//

import Foundation
import RxSwift

protocol BookNetworkType {
    func getBestsellerList() -> Observable<BookListModel>
    func getEditorChoiceList() -> Observable<BookListModel>
    func getNewSpecialList() -> Observable<BookListModel>
    func getNewCategoryList() -> Observable<BookListModel>
    func getNewAllList() -> Observable<BookListModel>
}

final class BookNetwork: BookNetworkType {
    private let network: Network<BookListModel>
    private let listPath = "itemList.aspx"
    
    init(network: Network<BookListModel>) {
        self.network = network
    }
    
    func getBestsellerList() -> Observable<BookListModel> {
        return network.getItemList(path: listPath, query: "QueryType=Bestseller&Cover=Big")
    }
    
    func getEditorChoiceList() -> Observable<BookListModel> {
        return network.getItemList(path: listPath, query: "QueryType=ItemEditorChoice&CategoryId=170")
    }
    
    func getNewSpecialList() -> Observable<BookListModel> {
        return network.getItemList(path: listPath, query: "QueryType=ItemNewSpecial")
    }
    
    func getNewCategoryList() -> Observable<BookListModel> {
        return network.getItemList(path: listPath, query: "QueryType=ItemNewAll&CategoryId=170")
    }
    
    func getNewAllList() -> Observable<BookListModel> {
        return network.getItemList(path: listPath, query: "QueryType=ItemNewAll")
    }
}

final class StubBookNetwork: BookNetworkType {
    func getBestsellerList() -> RxSwift.Observable<BookListModel> {
        let items: [Book] = [Book.stub1, Book.stub2, Book.stub3]
        let bookListModel: BookListModel = .init(item: items)
        return Observable.just(bookListModel)
    }
    
    func getEditorChoiceList() -> RxSwift.Observable<BookListModel> {
        let items: [Book] = [Book.stub1, Book.stub2, Book.stub3]
        let bookListModel: BookListModel = .init(item: items)
        return Observable.just(bookListModel)
    }
    
    func getNewSpecialList() -> RxSwift.Observable<BookListModel> {
        let items: [Book] = [Book.stub1, Book.stub2, Book.stub3]
        let bookListModel: BookListModel = .init(item: items)
        return Observable.just(bookListModel)
    }
    
    func getNewCategoryList() -> RxSwift.Observable<BookListModel> {
        let items: [Book] = [Book.stub1, Book.stub2, Book.stub3]
        let bookListModel: BookListModel = .init(item: items)
        return Observable.just(bookListModel)
    }
    
    func getNewAllList() -> RxSwift.Observable<BookListModel> {
        let items: [Book] = [Book.stub1, Book.stub2, Book.stub3]
        let bookListModel: BookListModel = .init(item: items)
        return Observable.just(bookListModel)
    }
}
