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
