import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/theme_model.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeModel()),
      ],
      child: Builder(
        builder: (context) {
          final themeModel = Provider.of<ThemeModel>(context);
          final brightness = themeModel.currentBrightness;

          return MaterialApp(
            title: 'Classificador',
            themeMode: brightness == Brightness.light
                ? ThemeMode.light
                : ThemeMode.dark,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                brightness: Brightness.light,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                brightness: Brightness.dark,
              ),
            ),
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}