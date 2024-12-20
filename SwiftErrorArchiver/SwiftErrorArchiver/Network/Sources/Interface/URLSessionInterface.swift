//
//  URLSessionInterface.swift
//  assignment-sdk
//
//  Created by MaraMincho on 12/2/24.
//

import Foundation

// MARK: - URLSessionInterface

protocol URLSessionInterface: Sendable {
  func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTaskInterface
}
