//
//  MockURLSession.swift
//  assignment-sdk
//
//  Created by MaraMincho on 12/2/24.
//

import Foundation

struct MockURLSession: URLSessionInterface {
  func dataTask(with _: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTaskInterface {
    completionHandler(nil, nil, nil)
    return MockSessionDataTask()
  }
}
