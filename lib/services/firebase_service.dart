class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Firebase est déjà initialisé dans main.dart, donc nous n'avons pas besoin de le faire ici
    _initialized = true;
  }
}
