//
//  SizeClassOverrideViewController.swift
//  PragmaticTweets
//
//  Created by Éric Trépanier on 16-04-06.
//  Copyright © 2016 Eric Trepanier. All rights reserved.
//

import UIKit

class SizeClassOverrideViewController: UIViewController {
  
  var embeddedSplitVC: UISplitViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "embedSplitViewSegue" {
      embeddedSplitVC = segue.destinationViewController
        as! UISplitViewController
    }
  }

  override func viewWillTransitionToSize(size: CGSize,
    withTransitionCoordinator coordinator:
    UIViewControllerTransitionCoordinator) {
      if size.width > 480.0 { 
        let overrideTraits = UITraitCollection ( 
        horizontalSizeClass: .Regular) 
        setOverrideTraitCollection(overrideTraits, 
          forChildViewController: embeddedSplitVC!) 
      } else {
        setOverrideTraitCollection(nil, 
          forChildViewController: embeddedSplitVC!) 
      }
  }
  
}
