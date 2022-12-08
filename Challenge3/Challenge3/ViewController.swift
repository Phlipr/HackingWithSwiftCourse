//
//  ViewController.swift
//  Challenge3
//
//  Created by Phillip Reynolds on 12/6/22.
//

import UIKit

class ViewController: UIViewController {
    
    var wrongAnswersLabel: UILabel!
    var answerLabel: UILabel!
    var inputField: UITextField!
    var buttonsView: UIView!
    var letterButtons = [UIButton]()
    var wrongLetters = [String]()
    var correctLetters = [String]()
    var wrongLetterButtons = [UIButton]()
    var correctLetterButtons = [UIButton]()
    
    var currentAnswer = String()
    var possibleAnswers = [String]()
    var previousAnswers = [String]()
    
    var wrongAnswers = 0
    
    let letters = ["A", "B", "C", "D", "E",
                   "F", "G", "H", "I", "J",
                   "K", "L", "M", "N", "O",
                   "P", "Q", "R", "S", "T",
                   "U", "V", "W", "X", "Y",
                   "Z"]
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        wrongAnswersLabel = UILabel()
        wrongAnswersLabel.translatesAutoresizingMaskIntoConstraints = false
        wrongAnswersLabel.textAlignment = .right
        wrongAnswersLabel.font = UIFont.systemFont(ofSize: 32)
        wrongAnswersLabel.text = "0/7 Wrong Answers"
        view.addSubview(wrongAnswersLabel)
        
        let newGameButton = UIButton(type: .system)
        newGameButton.translatesAutoresizingMaskIntoConstraints = false
        newGameButton.setTitle("New Game", for: .normal)
        newGameButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        view.addSubview(newGameButton)
        
