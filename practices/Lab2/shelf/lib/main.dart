import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/api/api_client.dart';
import 'core/env.dart';
import 'core/storage/secure_store.dart';
import 'features/auth/auth_model.dart';
import 'features/auth/login_screen.dart';
import 'features/catalogue/book_cache.dart';
import 'features/catalogue/book_repository.dart';
import 'features/catalogue/catalogue_model.dart';
import 'features/catalogue/catalogue_screen.dart';
import 'features/catalogue/fake_book_repository.dart';
import 'features/settings/settings_model.dart';
import 'features/shelf/fake_shelf_repository.dart';
import 'features/shelf/shelf_model.dart';
import 'features/shelf/shelf_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = SharedPreferencesAsync();
  final dark = await prefs.getBool('darkMode') ?? false;
  final status = await prefs.getString('statusFilter') ?? 'all';

  final store = SecureStore();
  final token = await store.readToken();

  final catalogueApi = ApiClient(store: store, host: Env.catalogueHost);
  final collectionApi = ApiClient(store: store, host: Env.collectionHost);

  final BookRepository bookRepo = Env.useFakes
      ? FakeBookRepository()
      : HttpBookRepository(catalogueApi, BookCache());
  final ShelfRepository shelfRepo = Env.useFakes
      ? FakeShelfRepository()
      : HttpShelfRepository(collectionApi);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              SettingsModel(prefs, dark: dark, defaultStatus: status),
        ),
        ChangeNotifierProvider(create: (_) => AuthModel(store, token: token)),
        ChangeNotifierProvider(
          create: (_) => CatalogueModel(bookRepo)..search('flutter'),
        ),
        ChangeNotifierProvider(create: (_) => ShelfModel(shelfRepo)..load()),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    final auth = context.watch<AuthModel>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: settings.dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      home: auth.signedIn ? const CatalogueScreen() : const LoginScreen(),
    );
  }
}
