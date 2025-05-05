import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/error_handler.dart';

/// Service de filtrage pour les données de l'application
class FilterService {
  static final FilterService instance = FilterService._internal();

  FilterService._internal();

  /// Formateur de date pour l'affichage
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  /// Formateur de date pour les requêtes API
  final DateFormat _apiDateFormatter = DateFormat('yyyy-MM-dd');

  /// Affiche un sélecteur de date et retourne la date sélectionnée
  Future<DateTime?> selectDate({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? helpText,
  }) async {
    try {
      final now = DateTime.now();
      return await showDatePicker(
        context: context,
        initialDate: initialDate ?? now,
        firstDate: firstDate ?? DateTime(2020),
        lastDate: lastDate ?? DateTime(now.year + 1, now.month, now.day),
        helpText: helpText,
        locale: const Locale('fr', 'FR'),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).primaryColor,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );
    } catch (error) {
      ErrorHandler.instance.logError(
        error,
        context: 'FilterService.selectDate',
      );
      return null;
    }
  }

  /// Affiche un sélecteur de plage de dates et retourne la plage sélectionnée
  Future<DateTimeRange?> selectDateRange({
    required BuildContext context,
    DateTimeRange? initialDateRange,
    DateTime? firstDate,
    DateTime? lastDate,
    String? helpText,
  }) async {
    try {
      final now = DateTime.now();
      final initialRange =
          initialDateRange ??
          DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now);

      return await showDateRangePicker(
        context: context,
        initialDateRange: initialRange,
        firstDate: firstDate ?? DateTime(2020),
        lastDate: lastDate ?? DateTime(now.year + 1, now.month, now.day),
        helpText: helpText,
        locale: const Locale('fr', 'FR'),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).primaryColor,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );
    } catch (error) {
      ErrorHandler.instance.logError(
        error,
        context: 'FilterService.selectDateRange',
      );
      return null;
    }
  }

  /// Formate une date pour l'affichage
  String formatDate(DateTime date) {
    try {
      return _dateFormatter.format(date);
    } catch (error) {
      ErrorHandler.instance.logError(
        error,
        context: 'FilterService.formatDate',
      );
      return 'Date invalide';
    }
  }

  /// Formate une date pour les requêtes API
  String formatDateForApi(DateTime date) {
    try {
      return _apiDateFormatter.format(date);
    } catch (error) {
      ErrorHandler.instance.logError(
        error,
        context: 'FilterService.formatDateForApi',
      );
      return '';
    }
  }

  /// Parse une chaîne de date au format API
  DateTime? parseDateFromApi(String dateString) {
    try {
      return _apiDateFormatter.parse(dateString);
    } catch (error) {
      ErrorHandler.instance.logError(
        error,
        context: 'FilterService.parseDateFromApi',
      );
      return null;
    }
  }

  /// Génère les paramètres de requête pour le filtrage par date
  Map<String, String> generateDateFilterParams({
    DateTime? startDate,
    DateTime? endDate,
    String startDateParam = 'startDate',
    String endDateParam = 'endDate',
  }) {
    final params = <String, String>{};

    if (startDate != null) {
      params[startDateParam] = formatDateForApi(startDate);
    }

    if (endDate != null) {
      params[endDateParam] = formatDateForApi(endDate);
    }

    return params;
  }

  /// Filtre une liste d'objets par date
  List<T> filterByDate<T>({
    required List<T> items,
    required DateTime? startDate,
    required DateTime? endDate,
    required DateTime Function(T item) getItemDate,
  }) {
    if (startDate == null && endDate == null) {
      return items;
    }

    return items.where((item) {
      final itemDate = getItemDate(item);

      if (startDate != null && endDate != null) {
        return itemDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
            itemDate.isBefore(endDate.add(const Duration(days: 1)));
      } else if (startDate != null) {
        return itemDate.isAfter(startDate.subtract(const Duration(days: 1)));
      } else if (endDate != null) {
        return itemDate.isBefore(endDate.add(const Duration(days: 1)));
      }

      return true;
    }).toList();
  }
}
