//
//  PendingStreamManager.swift
//  SwiftErrorArchiver
//
//  Created by MaraMincho on 12/23/24.
//

import Foundation

public protocol PendingStreamManagerInterface: Sendable {
    var getCurrentMaximumTransmissionUnit: Int { get }
    var isFinishPrevTransmission: Bool { get }
    func failedTransmission()
    func successTransmission()
    func finishTransmission()
    func startTransmission()
}
