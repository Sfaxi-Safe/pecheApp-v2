import 'package:flutter/material.dart';
import 'package:fish_marketplace/screens/login_screen.dart';
import 'package:fish_marketplace/utils/app_theme.dart';
import 'package:fish_marketplace/services/database_helper.dart';
import 'package:fish_marketplace/services/auth_service.dart';
import 'package:fish_marketplace/screens/pecheur/dashboard_screen.dart';
import 'package:fish_marketplace/screens/vitirinaire/dashboard_screen.dart';
import 'package:fish_marketplace/screens/maryeur/dashboard_screen.dart';
import 'package:fish_marketplace/screens/client/dashboard_screen.dart';

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
