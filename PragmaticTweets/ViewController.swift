//
//  ViewController.swift
//  PragmaticTweets
//
//  Created by Éric Trépanier on 16-03-26.
//  Copyright © 2016 Eric Trepanier. All rights reserved.
//

import UIKit
import Accounts
import Social

let defaultAvatarURL = NSURL(string: "https://abs.twimg.com/sticky/default_profile_images/default_profile_6_200x200.png")

class ViewController: UITableViewController {
  
  var parsedTweets: [ParsedTweet] = [
    ParsedTweet(tweetText: "iOS 9 SDK Development now in print. Swift programming FTW!",
      userName: "@pragprog",
      createdAt: "2015-09-09 15:44:30 EDT",
      userAvatarURL: defaultAvatarURL),
    
    ParsedTweet(tweetText: "But was that really such a good idea?",
      userName: "@redqueencoder",
      createdAt: "2014-12-04 22:15:55 CST",
      userAvatarURL: defaultAvatarURL),
    
    ParsedTweet(tweetText: "Struct all the things!",
      userName: "@invalidname",
      createdAt: "2015-07-31 05:39:39 EDT",
      userAvatarURL: defaultAvatarURL)
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    reloadTweets()
    let refresher = UIRefreshControl()
    refresher.addTarget(self, action: #selector(ViewController.handleRefresh(_:)), forControlEvents: .ValueChanged)
    refreshControl = refresher
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func handleRefresh(sender: UIRefreshControl?) {
    parsedTweets.append(
      ParsedTweet(tweetText: "New row",
        userName: "@refresh",
        createdAt: NSDate().description,
        userAvatarURL: defaultAvatarURL))
    reloadTweets()
    refreshControl?.endRefreshing()
  }
  
  func reloadTweets() {
    let accountStore = ACAccountStore()
    let twitterAccountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
    accountStore.requestAccessToAccountsWithType(twitterAccountType, options: nil) { (granted, error) in
      guard granted else {
        NSLog("account access not granted")
        return
      }
      let twitterAccounts = accountStore.accountsWithAccountType(twitterAccountType)
      guard twitterAccounts.count > 0 else {
        NSLog("no twitter accounts configured")
        return
      }
      let twitterParams = [
        "count": "100"
      ]
      let twitterAPIURL = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
      let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: twitterAPIURL, parameters: twitterParams)
      request.account = twitterAccounts.first as! ACAccount
      request.performRequestWithHandler({ (data, urlResponse, error) in
        self.handleTwitterData(data, urlResponse: urlResponse, error: error)
      })
    }
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1;
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return parsedTweets.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("CustomTweetCell") as! ParsedTweetCell!
    let parsedTweet = parsedTweets[indexPath.row]
    cell.userNameLabel.text = parsedTweet.userName
    cell.tweetTextLabel.text = parsedTweet.tweetText
    cell.createdAtLabel.text = parsedTweet.createdAt
    if let url = parsedTweet.userAvatarURL, imageData = NSData(contentsOfURL: url) {
      cell.avatarImageView.image = UIImage(data: imageData)
    }
    return cell
  }
  
  private func handleTwitterData(data: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) {
    guard let data = data else {
      NSLog("handleTwitterData() received no data")
      return
    }
    NSLog("handleTwitterData(), \(data.length) bytes")
    do {
      let jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions([]))
      NSLog("JSON is:\n\(jsonObject)")
    } catch let error as NSError {
      NSLog("JSON error: \(error)")
    }
  }
}
