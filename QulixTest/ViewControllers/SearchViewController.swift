import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    private var links: [String] = [] {
        didSet {
            if isSearchStopped {
                searchResultsTableView.reloadData()
            }
        }
    }
    private var isSearchStopped = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    @IBAction func searchButtonTouched() {
        isSearchStopped = progressView.isHidden ?  true : false
        startGoogleSearch()
        view.endEditing(true)
        setButtonTitle()
    }
    
    //MARK: set UI
    private func setUI() {
        searchButton.layer.cornerRadius = 3
        progressView.isHidden = true
        setButtonTitle()
    }
    
    private func setButtonTitle() {
        let titleText = progressView.isHidden ? "Google Search" : "Stop"
        searchButton.setTitle(titleText, for: .normal)
    }
    
    private func toggleUI() {
        self.searchTextField.text = nil
        self.progressView.isHidden = true
        self.setButtonTitle()
    }
    
    //MARK: - Google Search
    private func startGoogleSearch() {
        if let searchRequest = searchTextField.text, searchRequest != "" {
            progressView.isHidden = false
            NetworkManager.shared.fetchData(by: searchRequest, with: progressView) { (links, responseCode) in
                if let responseCode = responseCode {
                    self.showAlert(title: "Connection Error", message: "\(responseCode)")
                    self.toggleUI()
                } else {
                    self.links = links.compactMap { $0 }
                    self.toggleUI()
                }
            }
        }
    }
}

//MARK: - tableView methods
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        links.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = "Link \(indexPath.row)"
        content.secondaryText = links[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - textFields methods
extension SearchViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super .touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        startGoogleSearch()
        setButtonTitle()
        view.endEditing(true)
        return true
    }
}

// MARK: - Alert Controller
extension SearchViewController {
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

