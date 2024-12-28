//
//  URLSession+URLSessionInterface.swift
//
//  Created by MaraMincho on 12/1/24.
//

import Foundation

// MARK: - URLSession + URLSessionInterface

extension URLSession: URLSessionInterface {
  public func dataTask(with request: URLRequest, completionHandler: @Sendable @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTaskInterface {
    let dataTask: URLSessionDataTask = dataTask(with: request, completionHandler: completionHandler)
    return dataTask
  }
}
