import Foundation
import CoreML

class BuildingInfoRepository: IBuildingInfoRepository {
    
    let url = URL(string: UserDefaults.standard.string(forKey: "debugURL") ?? "http://51.250.107.202:8000/recognize")!
    
    enum RepositoryError: Error {
        case noReceiveResponse
        case unableSerialization
    }
    
    struct PlaceRecognitionResponse: Codable {
        let id: Int64?
        let address: Address?
        let metro_stations: [MetroStation]?
        let group: Group?
    }

    struct Address: Codable {
        let RU: String?
        let languages: [String]?
    }

    struct MetroStation: Codable {
        let id: Int?
        let line_id: Int?
        let name: Name?
        let line: Line?
    }

    struct Name: Codable {
        let RU: String?
        let languages: [String]?
    }

    struct Line: Codable {
        let id: Int?
        let name: Name?
    }

    struct Group: Codable {
        let construction_year: Int?
        let image_url: String?
        let id: Int?
        let title: Title?
        let description: String?
    }

    struct Title: Codable {
        let RU: String?
        let languages: [String]?
    }

    
    func getInfoByDecriptor(descriptor: [Float]) async throws -> RawPlaceRecognition {
        print("Start get image repository")
        let response = try await callFastAPIHandler(floatArray: descriptor)
        let raw = RawPlaceRecognition(id: response.id ?? 123321,
                                   name: response.group?.title?.RU ?? "None name",
                                   imageUrl: response.group?.image_url ?? "None",
                                   description: response.group?.description ?? "None",
                                   address: response.address?.RU ?? "Aboba lives here",
                                   metro: response.metro_stations?.map { map($0) } ?? []
        )
        print(raw)
        return raw
    }
    
    private func map(_ station: MetroStation?) -> RawPlaceRecognition.MetroStation {
        guard let station = station else {
            return RawPlaceRecognition.MetroStation(
                id: 123,
                line_id: 123,
                name: RawPlaceRecognition.Name(RU: "123", languages: []),
                line: RawPlaceRecognition.Line(id: 123, name: RawPlaceRecognition.Name(RU: "123", languages: []))
            )
        }
        return RawPlaceRecognition.MetroStation(
            id: station.id ?? 123,
            line_id: station.line_id ?? 123,
            name: RawPlaceRecognition.Name(RU: station.name?.RU ?? "123", languages: station.name?.languages ?? []),
            line: RawPlaceRecognition.Line(id: station.line?.id ?? 123, name: RawPlaceRecognition.Name(RU: station.line?.name?.RU ?? "123", languages: station.line?.name?.languages ?? []))
        )
    }
         
    
    private func callFastAPIHandler(floatArray: [Float]) async throws -> PlaceRecognitionResponse {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(UserDefaults.standard.string(forKey: "debugToken") ?? "abobatoken", forHTTPHeaderField: "debug-token")

        let json: [String: Any] = ["descriptor": floatArray]
        
        var jsonData: Data
        do {
            jsonData = try JSONSerialization.data(withJSONObject: json)
        } catch {
            throw RepositoryError.unableSerialization
        }
        
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
