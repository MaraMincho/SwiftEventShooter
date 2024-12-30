//
//  File.swift
//  SwiftErrorArchiver
//
//  Created by MaraMincho on 12/28/24.
//

import Foundation

struct MockNetworkMonitor: NetworkMonitorInterface {
  let isNetworkAvailable: Bool
  init(isNetworkAvailable: Bool = true) {
    self.isNetworkAvailable = isNetworkAvailable
  }
}
