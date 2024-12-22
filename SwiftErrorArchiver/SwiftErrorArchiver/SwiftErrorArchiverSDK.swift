//
//  SwiftErrorArchiver.swift
//  SwiftErrorArchiver
//
//  Created by MaraMincho on 12/20/24.
//
import Foundation

public struct SwiftErrorArchiverSDK: Sendable {
  public nonisolated(unsafe) static var shared: Self = .init()

  public init() {}
  public func sendMessage(event _: some Encodable) {}
}
