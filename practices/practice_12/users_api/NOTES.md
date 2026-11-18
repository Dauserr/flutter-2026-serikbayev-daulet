# Practice 12 - Notes

## Package verdicts

1. **shared_preferences** - Verified publisher flutter.dev, released in October 2026, supports Android, iOS, Linux, macOS, web and Windows, 160 pub points, BSD-3-Clause, depends on the platform implementation packages; `flutter/packages` shows 299 open issues overall but was pushed on 18 November 2026.
2. **flutter_secure_storage** - Third-party publisher steenbakker.dev, released in September 2026, supports Android, iOS, Linux, macOS, web and Windows, 160 pub points, BSD-3-Clause, depends on the platform implementation packages; its repository has 24 open issues and was pushed on 18 November 2026.
3. **path_provider** - Verified publisher flutter.dev, released in June 2026, supports Android, iOS, Linux, macOS and Windows, 160 pub points, BSD-3-Clause, depends on the platform implementation packages; `flutter/packages` shows 299 open issues overall but was pushed on 18 November 2026.
4. **image_picker** - Verified publisher flutter.dev, released in October 2026, supports Android, iOS, Linux, macOS, web and Windows, 160 pub points, Apache-2.0 / BSD-3-Clause, depends on the platform implementation packages; `flutter/packages` shows 299 open issues overall but was pushed on 18 November 2026.
5. **permission_handler** - Third-party publisher baseflow.com, released in September 2026, supports Android, iOS, web and Windows, 160 pub points, MIT, depends on the platform implementation packages; its repository has 157 open issues but was pushed on 6 November 2026.
6. **url_launcher** - Verified publisher flutter.dev, released in October 2026, supports Android, iOS, Linux, macOS, web and Windows, 160 pub points, BSD-3-Clause, depends on the platform implementation packages; `flutter/packages` shows 299 open issues overall but was pushed on 18 November 2026.

## Caret and lock file

`http` resolved to **1.6.0** in `pubspec.lock`.

`^1.2.0` accepts `>=1.2.0 <2.0.0`, so it accepts `1.2.0`, `1.6.0`, and `1.99.0`; it refuses `2.0.0` and anything above it.

`pubspec.lock` is committed because this is an application, not a package: it pins exact direct and transitive versions so every machine and CI build gets the same dependency graph.

`flutter pub outdated` showed `cupertino_icons` at `1.0.9` while `2.0.0` exists. It was not upgraded because the project still has `cupertino_icons: ^1.0.8`, which caps it below `2.0.0`.

## Token storage

`SharedPreferences.setString('token', ...)` would store the token in a plain preferences file: an XML file in the app's private data directory on Android, or a plist / NSUserDefaults file in the app container on iOS. It is readable through a device backup, by root or jailbreak access, or by anyone who can pull the app container over a cable. That is why the token goes to Keychain / Keystore through `flutter_secure_storage` instead.

Two platform surprises from the lecture:

- On iOS, Keychain items can survive an app uninstall; a reinstall can still see the old token.
- On Android, removing the lock screen or changing device credentials can invalidate the Keystore key, making the stored token unreadable.

## Permissions

Android: two "Don't allow" answers make the next `Permission.camera.request()` return `permanentlyDenied` without showing the system dialog. The app then shows its own dialog with **Open settings**, which calls `openAppSettings()`.

iOS: the system camera dialog is only shown once; after one **Don't Allow**, the status is permanently denied and only Settings can change it. In the Photos permission there is an extra fourth state, **limited**, for partial library access.

## Storage locations

- Settings: `SharedPreferencesAsync` (`darkMode`, `cityFilter`).
- Token: `flutter_secure_storage` (`token`).
- Offline users: `users.json` in `getApplicationDocumentsDirectory()`.
- Avatar: `avatar.jpg` in `getApplicationDocumentsDirectory()`, path saved in preferences.
