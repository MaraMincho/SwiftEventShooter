//
//  File.swift
//  SwiftErrorArchiver
//
//  Created by MaraMincho on 12/28/24.
//

import Foundation

final class TimerManager: @unchecked Sendable {
    private var timer: DispatchSourceTimer?
    private let interval: TimeInterval

    init(interval: TimeInterval) {
        self.interval = interval
    }

    func startTimer(action: @Sendable @escaping () -> Void) {
        timer = DispatchSource.makeTimerSource(queue: .global())
        timer?.schedule(deadline: .now(), repeating: interval)
        timer?.setEventHandler(handler: action)
        timer?.resume()
    }

    func stopTimer() {
        timer?.cancel()
        timer = nil
    }
}
