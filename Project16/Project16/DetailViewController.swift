//
//  DetailViewController.swift
//  Project16
//
//  Created by Phillip Reynolds on 1/18/23.
//

import UIKit
import WebKit

class DetailViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var capital: String?
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let capital = capital else {
            return
        }
        
        let capitalStr = capital.replacingOccurrences(of: " ", with: "_")
        
        let wikiUrlStr = "https://en.wikipedia.org/wiki/\(capitalStr)"
        let wikiUrl = URL(string: wikiUrlStr)!
        webView.load(URLRequest(url: wikiUrl))
        webView.allowsBackForwardNavigationGestures = true
    }
}
