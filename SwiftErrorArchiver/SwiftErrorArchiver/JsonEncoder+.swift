//
//  JsonEncoder+.swift
//  SwiftErrorArchiver
//
//  Created by MaraMincho on 12/20/24.
//

import Foundation

extension JSONEncoder {
  private static let encoder = JSONEncoder()
  static func encode(_ value: Encodable) throws -> Data {
    return try encoder.encode(value)
  }
}
