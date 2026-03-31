import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const JamiAthkarApp());
}

class JamiAthkarApp extends StatelessWidget {
  const JamiAthkarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseService>(
          create: (_) => DatabaseService(),
        ),
        // Additional providers (e.g. ChangeNotifierProvider) will be added here
        // as screens and state management are built in subsequent tasks.
      ],
      child: MaterialApp(
        title: 'جامع صحيح الأذكار',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1B5E20),
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.cairoTextTheme(),
          useMaterial3: true,
        ),
        home: const Scaffold(
          body: Center(
            child: Text(
              'جامع صحيح الأذكار',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}
