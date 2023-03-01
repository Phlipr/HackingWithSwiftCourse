//
//  ViewController.swift
//  Project21
//
//  Created by Phillip Reynolds on 3/1/23.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
    }

    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()

            center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if granted {
                    print("Yay!")
                } else {
                    print("D'oh")
                }
            }
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        let show = UNNotificationAction(identifier: "show", title: "Tell me more…", options: .foreground)
        let remindLater = UNNotificationAction(identifier: "remindMeLater", title: "Remind me later", options: .foreground)
        let category = UNNotificationCategory(identifier: "alarm", actions: [show, remindLater], intentIdentifiers: [])

        center.setNotificationCategories([category])
    }

    @objc func scheduleLocal() {
        registerCategories()
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default

        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 30
        // let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func remindMeLater() {
        registerCategories()
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "Late Reminder"
        content.body = "As instructed, I'm reminding you later."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "remindLater"]
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // pull out the buried userInfo dictionary
        let userInfo = response.notification.request.content.userInfo

        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")

            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // the user swiped to unlock
                print("Default identifier")
                let ac = UIAlertController(title: "Swiped Open", message: "You swiped the notification to get here...custom data = \(customData)", preferredStyle: .alert)
                
                let okayButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                ac.addAction(okayButton)
                present(ac, animated: true)

            case "show":
                // the user tapped our "show more info…" button
                print("Show more information…")
                let ac = UIAlertController(title: "Show More Information", message: "You tapped on the Tell Me More option to get here...custom data = \(customData)", preferredStyle: .alert)
                
                let okayButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                ac.addAction(okayButton)
                present(ac, animated: true)
                
            case "remindMeLater":
                // the user tapped our "Remind Me Later" button
                remindMeLater()
                let ac = UIAlertController(title: "Remind Me Later", message: "You tapped on the Remind Me Later option to get here...custom data = \(customData)", preferredStyle: .alert)
                
                let okayButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                ac.addAction(okayButton)
                present(ac, animated: true)

            default:
                break
            }
        }

        // you must call the completion handler when you're done
        completionHandler()
    }
}

