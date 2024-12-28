//
//  SDKNetworkError.swift
//
//  Created by MaraMincho on 12/1/24.
//

import Foundation

// MARK: - SDKNetworkError

enum SDKNetworkError: LocalizedError, Equatable {
  case invalidURL
  case jsonError(JSONError)
  case cantConvertResponseToHTTPResponse
  case nullDataError
  case internalServerError(report: String) // responseCode 500
  case serverError(report: String)
  case responseError(HTTPURLResponse)
  case retryError(report: String)
  case connectionError(report: String)
  case clientError(report: String)
  case otherError(report: String)

  // TODO: add error description
  var errorDescription: String? {
    switch self {
    case .invalidURL:
      NSErrorDomain().description
    default:
      ""
    }
  }
}
