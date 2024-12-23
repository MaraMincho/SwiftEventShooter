//
//  NetworkMonitor.swift
//  SwiftErrorArchiver
//
//  Created by MaraMincho on 12/23/24.
//

import Foundation
import Network

public protocol NetworkMonitorInterface: Sendable {
  var isNetworkAvailable: Bool { get }
}

public final class NetworkMonitor: NetworkMonitorInterface, @unchecked Sendable {
  private let monitor = NWPathMonitor()
  private let queue = DispatchQueue(label: "NetworkMonitor")
  private var _networkStatus: Bool = false
  private let syncQueue = DispatchQueue(label: "NetworkMonitor.Sync", attributes: .concurrent)

  // 네트워크 상태 접근
  var networkStatus: Bool {
    get {
      syncQueue.sync { _networkStatus }
    }
    set {
      syncQueue.async(flags: .barrier) {
        self._networkStatus = newValue
      }
    }
  }

  public init() {   
    monitor.start(queue: queue)
    monitor.pathUpdateHandler = { [weak self] path in
      guard let self = self else { return }
      self.networkStatus = (path.status == .satisfied)
    }

    // 초기 상태 설정
    if monitor.currentPath.status == .satisfied {
      networkStatus = true
    }
  }

  // 네트워크 상태를 외부에서 확인
  public var isNetworkAvailable: Bool {
    networkStatus
  }
}
