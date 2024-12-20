//
//  EventControllerInterface.swift
//  SwiftErrorArchiver
//
//  Created by MaraMincho on 12/20/24.
//

import Foundation

public protocol EventControllerInterface {
  func post<Event: EventInterface>(_ event: Event) async
  func sendPendingLogs() async
  func configure()
}
