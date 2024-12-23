//
//  MockURLSession.swift
//  assignment-sdk
//
//  Created by MaraMincho on 12/2/24.
//

import Foundation

public struct MockURLSession: URLSessionInterface {
  public func data(for _: URLRequest, delegate _: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse) {
    return (Data(), .init())
  }

  public func dataTask(with _: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTaskInterface {
    completionHandler(nil, nil, nil)
    return MockSessionDataTask()
  }
}
