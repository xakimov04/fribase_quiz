import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fribase/controllers/quiz_controller.dart';
import 'package:fribase/controllers/select_controller.dart';
import 'package:fribase/firebase_options.dart';
import 'package:fribase/views/screens/home_screen.dart';
import 'package:fribase/views/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SelectedOptionsNotifier()),
        ChangeNotifierProvider(create: (_) => QuizController()),
      ],
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                if (snapshot.hasData) {
                  return const HomeScreen();
                } else {
                  return const LoginPage();
                }
              }
            },
          ),
        );
      },
    );
  }
}