        newGameButton.addTarget(self, action: #selector(newGameTapped), for: .touchUpInside)
        
        answerLabel = UILabel()
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        answerLabel.font = UIFont.systemFont(ofSize: 54)
        answerLabel.text = "Loading Guess Word"
        view.addSubview(answerLabel)
        
        answerLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        
        buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        
        buttonsView.layer.borderWidth = 2
        buttonsView.layer.borderColor = UIColor.lightGray.cgColor
        buttonsView.isHidden = true
        
        NSLayoutConstraint.activate([
            wrongAnswersLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            wrongAnswersLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            newGameButton.centerYAnchor.constraint(equalTo: wrongAnswersLabel.centerYAnchor),
            newGameButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            answerLabel.topAnchor.constraint(equalTo: wrongAnswersLabel.bottomAnchor, constant: 10),
            answerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.widthAnchor.constraint(equalToConstant: 750),
            buttonsView.heightAnchor.constraint(equalToConstant: 480),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.topAnchor.constraint(equalTo: answerLabel.bottomAnchor, constant: 20),
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
        ])
        
        // set some values for the width and height of each button
        let width = 150
        let height = 80

        // create 20 buttons as a 4x5 grid
        for row in 0..<6 {
            for col in 0..<5 {
                if row == 5 && (col != 2) {
                    continue
                }
                var letterIndex = row * 5 + col
                
                if (row == 5 && col == 2) {
                    letterIndex = 25
                }
                
                let letterString = letters[letterIndex]
                
                // create a new button and give it a big font size
                let letterButton = UIButton(type: .system)
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)

                // give the button some temporary text so we can see it on-screen
                letterButton.setTitle(letterString, for: .normal)

                // calculate the frame of this button using its column and row
                let frame = CGRect(x: col * width, y: row * height, width: width, height: height)
                letterButton.frame = frame

                // add it to the buttons view
                buttonsView.addSubview(letterButton)

                // and also to our letterButtons array
                letterButtons.append(letterButton)
                
                letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
            }
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        performSelector(inBackground: #selector(loadPossibleAnswers), with: nil)
    }
    
    @objc func letterTapped(_ sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text else { return }
        
        if currentAnswer.uppercased().contains(buttonTitle) {
            correctLetters.append(buttonTitle)
            correctLetterButtons.append(sender)
            sender.isHidden = true
            updateAnswerLabel(with: buttonTitle)
            
            if !(answerLabel.text?.contains("?") ?? true) {
                // Game has been won
                gameWon()
            }
        } else {
            sender.tintColor = .red
            wrongLetters.append(buttonTitle)
            wrongLetterButtons.append(sender)
            updateWrongLabel()
        }
    }
    
    func gameWon() {
        let ac = UIAlertController(title: "Congratulations!", message: "You guessed the word '\(currentAnswer)'.", preferredStyle: .alert)
        
        let newGameAction = UIAlertAction(title: "New Game", style: .default, handler: loadNewGame)
        
        ac.addAction(newGameAction)
        
        present(ac, animated: true)
    }
    
    @objc func newGameTapped(_ sender: UIButton) {
        let ac = UIAlertController(title: "New Game", message: "Are you sure you want to start a new game?", preferredStyle: .alert)
        
        let agreeAction = UIAlertAction(title: "Yes", style: .default, handler: createNewGame)
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        ac.addAction(agreeAction)
        ac.addAction(cancelAction)
        
        present(ac, animated: true)
    }
    
    func createNewGame(action: UIAlertAction! = nil) {
        let ac = UIAlertController(title: "Current Answer", message: "The answer was '\(currentAnswer)'.", preferredStyle: .alert)
        
        let closeAction = UIAlertAction(title: "Close", style: .cancel, handler: loadNewGame)
        
        ac.addAction(closeAction)
        
        present(ac, animated: true)
    }
    
    func updateAnswerLabel(with: String) {
        var newAnswerStringLabel = ""
        
        for letter in currentAnswer {
            
            if correctLetters.contains(String(letter).uppercased()) {
                newAnswerStringLabel.append(letter)
            } else {
                newAnswerStringLabel.append("?")
            }
        }
        
        answerLabel.text = newAnswerStringLabel
    }
    
    func updateWrongLabel() {
        wrongAnswers += 1
        
        wrongAnswersLabel.text = "\(wrongAnswers) / 7 Wrong Answers"
        
        if wrongAnswers == 7 {
            hangman()
        }
    }
    
    func hangman() {
        let ac = UIAlertController(title: "Game Over", message: "You did not guess the word '\(currentAnswer)'.", preferredStyle: .alert)
        
        let playAgain = UIAlertAction(title: "Play Again?", style: .default, handler: loadNewGame)
        ac.addAction(playAgain)
        
        present(ac, animated: true)
    }
    
    func loadNewGame(action: UIAlertAction! = nil) {
        wrongAnswers = 0
        wrongAnswersLabel.text = "0 / 7 Wrong Answers"
        
        for button in wrongLetterButtons {
            button.tintColor = .systemBlue
        }
        
        wrongLetterButtons.removeAll()
        wrongLetters.removeAll()
        
        for button in correctLetterButtons {
            button.isHidden = false
        }
        
        correctLetterButtons.removeAll()
        correctLetters.removeAll()
        
        buttonsView.isHidden = true
        answerLabel.text = "Loading Guessword"
        
        loadPossibleAnswer()
    }

    @objc func loadPossibleAnswers() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                possibleAnswers = startWords.components(separatedBy: "\n")
            }
        }

        if possibleAnswers.isEmpty {
            possibleAnswers = ["silkworm"]
        }
        
        loadPossibleAnswer()
    }
    
    func loadPossibleAnswer() {
        currentAnswer = possibleAnswers.randomElement() ?? "skewer"
        
        while previousAnswers.contains(currentAnswer) {
            currentAnswer = possibleAnswers.randomElement() ?? "skewer"
        }
        
        previousAnswers.append(currentAnswer)
        
        var answerLabelString = ""
        
        for _ in 0..<currentAnswer.count {
            answerLabelString.append("?")
        }
        
        DispatchQueue.main.async {
            self.answerLabel.text = answerLabelString
            self.buttonsView.isHidden = false
        }
    }
}

