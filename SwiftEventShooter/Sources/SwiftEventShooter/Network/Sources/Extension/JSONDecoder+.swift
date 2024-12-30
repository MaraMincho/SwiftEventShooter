//
//  JSONDecoder+.swift
//
//  Created by MaraMincho on 12/1/24.
//

import Foundation

extension JSONDecoder {
  static let shared = JSONDecoder()
  static func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
    try shared.decode(type, from: data)
  }
}
