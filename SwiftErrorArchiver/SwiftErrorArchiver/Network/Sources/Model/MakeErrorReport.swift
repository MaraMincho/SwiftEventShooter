//
//  MakeErrorReport.swift
//  assignment-sdk
//
//  Created by MaraMincho on 12/2/24.
//

import Foundation

func makeErrorReport(_ error: Error, data: Data? = nil) -> String {
    let dataString: String? = .String(optionalData: data, encoding: .utf8)
    var report = ""
    dump(error.localizedDescription, to: &report)
    return [dataString, report].compactMap { $0 }.joined(separator: "\n")
}

func makeHTTPErrorReport(_ response: URLResponse, data: Data? = nil) -> String {
    let dataString: String? = .String(optionalData: data, encoding: .utf8)
    let urlResponseTitle = "<--URLResponse title-->"
    let httpResponseTitle = "<--HTTPResponse title-->"

    var urlResponseReport = ""
    dump(response, to: &urlResponseReport)

    let HTTPURLResponse = response as? HTTPURLResponse

    var httpResponseReport = ""
    dump(HTTPURLResponse, to: &httpResponseReport)

    return [dataString, urlResponseTitle, urlResponseReport, httpResponseTitle, httpResponseReport]
        .compactMap { $0 }
        .joined(separator: "\n")
}

extension String {
    static func String(optionalData data: Data?, encoding: String.Encoding) -> Self? {
        guard let data else {
            return nil
        }
        return Swift.String(data: data, encoding: encoding)
    }
}
