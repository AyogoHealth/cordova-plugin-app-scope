/**
 * Copyright 2018 Ayogo Health Inc.
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

@objc(CDVAppScopePlugin)
class CDVAppScopePlugin : CDVPlugin {

    var notificationData: String? = nil;

    override func pluginInitialize() {

        NotificationCenter.default.addObserver(self,
                selector: #selector(CDVAppScopePlugin._didFinishLaunchingWithOptions(_:)),
                name: NSNotification.Name.UIApplicationDidFinishLaunching,
                object: nil);


        NotificationCenter.default.addObserver(self,
                selector: #selector(CDVAppScopePlugin._handleOpenURL(_:)),
                name: NSNotification.Name.CDVPluginHandleOpenURL,
                object: nil);

        NotificationCenter.default.addObserver(self,
                selector: #selector(CDVAppScopePlugin.handlePageLoad),
                name: NSNotification.Name.CDVPageDidLoad,
                object: nil);


        NotificationCenter.default.addObserver(self,
                selector: #selector(CDVAppScopePlugin.handleNotificationData),
                name: NSNotification.Name(rawValue: "AyHandleUrlCustomData"),
                object: nil);
    }


    /* Application Launch URL handling ***************************************/

    @objc internal func _didFinishLaunchingWithOptions(_ notification : NSNotification) {
        let options = notification.userInfo;
        if options == nil {
            return;
        }

        if let incomingUrl = options?[UIApplication.LaunchOptionsKey.url] as? URL {
            NSLog("APPSCOPE-PLUGIN: Got launched with URL: \(incomingUrl)")

            NotificationCenter.default.post(name: NSNotification.Name.CDVPluginHandleOpenURL, object: incomingUrl);
        }
    }

    @objc internal func handlePageLoad() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if (self.notificationData != nil) {
                self.webViewEngine.evaluateJavaScript("window.dispatchEvent(new CustomEvent('notificationClicked', { detail: '\(self.notificationData!)' }));", completionHandler: nil)
            }
        }
    }

    @objc internal func handleNotificationData(_ notificationData : NSNotification) {
        guard let dataObject = notificationData.object else {
            return;
        }

        if let notificationJSONData = try? JSONSerialization.data(withJSONObject: dataObject,options: []) {
            let notificationTextData = String(data: notificationJSONData,
                                       encoding: .utf8)
            self.notificationData = notificationTextData;
        }
    }

    @objc internal func _handleOpenURL(_ notification : NSNotification) {
        guard let url = notification.object as? URL else {
            return
        }

        guard let scope = self.commandDelegate.settings["scope"] as? String else {
            return
        }

        if !url.absoluteString.hasPrefix(scope) {
            return
        }

        var remapped = String(url.absoluteString.dropFirst(scope.count))
        if remapped.hasPrefix("#") || remapped.hasPrefix("?") || remapped.count == 0 {
            remapped = "index.html" + remapped;
        }

        let startURL = URL(string: remapped)
        let startFilePath = self.commandDelegate.path(forResource: startURL?.path)

        var appURL = URL(fileURLWithPath: startFilePath!)

        if let r = remapped.rangeOfCharacter(from: CharacterSet(charactersIn: "?#")) {
            let queryAndOrFragment = String(remapped[r.lowerBound..<remapped.endIndex])
            appURL = URL(string: queryAndOrFragment, relativeTo: appURL)!
        }

        NSLog("APPSCOPE-PLUGIN: Loading with URL: \(appURL.absoluteString)")

        let appReq = URLRequest(url: appURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20.0)
        self.webViewEngine.load(appReq)
    }
}
