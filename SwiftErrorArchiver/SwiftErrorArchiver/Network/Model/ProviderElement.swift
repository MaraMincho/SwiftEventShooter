//
//  ProviderElement.swift
//  assignment-sdk
//
//  Created by MaraMincho on 12/1/24.
//

import Foundation

// MARK: - ProviderElement

struct ProviderElement {
    private var duration: Double = Defaults.duration
    var getDuration: Double { duration }
    var interceptor: Interceptor?
}

// MARK: - Interceptor

struct Interceptor {
    var adapt: (URLRequest) -> URLRequest
    var retry: (DefaultCompletionNetworkResponseElement) throws -> DefaultCompletionNetworkResponseElement

    init(adapt: @escaping (URLRequest) -> URLRequest, retry: @escaping (DefaultCompletionNetworkResponseElement) throws -> DefaultCompletionNetworkResponseElement) {
        self.adapt = adapt
        self.retry = retry
    }
}

extension ProviderElement {
    private enum Defaults {
        static let duration: Double = 60
    }

    static var `default`: Self {
        return .init()
    }
}
