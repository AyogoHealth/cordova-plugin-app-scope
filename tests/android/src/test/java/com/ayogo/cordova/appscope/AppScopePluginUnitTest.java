/**
    Copyright 2026 Darryl Pogue

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
 */

package com.ayogo.cordova.appscope;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

import android.net.Uri;
import androidx.test.ext.junit.runners.AndroidJUnit4;

import org.apache.cordova.CordovaPreferences;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(AndroidJUnit4.class)
public class AppScopePluginUnitTest {
    static class TestAppScopePlugin extends AppScopePlugin {
        TestAppScopePlugin(CordovaPreferences prefs) {
            super();
            this.preferences = prefs;

            pluginInitialize();
        }

        String getAppScope() {
            return this.appScope;
        }
    }

    @Test
    public void remapWithNullScope() {
        CordovaPreferences prefs = new CordovaPreferences();

        TestAppScopePlugin plugin = new TestAppScopePlugin(prefs);
        assertNull(plugin.getAppScope());

        Uri uriMock = Uri.parse("http://example.com");
        assertNull(plugin.remapUri(uriMock));
    }

    @Test
    public void remapWithoutMatchingScope() {
        CordovaPreferences prefs = new CordovaPreferences();
        prefs.set("Scope", "http://cordova.example.com");

        TestAppScopePlugin plugin = new TestAppScopePlugin(prefs);
        assertEquals("http://cordova.example.com", plugin.getAppScope());

        Uri uriMock = Uri.parse("http://example.com");
        assertNull(plugin.remapUri(uriMock));
    }

    @Test
    public void remapWithMatchingScopeAppScheme() {
        CordovaPreferences prefs = new CordovaPreferences();
        prefs.set("Scope", "http://cordova.example.com/");

        TestAppScopePlugin plugin = new TestAppScopePlugin(prefs);
        Uri uriMock = Uri.parse("http://cordova.example.com/test.html");

        Uri result = plugin.remapUri(uriMock);
        assertEquals("https://localhost/test.html", result.toString());
    }

    @Test
    public void remapWithMatchingScopeFileScheme() {
        CordovaPreferences prefs = new CordovaPreferences();
        prefs.set("Scope", "http://cordova.example.com");
        prefs.set("AndroidInsecureFileModeEnabled", true);

        TestAppScopePlugin plugin = new TestAppScopePlugin(prefs);
        Uri uriMock = Uri.parse("http://cordova.example.com/test.html");

        Uri result = plugin.remapUri(uriMock);
        assertEquals("file:///android_asset/www/test.html", result.toString());
    }
}
