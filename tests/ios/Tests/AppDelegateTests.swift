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

class AppDelegateTests: XCTestCase {
    var appDelegate: AppDelegate!

    override func setUpWithError() throws {
        self.appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    }

    override func tearDownWithError() throws {
        self.appDelegate = nil
    }

    func testContinueUserActivity() throws {
        let url = URL(string: "http://example.com/index.html")
        let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        activity.webpageURL = url

        expectation(forNotification: NSNotification.Name.CDVPluginContinueUserActivity, object: activity, handler: nil)
        expectation(forNotification: NSNotification.Name.CDVPluginHandleOpenURL, object: url, handler: nil)

        self.appDelegate.application(UIApplication.shared, continue:activity, restorationHandler:{ (restorableObjects: [any UIUserActivityRestoring]?) in
            return
        })

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testContinueUserActivitySkipsNonWebpages() throws {
        let activity = NSUserActivity(activityType: "SomethingElse")

        expectation(forNotification: NSNotification.Name.CDVPluginContinueUserActivity, object: activity, handler: nil)
        expectation(forNotification: NSNotification.Name.CDVPluginHandleOpenURL, object: nil, handler: nil).isInverted = true

        self.appDelegate.application(UIApplication.shared, continue:activity, restorationHandler:{ (restorableObjects: [any UIUserActivityRestoring]?) in
            return
        })

        waitForExpectations(timeout: 0.1, handler: nil)
    }
}
