//
//  SwiftErrorArchiverLogger.swift
//  SwiftErrorArchiver
//
//  Created by MaraMincho on 12/23/24.
//

import Foundation
import OSLog

public enum SwiftErrorArchiverLogger: Sendable {
  private nonisolated(unsafe) static let logger = Logger()
  static func debug(message: String? = nil, dumpObject: Any? = nil) {
    logger.debug("\(makeLogMessage(message: message, dumpObject: dumpObject))")
  }

  static func error(message: String? = nil, dumpObject: Any? = nil) {
    logger.error("\(makeLogMessage(message: message, dumpObject: dumpObject))")
  }

  static func warning(message: String? = nil, dumpObject: Any? = nil) {
    logger.warning("\(makeLogMessage(message: message, dumpObject: dumpObject))")
  }

  static func fault(message: String? = nil, dumpObject: Any? = nil) {
    logger.fault("\(makeLogMessage(message: message, dumpObject: dumpObject))")
  }

  static func info(message: String? = nil, dumpObject: Any? = nil) {
    logger.info("\(makeLogMessage(message: message, dumpObject: dumpObject))")
  }

  private static func makeLogMessage(message: String? = nil, dumpObject: Any? = nil) -> String {
    var report = String()
    dump(dumpObject, to: &report)
    return [message, report].compactMap { $0 }.joined(separator: "\n")
  }
}
