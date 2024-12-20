//
//  JsonDecoder+.swift
//  SwiftErrorArchiver
//
//  Created by MaraMincho on 12/20/24.
//

import Foundation

extension JSONDecoder {
  private static let decoder = JSONDecoder()
  static func decode<DecodeType: Decodable>(_: DecodeType, from data: Data) throws -> DecodeType {
    return try decoder.decode(DecodeType.self, from: data)
  }
}
