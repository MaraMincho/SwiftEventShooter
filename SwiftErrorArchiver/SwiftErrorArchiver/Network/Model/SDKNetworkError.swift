//
//  SDKNetworkError.swift
//  assignment-sdk
//
//  Created by MaraMincho on 12/1/24.
//

import Foundation

// MARK: - SDKNetworkError

enum SDKNetworkError: LocalizedError {
    case invalidURL
    case jsonError(JSONError)
    case cantConvertResponseToHTTPResponse
    case nullDataError
    case serverError(errorDump: String)
    case responseError(HTTPURLResponse)
    case retryError(Error)

    // TODO: add error description
    var errorDescription: String? {
        ""
    }
}

// MARK: - JSONError

enum JSONError: LocalizedError {
    case jsonEncodingError
    case jsonDecodingError
}

private func makeErrorReport(_ error: Error) -> String {
    var report = ""
    dump(error.localizedDescription, to: &report)
    return report
}
