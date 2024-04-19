//
//  Network.swift
//  BookDemoApp
//
//  Created by Zerom on 4/18/24.
//

import Foundation
import RxSwift
import RxAlamofire

class Network<T: Decodable> {
    private let endpoint: String
    private let queue: ConcurrentDispatchQueueScheduler
    
    init(_ endpoint: String) {
        self.endpoint = endpoint
        self.queue = ConcurrentDispatchQueueScheduler(qos: .background)
    }
    
    func getItemList(path: String, query: String = "") -> Observable<T> {
        let fullPath = "\(endpoint)\(path)?ttbkey=\(APIKey)&output=js\(query)"
        return RxAlamofire.data(.get, fullPath)
            .observe(on: queue)
            .debug()
            .map { data -> T in
                return try JSONDecoder().decode(T.self, from: data)
            }
    }
}