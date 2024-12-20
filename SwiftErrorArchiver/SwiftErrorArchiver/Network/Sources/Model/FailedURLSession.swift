//
//  FailedURLSession.swift
//  assignment-sdk
//
//  Created by MaraMincho on 12/2/24.
//

import Foundation

// MARK: - FailedURLSession

struct FailedURLSession: URLSessionInterface {
    func dataTask(with _: URLRequest, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTaskInterface {
        let dataTask = URLSessionDataTask()
        _ = completionHandler(nil, nil, nil)
        return dataTask
    }

    func resume() {}
}
