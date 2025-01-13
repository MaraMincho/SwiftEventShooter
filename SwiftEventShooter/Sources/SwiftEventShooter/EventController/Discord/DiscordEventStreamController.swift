//
//  DiscordEventStreamController.swift
//  DiscordEventStreamController
//
//  Created by MaraMincho on 12/20/24.
//

import Foundation

// MARK: - DiscordEventStreamController

public struct DiscordEventStreamController: EventStreamControllerInterface, Sendable {
  private let nowNetworkingStorageController: EventStorageControllerInterface?
  private let networkingFailedStorageController: EventStorageControllerInterface?
  private let provider: SDKNetworkProvider<DiscordNetworkTargetType>
  private let discordNetworkTarget: DiscordNetworkTargetType
  private let pendingStreamManager: PendingStreamManagerInterface
  private let networkMonitor: NetworkMonitorInterface
  private let timer: TimerManager
  public init(
    provider: SDKNetworkProvider<DiscordNetworkTargetType> = .init(),
    discordNetworkURL: String,
    nowNetworkingStorageController: EventStorageControllerInterface? = EventCacheDirectoryController(storageControllerType: .discord(.nowNetworking)),
    networkingFailedStorageController: EventStorageControllerInterface? = EventCacheDirectoryController(storageControllerType: .discord(.failedNetworking)),
    timeInterval: Double = 60,
    pendingStreamManager: PendingStreamManagerInterface = CountedBasedPendingStreamManager(capacity: 4),
    networkMonitor: NetworkMonitorInterface = NetworkMonitor()
  ) {
    self.provider = provider
    self.nowNetworkingStorageController = nowNetworkingStorageController
    self.networkingFailedStorageController = networkingFailedStorageController
    discordNetworkTarget = .init(webHookURLString: discordNetworkURL)
    self.pendingStreamManager = pendingStreamManager
    self.networkMonitor = networkMonitor
    timer = .init(interval: timeInterval)
  }

  public func post(_ event: some EventInterface) async {
    guard networkMonitor.isNetworkAvailable else {
      SwiftEventShooterLogger.debug(message: "Network is not available")
      return
    }
    guard let data = try? JSONEncoder.encode(event),
          let currentString = String(data: data, encoding: .utf8)
    else {
      SwiftEventShooterLogger.error(message: "Json decoding error occurred", dumpObject: event)
      return
    }
    var fileName: String? = nil
    do {
      fileName = try await nowNetworkingStorageController?.save(event: event)
      try await sendDiscordLog(currentString)
      SwiftEventShooterLogger.debug(message: "Network worked correctly")
    } catch {
      await failedNetworkingRoutine(event: event)
      SwiftEventShooterLogger.error(message: "Network error occurred", dumpObject: error)
    }

    // 만약 fileName이 있다면
    if let fileName {
      await nowNetworkingStorageController?.delete(fileName: fileName)
    }
  }

  private func failedNetworkingRoutine(event: some EventInterface) async {
    do {
      try await networkingFailedStorageController?.save(event: event)
    } catch {
      SwiftEventShooterLogger.error(message: "Failed to save failed networking event to storage", dumpObject: event)
    }
  }

  public func initialSendPendingLogRoutine() async {
    guard let nowNetworkingStorageController,
          let networkingFailedStorageController
    else {
      return
    }
    await withTaskGroup(of: Result<Void, Error>.self) { group in
      for fileName in await nowNetworkingStorageController.getAllEventFileNames() {
        group.addTask {
          do {
            let event = await nowNetworkingStorageController.getEvent(from: fileName)
            try await networkingFailedStorageController.save(event: event)
            await nowNetworkingStorageController.delete(fileName: fileName)
            return .success(())
          } catch {
            // 로그 저장에 실패해도 일단 지우기
            await nowNetworkingStorageController.delete(fileName: fileName)
            return .failure(error)
          }
        }
      }

      for await result in group {
        switch result {
        case let .failure(error):
          SwiftEventShooterLogger.error(message: "Unable to save failedNetworking event to storage", dumpObject: error)
        case .success:
          break
        }
      }
    }
  }

  public func sendPendingEvents() async {
    guard networkMonitor.isNetworkAvailable else {
      SwiftEventShooterLogger.debug(message: "Network is not available")
      return
    }

    guard let networkingFailedStorageController else {
      SwiftEventShooterLogger.error(message: "NetworkingFailedStorageController is not initiated")
      return
    }


    let currentTransmissionCount = pendingStreamManager.getCurrentMaximumTransmissionUnit
    // 더이상 전달할 내용이 없으면 return
    let prevEventNames = await networkingFailedStorageController.getAllEventFileNames()
    if prevEventNames.isEmpty {
      return
    }

    pendingStreamManager.startTransmission()

    await withTaskGroup(of: Void.self) { group in
      let prevEventNames = prevEventNames.sorted().prefix(currentTransmissionCount)
      for prevEventName in prevEventNames {
        group.addTask {
          do {
            if
              let prevEvent = await networkingFailedStorageController.getEvent(from: prevEventName),
              let currentMessage = String(data: prevEvent.data, encoding: .utf8) {
              try await sendDiscordLog(currentMessage)
            }
            await networkingFailedStorageController.delete(fileName: prevEventName)
          } catch {
            pendingStreamManager.failedTransmission()
          }
        }
      }
    }
    pendingStreamManager.finishTransmission()
    await sendPendingEvents()
  }

  public func configure() {
    Task {
      await initialSendPendingLogRoutine()
    }
    timer.startTimer {
      timerAction()
    }
  }

  private func timerAction() {
    Task(priority: .low) {
      if pendingStreamManager.isFinishPrevTransmission {
        await sendPendingEvents()
      }
    }
  }

  private func sendDiscordLog(_ content: String) async throws {
    for currentContent in content.splitByLength(Constants.discordTextLength) {
      _ = try await provider.request(discordNetworkTarget.setBody(DiscordMessage(content: currentContent)))
    }
  }

  enum Constants {
    static let discordTextLength: Int = 1900
  }

  private struct DiscordMessage<Item: Encodable>: Encodable {
    let content: Item
    init(content: Item) {
      self.content = content
    }
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
      let chunk = self[offset ..< chunkEnd]
      result.append(chunk)
      offset = chunkEnd
    }

    return result
  }
}
