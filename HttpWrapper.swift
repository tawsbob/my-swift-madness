import Foundation

class APIClient {
    static let shared = APIClient()  // Singleton instance
    private init() {}

    
    enum HTTPMethod: String {
        case GET, POST, PUT, DELETE
    }

    struct APIClientError: Error, Decodable {
        let message: String
    }

    func request<SuccessType: Decodable, ErrorType: Decodable & Error>(
        url: URL,
        method: HTTPMethod = .GET,
        body: Encodable? = nil,
        headers: [String: String] = [:],
        completion: @escaping (Result<SuccessType, ErrorType>) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Add headers
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Encoding error"]) as! ErrorType))
                }
                return
            }
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription]) as! ErrorType))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"]) as! ErrorType))
                }
                return
            }

            if let successResponse = try? JSONDecoder().decode(SuccessType.self, from: data) {
                DispatchQueue.main.async {
                    completion(.success(successResponse))
                }
            } else if let apiError = try? JSONDecoder().decode(ErrorType.self, from: data) {
                DispatchQueue.main.async {
                    completion(.failure(apiError))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unexpected response format"]) as! ErrorType))
                }
            }
        }.resume()
    }

}
