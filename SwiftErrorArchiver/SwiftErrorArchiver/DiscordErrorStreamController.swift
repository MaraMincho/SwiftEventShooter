//
//  DiscordErrorStreamController.swift
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
  private let discordNetworkTarget: DiscordNetworkTargetType
  private let pendingStreamManager: PendingStreamManagerInterface
  public init(
    provider: SDKNetworkProvider<DiscordNetworkTargetType>,
    discordNetworkURL: String,
    nowNetworkingStorageController: EventStorageControllerInterface? = nil,
    networkingFailedStorageController: EventStorageControllerInterface? = nil,
    timeInterval: Double = 5 * 60,
    pendingStreamManager: PendingStreamManagerInterface?
  ) {
    self.provider = provider
    self.nowNetworkingStorageController = nowNetworkingStorageController
    self.networkingFailedStorageController = networkingFailedStorageController
    self.timeInterval = timeInterval
    discordNetworkTarget = .init(webHookURLString: discordNetworkURL)
    self.pendingStreamManager = pendingStreamManager ?? TCPTahoe()
  }

  public func post(_ event: some EventInterface) async {
    guard NetworkMonitor.isNetworkAvailable else {
      SwiftErrorArchiverLogger.debug(message: "Network is not available")
      return
    }
    guard let data = try? JSONEncoder.encode(event) else {
      SwiftErrorArchiverLogger.error(message: "Json decoding error occurred", dumpObject: event)
      return
    }
    var fileName: String? = nil

    do {
      fileName = try await nowNetworkingStorageController?.save(event: event)
      try await sendDiscordLog(data)
      SwiftErrorArchiverLogger.debug(message: "Network worked correctly")
    } catch {
      await failedNetworkingRoutine(event: event)
      SwiftErrorArchiverLogger.error(message: "Network error occurred", dumpObject: error)
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
      SwiftErrorArchiverLogger.error(message: "Failed to save failed networking event to storage", dumpObject: event)
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
          SwiftErrorArchiverLogger.error(message: "Unable to save failedNetworking event to storage", dumpObject: error)
        case .success:
          break
        }
      }
    }
  }

  public func sendPendingEvents() async {
    guard NetworkMonitor.isNetworkAvailable else {
      SwiftErrorArchiverLogger.debug(message: "Network is not available")
      return
    }

    guard let networkingFailedStorageController else {
      SwiftErrorArchiverLogger.error(message: "NetworkingFailedStorageController is not initiated")
      return
    }

    pendingStreamManager.startTransmission()
    let currentTransmissionCount = pendingStreamManager.getCurrentMaximumTransmissionUnit

    await withTaskGroup(of: Void.self) { group in
      let prevEventNames = await networkingFailedStorageController.getAllEventFileNames().sorted().prefix(currentTransmissionCount)
      for prevEventName in prevEventNames {
        group.addTask {
          do {
            if let prevEvent = await networkingFailedStorageController.getEvent(from: prevEventName) {
              try await sendDiscordLog(prevEvent.data)
            }
            await networkingFailedStorageController.delete(fileName: prevEventName)
          } catch {
            pendingStreamManager.failedTransmission()
          }
        }
      }
    }
    pendingStreamManager.finishTransmission()
  }

  public func configure() {
    Task {
      await initialSendPendingLogRoutine()
      Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { _ in
        timerAction()
      }
    }
  }

  private func timerAction() {
    Task {
      if pendingStreamManager.isFinishPrevTransmission {
        await sendPendingEvents()
      }
    }
  }

  private func sendDiscordLog(_ data: Data) async throws {
    for data in data.splitByLength(Constants.discordTextLength) {
      let _ = try await provider.request(discordNetworkTarget.setBody(data))
    }
  }

  enum Constants {
    static let discordTextLength: Int = 1900
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
