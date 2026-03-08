import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import './presentation/screens/score/widgets/auth_gate.dart';
import './services/subscription_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anotar',

      // ✅ navigatorKey necesario para SubscriptionService
      navigatorKey: SubscriptionService.navigatorKey,

      theme: ThemeData(
        primaryColor: const Color(0xFF2563EB),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'Roboto',
      ),
      home: const AppStartup(),
    );
  }
}

// ✅ Inicializa RevenueCat DESPUÉS de que el contexto existe
class AppStartup extends StatefulWidget {
  const AppStartup({Key? key}) : super(key: key);

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await SubscriptionService().init();
    } catch (_) {
      // Si RevenueCat falla, la app sigue funcionando en modo free
    }
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFf97316)),
        ),
      );
    }
    return const AuthGate();
  }
}
