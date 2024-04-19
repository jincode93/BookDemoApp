//
//  Book.swift
//  BookDemoApp
//
//  Created by Zerom on 4/18/24.
//

import Foundation

struct BookListModel: Decodable {
    let item: [Book]?
    
    private enum CodingKeys: String, CodingKey {
        case item
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        item = try container.decodeIfPresent([Book].self, forKey: .item)
    }
}
        
struct Book: Decodable, Hashable {
    let id: String
    let title: String
    let author: String
    let pubdate: String
    let desc: String
    let sales: Int?
    let price: Int?
    let coverURL: String
    let publisher: String
    let reviewRank: Int
    
    private enum CodingKeys: String, CodingKey {
        case id = "isbn"
        case title
        case author
        case pubdate = "pubDate"
        case desc = "description"
        case sales = "pricesales"
        case price = "pricestandard"
        case coverURL = "cover"
        case publisher
        case reviewRank = "customerReviewRank"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        author = try container.decode(String.self, forKey: .author)
        pubdate = try container.decode(String.self, forKey: .pubdate)
        desc = try container.decode(String.self, forKey: .desc)
        sales = try container.decodeIfPresent(Int.self, forKey: .sales)
        price = try container.decodeIfPresent(Int.self, forKey: .price)
        coverURL = try container.decode(String.self, forKey: .coverURL)
        publisher = try container.decode(String.self, forKey: .publisher)
        reviewRank = try container.decode(Int.self, forKey: .reviewRank)
    }
}

extension Book {
    private init(
        id: String,
        title: String,
        author: String,
        pubdate: String,
        desc: String,
        sales: Int,
        price: Int,
        coverURL: String,
        publisher: String,
        reviewRank: Int
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.pubdate = pubdate
        self.desc = desc
        self.sales = sales
        self.price = price
        self.coverURL = coverURL
        self.publisher = publisher
        self.reviewRank = reviewRank
    }
    
    static var stub1: Book {
        .init(id: "1111",
              title: "테스트책1",
              author: "Zerom",
              pubdate: "",
              desc: "테스트 모델 첫번째",
              sales: 10000,
              price: 12000,
              coverURL: "",
              publisher: "1번 출판사",
              reviewRank: 10)
    }
    
    static var stub2: Book {
        .init(id: "2222",
              title: "테스트책2",
              author: "Zerom",
              pubdate: "",
              desc: "테스트 모델 두번째",
              sales: 8000,
              price: 11000,
              coverURL: "",
              publisher: "2번 출판사",
              reviewRank: 8)
    }
    
    static var stub3: Book {
        .init(id: "3333",
              title: "테스트책3",
              author: "Zerom",
              pubdate: "",
              desc: "테스트 모델 세번째",
              sales: 24000,
              price: 28000,
              coverURL: "",
              publisher: "3번 출판사",
              reviewRank: 3)
    }
}
