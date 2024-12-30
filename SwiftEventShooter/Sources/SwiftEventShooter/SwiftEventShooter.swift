//
//  SwiftEventShooterSDK.swift
//  SwiftEventShooter
//
//  Created by MaraMincho on 12/20/24.
//
import Foundation

// MARK: - SwiftEventShooterSDK

public struct SwiftEventShooterSDK: Sendable {
  let eventController: EventStreamControllerInterface
  public init(type: SwiftEventShooterSDKInitialType) {
    eventController = switch type {
    case let .discord(controller):
      controller
    case let .slack(controller):
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

// MARK: - SwiftEventShooterSDKInitialType

public enum SwiftEventShooterSDKInitialType {
  case discord(DiscordEventStreamController)
  case slack(SlackEventStreamController)
}
