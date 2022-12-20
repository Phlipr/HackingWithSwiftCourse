//
//  ViewController.swift
//  Project5
//
//  Created by Phillip Reynolds on 11/29/22.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(restartGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }

        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
    }
    
    @objc func restartGame() {
        title = getRandomwWord()
        resetUsedWords()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    func startGame() {
        title = getCurrentWord()
        usedWords = getUsedWords()
    }
    
    func getCurrentWord() -> String {
        let defaults = UserDefaults.standard
        
        let savedCurrentWord = defaults.string(forKey: "currentWord")
        
        guard let currentWord = savedCurrentWord else {
            return getRandomwWord()
        }
        
        return currentWord
    }
    
    func getRandomwWord() -> String {
        let defaults = UserDefaults.standard
        let currentWord = allWords.randomElement() ?? "silkworm"
        defaults.set(currentWord, forKey: "currentWord")
        return currentWord
    }
    
    func getUsedWords() -> [String] {
        let defaults = UserDefaults.standard
        
        let savedUsedWords = defaults.object(forKey: "savedUsedWords") as? [String] ?? [String]()
        
        return savedUsedWords
    }
    
    func resetUsedWords() {
        usedWords.removeAll(keepingCapacity: true)
        saveUsedWords()
        tableView.reloadData()
    }
    
    func saveUsedWords() {
        let defaults = UserDefaults.standard
        
        defaults.set(usedWords, forKey: "savedUsedWords")
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }

        ac.addAction(submitAction)
        present(ac, animated: true)
    }

    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()

            if isPossible(word: lowerAnswer) {
                if isOriginal(word: lowerAnswer) {
                    if isReal(word: lowerAnswer) {
                        usedWords.insert(lowerAnswer, at: 0)

                        let indexPath = IndexPath(row: 0, section: 0)
                        tableView.insertRows(at: [indexPath], with: .automatic)
                        
                        saveUsedWords()

                        return
                    } else {
                        showErrorMessage(errorTitle: "Word not recognised", errorMessage: "You can't just make them up, you know!")
                    }
                } else {
                    showErrorMessage(errorTitle: "Word used already", errorMessage: "Be more original!")
                }
            } else {
                guard let title = title?.lowercased() else { return }
                showErrorMessage(errorTitle: "Word not possible", errorMessage: "You can't spell that word from \(title)")
            }
    }
    
    func showErrorMessage(errorTitle: String, errorMessage: String) {
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }

            for letter in word {
                if let position = tempWord.firstIndex(of: letter) {
                    tempWord.remove(at: position)
                } else {
                    return false
                }
            }

            return true
    }

    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }

    func isReal(word: String) -> Bool {
        if word == title || word.count < 3 {
            return false
        }
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
}

