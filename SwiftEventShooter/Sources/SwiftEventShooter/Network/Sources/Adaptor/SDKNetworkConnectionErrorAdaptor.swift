//
//  SDKNetworkConnectionErrorAdaptor.swift
//
//  Created by MaraMincho on 12/2/24.
//

import Foundation

enum SDKNetworkConnectionErrorAdaptor {
  static func isConnectionError(error: Error) -> SDKNetworkError? {
    let error = error as NSError
    if connectionErrorList.contains(error.code) {
      let report = makeErrorReport(error)
      return .connectionError(report: report)
    }
    return nil
  }

  private static let connectionErrorList: [Int] = [
    NSURLErrorCannotFindHost, // 호스트를 찾을 수 없음
    NSURLErrorCannotConnectToHost, // 호스트에 연결할 수 없음
    NSURLErrorNetworkConnectionLost, // 네트워크 연결 끊김(Wi-Fi 신호 약화 또는 모바일 데이터 손실)
    NSURLErrorDNSLookupFailed, // DNS 조회 실패
    NSURLErrorHTTPTooManyRedirects, // HTTP 리디렉션이 너무 많음
    NSURLErrorResourceUnavailable, // 리소스를 사용할 수 없음
    NSURLErrorNotConnectedToInternet, // 인터넷에 연결되지 않음
    NSURLErrorTimedOut,
  ]
}
