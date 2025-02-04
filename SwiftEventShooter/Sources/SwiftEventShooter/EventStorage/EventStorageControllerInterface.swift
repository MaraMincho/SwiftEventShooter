//
//  EventStorageControllerInterface.swift
//  SwiftEventShooter
//
//  Created by MaraMincho on 12/20/24.
//

import Foundation

public typealias EventInterface = Codable & Equatable & Sendable

// MARK: - EventWithDateInterface

public protocol EventWithDateInterface: Equatable & Codable & Identifiable & Sendable {
  var date: TimeInterval { get }
  var event: Event { get }
  associatedtype Event = EventInterface
}

// MARK: - EventStorageControllerInterface

public protocol EventStorageControllerInterface: Sendable, Actor {
  @discardableResult
  func save(event: some EventInterface) throws -> String
//  func delete(event: some EventWithDateInterface)
  func delete(fileName: String)
  func getEvent(from fileName: String) -> EventWithDate?
  func getAllEventFileNames() -> [String]
  func deleteAllEventFromDirectory()
}
