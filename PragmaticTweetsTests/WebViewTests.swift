//
//  WebViewTests.swift
//  PragmaticTweets
//
//  Created by Éric Trépanier on 16-03-27.
//  Copyright © 2016 Eric Trepanier. All rights reserved.
//

import XCTest

@testable import PragmaticTweets

class WebViewTests: XCTestCase, UIWebViewDelegate {
    
    var loadedWebViewExpetation: XCTestExpectation?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAutomaticWebLoad() {
        guard let viewController = UIApplication.sharedApplication().windows[0].rootViewController as? ViewController else {
            XCTFail("couldn't get root view controller")
            return
        }
        viewController.twitterWebView.delegate = self
        loadedWebViewExpetation = expectationWithDescription("web view auto-load test")
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        XCTFail("web view load failed")
        loadedWebViewExpetation?.fulfill()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if let webViewContents = webView.stringByEvaluatingJavaScriptFromString("document.documentElement.textContent")
            where webViewContents != "" {
            loadedWebViewExpetation?.fulfill()
        }
    }
}
