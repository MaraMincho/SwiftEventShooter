

import Foundation

final class TCPTahoe: PendingStreamManagerInterface, @unchecked Sendable {
  private var ssthresh: Int
  private var currentMaximumTransmissionUnit: Int
  private let increaseUnit: Int
  private let queue = DispatchQueue(label: "TCPRenoQueue")
  private var failedTransmissionCount: Int = 0
  private var isFinished: Bool = true

  var isFinishPrevTransmission: Bool {
    queue.sync {
      isFinished
    }
  }

  var getCurrentMaximumTransmissionUnit: Int {
    queue.sync {
      currentMaximumTransmissionUnit
    }
  }

  init?(ssthresh: Int, increaseUnit: Int) {
    guard ssthresh >= 2 else {
      return nil
    }
    self.increaseUnit = increaseUnit
    self.ssthresh = ssthresh
    currentMaximumTransmissionUnit = Constants.defaultCurrentMaximumTransmissionUnit
  }

  init() {
    ssthresh = Constants.defaultInitialSsthresh
    currentMaximumTransmissionUnit = Constants.defaultCurrentMaximumTransmissionUnit
    increaseUnit = Constants.defaultIncreaseUnit
  }

  private func increaseSsthresh() {
    let currentMaximumUnit = currentMaximumTransmissionUnit
    let nextUnit: Int = if currentMaximumUnit >= ssthresh {
      currentMaximumUnit + increaseUnit
    } else {
      currentMaximumUnit * 2
    }
    currentMaximumTransmissionUnit = nextUnit
  }

  private func reduceSsthresh() {
    ssthresh = max(currentMaximumTransmissionUnit / 2, 1)
    currentMaximumTransmissionUnit = 1
  }

  func failedTransmission() {
    queue.sync { [weak self] in
      guard let self else { return }
      failedTransmissionCount += 1
    }
  }

  func successTransmission() {
    queue.sync { [weak self] in
      guard let self else { return }
      increaseSsthresh()
    }
  }

  func finishTransmission() {
    queue.sync { [weak self] in
      guard let self else { return }
      isFinished = true
      if failedTransmissionCount == 0 {
        increaseSsthresh()
      } else {
        reduceSsthresh()
      }
    }
  }

  func startTransmission() {
    queue.sync { [weak self] in
      guard let self else { return }
      failedTransmissionCount = 0
      isFinished = false
    }
  }

  private enum Constants {
    static let defaultInitialSsthresh = 16
    static let defaultCurrentMaximumTransmissionUnit = 1
    static let defaultIncreaseUnit = 2
  }
}
