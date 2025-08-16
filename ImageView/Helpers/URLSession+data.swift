import Foundation

enum NetworkError: Error {  // 1
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fullfillCompletionOnMainThread: (Result<Data, Error>) -> Void = {
            result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        let task = dataTask(
            with: request,
            completionHandler: { data, response, error in
                if let data = data,
                    let response = response,
                    let statusCode = (response as? HTTPURLResponse)?.statusCode
                {
                    if 200..<300 ~= statusCode {
                        fullfillCompletionOnMainThread(.success(data))
                    } else {
                        fullfillCompletionOnMainThread(
                            .failure(NetworkError.httpStatusCode(statusCode)))
                    }
                } else if let error = error {
                    fullfillCompletionOnMainThread(
                        .failure(NetworkError.urlRequestError(error)))
                } else {
                    fullfillCompletionOnMainThread(
                        .failure(NetworkError.urlSessionError))
                }
            })
        return task
    }
}
