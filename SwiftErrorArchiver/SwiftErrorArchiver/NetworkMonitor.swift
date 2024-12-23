//
//  NetworkMonitor.swift
//  SwiftErrorArchiver
//
//  Created by MaraMincho on 12/23/24.
//

import Foundation
import Network

final class NetworkMonitor: @unchecked Sendable {
  let monitor = NWPathMonitor()
  let queue = DispatchQueue(label: "NetworkMonitor")
  var networkStatus: Bool = false
  init() {
    monitor.start(queue: queue)
    monitor.pathUpdateHandler = { [weak self] path in
      if path.status == .satisfied {
        self?.networkStatus = true
      } else {
        self?.networkStatus = false
      }
    }
  }

  static let shared: NetworkMonitor = .init()
  static var isNetworkAvailable: Bool { shared.networkStatus }
}
