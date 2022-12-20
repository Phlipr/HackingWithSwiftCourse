//
//  ViewController.swift
//  Project1
//
//  Created by Phillip Reynolds on 11/3/22.
//

import UIKit

class ViewController: UITableViewController {
    
    var pictures = [Picture]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(recommendToOthers))
        
        let defaults = UserDefaults.standard

        if let savedPictures = defaults.object(forKey: "pictures") as? Data {
            let jsonDecoder = JSONDecoder()

            do {
                pictures = try jsonDecoder.decode([Picture].self, from: savedPictures)
            } catch {
                print("Failed to load people")
            }
        }
        
        if pictures.isEmpty {
            performSelector(inBackground: #selector(fetchPictures), with: nil)
        }
    }
    
    @objc func fetchPictures() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix("nssl") {
                let picture = Picture(fileName: item)
                pictures.append(picture)
            }
        }
        
        save()
        
        tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        cell.textLabel?.text = pictures[indexPath.row].fileName
        
        let timesAccessed = pictures[indexPath.row].accessCount
        
        let timesLabel = timesAccessed == 1 ? "time" : "times"
        
        cell.detailTextLabel?.text = "Picture accessed \(String(timesAccessed)) \(timesLabel)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedImage = pictures[indexPath.row].fileName
            
            pictures[indexPath.row].incrementAccessCount()
            save()
            
            tableView.reloadData()
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func recommendToOthers() {
        let vc = UIActivityViewController(activityItems: ["You have to try out this cool app!"], applicationActivities: nil)
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(pictures) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "pictures")
        } else {
            print("Failed to save people.")
        }
    }
}

