//
//  CategoryType.swift
//  BookDemoApp
//
//  Created by Zerom on 4/24/24.
//

import Foundation

struct CategoryType: Hashable {
    let categorys: [Category]
}

struct Category: Hashable {
    let id: Int
    let title: String
    let image: String
    
    static let economy: Category = .init(id: 170, title: "경제", image: "newspaper")
    static let science: Category = .init(id: 987, title: "과학", image: "atom")
    static let comic: Category = .init(id: 2551, title: "만화", image: "quote.opening")
    static let social: Category = .init(id: 798, title: "시사", image: "person.line.dotted.person")
    static let novel: Category = .init(id: 1, title: "소설", image: "book.pages")
    static let test: Category = .init(id: 1383, title: "수험서", image: "pencil.line")
    static let kids: Category = .init(id: 1108, title: "어린이", image: "figure.2.and.child.holdinghands")
    static let essay: Category = .init(id: 55889, title: "에세이", image: "book.closed")
    static let travel: Category = .init(id: 1196, title: "여행", image: "airplane")
    static let history: Category = .init(id: 74, title: "역사", image: "globe.americas")
}
