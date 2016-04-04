//
//  UserDetailViewController.swift
//  PragmaticTweets
//
//  Created by Éric Trépanier on 16-04-04.
//  Copyright © 2016 Eric Trepanier. All rights reserved.
//

import UIKit

class UserDetailViewController: UIViewController {
  
  @IBOutlet weak var userImageView: UIImageView!
  @IBOutlet weak var userRealNameLabel: UILabel!
  @IBOutlet weak var userScreenNameLabel: UILabel!
  @IBOutlet weak var userLocationLabel: UILabel!
  @IBOutlet weak var userDescriptionLabel: UILabel!
  
  var screenName: String?
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    guard let screenName = screenName else {
      return
    }
    if let twitterAPIURL = NSURL(string: "https://api.twitter.com/1.1/users/show.json") {
      let twitterParams = ["screen_name": screenName]
      sendTwitterRequest(twitterAPIURL, params: twitterParams) { (data, urlResponse, error) in
        dispatch_async(dispatch_get_main_queue(), {
          self.handleTwitterData(data, urlResponse: urlResponse, error: error)
        })
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
  private func handleTwitterData(data: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) {
    guard let data = data else {
      NSLog("handleTwitterData() receive no data")
      return
    }
    NSLog("handleTwitterData(), \(data.length) bytes")
    do {
      let jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions([]))
      guard let tweetDict = jsonObject as? [String: AnyObject] else {
        NSLog("handleTwitterData() didn't get a dictionary")
        return
      }
      NSLog("tweetDict: \(tweetDict)")
      self.userRealNameLabel.text = tweetDict["name"] as? String
      self.userScreenNameLabel.text = tweetDict["screen_name"] as? String
      self.userLocationLabel.text = tweetDict["location"] as? String
      self.userDescriptionLabel.text = tweetDict["description"] as? String
      if let userImageURL = NSURL(string: tweetDict["profile_image_url_https"] as! String), userImageData = NSData(contentsOfURL: userImageURL) {
        self.userImageView.image = UIImage(data: userImageData)
      }
    } catch let error as NSError {
      NSLog("JSON error: \(error)")
    }
  }
}
