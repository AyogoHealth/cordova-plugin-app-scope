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

const configPatches = {
    android: function(context, scope) {
        const et = require('elementtree');

        let intentFilter = et.Element('intent-filter');
        intentFilter.set('android:label', '@string/launcher_name');
        intentFilter.set('android:autoVerify', 'true');

        et.SubElement(intentFilter, 'action').set('android:name', 'android.intent.action.VIEW');
        et.SubElement(intentFilter, 'category').set('android:name', 'android.intent.category.DEFAULT');
        et.SubElement(intentFilter, 'category').set('android:name', 'android.intent.category.BROWSABLE');

        let data = et.SubElement(intentFilter, 'data');
        data.set('android:scheme', scope.protocol.replace(/:/, ''));
        data.set('android:host', scope.host);
        if (scope.pathname) {
            data.set('android:pathPrefix', scope.pathname);
        }

        return [{
            target: 'app/src/main/AndroidManifest.xml',
            parent: '/manifest/application/activity',
            xmls: [intentFilter]
        }];
    },

    ios: function(context, scope) {
        const et = require('elementtree');

        let array = et.Element('array');

        let applink = et.SubElement(array, 'string');
        applink.text = 'applinks:' + scope.host;

        let continuation = et.SubElement(array, 'string');
        continuation.text = 'activitycontinuation:' + scope.host;

        let credentials = et.SubElement(array, 'string');
        credentials.text = 'webcredentials:' + scope.host;

        return [{
          target: '*/Entitlements-Debug.plist',
          parent: 'com.apple.developer.associated-domains',
          xmls: [array]
        }, {
          target: '*/Entitlements-Release.plist',
          parent: 'com.apple.developer.associated-domains',
          xmls: [array]
        }];
    }
};


class PatchConfig {
    constructor(context, scope) {
        this.context = context;
        this.scope = scope;
        this.id = this.name = 'cordova-plugin-app-scope';
    }

    getConfigFiles(platform) {
        if (configPatches[platform]) {
            return configPatches[platform](this.context, this.scope);
        } else {
            return [];
        }
    }
}


module.exports = function(context) {
    // Module imports
    const path = require('path');
    const url = require('url');
    const common = context.requireCordovaModule('cordova-common');
    const utils = context.requireCordovaModule('cordova-lib/src/cordova/util');

    // Global-ish variables
    const projectRoot = context.opts.projectRoot;
    const configFile = new common.ConfigParser(utils.projectConfig(projectRoot));

    context.opts.platforms.forEach(platform => {
        const scope = configFile.getPreference('scope', platform);
        if (!scope) {
            common.events.emit('warn', 'No scope preference defined. Skipping URL association setup for ' + platform);
            return;
        }

        const scopeUrl = url.URL ? new url.URL(scope) : url.parse(scope);

        const platformRoot = path.join(projectRoot, 'platforms', platform);
        const platformJson = common.PlatformJson.load(platformRoot, platform);
        const patchConfig = new PatchConfig(context, scopeUrl);
        const munger = new common.ConfigChanges.PlatformMunger(platform, platformRoot, platformJson);

        munger.add_plugin_changes(patchConfig, {}, true, true).save_all();
    });
}
