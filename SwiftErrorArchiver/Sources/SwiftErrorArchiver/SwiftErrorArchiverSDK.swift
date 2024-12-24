//
//  SwiftErrorArchiver.swift
//  SwiftErrorArchiver
//
//  Created by MaraMincho on 12/20/24.
//
import Foundation

// MARK: - SwiftErrorArchiverSDK

public struct SwiftErrorArchiverSDK: Sendable {
  let eventController: EventControllerInterface
  public init(type: SwiftErrorArchiverSDKInitialType) {
    eventController = switch type {
    case let .discord(controller):
      controller
    }
  }

  public func sendMessage(event: some EventInterface) {
    Task {
      await eventController.post(event)
    }
  }

  public func configure() {
    eventController.configure()
  }
}

// MARK: - SwiftErrorArchiverSDKInitialType

public enum SwiftErrorArchiverSDKInitialType {
  case discord(DiscordErrorStreamController)
}

// MARK: - SwiftErrorArchiverFactory

final class SwiftErrorArchiverFactory {}
