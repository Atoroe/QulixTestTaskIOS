import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    private var observation: NSKeyValueObservation?
    private let parsQueue = DispatchQueue(label: "parsing", qos: .background, attributes: .concurrent)
    
    private let url = "https://google-search3.p.rapidapi.com/api/v1/search/q="
    private let keyName = "x-rapidapi-key"
    private let keyValue = "9f4956566cmshc61863da97af94ep1413b3jsnf3632b04ee2d"
    
    //MARK: - Fetch data using AF
    func fetchDataAF(by searchRequest: String, with progressView: UIProgressView, and complition: @escaping ([String?], Int?) -> Void) {
        let searchUrl = url + searchRequest.replacingOccurrences(of: " ", with: "+")
        let header = HTTPHeaders([keyName : keyValue])
        
        AF.request(searchUrl, method: .get, headers: header)
            .downloadProgress(closure: { progress in
                progressView.setProgress(Float(progress.fractionCompleted), animated: true)
            })
            .validate()
            .responseDecodable(of: GoogleSearchResponse.self, queue: DispatchQueue.global(qos: .utility)) { dataResponse in
                switch dataResponse.result {
                case .success(let result):
                    guard let results = result.results else { return }
                    var links: [String?] = []
                    for result in results {
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
    
    //MARK: - Fetch data using URLSession
    func fetchDataURLSession(by searchRequest: String,with progressView: UIProgressView, and complition: @escaping ([String?], Int?) -> Void) {
        let urlString = url + searchRequest.replacingOccurrences(of: " ", with: "+")
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(keyValue, forHTTPHeaderField: keyName)
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else { return }
            let statusCode = httpResponse.statusCode
            
            if (200..<300).contains(statusCode) {
                guard let data = data else {
                    print(error?.localizedDescription ?? "No error description")
                    return
                }
                self.parsQueue.async {
                    do {
                        let decoder = JSONDecoder()
                        let googleSearchResponse = try decoder.decode(GoogleSearchResponse.self, from: data)
                        guard let results = googleSearchResponse.results else { return }
                        var links: [String?] = []
                        for result in results {
                            links.append(result.link)
                        }
                        DispatchQueue.main.async {
                            complition(links , nil)
                        }
                        print(googleSearchResponse)
                    } catch let error {
                        DispatchQueue.main.async {
                            print(error.localizedDescription)
                        }
                    }
                }
            } else {
                print("statusCode: \(statusCode)")
                DispatchQueue.main.async {
                    complition([nil], statusCode)
                }
            }
        }
        
        observation = task.progress.observe(\.fractionCompleted) { progress, _ in
            DispatchQueue.main.async {
                progressView.setProgress(Float(progress.fractionCompleted), animated: true)
            }
        }
        task.resume()
    }
    
}

