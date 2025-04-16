import 'package:flutter/foundation.dart';

/// Service générique pour le chargement paresseux des données
class LazyLoadingService<T> with ChangeNotifier {
  List<T> _items = [];
  bool _isLoading = false;
  bool _hasMoreItems = true;
  int _currentPage = 0;
  final int _pageSize;
  String? _errorMessage;

  /// Fonction qui charge les données
  final Future<List<T>> Function(int page, int pageSize) _loadItemsFunction;

  LazyLoadingService({
    required Future<List<T>> Function(int page, int pageSize) loadItemsFunction,
    int pageSize = 10,
  })  : _loadItemsFunction = loadItemsFunction,
        _pageSize = pageSize;

  List<T> get items => _items;
  bool get isLoading => _isLoading;
  bool get hasMoreItems => _hasMoreItems;
  String? get errorMessage => _errorMessage;

  /// Charger la première page
  Future<void> loadFirstPage() async {
    _items = [];
    _currentPage = 0;
    _hasMoreItems = true;
    _errorMessage = null;
    await loadNextPage();
  }

  /// Charger la page suivante
  Future<void> loadNextPage() async {
    if (_isLoading || !_hasMoreItems) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newItems = await _loadItemsFunction(_currentPage, _pageSize);
      
      if (newItems.isEmpty) {
        _hasMoreItems = false;
      } else {
        _items.addAll(newItems);
        _currentPage++;
      }
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des données: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rafraîchir les données
  Future<void> refresh() async {
    await loadFirstPage();
  }

  /// Ajouter un élément
  void addItem(T item) {
    _items.insert(0, item);
    notifyListeners();
  }

  /// Mettre à jour un élément
  void updateItem(T item, bool Function(T) finder) {
    final index = _items.indexWhere(finder);
    if (index != -1) {
      _items[index] = item;
      notifyListeners();
    }
  }

  /// Supprimer un élément
  void removeItem(bool Function(T) finder) {
    _items.removeWhere(finder);
    notifyListeners();
  }
}
