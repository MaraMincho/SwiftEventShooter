
import Foundation

final class TCPCUBIC: PendingStreamManagerInterface, @unchecked Sendable {
  private let queue = DispatchQueue(label: "TCPCUBICQueue")
  /// x^3, x^2, x^1, x^0
  let cubicFunctionArguments: (Double, Double, Double, Double)
  private var failedTransmissionCount: Int = 0
  private var isFinished: Bool = true
  private var currentTime: Double = 0
  var isFinishPrevTransmission: Bool {
    queue.sync {
      isFinished
    }
  }

  var getCurrentMaximumTransmissionUnit: Int {
    queue.sync { [cubicFunctionArguments] in
      let cubicFunctionArguments: [Double] = [
        cubicFunctionArguments.0,
        cubicFunctionArguments.1,
        cubicFunctionArguments.2,
        cubicFunctionArguments.3,
      ].reversed()
      let currentSum = (0 ..< 4).reduce(0) { $0 + cubicFunctionArguments[$1] * pow(currentTime, Double($1)) }
      return Int(currentSum)
    }
  }

  init?(cubicFunctionArguments: (Double, Double, Double, Double), initialCubicValue _: Int = 0) {
    self.cubicFunctionArguments = cubicFunctionArguments
    currentTime = Double(currentTime)
  }

  init() {
    cubicFunctionArguments = Constants.defaultCubicFunctionArguments
  }

  private func increaseTransmission() {
    currentTime += 1
  }

  private func reduceTransmission() {
    currentTime = 0
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
      increaseTransmission()
    }
  }

  func finishTransmission() {
    queue.sync { [weak self] in
      guard let self else { return }
      isFinished = true
      if failedTransmissionCount == 0 {
        increaseTransmission()
      } else {
        reduceTransmission()
      }
    }
  }

  func startTransmission() {
    queue.sync { [weak self] in
      guard let self else { return }
      isFinished = false
      failedTransmissionCount = 0
    }
  }

  private enum Constants {
    static let defaultCubicFunctionArguments: (Double, Double, Double, Double) = (0.125, 1, 8, 8)
    static let defaultSsthresh: Int = 64
  }
}
