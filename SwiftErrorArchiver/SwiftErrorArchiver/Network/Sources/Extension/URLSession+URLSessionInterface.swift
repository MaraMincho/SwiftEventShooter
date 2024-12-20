//
//  URLSession+URLSessionInterface.swift
//  assignment-sdk
//
//  Created by MaraMincho on 12/1/24.
//

import Foundation

// MARK: - URLSession + URLSessionInterface

extension URLSession: URLSessionInterface {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTaskInterface {
        let dataTask: URLSessionDataTask = dataTask(with: request, completionHandler: completionHandler)
        return dataTask
    }
}
