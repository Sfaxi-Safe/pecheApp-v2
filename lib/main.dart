import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'utils/app_theme.dart';
import 'services/database_helper.dart';
import 'services/auth_service.dart';
import 'screens/pecheur/dashboard_screen.dart';
import 'screens/vitirinaire/dashboard_screen.dart';
import 'screens/maryeur/dashboard_screen.dart';
import 'screens/client/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the database
  await DatabaseHelper.instance.database;
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  Widget _initialScreen = const LoginScreen();

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    final user = await AuthService().getCurrentUser();
    
    if (user != null) {
      if (user.isPecheur()) {
        _initialScreen = const PecheurDashboardScreen();
      } else if (user.isVeterinaire()) {
        _initialScreen = const VitirinaireScreen();
      } else if (user.isMaryeur()) {
        _initialScreen = const MaryeurDashboardScreen();
      } else if (user.isClient()) {
        _initialScreen = const ClientDashboardScreen();
      }
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fish Marketplace',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: _isLoading
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _initialScreen,
    );
  }
}
