//
//  URLSession+URLSessionInterface.swift
//  assignment-sdk
//
//  Created by MaraMincho on 12/1/24.
//

import Foundation

// MARK: - URLSessionInterface

protocol URLSessionInterface {
    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask
}

// MARK: - URLSession + URLSessionInterface

extension URLSession: URLSessionInterface {}

// MARK: - FailedURLSession

struct FailedURLSession: URLSessionInterface {
    func dataTask(with _: URLRequest, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
        let dataTask = URLSessionDataTask()
        _ = completionHandler(nil, nil, nil)
        return dataTask
    }
}
