//
//  EventControllerInterface.swift
//  SwiftErrorArchiver
//
//  Created by MaraMincho on 12/20/24.
//

import Foundation

public protocol EventControllerInterface: Sendable {
  func post(_ event: some EventInterface) async
  func sendPendingEvents() async
  func configure()
}
