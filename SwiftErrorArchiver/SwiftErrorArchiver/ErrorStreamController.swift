//
//  ErrorStreamController.swift
//  SwiftErrorArchiver
//
//  Created by MaraMincho on 12/20/24.
//

import Foundation

// MARK: - DiscordErrorStreamController

public struct DiscordErrorStreamController: EventControllerInterface, Sendable {
  private let nowNetworkingStorageController: EventStorageControllerInterface?
  private let networkingFailedStorageController: EventStorageControllerInterface?
  private let timeInterval: TimeInterval
  private let provider: SDKNetworkProvider<DiscordNetworkTargetType>
  private let discordNetworkURL: String
  public init(
    provider: SDKNetworkProvider<DiscordNetworkTargetType>,
    discordNetworkURL: String,
    nowNetworkingStorageController: EventStorageControllerInterface? = nil,
    networkingFailedStorageController: EventStorageControllerInterface? = nil,
    timeInterval: Double = 5 * 60
  ) {
    self.provider = provider
    self.nowNetworkingStorageController = nowNetworkingStorageController
    self.networkingFailedStorageController = networkingFailedStorageController
    self.timeInterval = timeInterval
    self.discordNetworkURL = discordNetworkURL
  }

  public func post(_ event: some EventInterface) async {
    let eventWithDate = EventWithDate(event: event)
    await nowNetworkingStorageController?.save(event: eventWithDate)
    guard let data = try? JSONEncoder.encode(event),
          let networkTarget = DiscordNetworkTargetType(webHookURLString: discordNetworkURL)
    else {
      print("섬딩")
      return
    }
    for data in data.splitByLength(500) {
      _ = try? await provider.request(networkTarget.setBody(data))
    }
    
  }

  public func sendPendingLogs() {}

  public func configure() {}

  enum Constants {
    static let discordTextLength: Int = 2000
  }
}

private extension String {
  func splitByLength(_ length: Int) -> [String] {
    var result: [String] = []
    var currentIndex = startIndex

    while currentIndex < endIndex {
      let nextIndex = index(currentIndex, offsetBy: length, limitedBy: endIndex) ?? endIndex
      result.append(Swift.String(self[currentIndex ..< nextIndex]))
      currentIndex = nextIndex
    }

    return result
  }
}

private extension Data {
  func splitByLength(_ length: Int) -> [Data] {
    guard length > 0 else { return [] } // 유효성 검사: 길이는 0보다 커야 함
    var result: [Data] = []
    var offset = 0

    while offset < count {
      let chunkEnd = Swift.min(offset + length, count)
      let chunk = self[offset..<chunkEnd]
      result.append(chunk)
      offset = chunkEnd
    }

    return result
  }
}
