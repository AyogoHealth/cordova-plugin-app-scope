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
package com.ayogo.cordova.appscope;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import java.lang.reflect.Field;
import java.lang.reflect.Method;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.LOG;


public class AppScopePlugin extends CordovaPlugin {
    private String appScope;

    private final String TAG = "AppScopePlugin";


    /**
     * Called after plugin construction and fields have been initialized.
     */
    @Override
    public void pluginInitialize() {
        LOG.i(TAG, "Initializing");

        this.appScope = preferences.getString("scope", null);
    }


    /**
     * Called when the activity is becoming visible to the user.
     */
    @Override
    public void onStart() {
        onNewIntent(cordova.getActivity().getIntent());
    }


    /**
     * Called when the activity receives a new intent.
     */
    @Override
    public void onNewIntent(Intent intent) {
        if (intent == null || !intent.getAction().equals(Intent.ACTION_VIEW)) {
            return;
        }

        final Uri intentUri = intent.getData();

        LOG.i(TAG, "Handling intent URL: " + intentUri.toString());

        final Uri remapped = this.remapUri(intentUri);

        if (remapped != null) {
            this.webView.getEngine().loadUrl(remapped.toString(), false);
        }
    }


    /**
     * Hook for blocking the loading of external resources.
     */
    @Override
    public Boolean shouldAllowRequest(String url) {
        if (url.startsWith(this.appScope)) {
            return true;
        }

        return null;
    }


    /**
     * Hook for blocking navigation by the Cordova WebView.
     *
     * This applies both to top-level and iframe navigations.
     */
    @Override
    public Boolean shouldAllowNavigation(String url) {
        if (url.startsWith(this.appScope)) {
            return true;
        }

        return null;
    }


    /**
     * Hook for redirecting requests.
     *
     * Applies to WebView requests as well as requests made by plugins.
     */
    @Override
    public Uri remapUri(Uri uri) {
        if (!uri.toString().startsWith(this.appScope)) {
            return null;
        }

        String remapped = uri.toString().replace(this.appScope, "");

        if (remapped.startsWith("/")) {
            remapped = remapped.substring(1);
        }

        if (remapped.startsWith("#") || remapped.startsWith("?") || remapped.length() == 0) {
            remapped = "index.html" + remapped;
        }

        String resultURL = "file:///android_asset/www/" + remapped;

        try {
            CordovaPlugin codepush = this.webView.getPluginManager().getPlugin("CodePush");
            if (codepush != null) {
                Class<?> codepushClass = codepush.getClass();
                Field pkgMgr = codepushClass.getDeclaredField("codePushPackageManager");
                pkgMgr.setAccessible(true);

                Object codePushPackageManager = pkgMgr.get(codepush);

                Class<?> cppmClass = pkgMgr.getType();

                Method getCurrentPackageMetadata = cppmClass.getDeclaredMethod("getCurrentPackageMetadata");

                Object packageMetadata = getCurrentPackageMetadata.invoke(codePushPackageManager);

                if (packageMetadata != null) {
                    Class<?> metadataClass = getCurrentPackageMetadata.getReturnType();
                    Field localPathField = metadataClass.getDeclaredField("localPath");
                    String localPath = (String)localPathField.get(packageMetadata);

                    if (localPath != null) {
                        resultURL = "file://" + this.cordova.getActivity().getFilesDir() + localPath + "www/" + remapped;
                    }
                }
            }
        } catch (Exception e) {
          LOG.e(TAG, Log.getStackTraceString(e));
        }

        LOG.d(TAG, "Result URL is " + resultURL);
        return Uri.parse(resultURL);
    }
}
