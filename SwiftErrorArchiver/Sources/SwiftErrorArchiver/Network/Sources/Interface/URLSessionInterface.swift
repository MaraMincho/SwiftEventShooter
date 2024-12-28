//
//  URLSessionInterface.swift
//
//  Created by MaraMincho on 12/2/24.
//

import Foundation

// MARK: - URLSessionInterface

public protocol URLSessionInterface: Sendable {
  func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTaskInterface
  func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}
