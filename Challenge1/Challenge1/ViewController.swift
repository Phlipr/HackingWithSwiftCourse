//
//  ViewController.swift
//  Challenge1
//
//  Created by Phillip Reynolds on 11/18/22.
//

import UIKit

class ViewController: UITableViewController {
    
    var flags = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Flags From Around the World"
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasSuffix(".png") {
                let splitFileName = item.split(separator: "@")
                let flagName = splitFileName[0]
                if (!flags.contains(String(flagName).uppercased())) {
                    flags.append(String(flagName).uppercased())
                }
            }
        }
        
        print(flags)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flags.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Flag", for: indexPath)
        cell.textLabel?.text = flags[indexPath.row]
        cell.imageView?.image = UIImage(named: flags[indexPath.row].lowercased())
        cell.imageView?.layer.borderWidth = CGFloat(2.0)
        cell.imageView?.layer.borderColor = UIColor.lightGray.cgColor
        
        cell.layer.borderWidth = CGFloat(2.0)
        cell.layer.borderColor = tableView.backgroundColor?.cgColor
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedImage = flags[indexPath.row].lowercased()
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }


}

