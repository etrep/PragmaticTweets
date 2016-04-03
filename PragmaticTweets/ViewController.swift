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
  
  var parsedTweets: [ParsedTweet] = []
  
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
    cell.avatarImageView.image = nil
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) { 
      if let url = parsedTweet.userAvatarURL, imageData = NSData(contentsOfURL: url) where cell.userNameLabel.text == parsedTweet.userName {
        dispatch_async(dispatch_get_main_queue(), { 
          cell.avatarImageView.image = UIImage(data: imageData)
        })
      }
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
      guard let jsonArray = jsonObject as? [[String: AnyObject]] else {
        NSLog("handleTwitterData() didn't get an array")
        return
      }
      parsedTweets.removeAll()
      for tweetDict in jsonArray {
        var parsedTweet = ParsedTweet()
        parsedTweet.tweetText = tweetDict["text"] as? String
        parsedTweet.createdAt = tweetDict["created_at"] as? String
        if let userDict = tweetDict["user"] as? [String: AnyObject] {
          parsedTweet.userName = userDict["name"] as? String
          if let avatarURLString = userDict["profile_image_url_https"] as? String {
            parsedTweet.userAvatarURL = NSURL(string: avatarURLString)
          }
        }
        parsedTweets.append(parsedTweet)
      }
      dispatch_async(dispatch_get_main_queue(), { 
        self.tableView.reloadData()
      })
    } catch let error as NSError {
      NSLog("JSON error: \(error)")
    }
  }
}
