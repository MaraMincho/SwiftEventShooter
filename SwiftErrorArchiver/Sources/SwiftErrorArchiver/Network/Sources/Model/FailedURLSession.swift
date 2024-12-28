//
//  FailedURLSession.swift
//
//  Created by MaraMincho on 12/2/24.
//

import Foundation

// MARK: - FailedURLSession

struct FailedURLSession: URLSessionInterface {
  func dataTask(with _: URLRequest, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTaskInterface {
    let dataTask = URLSessionDataTask()
    _ = completionHandler(nil, nil, nil)
    return dataTask
  }

  func data(for _: URLRequest, delegate _: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse) {
    throw NSError()
  }

  func resume() {}
}
