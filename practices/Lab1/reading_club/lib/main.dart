import 'package:flutter/material.dart';

import 'models/book.dart';
import 'routes.dart';
import 'screens/book_form_screen.dart';
import 'screens/detail_screen.dart';
import 'shell.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _themeMode = ValueNotifier(ThemeMode.system);

  @override
  void dispose() {
    _themeMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seed = const ColorScheme.light().primary;
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, mode, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Reading Club',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: seed)),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: seed,
            brightness: Brightness.dark,
          ),
        ),
        themeMode: mode,
        initialRoute: Routes.home,
        routes: {
          Routes.home: (_) => ValueListenableBuilder<ThemeMode>(
            valueListenable: _themeMode,
            builder: (context, mode, child) => Shell(
              themeMode: mode,
              onThemeChanged: (value) => _themeMode.value = value,
            ),
          ),
        },
        onGenerateRoute: (settings) {
          if (settings.name == Routes.detail &&
              settings.arguments is DetailArguments) {
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => DetailScreen(
                arguments: settings.arguments as DetailArguments,
              ),
            );
          }
          if (settings.name == Routes.form &&
              settings.arguments is FormArguments) {
            final arguments = settings.arguments as FormArguments;
            return MaterialPageRoute<Book>(
              settings: settings,
              builder: (_) => BookFormScreen(book: arguments.book),
            );
          }
          return null;
        },
        onUnknownRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Not found')),
            body: const Center(child: Text('Not found')),
          ),
        ),
      ),
    );
  }
}
