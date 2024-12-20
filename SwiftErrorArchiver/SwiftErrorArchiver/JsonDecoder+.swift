//
//  JsonDecoder+.swift
//  SwiftErrorArchiver
//
//  Created by MaraMincho on 12/20/24.
//

import Foundation

extension JSONDecoder {
  private static let decoder = JSONDecoder()
  static func decode<T>(_: T.Type, from data: Data) throws -> T where T: Decodable {
    return try decoder.decode(T.self, from: data)
  }
}
