<!--
  Copyright 2018 Ayogo Health Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->

cordova-plugin-app-scope
========================

This plugin permits registering the application as a handler for a URL scope, and remapping URLs within that scope to the application bundle. This allows for deep linking from web URLs into the application using [Universal Links](https://developer.apple.com/ios/universal-links/) on iOS and [App Links](https://developer.android.com/training/app-links/) on Android.

This plugin is compatible with [cordova-plugin-code-push](https://www.npmjs.com/package/cordova-plugin-code-push).


Installation
------------

```
cordova plugin add cordova-plugin-app-scope
```


Supported Platforms
-------------------

* iOS
* Android


Usage
-----

This plugin will take an HTTPS URL scope, and translate any URL within that scope into a local path to within the application bundle. For example, if the scope were defined as `https://example.com/myapp/` and the app were asked to load `https://example.com/myapp/products/index.html`, it would rewrite the URL to point to the bundled www files of the Cordova application. In this example on Android, it would result in `file:///android_asset/www/products/index.html`.

The URL scope **must** be HTTPS, **must** end with a trailing slash, and needs to be defined in config.xml as a preference with the name `"Scope"`:

```
<preference name="Scope" value="https://example.com/myapp/" />
```

In addition to rewriting URLs when loaded in the Cordova application, the plugin will also attempt to register the application as a system-wide handler for URLs matching the scope. This requires some additional server-side configuration at the website matching the URL scope:

* iOS: [Setting Up an App's Associated Domains](https://developer.apple.com/documentation/uikit/core_app/allowing_apps_and_websites_to_link_to_your_content/enabling_universal_links)
* Android: [Verify Android App Links](https://developer.android.com/training/app-links/verify-site-associations)

The plugin will take care of setting up the Associated Domains entitlements for iOS and the Intent filters for Android, but you must set up the `assetlinks.json` and `apple-app-site-association` files on the web server.

If you want to allow your iOS app to use web credentials from Safari, you'll also need to include [`webcredentials`](https://developer.apple.com/documentation/security/password_autofill/setting_up_an_app_s_associated_domains) in your `apple-app-site-association` file.


### JavaScript API

This plugin exposes no API to the application.


Contributing
------------

Contributions of bug reports, feature requests, and pull requests are greatly appreciated!

Please note that this project is released with a [Contributor Code of Conduct](https://github.com/AyogoHealth/cordova-plugin-app-scope/blob/master/CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

Licence
-------

Released under the Apache 2.0 Licence.
Copyright © 2018 Ayogo Health Inc.
