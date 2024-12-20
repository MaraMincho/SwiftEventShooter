//
//  JSONEncoder+.swift
//  assignment-sdk
//
//  Created by MaraMincho on 12/1/24.
//

import Foundation

extension JSONEncoder {
    private static let `default` = JSONEncoder()
    static func encode(_ value: some Encodable) throws(SDKNetworkError) -> Data {
        do {
            return try JSONEncoder.default.encode(value)
        } catch {
            throw .jsonError(.jsonEncodingError)
        }
    }
}
