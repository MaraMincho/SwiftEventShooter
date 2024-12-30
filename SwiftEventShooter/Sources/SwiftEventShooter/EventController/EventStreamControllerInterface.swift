//
//  EventStreamControllerInterface.swift
//  SwiftEventShooter
//
//  Created by MaraMincho on 12/20/24.
//

import Foundation

public protocol EventStreamControllerInterface: Sendable {
  func post(_ event: some EventInterface) async
  func sendPendingEvents() async
  func configure()
}
