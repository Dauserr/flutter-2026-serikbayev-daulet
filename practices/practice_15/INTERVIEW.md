# Interview Day

Three-sentence answers. Each answer names a file that exists in this repository. A `*` means the answer still needs another rehearsal.

## Junior question bank

### 1. What is Flutter?

Flutter is a UI toolkit that renders its own widget tree on Android, iOS, web and desktop. I build screens such as `UsersScreen` as widgets under `lib/features/users/users_screen.dart`. The useful detail is that layout constraints flow down and sizes flow up, which is why `Expanded` is needed around scrollable content in a `Column`.

### 2. StatelessWidget vs StatefulWidget?

A `StatelessWidget` describes a configuration and rebuilds when its inputs change; a `StatefulWidget` owns a long-lived `State` object. `UserTile` in `lib/features/users/widgets/user_tile.dart` is stateless, while `LoginScreen` is stateful because it owns controllers and a busy flag. `LoginScreen` disposes its controllers in `dispose()`, which is the point of having that State object.

### 3. What is BuildContext?

`BuildContext` is a handle to a widget's position in the element tree. I use it in `UsersScreen.build` to call `context.watch<UsersModel>()`, and in the Settings screen to read the `ApiClient`. If I need a `Navigator` or provider, I must use a context below the widget that supplies it, not the context above it.

### 4. What does setState do?

`setState` marks a `State` object dirty so the framework rebuilds it on the next frame. `LoginScreen` uses it only for `_busy`, because the form's validation result and `AuthModel` are separate concerns. It is not a state-management system: state that two routes need belongs in a `ChangeNotifier` instead.

### 5. initState and dispose?

`initState` runs once after the State is inserted; `dispose` runs once when the element is removed. `ProfileScreen.initState` starts loading the saved avatar, and `LoginScreen.dispose` disposes all text controllers. Anything I subscribe to or create in `initState` must be unsubscribed or disposed in `dispose`.

### 6. provider watch, read and select?

`watch` subscribes the current build to a `ChangeNotifier`, `read` gets the object without subscribing, and `select` subscribes only to one derived value. `CartBadge` uses `context.select<Cart, int>((cart) => cart.count)` in `practice_9/.../cart_badge.dart`, while `BookRow` uses `watch` for its `Added` state. Calls from callbacks use `read`, never `watch`.

### 7. What is ChangeNotifier?

`ChangeNotifier` is a small Flutter foundation class that stores listeners and exposes `notifyListeners()`. `UsersModel` in `lib/features/users/users_model.dart` owns `items`, `loading`, `error` and `fromCache`, and calls `notifyListeners()` after every load. It has no `BuildContext`, no `mounted` and no widgets, so it can be unit tested.

### 8. Future vs Stream? *

A `Future` completes once; a `Stream` can emit many values over time. `UsersModel.load` awaits one `Future` from `UserRepository`, while the countdown in `practice_10/students_async/lib/api/countdown.dart` is an `async*` stream that yields once per second. The lifecycle difference matters: a FutureBuilder resubscribes only to a new Future, but a Stream subscription must be cancelled in `dispose`.

### 9. async, await and errors?

`async` marks a function that returns a Future; `await` suspends that function without blocking the UI isolate. `HttpUserRepository.getAll` awaits `ApiClient.get` and maps a `NoConnectionException` to cached data in `lib/features/users/user_repository.dart`. Errors are caught with `on ApiException` in `UsersModel`; an empty catch would hide the state change I need to test.

### 10. FutureBuilder states?

`FutureBuilder` gives me `connectionState`, `hasError` and `data` for one Future. In `practice_10/students_async/lib/students_future_screen.dart` I check `hasError` first, then `connectionState != done` for loading, then `data ?? []` and empty. The Future is stored in a field because creating it in `build` starts a new request on every rebuild.

### 11. JSON int vs double?

`jsonDecode` returns `int` for a whole JSON number and `double` for a decimal; a JSON string stays a `String`. `Geo.fromJson` in `lib/features/users/user.dart` uses `double.parse(json['lat'] as String)` because JSONPlaceholder sends `lat` as a string. If the server sends `-37.3159` as a number, the cast fails with `TypeError`; `HttpUserRepository` catches that and turns it into `BadResponseException`.

### 12. Why an ApiClient and a repository?

