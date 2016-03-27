//
//  ViewController.swift
//  PragmaticTweets
//
//  Created by Éric Trépanier on 16-03-26.
//  Copyright © 2016 Eric Trepanier. All rights reserved.
//

import UIKit
import Social

class ViewController: UIViewController {

    @IBOutlet weak var twitterWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadTweets()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func handleShowMyTweetsTapped(sender: UIButton) {
        reloadTweets()
    }
    
    @IBAction func handleTweetButtonTapped(sender: UIButton) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            let tweetVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            tweetVC.setInitialText("I just finished the first project in iOS 9 SDK Development. #pragios9")
            self.presentViewController(tweetVC, animated: true, completion: nil)
        } else {
            NSLog("Can't send tweet")
        }
    }

    func reloadTweets() {
        guard let url = NSURL(string: "https://twitter.com/eric_appleseed") else {
            return
        }
        let urlRequest = NSURLRequest(URL: url)
        twitterWebView.loadRequest(urlRequest)
    }
}

