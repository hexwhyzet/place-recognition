import Foundation
import CoreML

class BuildingInfoRepository: IBuildingInfoRepository {
    
    let url = URL(string: "http://51.250.107.202:8000/recognize")!
    
    enum RepositoryError: Error {
        case noReceiveResponse
    }
    
    struct PlaceRecognitionResponse: Codable {
        let id: Int64
        let name: String
        let description: String
        let url: String
        let address: String
        let metro: String
    }

    
    func getInfoByDecriptor(descriptor: [Float]) async throws -> RawPlaceRecognition {
        print("Start get image repository")
        let response = try await callFastAPIHandler(floatArray: descriptor)
        return RawPlaceRecognition(id: response.id,
                                   name: response.name,
                                   imageUrl: response.url,
                                   description: response.description,
                                   address: response.address,
                                   metro: response.metro)
    }
    
    
    private func callFastAPIHandler(floatArray: [Float]) async throws -> PlaceRecognitionResponse {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let json: [String: Any] = ["data": floatArray]
        let jsonData = try JSONSerialization.data(withJSONObject: json)
            
        request.httpBody = jsonData

        let (data, _) = try await fetchData(with: request)
        
        if let serverResponseString = String(data: data, encoding: .utf8) {
            print("Raw Server Response: \(serverResponseString)")
        }
        
        do {
            let responseData = try JSONDecoder().decode(PlaceRecognitionResponse.self, from: data)
            return responseData
        } catch let error {
            throw error
        }
    }

    private func fetchData(with request: URLRequest) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data, let response = response {
                    continuation.resume(returning: (data, response))
                } else {
                    continuation.resume(throwing: NSError(domain: "Unknown URLSession error", code: -1, userInfo: nil))
                }
            }.resume()
        }
    }

}
