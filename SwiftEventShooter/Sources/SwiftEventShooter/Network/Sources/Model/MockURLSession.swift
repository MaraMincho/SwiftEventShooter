//
//  MockURLSession.swift
//
//  Created by MaraMincho on 12/2/24.
//

import Foundation

public struct MockURLSession: @unchecked Sendable, URLSessionInterface {
  var userCompletion: ((_ for: URLRequest, _ delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse))?
  public init(
    completion: ((_ request: URLRequest, _ delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse))? = nil
  ) {
    userCompletion = completion
  }

  public func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse) {
    if let userCompletion {
      return try await userCompletion(request, delegate)
    }
    return (Data(), .init())
  }

  public func dataTask(with _: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTaskInterface {
    completionHandler(nil, nil, nil)
    return MockSessionDataTask()
  }
}
