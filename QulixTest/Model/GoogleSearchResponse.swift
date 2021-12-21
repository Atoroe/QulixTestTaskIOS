struct GoogleSearchResponse: Codable {
    let results: [Result]?
}

struct Result: Codable {
    let link: String?
}
