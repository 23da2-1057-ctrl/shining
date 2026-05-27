import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shining/firebase_options.dart';
import 'package:shining/theme/app_theme.dart';
import 'package:shining/navigation/app_router.dart';
import 'package:shining/utils/constants.dart';
import 'package:shining/data/migration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Uploads products to Firestore only on first run — safe to leave forever.
  await migrateProductsToFirestore();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
