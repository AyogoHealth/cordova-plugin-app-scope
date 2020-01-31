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
    override func pluginInitialize() {
        NotificationCenter.default.addObserver(self,
                selector: #selector(CDVAppScopePlugin._didFinishLaunchingWithOptions(_:)),
                name: UIApplication.didFinishLaunchingNotification,
                object: nil);


        NotificationCenter.default.addObserver(self,
                selector: #selector(CDVAppScopePlugin._handleOpenURL(_:)),
                name: NSNotification.Name.CDVPluginHandleOpenURL,
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
