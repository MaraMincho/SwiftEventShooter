//
//  SDKNetworkProvider.swift
//  assignment-sdk
//
//  Created by MaraMincho on 12/1/24.
//

import Foundation

// MARK: - SDKNetworkProvider

struct SDKNetworkProvider<TargetType: NetworkTargetType>: Sendable {
  let session: URLSessionInterface
  let providerElement: ProviderElement

  init(
    session: URLSessionInterface = URLSession(configuration: .default),
    providerElement: ProviderElement = .default,
    responseHandler: @escaping (@Sendable (DefaultCompletionNetworkResponseElement) -> Result<Data, SDKNetworkError>) = defaultResponseHandler
  ) {
    self.session = session
    self.providerElement = providerElement
    self.responseHandler = responseHandler
  }

  @discardableResult
  func request(_ type: TargetType, completion: @escaping @Sendable (Result<Data, SDKNetworkError>) -> Void) -> URLSessionDataTaskInterface {
    do {
      let targetTypeRequest = try type.getURLRequest()
      let adaptedRequestWithProviderElement = ProviderElementAdaptor.set(providerElement: providerElement, urlRequest: targetTypeRequest)
      return requestResume(request: adaptedRequestWithProviderElement, completion: completion)
    } catch {
      // CreateURL Session Error
      let session = FailedURLSession()
      let dataTask = session.dataTask(with: URLRequest(url: .init(string: "https://example.com")!)) { _, _, _ in
        completion(.failure(.invalidURL))
      }
      return dataTask
    }
  }

  private func requestResume(request: URLRequest, completion: @escaping @Sendable (Result<Data, SDKNetworkError>) -> Void) -> URLSessionDataTaskInterface {
    let dataTask = session.dataTask(with: request) { data, response, error in
      let result: Result<Data, SDKNetworkError>

      defer { completion(result) }
      do {
        let responseElements = try ProviderElementAdaptor.set(providerElement: providerElement, response: (data, response, error))
        result = responseHandler(responseElements)
      } catch {
        let report = makeErrorReport(error)
        result = .failure(.retryError(report: report))
      }
    }
    dataTask.resume()
    return dataTask
  }

  private let responseHandler: @Sendable (DefaultCompletionNetworkResponseElement) -> Result<Data, SDKNetworkError>
}

private let defaultResponseHandler: @Sendable (
  _ arguments: DefaultCompletionNetworkResponseElement
) -> Result<Data, SDKNetworkError> = { arg in
  let (data, response, error) = arg

  if let networkError = error {
    return handleNetworkError(networkError)
  }

  guard let httpResponse = response as? HTTPURLResponse else {
    return .failure(.cantConvertResponseToHTTPResponse)
  }

  guard let responseData = data else {
    return .failure(.nullDataError)
  }

  return handleHTTPResponse(httpResponse, responseData)
}

private func handleNetworkError(_ error: Error) -> Result<Data, SDKNetworkError> {
  if let connectionError = SDKNetworkConnectionErrorAdaptor.isConnectionError(error: error) {
    return .failure(connectionError)
  }

  let errorReport = makeErrorReport(error)
  return .failure(.otherError(report: errorReport))
}

private func handleHTTPResponse(
  _ response: HTTPURLResponse,
  _ data: Data
) -> Result<Data, SDKNetworkError> {
  switch response.statusCode {
  case 200 ..< 300:
    return .success(data)
  case 400 ..< 500:
    return .failure(.clientError(report: makeHTTPErrorReport(response, data: data)))
  case 500:
    return .failure(.internalServerError(report: makeHTTPErrorReport(response, data: data)))
  case 500 ..< 600:
    return .failure(.serverError(report: makeHTTPErrorReport(response, data: data)))
  default:
    return .failure(.responseError(response))
  }
}
