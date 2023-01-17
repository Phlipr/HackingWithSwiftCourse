//
//  DetailViewController.swift
//  Challenge5
//
//  Created by Phillip Reynolds on 1/16/23.
//

import UIKit

class DetailViewController: UITableViewController {
    
    var country: Country?
    var countryFacts = [CountryFact]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let country = country {
            title = country.name
            
            if let capital = country.capital {
                let fact = CountryFact(factLabel: "capital", fact: capital)
                countryFacts.append(fact)
            }
            
            if let population = country.population {
                let fact = CountryFact(factLabel: "population", fact: String(population))
                countryFacts.append(fact)
            }
            
            if let area = country.area {
                let fact = CountryFact(factLabel: "area", fact: String(area))
                countryFacts.append(fact)
            }
            
            if let currencies = country.currencies {
                let mainCurrency = currencies[0]
                let mainCurrencyStr = "\(mainCurrency.name) (\(mainCurrency.symbol), \(mainCurrency.code))"
                let fact = CountryFact(factLabel: "main currency", fact: mainCurrencyStr)
                countryFacts.append(fact)
            }
            
            if let independent = country.independent {
                let independenceStr = independent ? "have" : "have not"
                let fact = CountryFact(factLabel: "independence", fact: "They \(independenceStr) gained their independence.")
                countryFacts.append(fact)
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return countryFacts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Fact", for: indexPath)
        
        let currentFact = countryFacts[indexPath.row]

        cell.textLabel?.text = currentFact.factLabel.uppercased() + ":"
        cell.detailTextLabel?.text = currentFact.fact

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
