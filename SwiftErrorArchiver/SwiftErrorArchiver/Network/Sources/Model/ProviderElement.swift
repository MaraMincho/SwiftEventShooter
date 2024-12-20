//
//  ProviderElement.swift
//  assignment-sdk
//
//  Created by MaraMincho on 12/1/24.
//

import Foundation

// MARK: - ProviderElement

struct ProviderElement: Sendable {
  private var _timeoutInterval: Double = Defaults.duration
  var timeoutInterval: Double { _timeoutInterval }
  var interceptor: Interceptor?
  init(timeoutInterval: Double = Defaults.duration, interceptor: Interceptor? = nil) {
    _timeoutInterval = timeoutInterval
    self.interceptor = interceptor
  }
}

extension ProviderElement {
  private enum Defaults {
    static let duration: Double = 60
  }

  static var `default`: Self {
    return .init()
  }
}
