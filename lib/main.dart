import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/student/home_screen.dart';
import '../screens/student/qr_scanner_screen.dart';
import '../screens/student/register_screen.dart';
import '../screens/student/loading_screen.dart';
import '../screens/student/trivia_screen.dart';
import '../screens/student/mapa_screen.dart';
import '../screens/student/premios_screen.dart';
import '../screens/admin/login_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/crear_pregunta_screen.dart';
import '../screens/admin/ver_preguntas_screen.dart';
import '../screens/admin/crear_qr_simple_screen.dart';
import '../screens/admin/admin_ver_qr_screen.dart';
import '../screens/admin/dashboards.dart';
import '../screens/admin/ver_feedback_usuarios.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase de forma segura
  await _initializeFirebase();

  // Verifica si el usuario ya está registrado
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');

  runApp(MainApp(initialRoute: userId == null ? '/register' : '/home'));
}

Future<void> _initializeFirebase() async {
  try {
    // Verifica si Firebase ya está inicializado
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

    }
  } catch (e) {
    // Maneja errores de inicialización
    debugPrint('Error al inicializar Firebase: $e');
    rethrow; // Lanza el error nuevamente si es necesario
  }
}

class MainApp extends StatelessWidget {
  final String initialRoute;
  const MainApp({super.key, this.initialRoute = '/register'});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UCB Explorer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF005CA7),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/loading': (context) => const LoadingScreen(),
        '/': (context) => const RegisterScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/qr': (context) => const QRScannerScreen(),
        '/trivia': (context) => const TriviaScreen(),
        '/mapa': (context) => const MapaScreen(),
        '/premios': (context) => const PremiosScreen(),
        '/login': (context) => const LoginScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/admin-crear-pregunta': (context) => const CrearPreguntaScreen(),
        '/admin-ver-preguntas': (context) => const VerPreguntasScreen(),
        '/admin-crear-qr': (context) => const CrearQRSimpleScreen(),
        '/admin-ver-qr': (context) => const AdminVerQRScreen(),
        '/admin-dash': (context) => const DashboardsScreen(),
        '/admin-ver-feedback': (context) => const VerFeedbackUsuarios(),
      },
    );
  }
}