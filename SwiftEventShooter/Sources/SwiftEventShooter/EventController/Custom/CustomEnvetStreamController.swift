//
//  File.swift
//  SwiftEventShooter
//
//  Created by MaraMincho on 1/13/25.
//

import Foundation


public struct CustomEventStreamController<TargetType: NetworkTargetType>: EventStreamControllerInterface, Sendable {
  private let nowNetworkingStorageController: EventStorageControllerInterface?
  private let networkingFailedStorageController: EventStorageControllerInterface?
  private let provider: SDKNetworkProvider<TargetType>
  private let customNetworkTarget: TargetType
  private let pendingStreamManager: PendingStreamManagerInterface
  private let networkMonitor: NetworkMonitorInterface
  private let timer: TimerManager
  public init(
    targetType: TargetType,
    provider: SDKNetworkProvider<TargetType> = .init(),
    networkURLString: String,
    nowNetworkingStorageController: EventStorageControllerInterface? = EventCacheDirectoryController(storageControllerType: .discord(.nowNetworking)),
    networkingFailedStorageController: EventStorageControllerInterface? = EventCacheDirectoryController(storageControllerType: .discord(.failedNetworking)),
    timeInterval: Double = 60,
    pendingStreamManager: PendingStreamManagerInterface = CountedBasedPendingStreamManager(capacity: 2),
    networkMonitor: NetworkMonitorInterface = NetworkMonitor()
  ) {
    self.provider = provider
    self.nowNetworkingStorageController = nowNetworkingStorageController
    self.networkingFailedStorageController = networkingFailedStorageController
    self.customNetworkTarget = targetType
    self.pendingStreamManager = pendingStreamManager
    self.networkMonitor = networkMonitor
    timer = .init(interval: timeInterval)
  }

  public func post(_ event: some EventInterface) async {
    guard networkMonitor.isNetworkAvailable else {
      SwiftEventShooterLogger.debug(message: "Network is not available")
      return
    }
    var fileName: String? = nil
    do {
      fileName = try await nowNetworkingStorageController?.save(event: event)
      try await provider.request(customNetworkTarget.setBody(event))
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

    pendingStreamManager.startTransmission()
    let currentTransmissionCount = pendingStreamManager.getCurrentMaximumTransmissionUnit

    await withTaskGroup(of: Void.self) { group in
      let prevEventNames = await networkingFailedStorageController.getAllEventFileNames().sorted().prefix(currentTransmissionCount)
      for prevEventName in prevEventNames {
        group.addTask {
          do {
            if
              let prevEvent = await networkingFailedStorageController.getEvent(from: prevEventName),
              let currentMessage = String(data: prevEvent.data, encoding: .utf8) {
              try await provider.request(customNetworkTarget.setBody(currentMessage))
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
    Task {
      if pendingStreamManager.isFinishPrevTransmission {
        await sendPendingEvents()
      }
    }
  }
}
