// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/item_service.dart';
import 'views/login_page.dart';
import 'views/home_page.dart';
import 'views/upload_item_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ItemService(),
      child: MaterialApp(
        title: 'Lost & Found',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFFB71C1C), // red
          appBarTheme: const AppBarTheme(color: Color(0xFFb71c1c)),
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const LoginPage(),
          '/home': (_) => const HomePage(),
          '/upload': (_) => const UploadItemPage(),
        },
      ),
    );
  }
}
