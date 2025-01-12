//
//  NetworkTargetType.swift
//
//  Created by MaraMincho on 12/1/24.
//

import Foundation

// MARK: - NetworkTargetType

public protocol NetworkTargetType: Sendable {
  var baseURL: String { get }
  var path: String? { get }
  var method: HTTPMethod { get }
  var body: Encodable? { get }
  var headers: [String: String] { get }
  init(baseURL: String, path: String?, method: HTTPMethod, body: (any Encodable)?, headers: [String: String]) 
}

extension NetworkTargetType {
  func setBody(_ body: any Encodable) -> Self {
    return .init(baseURL: baseURL, path: path, method: method, body: body, headers: headers)
  }

  private var currentURL: URL? {
    let urlComponents = [baseURL, path]
    let urlString = urlComponents.compactMap { $0 }.joined(separator: "/")
    return .init(string: urlString)
  }

  func getURLRequest() throws(SDKNetworkError) -> URLRequest {
    guard let currentURL else {
      throw .invalidURL
    }
    var request = URLRequest(url: currentURL)
    request.httpMethod = method.rawValue
    if let body {
      request.httpBody = try JSONEncoder.encode(body)
    }
    headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
    return request
  }
}
