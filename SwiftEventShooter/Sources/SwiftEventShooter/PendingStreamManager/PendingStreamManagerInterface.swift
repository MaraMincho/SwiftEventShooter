

import Foundation

public protocol PendingStreamManagerInterface: Sendable {
  var getCurrentMaximumTransmissionUnit: Int { get }
  var isFinishPrevTransmission: Bool { get }
  func failedTransmission()
  func successTransmission()
  func finishTransmission()
  func startTransmission()
}
