# Deep Links (Password Reset)
## Android — android/app/src/main/AndroidManifest.xml
```xml
<meta-data android:name="flutter_deeplinking_enabled" android:value="false" />
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="app.lunora" android:host="login-callback" />
</intent-filter>
```
## iOS — ios/Runner/Info.plist
```xml
<key>FlutterDeepLinkingEnabled</key><false/>
<key>CFBundleURLTypes</key>
<array><dict>
  <key>CFBundleTypeRole</key><string>Editor</string>
  <key>CFBundleURLSchemes</key><array><string>app.lunora</string></array>
</dict></array>
```
## Supabase Dashboard
Authentication → URL Configuration → Redirect URLs: `app.lunora://login-callback`
