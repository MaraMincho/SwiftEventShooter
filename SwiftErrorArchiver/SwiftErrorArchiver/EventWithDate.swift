//
//  EventWithDate.swift
//  SwiftErrorArchiver
//
//  Created by MaraMincho on 12/20/24.
//

import Foundation

struct EventWithDate<Event: EventInterface>: EventWithDateInterface {
  let id: UUID
  let event: Event
  let date: Double
  init(event: Event, id: UUID = .init()) {
    self.id = id
    self.event = event
    date = Date.now.timeIntervalSince1970
  }
}
