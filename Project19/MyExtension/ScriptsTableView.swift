//
//  ScriptsTableView.swift
//  MyExtension
//
//  Created by Phillip Reynolds on 2/24/23.
//

import UIKit

class ScriptsTableView: UITableViewController {
    
    var scripts = [Script]()
    weak var delegate: ActionViewController!
    var mode: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Saved Scripts"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return scripts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Script", for: indexPath)

        let currScript = scripts[indexPath.row]
        
        cell.textLabel?.text = currScript.scriptName

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currScript = scripts[indexPath.row]
        
        switch mode {
        case "loading":
            delegate.updateScriptText(newScriptText: currScript.scriptText)
        case "deleting":
            delegate.removeScript(named: currScript.scriptName)
        default:
            delegate.updateScriptText(newScriptText: currScript.scriptText)
        }
        
        navigationController?.popViewController(animated: true)
    }
}
