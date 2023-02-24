//
//  ActionViewController.swift
//  MyExtension
//
//  Created by Phillip Reynolds on 2/9/23.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionViewController: UIViewController {
    
    
    @IBOutlet var script: UITextView!
    var pageTitle = ""
    var pageURL = ""
    var scripts = [Script]()
    
    override func viewDidLoad() {
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
                if let itemProvider = inputItem.attachments?.first {
                    itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [weak self] (dict, error) in
                        guard let itemDictionary = dict as? NSDictionary else { return }
                        guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                        self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                        self?.pageURL = javaScriptValues["URL"] as? String ?? ""

                        DispatchQueue.main.async {
                            self?.title = self?.pageTitle
                            
                            let defaults = UserDefaults.standard
                            
                            if let savedUrl = URL(string: self?.pageURL ?? "") {
                                if let savedScript = defaults.string(forKey: savedUrl.host!) {
                                    self?.script.text = savedScript
                                }
                            }
                            
                            if let savedScripts = defaults.object(forKey: "scripts") as? Data {
                                let jsonDecoder = JSONDecoder()

                                do {
                                    self?.scripts = try jsonDecoder.decode([Script].self, from: savedScripts)
                                    if self?.scripts.count ?? 0 < 3 {
                                        self?.initializeScripts()
                                    }
                                } catch {
                                    print("Failed to load scripts")
                                }
                            }
                        }
                    }
                }
            }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Scripts", style: .plain, target: self, action: #selector(chooseScriptAction))
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @IBAction func done() {
        let defaults = UserDefaults.standard
        
        if let urlKey = URL(string: pageURL) {
            defaults.set(script.text, forKey: urlKey.host!)
        }
        
        let item = NSExtensionItem()
            let argument: NSDictionary = ["customJavaScript": script.text]
            let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
            let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
            item.attachments = [customJavaScript]

            extensionContext?.completeRequest(returningItems: [item])
    }

    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            script.contentInset = .zero
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        script.scrollIndicatorInsets = script.contentInset

        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }
    
    @objc func chooseScriptAction() {
        let ac = UIAlertController(title: "Script Actions", message: "Please choose which script action you would like to take.", preferredStyle: .actionSheet)
        
        let saveScript = UIAlertAction(title: "Save Script", style: .default, handler: saveScript)
        let loadScript = UIAlertAction(title: "Load Script", style: .default, handler: loadScript)
        let deleteScript = UIAlertAction(title: "Delete Script", style: .default, handler: deleteScript)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ac.addAction(saveScript)
        ac.addAction(loadScript)
        ac.addAction(deleteScript)
        ac.addAction(cancelAction)
        
        present(ac, animated: true)
    }
    
    func saveScript(action: UIAlertAction! = nil) {
        let ac = UIAlertController(title: "Save Script as", message: "Please enter a name for the script.", preferredStyle: .alert)
        
        ac.addTextField()

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else { return }
            let currScriptName = newName
            
            let genericName = "Script\((self?.scripts.count ?? 0) + 1)"
            
            let currScript = Script(scriptText: self?.script.text ?? "", scriptName: currScriptName == "" ? genericName : currScriptName)
            
            self?.scripts.append(currScript)
            
            self?.save()
        })
        
        present(ac, animated: true)
    }
    
    func loadScript(action: UIAlertAction! = nil) {
        loadTableViewOfScripts(for: "loading")
    }
    
    func deleteScript(action: UIAlertAction! = nil) {
        loadTableViewOfScripts(for: "deleting")
    }
    
    func loadTableViewOfScripts(for mode: String) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ScriptsTable") as? ScriptsTableView {
            vc.scripts = self.scripts
            vc.mode = mode
            
            vc.delegate = self
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func initializeScripts() {
        var scriptDictionary: [String: String] = [:]
        
        scriptDictionary["AlertTitleOnly"] = "alert(document.title);"
        scriptDictionary["AlertUrlOnly"] = "alert(window.location.href);"
        scriptDictionary["AlertBoth"] = "alert(document.title + ': ' + window.location.href);"
        
        for (currName, currText) in scriptDictionary {
            let currScript = Script(scriptText: currText, scriptName: currName)
            
            scripts.append(currScript)
        }
        
        save()
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(scripts) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "scripts")
        } else {
            print("Failed to save people.")
        }
    }
    
    func updateScriptText(newScriptText: String) {
        script.text = newScriptText
    }
    
    func removeScript(named scriptNameToRemove: String) {
        scripts = scripts.filter { script in
            if script.scriptName != scriptNameToRemove {
                return true
            } else {
                return false
            }
        }
        
        save()
    }
}
