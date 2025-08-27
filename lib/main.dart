// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:joinfy/source/modules/events/events_page.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // gerado pelo FlutterFire

// Tema
import 'package:joinfy/theme/app_theme.dart';

// Páginas
import 'package:joinfy/source/modules/pages/auth/register/register_page.dart';
import 'package:joinfy/source/modules/pages/auth/login/login_page.dart';
import 'package:joinfy/source/modules/pages/home/home_page.dart';

Future<void> main() async {
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
    return MaterialApp(
      title: 'Joinfy',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      builder: (context, child) => Theme(
        data: AppTheme.light(context),
        child: child!,
      ),

      home: const AuthGate(showRegisterByDefault: false),

      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/home_page': (_) => const HomePage(),
        '/events_page': (_) => const EventsPage(),
      },

      // Fallback seguro
      onUnknownRoute: (_) =>
          MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }
}

/// "Portão" de autenticação.
/// Se `showRegisterByDefault` = true, cai na Register quando não logado.
/// Se quiser abrir a Login por padrão, passe `showRegisterByDefault: false`.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, this.showRegisterByDefault = true});
  final bool showRegisterByDefault;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        // Enquanto carrega o estado de auth
        if (snap.connectionState == ConnectionState.waiting) {
          return const _Splash();
        }

        // Logado -> Home
        if (snap.hasData && snap.data != null) {
          return const HomePage();
        }

        // Não logado -> Register (ou Login, se preferir)
        return showRegisterByDefault ? const RegisterPage() : const LoginPage();
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Carregando...', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
