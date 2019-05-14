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
"use strict";

const fs = require('fs');

module.exports = function(context) {
    if (context.opts.platforms.indexOf('ios') >= 0) {
        const pkg = require('cordova-ios/package.json');

        // Don't need to do this on Cordova iOS 5.x and higher
        if (parseInt(pkg.version.split('.')[0], 10) > 4) {
          return;
        }

        console.warn('UPDATING the Xcode Project files');

        const encoding = 'utf-8';
        const filepath = 'platforms/ios/cordova/build.xcconfig';

        var xcconfig = fs.readFileSync(filepath, encoding);

        if (!xcconfig.match(/SWIFT_VERSION/)) {
          const content = '\nEMBEDDED_CONTENT_CONTAINS_SWIFT = YES\nSWIFT_VERSION=4.0\nALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=NO';

          xcconfig += content;
          fs.writeFileSync(filepath, xcconfig, encoding);
        }
    }
};