`ApiClient` is the only class that knows `package:http`, headers, timeouts and status codes. `HttpUserRepository` in `lib/features/users/user_repository.dart` turns `Response` objects into `User` models and caches the good list. The screen only sees users or a sealed `ApiException`, so `UsersScreen` never imports `package:http`.

### 13. Dependency injection and fakes? *

`UsersModel` takes a `UserRepository` through its constructor instead of constructing `HttpUserRepository` itself. That is the seam that lets `test/fakes/fake_user_repository.dart` return two users or throw `NoConnectionException` without a network. `main.dart` is the only composition root and the only place that constructs the real HTTP repository.

### 14. Why a sealed class?

A `sealed` class restricts its subclasses to the same library, so the compiler knows every possible case. `ApiException` in `lib/core/api/api_exception.dart` has five cases, and `UsersErrorView` switches over them without a `default`. Adding a new error would make that switch fail to compile until the UI handles it.

### 15. SharedPreferences or secure storage?

`shared_preferences` is for small, non-sensitive settings such as `darkMode` and `cityFilter` in `lib/features/settings/settings_model.dart`. A token is different: `SecureStore` in `lib/core/storage/secure_store.dart` uses `flutter_secure_storage`, which reaches Keychain or Keystore. A token in SharedPreferences would be a plain XML/plist value readable through a backup or root access.

### 16. How does the offline cache work?

`UsersCache` in `lib/features/users/users_cache.dart` writes `users.json` to `getApplicationDocumentsDirectory()`. `HttpUserRepository.getAll` saves every successful list and, on `NoConnectionException`, returns the saved list with `fromCache: true`. `UsersModel` passes that flag to `OfflineBanner`, which is why the screen can say “Saved data · no connection” instead of pretending the data is fresh.

### 17. How do you navigate? *

The app uses named routes for the books/cart shell and `MaterialPageRoute` for the users detail and settings screens. In `UsersScreen`, tapping a `UserTile` pushes `UserDetailScreen` with the selected `User`, and `SettingsScreen` pushes `ProfileScreen` and `AboutScreen`. Navigation lives in widgets, never in a model or repository.

### 18. Forms and validation?

A `Form` with a `GlobalKey<FormState>` groups fields and calls each validator. `LoginScreen` and `NewUserScreen` create controllers once in `State`, dispose them, and use `TextFormField` validators for email and password/name rules. In `warmups/warmup_3_form/lib/validators.dart` the same rules are plain functions, so a unit test can check them without pumping a widget.

### 19. Camera permission and image picker?

`ProfileScreen` in `lib/features/profile/profile_screen.dart` requests `Permission.camera` at the moment of the tap, not in `initState`. It handles `granted`, `denied`, `permanentlyDenied`, `restricted`, `limited` and `provisional`; the blocked case opens my own dialog and then `openAppSettings()`. `ImagePicker.pickImage` returns `null` on Cancel, so the next line checks `null` and `mounted` before saving `avatar.jpg`.

### 20. How is the Android release built?

The Gradle file reads `android/key.properties`, creates a release signing config with the upload key, and enables minification; `versionCode` and `versionName` come from `flutter.versionCode` and `flutter.versionName`. The arm64 APK is built with `--split-per-abi --obfuscate --split-debug-info=build/symbols`, so a crash is symbolized with `flutter symbolize`. The release is attached to GitHub Release `v1.0.1` and was installed on a real phone.

## Stories

### A bug in five beats

**Symptom:** the countdown kept printing `tick 6`, `tick 5` after I left the screen.

**Wrong first guess:** I thought `StreamBuilder` was rebuilding a dead widget.

**What found it:** the console and the `dispose` method showed that version B had a live `StreamSubscription` with no `cancel()`.

**Fix:** I called `_sub.cancel()` before `super.dispose()` in `_ListenCountdownState`.

**Habit:** every subscription, controller and timer now gets a matching cleanup line before I call a feature done.

### A design decision

For the shop cart I chose a `ChangeNotifier` above `MaterialApp` and provider verbs instead of passing a list and callbacks down from a StatefulWidget. The alternative was lifting the cart through every constructor, which would have touched each screen and rebuilt the whole route on every add. With provider, `CartBadge` selects only `count`, rows watch for membership, and callbacks read the model; the cost is one extra concept and a provider above the app.

### One thing I would do differently

I would write `FakeUserRepository` first and build the screens against it, then connect the real API. In this project I built the HTTP path early, and screen details were shaped around JSONPlaceholder's quirks before the fake made the model testable. The next project starts with the fake and the failing test, then the real client.
