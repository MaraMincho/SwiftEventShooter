//
//  Interceptor.swift
//  assignment-sdk
//
//  Created by MaraMincho on 12/2/24.
//

import Foundation

// MARK: - Interceptor

struct Interceptor {
    var adapt: (URLRequest) -> URLRequest
    var retry: (DefaultCompletionNetworkResponseElement) throws -> DefaultCompletionNetworkResponseElement

    init(adapt: @escaping (URLRequest) -> URLRequest, retry: @escaping (DefaultCompletionNetworkResponseElement) throws -> DefaultCompletionNetworkResponseElement) {
        self.adapt = adapt
        self.retry = retry
    }
}
