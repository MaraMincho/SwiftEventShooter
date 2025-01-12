//
//  DiscordNetworkTargetType.swift
//  DiscordNetworkTargetType
//
//  Created by MaraMincho on 12/20/24.
//

import Foundation

public struct DiscordNetworkTargetType: NetworkTargetType, @unchecked Sendable {
  public let baseURL: String
  public let path: String?
  public let method: HTTPMethod
  public let body: (any Encodable)?
  public let headers: [String: String]

  public init(baseURL: String, path: String? = nil, method: HTTPMethod, body: (any Encodable)? = nil, headers: [String: String]) {
    self.baseURL = baseURL
    self.path = path
    self.method = method
    self.body = body
    self.headers = headers
  }

  init(webHookURLString: String) {
    baseURL = webHookURLString
    path = nil
    method = .post
    body = nil
    headers = [
      "Content-Type": "application/json",
    ]
  }

}
