## Practice 13 - Where things go

### The seam that made the test possible

The old `UsersModel` created its own repository, so the arrange step for "NoConnection sets error" could not be written: there was no constructor seam through which to hand the model a failing repository.

### Why a widget, not a `_build...()` method

An extracted widget can be `const`, has its own rebuild scope, appears in DevTools, and can be pumped and tested in isolation. A private build method has none of those properties.

### The planted lat trace

`lat` was changed from `"-37.3159"` to `-37.3159` for user **Leanne Graham** (user id 1). `jsonplaceholder` sends `lat` as a string, so this violates the contract.

```text
type 'double' is not a subtype of type 'String' in type cast
#0      new Geo.fromJson (package:users_api/features/users/user.dart:9:37)
#1      new Address.fromJson (package:users_api/features/users/user.dart:40:16)
#2      new User.fromJson (package:users_api/features/users/user.dart:88:24)
#3      BadRepository.getAll (file:///C:/Users/FoxOS_User/flutter-2026-serikbayev-daulet/practices/practice_13/users_api/test/tmp_trace_test.dart:40:26)
#4      UsersModel.load (package:users_api/features/users/users_model.dart:23:34)
#5      main.<anonymous closure> (.../test/tmp_trace_test.dart:55:19)
<asynchronous suspension>
```

`#0` is the right place to throw because `Geo.fromJson` is the first place that can see the broken `lat` claim, and it names the exact field. It is the wrong place to fix because `Geo` cannot decide whether bad JSON should become a cached result, a generic error, or a retry; that decision belongs to the repository and the model.

### Layer rule

`tool/check_layers.sh` checks both directions:

- `package:http` appears only under `core/api` or in a `*_repository.dart`.
- `package:flutter/material` never appears in a model, a repository or `core/api`.

### Tests

- `user_test.dart`: real JSON parses; string `id` throws `TypeError`.
- `users_model_test.dart`: loaded items; `NoConnectionException` sets `error`.
- `user_repository_test.dart`: `404` → `NotFoundException`, `500` → `ServerException`, `SocketException` → `NoConnectionException`, broken `lat` → `BadResponseException`.
- `users_screen_test.dart`: offline view and Retry.

The planted lat bug is reproduced in `user_test.dart` (`Geo rejects a numeric lat`) and mapped at the repository level in `user_repository_test.dart`.

## Practice 14 - Ship It

### Version

`1.0.1` is the version name: people and the store display it. `1` / `2` after `+` is the build number: the store uses it to order uploads, and it must increase on every upload. A changed version name with the same build number is still a refused update.

### Signing

The upload key is at `C:\Users\FoxOS_User\keys\upload-keystore.jks`, outside the repository. The backup copy is `C:\Users\FoxOS_User\OneDrive\upload-keystore-backup.jks`; the password is not written down here or in any tracked file.

`keytool -printcert -jarfile` on the arm64 release:

```text
Owner: CN=Daulet Serikbayev, OU=Mobile, O=KBTU, L=Almaty, ST=Almaty, C=KZ
Issuer: CN=Daulet Serikbayev, OU=Mobile, O=KBTU, L=Almaty, ST=Almaty, C=KZ
Valid from: Fri Nov 20 18:40:17 GMT+05:00 2026 until: Tue Apr 07 18:40:17 GMT+05:00 2054
```

A classmate with this keystore and `applicationId` could sign an update with the same identity and distribute it to any device that already trusts the app. Play App Signing moves the app-signing key to Google; the local key becomes an upload key, and a compromised upload key can be reset without changing the installed app's signing identity.

Two history-scrubbing commands:

```bash
git filter-repo --path android/key.properties --invert-paths
git filter-branch --index-filter "git rm --cached --ignore-unmatch android/key.properties" --prune-empty -- --all
```

### Environments

`Env.host`, `Env.useFakes` and `Env.name` are compile-time values. The debug API-host tile in Settings cannot use `fromEnvironment` because that value is frozen at compile time; it writes `apiHost` to `shared_preferences` and updates the live `ApiClient`. The tile is hidden behind `if (kDebugMode)` so a release build never shows a way to redirect production traffic.

### Build sizes

- Debug APK: `163,315,061` bytes (about 156 MB).
- arm64 release APK: `18,109,486` bytes (about 17.3 MB).
- Universal release APK: `50,478,406` bytes (about 48.1 MB), used for the About screenshot.

Without the `build/symbols/` folder, an obfuscated crash shows names such as `a`, `b` and `c` instead of Dart classes. The symbolication command is:

```bash
flutter symbolize -i crash.txt -d releases/1.0.1+2/symbols/app.android-arm64.symbols
```

### Release checks

- Archive: `releases/1.0.1+2/app-arm64-v8a-release.apk` plus `symbols/`.
- App bundle: `build/app/outputs/bundle/release/app-release.aab`.
- Release icon says `Users`; the launcher shows the custom U icon.
- About screen: `1.0.1 (2)`, `release`, `prod`, `jsonplaceholder.typicode.com`.
- `screenshot_about_release.png` captured from the installed release on the Android emulator; a physical phone and GitHub Release page are still pending because this environment has no GitHub credentials or physical device.
