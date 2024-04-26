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
    func getNewSpecialList(_ page: Int) -> Observable<BookListModel>
    func getNewCategoryList(_ cid: Int) -> Observable<BookListModel>
    func getNewAllList(_ page: Int) -> Observable<BookListModel>
}

final class BookNetwork: BookNetworkType {
    private let network: Network<BookListModel>
    private let listPath = "itemList.aspx"
    
    init(network: Network<BookListModel>) {
        self.network = network
    }
    
    func getBestsellerList() -> Observable<BookListModel> {
        return network.getItemList(path: listPath, query: "QueryType=Bestseller")
    }
    
    func getEditorChoiceList() -> Observable<BookListModel> {
        return network.getItemList(path: listPath, query: "QueryType=ItemEditorChoice&CategoryId=170")
    }
    
    func getNewSpecialList(_ page: Int) -> Observable<BookListModel> {
        return network.getItemList(path: listPath, query: "QueryType=ItemNewSpecial&start=\(page)", maxResults: 20)
    }
    
    func getNewCategoryList(_ cid: Int) -> Observable<BookListModel> {
        return network.getItemList(path: listPath, query: "QueryType=ItemNewAll&CategoryId=\(cid)", maxResults: 20)
    }
    
    func getNewAllList(_ page: Int) -> Observable<BookListModel> {
        return network.getItemList(path: listPath, query: "QueryType=ItemNewAll&start=\(page)", maxResults: 20)
    }
}

final class StubBookNetwork: BookNetworkType {
    func getBestsellerList() -> RxSwift.Observable<BookListModel> {
        let items: [Book] = [
            Book.stub1.newBook(newId: "1"), Book.stub2.newBook(newId: "1"), Book.stub3.newBook(newId: "1"),
            Book.stub1.newBook(newId: "2"), Book.stub2.newBook(newId: "2"), Book.stub3.newBook(newId: "2"),
            Book.stub1.newBook(newId: "3"), Book.stub2.newBook(newId: "3"), Book.stub3.newBook(newId: "3")
        ]
        let bookListModel: BookListModel = .init(item: items)
        return Observable.just(bookListModel)
    }
    
    func getEditorChoiceList() -> RxSwift.Observable<BookListModel> {
        let items: [Book] = [
            Book.stub1.newBook(newId: "1"), Book.stub2.newBook(newId: "1"), Book.stub3.newBook(newId: "1"),
            Book.stub1.newBook(newId: "2"), Book.stub2.newBook(newId: "2"), Book.stub3.newBook(newId: "2"),
            Book.stub1.newBook(newId: "3"), Book.stub2.newBook(newId: "3"), Book.stub3.newBook(newId: "3")
        ]
        let bookListModel: BookListModel = .init(item: items)
        return Observable.just(bookListModel)
    }
    
    func getNewSpecialList(_ page: Int) -> RxSwift.Observable<BookListModel> {
        let items: [Book] = [
            Book.stub1.newBook(newId: "\(page)1"), Book.stub2.newBook(newId: "\(page)1"), Book.stub3.newBook(newId: "\(page)1"),
            Book.stub1.newBook(newId: "\(page)2"), Book.stub2.newBook(newId: "\(page)2"), Book.stub3.newBook(newId: "\(page)2"),
            Book.stub1.newBook(newId: "\(page)3"), Book.stub2.newBook(newId: "\(page)3"), Book.stub3.newBook(newId: "\(page)3"),
            Book.stub1.newBook(newId: "\(page)4")
        ]
        let bookListModel: BookListModel = .init(item: items)
        return Observable.just(bookListModel)
    }
    
    func getNewCategoryList(_ cid: Int) -> RxSwift.Observable<BookListModel> {
        let items: [Book] = [
            Book.stub1.newBook(newId: "\(cid)1"), Book.stub2.newBook(newId: "\(cid)1"), Book.stub3.newBook(newId: "\(cid)1"),
            Book.stub1.newBook(newId: "\(cid)2"), Book.stub2.newBook(newId: "\(cid)2"), Book.stub3.newBook(newId: "\(cid)2"),
            Book.stub1.newBook(newId: "\(cid)3"), Book.stub2.newBook(newId: "\(cid)3"), Book.stub3.newBook(newId: "\(cid)3")
        ]
        let bookListModel: BookListModel = .init(item: items)
        return Observable.just(bookListModel)
    }
    
    func getNewAllList(_ page: Int) -> RxSwift.Observable<BookListModel> {
        let items: [Book] = [
            Book.stub1.newBook(newId: "\(page)1"), Book.stub2.newBook(newId: "\(page)1"), Book.stub3.newBook(newId: "\(page)1"),
            Book.stub1.newBook(newId: "\(page)2"), Book.stub2.newBook(newId: "\(page)2"), Book.stub3.newBook(newId: "\(page)2"),
            Book.stub1.newBook(newId: "\(page)3"), Book.stub2.newBook(newId: "\(page)3"), Book.stub3.newBook(newId: "\(page)3"),
            Book.stub1.newBook(newId: "\(page)4")
        ]
        let bookListModel: BookListModel = .init(item: items)
        return Observable.just(bookListModel)
    }
}
