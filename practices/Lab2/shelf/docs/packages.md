# Package verdicts

- **http 1.6.0** - Verified publisher flutter.dev, released in 2026, all six platforms, 160 pub points, BSD-3-Clause, depends on the platform HTTP implementations; used in `core/api/api_client.dart`.
- **provider 6.1.5+1** - Publisher dash-overflow.dev, released in 2026, all six platforms, 160 pub points, MIT, no runtime dependencies beyond Flutter; used by `CatalogueModel` and `ShelfModel`.
- **shared_preferences 2.5.6** - Verified publisher flutter.dev, released in October 2026, all six platforms, 160 pub points, BSD-3-Clause, depends on the platform preference packages; used for dark mode and the default shelf filter.
- **flutter_secure_storage 11.2.0** - Third-party publisher steenbakker.dev, released in September 2026, all six platforms, 160 pub points, BSD-3-Clause, depends on the platform secure-storage packages; used by `SecureStore`.
- **path_provider 2.1.6** - Verified publisher flutter.dev, released in June 2026, Android/iOS/Linux/macOS/Windows, 160 pub points, BSD-3-Clause, depends on platform path packages; used for `books.json` in Documents.
- **image_picker 1.2.4** - Verified publisher flutter.dev, released in October 2026, all six platforms, 160 pub points, Apache-2.0/BSD-3-Clause, depends on platform picker packages; used by `ProfileScreen`.
- **permission_handler 13.0.2** - Third-party publisher baseflow.com, released in September 2026, Android/iOS/web/Windows, 160 pub points, MIT, depends on platform permission packages; used for the camera flow.
- **url_launcher 6.3.3** - Verified publisher flutter.dev, released in October 2026, all six platforms, 160 pub points, BSD-3-Clause, depends on platform URL launcher packages; used by `BookDetailScreen`.
- **package_info_plus 10.2.2** - Publisher fluttercommunity.dev, released in 2026, all six platforms, 160 pub points, BSD-3-Clause, depends on the platform package-info interfaces; used by `AboutScreen`.
- **flutter_launcher_icons 0.14.4** - Publisher fluttercommunity.dev, released in 2026, development-only, 160 pub points, MIT, depends on image tooling; generates the adaptive icon.
- **flutter_native_splash 2.4.8** - Publisher jonatha.o, released in 2026, development-only, 160 pub points, MIT, depends on image and YAML tooling; generates the Android 12 splash.
- **cupertino_icons 1.0.8** - Verified publisher flutter.dev, released in 2025, all six platforms, BSD-3-Clause, assets only; used for the Cupertino icon font.
- **flutter_lints 6.0.0** - Verified publisher flutter.dev, released in 2026, development-only, BSD-3-Clause, depends on Dart lints; supplies the analyzer rules.
- **shared_preferences_platform_interface 2.4.2** - Verified publisher flutter.dev, development/test helper, BSD-3-Clause, provides the shared-preferences platform seam used by tests.

`pubspec.lock` is committed so the exact transitive versions are reproducible on the defence machine.
