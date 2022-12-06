//
//  ViewController.swift
//  Project7
//
//  Created by Phillip Reynolds on 11/30/22.
//

import UIKit

class ViewController: UITableViewController {
    
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()
    var filterTerm: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showCredits))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterPetitions))
        
        performSelector(inBackground: #selector(fetchJSON), with: nil)
    }
        
    @objc func fetchJSON() {
        let urlString: String

        if navigationController?.tabBarItem.tag == 0 {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }

        if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    self.parse(json: data)
                    return
                }
            }
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()

        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            filteredPetitions = petitions
            performSelector(onMainThread: #selector(updateTitle), with: nil, waitUntilDone: false)
            tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        } else {
            performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        }
    }
    
    @objc func updateTitle() {
        let petitionsString = filteredPetitions.count == 1 ? "petition" : "petitions"
        title = "\(filteredPetitions.count) \(petitionsString)"
    }
    
    @objc func showCredits() {
        let ac = UIAlertController(title: "Credits", message: "The data shown here comes from the We The People API of the White House", preferredStyle: .alert)
        
        let closeDialog = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        
        ac.addAction(closeDialog)
        present(ac, animated: true)
    }
    
    @objc func filterPetitions() {
        let ac = UIAlertController(title: "Filter", message: "Enter a term to filter the posts by.", preferredStyle: .alert)
        ac.addTextField()
        
        let submitFilter = UIAlertAction(title: "Filter posts", style: .default) { [weak self, weak ac] action in
            guard let filterByTerm = ac?.textFields?[0].text else { return }
            self?.filterBy(term: filterByTerm)
        }
        
        ac.addAction(submitFilter)
        present(ac, animated: true)
    }
    
    @objc func clearFilter() {
        filterTerm = nil
        filteredPetitions = petitions
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterPetitions))
        updateTitle()
        tableView.reloadData()
    }
    
    func filterBy(term: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.filteredPetitions = self.filteredPetitions.filter { $0.title.contains(term) || $0.body.contains(term)}
        }
        
        DispatchQueue.main.async {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear Filter", style: .plain, target: self, action: #selector(self.clearFilter))
            self.updateTitle()
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPetitions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = filteredPetitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

