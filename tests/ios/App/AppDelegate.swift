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

import UIKit
import Cordova

@UIApplicationMain
class AppDelegate: CDVAppDelegate {
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if #available(iOS 13.0, *) {
            // Handled in application:configurationForConnecting:options:
        } else {
            let bounds = UIScreen.main.bounds;
            let window = UIWindow(frame: bounds);
            window.autoresizesSubviews = true;
            window.rootViewController = CDVViewController();
            window.makeKeyAndVisible();

            self.window = window;
        }

        return true;
    }

    @available(iOS 13.0, *)
    override func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole:connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}

@available(iOS 13.0, *)
class SceneDelegate: CDVSceneDelegate {
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }

        let window = UIWindow(windowScene: windowScene)
        window.autoresizesSubviews = true;
        window.rootViewController = CDVViewController();
        window.makeKeyAndVisible();

        self.window = window;

        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            appDelegate.window = window;
        }
    }
}
