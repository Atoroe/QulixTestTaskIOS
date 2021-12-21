import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    private let url = "https://google-search3.p.rapidapi.com/api/v1/search/q="
    private let header = HTTPHeaders(["x-rapidapi-key" : "9f4956566cmshc61863da97af94ep1413b3jsnf3632b04ee2d"])
    
    func fetchData(by searchRequest: String, with progressView: UIProgressView, and complition: @escaping ([String?], Int?) -> Void) {
        let searchUrl = url + searchRequest.replacingOccurrences(of: " ", with: "+")
        
        AF.request(searchUrl, method: .get, headers: header)
            .downloadProgress(closure: { progress in
                progressView.setProgress(Float(progress.fractionCompleted), animated: true)
            })
            .validate()
            .responseDecodable(of: GoogleSearchResponse.self, queue: DispatchQueue.global(qos: .utility)) { dataResponse in
                switch dataResponse.result {
                case .success(let searchResponse):
                    var links: [String?] = []
                    for result in searchResponse.results! {
                        links.append(result.link)
                    }
                    DispatchQueue.main.async {
                        complition(links , nil)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        complition([nil], error.responseCode)
                    }
                }
            }
    }
    
}

