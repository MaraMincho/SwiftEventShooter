//
//  ProviderElementAdaptor.swift
//  assignment-sdk
//
//  Created by MaraMincho on 12/1/24.
//

import Foundation

enum ProviderElementAdaptor {
    static func set(providerElement: ProviderElement, urlRequest: URLRequest) -> URLRequest {
        var mutableRequest = urlRequest
        mutableRequest.timeoutInterval = providerElement.timeoutInterval
        if let adapt = providerElement.interceptor?.adapt {
            mutableRequest = adapt(mutableRequest)
        }
        return mutableRequest
    }

    static func set(providerElement: ProviderElement, response: DefaultCompletionNetworkResponseElement) throws -> DefaultCompletionNetworkResponseElement {
        if let retry = providerElement.interceptor?.retry {
            return try retry(response)
        }
        return response
    }
}
