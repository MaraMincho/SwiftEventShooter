
import Foundation

public final class CountedBasedPendingStreamManager: PendingStreamManagerInterface, @unchecked Sendable {
  private var capacity: Int
  private var isFinished: Bool = true
  private let queue = DispatchQueue(label: "TargetValueManagerQueue")

  public var getCurrentMaximumTransmissionUnit: Int { capacity }

  var currentMaximumTransmissionUnit: Int {
    capacity
  }

  public var isFinishPrevTransmission: Bool {
    queue.sync {
      isFinished
    }
  }

  public func finishTransmission() {
    queue.sync {
      isFinished = true
    }
  }

  public func startTransmission() {
    isFinished = false
  }

  public init(capacity: Int) {
    self.capacity = capacity
  }

  public func failedTransmission() {}
  public func successTransmission() {}
}
