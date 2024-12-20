//
//  EventStorageControllerInterface.swift
//  SwiftErrorArchiver
//
//  Created by MaraMincho on 12/20/24.
//

import Foundation

public typealias EventInterface = Codable & Equatable & Hashable

// MARK: - EventWithDateInterface

public protocol EventWithDateInterface: Equatable & Codable & Hashable & Identifiable {
  var date: TimeInterval { get }
  var event: Event { get }
  associatedtype Event = EventInterface
}

// MARK: - EventStorageControllerInterface

public protocol EventStorageControllerInterface: Sendable, Actor {
  func save<Event: EventWithDateInterface>(event: Event)
  func delete<Event: EventWithDateInterface>(event: Event)
  func delete(fileName: String)
  func getEvent<Event: EventWithDateInterface>(from fileName: String) -> Event?
  func getAllEventFileNames() -> [String]
}
