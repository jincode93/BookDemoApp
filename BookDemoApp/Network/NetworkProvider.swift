//
//  NetworkProvider.swift
//  BookDemoApp
//
//  Created by Zerom on 4/19/24.
//

import Foundation

final class NetworkProvider {
    private let endpoint: String
    
    init() {
        self.endpoint = "https://www.aladin.co.kr/ttb/api/"
    }
    
    func makeBookNetwork() -> BookNetworkType {
        let network = Network<BookListModel>(endpoint)
        return BookNetwork(network: network)
    }
    
    func makeStubBookNetwork() -> BookNetworkType {
        return StubBookNetwork()
    }
}
