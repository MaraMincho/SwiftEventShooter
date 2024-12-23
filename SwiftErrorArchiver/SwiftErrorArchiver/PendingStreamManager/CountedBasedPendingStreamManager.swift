
import Foundation

final class CountedBasedPendingStreamManager: PendingStreamManagerInterface, @unchecked Sendable {
  private var capacity: Int
  private var isFinished: Bool = true
  private let queue = DispatchQueue(label: "TargetValueManagerQueue")

  var getCurrentMaximumTransmissionUnit: Int { capacity }

  var currentMaximumTransmissionUnit: Int {
    capacity
  }

  var isFinishPrevTransmission: Bool {
    queue.sync {
      isFinished
    }
  }

  func finishTransmission() {
    queue.sync {
      isFinished = true
    }
  }

  func startTransmission() {
    isFinished = false
  }

  init(capacity: Int) {
    self.capacity = capacity
  }

  func failedTransmission() {}
  func successTransmission() {}
}
