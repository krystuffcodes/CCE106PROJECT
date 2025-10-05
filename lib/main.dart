import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/lost_found_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/item_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


// Import all your pages
import 'views/login_page.dart';
import 'views/register_page.dart';
import 'views/home_page.dart';
import 'views/upload_item_page.dart';
import 'views/profile_page.dart'; // ✅ make sure this file exists

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
          primaryColor: const Color(0xFFB71C1C),
          appBarTheme: const AppBarTheme(color: Color(0xFFb71c1c)),
        ),
        // 🔹 Set initial route to LoginPage
        initialRoute: '/login',
        routes: {
          '/login': (_) => const LoginPage(),
          '/register': (_) => const RegisterPage(),
          '/home': (_) => const HomePage(),
          '/upload': (_) => const UploadItemPage(),
          '/profile': (_) => const ProfilePage(),
          '/lostfound': (context) => const LostFoundPage(),

        },
      ),
    );
  }
}
