//
//  Interceptor.swift
//  assignment-sdk
//
//  Created by MaraMincho on 12/2/24.
//

import Foundation

// MARK: - Interceptor

struct Interceptor: Sendable {
  var adapt: @Sendable (URLRequest) -> URLRequest
  var retry: @Sendable (DefaultCompletionNetworkResponseElement) throws -> DefaultCompletionNetworkResponseElement

  init(
    adapt: @escaping @Sendable (URLRequest) -> URLRequest,
    retry: @escaping @Sendable (DefaultCompletionNetworkResponseElement) throws -> DefaultCompletionNetworkResponseElement
  ) {
    self.adapt = adapt
    self.retry = retry
  }
}
