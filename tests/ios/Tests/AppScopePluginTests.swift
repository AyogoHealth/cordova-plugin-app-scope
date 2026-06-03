/**
 * Copyright 2026 Darryl Pogue
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import XCTest
import WebKit
@testable import Cordova
@testable import AppScopePluginTest

class MockWebViewEngine : NSObject, CDVWebViewEngineProtocol {
    var engineWebView: UIView
    var _loadedURL: URL?
    var didReceiveLoadRequest: Bool = false

    func evaluateJavaScript(_ javaScriptString: String, completionHandler: ((Any, Error) -> Void)? = nil) { }

    func url() -> URL {
        return self._loadedURL ?? URL(string: "app://localhost")!
    }

    func canLoad(_ request: URLRequest) -> Bool {
        return true
    }

    override init() {
        self.engineWebView = WKWebView()
    }

    required init?(frame: CGRect) {
        self.engineWebView = WKWebView()
    }
    required init?(frame: CGRect, configuration: WKWebViewConfiguration?) {
        self.engineWebView = WKWebView()
    }
    func update(withInfo info: [AnyHashable : Any]) { }

    func load(_ request: URLRequest) -> Any {
        self._loadedURL = request.url
        return self.didReceiveLoadRequest = true
    }

    func loadHTMLString(_ string: String, baseURL: URL?) -> Any { return 0 }
}

class AppScopePluginTests: XCTestCase {
    var viewController: CDVViewController!
    var plugin: AppScopePlugin!

    override func setUpWithError() throws {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let window = appDelegate.window!

        self.viewController = (window.rootViewController as! CDVViewController)
        self.plugin = (self.viewController.getCommandInstance("AppScope") as! AppScopePlugin)
    }

    override func tearDownWithError() throws {
        self.plugin.commandDelegate.settings.perform(#selector(NSMutableDictionary.removeObject(forKey:)), with:"scope")
        self.plugin.setValue(self.viewController.webViewEngine, forKey:"webViewEngine")

        self.plugin = nil
        self.viewController = nil
    }

    // MARK: _handleOpenURL
    func testHandleOpenURLWithoutURL() throws {
        let mockWebViewEngine = MockWebViewEngine()
        self.plugin.setValue(mockWebViewEngine, forKey:"webViewEngine")

        NotificationCenter.default.post(name: NSNotification.Name.CDVPluginHandleOpenURL, object: nil)

        XCTAssertFalse(mockWebViewEngine.didReceiveLoadRequest)
    }

    func testHandleOpenURLWithoutDefinedScope() throws {
        let mockWebViewEngine = MockWebViewEngine()
        self.plugin.setValue(mockWebViewEngine, forKey:"webViewEngine")

        NotificationCenter.default.post(name: NSNotification.Name.CDVPluginHandleOpenURL, object: URL(string: "http://cordova.example.com/test.html"))

        XCTAssertFalse(mockWebViewEngine.didReceiveLoadRequest)
    }

    func testHandleOpenURLWithNonMatchingScope() throws {
        let mockWebViewEngine = MockWebViewEngine()
        self.plugin.setValue(mockWebViewEngine, forKey:"webViewEngine")

        self.plugin.commandDelegate.settings.setCordovaSetting("http://example.com/", forKey:"scope")

        NotificationCenter.default.post(name: NSNotification.Name.CDVPluginHandleOpenURL, object: URL(string: "http://cordova.example.com/test.html"))

        XCTAssertFalse(mockWebViewEngine.didReceiveLoadRequest)
    }

    func testHandleOpenURLWithMatchingScope() throws {
        let mockWebViewEngine = MockWebViewEngine()
        self.plugin.setValue(mockWebViewEngine, forKey:"webViewEngine")

        self.plugin.commandDelegate.settings.setCordovaSetting("http://cordova.example.com/", forKey:"scope")

        NotificationCenter.default.post(name: NSNotification.Name.CDVPluginHandleOpenURL, object: URL(string: "http://cordova.example.com/test.html"))

        XCTAssertTrue(mockWebViewEngine.didReceiveLoadRequest)
        XCTAssertTrue(mockWebViewEngine.url().absoluteString.hasPrefix("file:///"))
        XCTAssertTrue(mockWebViewEngine.url().absoluteString.hasSuffix("/test.html"))
    }

    func testHandleOpenURLWithNoResourcePath() throws {
        let mockWebViewEngine = MockWebViewEngine()
        self.plugin.setValue(mockWebViewEngine, forKey:"webViewEngine")

        self.plugin.commandDelegate.settings.setCordovaSetting("http://cordova.example.com/", forKey:"scope")

        NotificationCenter.default.post(name: NSNotification.Name.CDVPluginHandleOpenURL, object: URL(string: "http://cordova.example.com/"))

        XCTAssertTrue(mockWebViewEngine.didReceiveLoadRequest)
        XCTAssertTrue(mockWebViewEngine.url().absoluteString.hasPrefix("file:///"))
        XCTAssertTrue(mockWebViewEngine.url().absoluteString.hasSuffix("/index.html"))
    }

    func testHandleOpenURLWithHash() throws {
        let mockWebViewEngine = MockWebViewEngine()
        self.plugin.setValue(mockWebViewEngine, forKey:"webViewEngine")

        self.plugin.commandDelegate.settings.setCordovaSetting("http://cordova.example.com/", forKey:"scope")

        NotificationCenter.default.post(name: NSNotification.Name.CDVPluginHandleOpenURL, object: URL(string: "http://cordova.example.com/test.html#foo"))

        XCTAssertTrue(mockWebViewEngine.didReceiveLoadRequest)
        XCTAssertTrue(mockWebViewEngine.url().absoluteString.hasPrefix("file:///"))
        XCTAssertTrue(mockWebViewEngine.url().absoluteString.hasSuffix("/test.html#foo"))
    }

    func testHandleOpenURLWithQueryParams() throws {
        let mockWebViewEngine = MockWebViewEngine()
        self.plugin.setValue(mockWebViewEngine, forKey:"webViewEngine")

        self.plugin.commandDelegate.settings.setCordovaSetting("http://cordova.example.com/", forKey:"scope")

        NotificationCenter.default.post(name: NSNotification.Name.CDVPluginHandleOpenURL, object: URL(string: "http://cordova.example.com/test.html?foo=bar"))

        XCTAssertTrue(mockWebViewEngine.didReceiveLoadRequest)
        XCTAssertTrue(mockWebViewEngine.url().absoluteString.hasPrefix("file:///"))
        XCTAssertTrue(mockWebViewEngine.url().absoluteString.hasSuffix("/test.html?foo=bar"))
    }

    // MARK: _handleContinueUserActivity
    func testContinueUserActivityWithoutActivity() throws {
        expectation(forNotification: NSNotification.Name.CDVPluginHandleOpenURL, object: nil, handler: nil).isInverted = true

        NotificationCenter.default.post(name: NSNotification.Name.CDVPluginContinueUserActivity, object: nil)

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testContinueUserActivityWithoutTypeBrowsingWeb() throws {
        let activity = NSUserActivity(activityType: "SomethingElse")

        expectation(forNotification: NSNotification.Name.CDVPluginHandleOpenURL, object: nil, handler: nil).isInverted = true

        NotificationCenter.default.post(name: NSNotification.Name.CDVPluginContinueUserActivity, object: activity)

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testContinueUserActivityWithoutWebPage() throws {
        let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)

        expectation(forNotification: NSNotification.Name.CDVPluginHandleOpenURL, object: nil, handler: nil).isInverted = true

        NotificationCenter.default.post(name: NSNotification.Name.CDVPluginContinueUserActivity, object: activity)

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testContinueUserActivity() throws {
        let url = URL(string: "http://example.com/index.html")
        let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        activity.webpageURL = url

        expectation(forNotification: NSNotification.Name.CDVPluginHandleOpenURL, object: url, handler: nil)

        NotificationCenter.default.post(name: NSNotification.Name.CDVPluginContinueUserActivity, object: activity)

        waitForExpectations(timeout: 0.1, handler: nil)
    }
}
