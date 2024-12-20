//
//  ErrorStreamController.swift
//  SwiftErrorArchiver
//
//  Created by MaraMincho on 12/20/24.
//

import Foundation

public struct DiscordErrorStreamController: EventControllerInterface, Sendable {
  private let nowNetworkingStorageController: EventStorageControllerInterface?
  private let networkingFailedStorageController: EventStorageControllerInterface?

  public init(
    nowNetworkingStorageController: EventStorageControllerInterface? = nil,
    networkingFailedStorageController: EventStorageControllerInterface? = nil,
    timerInterval _: Double = 5 * 60
  ) {
    self.nowNetworkingStorageController = nowNetworkingStorageController
    self.networkingFailedStorageController = networkingFailedStorageController
  }

  public func post(_ event: some EventInterface) async {
    let eventWithDate = EventWithDate(event: event)
    await nowNetworkingStorageController?.save(event: eventWithDate)
  }

  public func sendPendingLogs() {}

  public func configure() {}
}
