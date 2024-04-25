//
//  Network.swift
//  BookDemoApp
//
//  Created by Zerom on 4/18/24.
//

import Foundation
import RxSwift
import RxAlamofire
import Alamofire

class Network<T: Decodable> {
    private let endpoint: String
    private let queue: ConcurrentDispatchQueueScheduler
    
    init(_ endpoint: String) {
        self.endpoint = endpoint
        self.queue = ConcurrentDispatchQueueScheduler(qos: .background)
    }
    
    func getItemList(path: String, query: String = "", maxResults: Int = 10) -> Observable<T> {
        let fullPath = "\(endpoint)\(path)?ttbkey=\(APIKey)&output=js&\(query)&MaxResults=\(maxResults)&SearchTarget=Book&Cover=Big&Version=20131101"

        return RxAlamofire.data(.get, fullPath)
            .observe(on: queue)
            .debug()
            .map { data -> T in
                return try JSONDecoder().decode(T.self, from: data)
            }
    }
}
