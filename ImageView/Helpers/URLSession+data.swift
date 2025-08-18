import Foundation

enum NetworkError: Error {  // 1
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func objectTask<T: Codable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let fullfillCompletionOnMainThread: (Result<T, Error>) -> Void = {
            result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let decoder = JSONDecoder()
        let task = dataTask(
            with: request,
            completionHandler: { data, response, error in
                if let data = data,
                    let response = response,
                    let statusCode = (response as? HTTPURLResponse)?.statusCode
                {
                    if 200..<300 ~= statusCode {
                        do {
                            let decodedData = try decoder.decode(T.self, from: data)
                            fullfillCompletionOnMainThread(.success(decodedData))
                        } catch {
                            // TODO: need to change to Alert Presenter later
                            print("Ошибка декодирования: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                            fullfillCompletionOnMainThread(.failure(error))
                        }
                        
                    } else {
                        print("URLSession: objectTask: NetworkError - код ошибки \(statusCode)")
                        fullfillCompletionOnMainThread(
                            .failure(NetworkError.httpStatusCode(statusCode)))
                    }
                } else if let error = error {
                    print("URLSession: objectTask: URLRequest error - \(error.localizedDescription)")
                    fullfillCompletionOnMainThread(
                        .failure(NetworkError.urlRequestError(error)))
                } else {
                    print("URLSession: objectTask: URLSession error")
                    fullfillCompletionOnMainThread(
                        .failure(NetworkError.urlSessionError))
                }
            })
        return task
    }
}
