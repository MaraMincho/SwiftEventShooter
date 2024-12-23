//
//  EventWithDate.swift
//  SwiftErrorArchiver
//
//  Created by MaraMincho on 12/20/24.
//

import Foundation

public struct EventWithDate: Equatable & Codable & Hashable & Identifiable & Sendable {
  public let date: TimeInterval
  public let id: UUID
  public let data: Data
  init(data: Data) {
    self.date = Date.now.timeIntervalSince1970
    self.id = .init()
    self.data = data
  }
}
