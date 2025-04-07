import 'dart:convert';
import 'dart:io';

class SqlParser {
  // Analyser le fichier de dump SQL et extraire les données pour une table spécifique
  static Future<List<Map<String, dynamic>>> parseTableData(
    String filePath,
    String tableName,
  ) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Fichier SQL non trouvé');
    }

    final content = await file.readAsString();
    final List<Map<String, dynamic>> result = [];

    // Trouver les instructions INSERT pour la table spécifiée
    final RegExp insertRegex = RegExp(
      r'INSERT INTO `' + tableName + r'` $$(.*?)$$ VALUES\s*(.*?);',
      dotAll: true,
    );

    final matches = insertRegex.allMatches(content);
    if (matches.isEmpty) {
      return result; // Aucune donnée trouvée pour cette table
    }

    // Extraire les noms de colonnes
    final columnsMatch = RegExp(
      r'INSERT INTO `' + tableName + r'` $$(.*?)$$',
    ).firstMatch(content);

    if (columnsMatch == null || columnsMatch.groupCount < 1) {
      return result;
    }

    final columns =
        columnsMatch
            .group(1)!
            .split(',')
            .map((col) => col.trim().replaceAll('`', ''))
            .toList();

    // Extraire les valeurs
    for (final match in matches) {
      if (match.groupCount < 2) continue;

      final valuesString = match.group(2)!;
      final valueMatches = RegExp(r'$$(.*?)$$').allMatches(valuesString);

      for (final valueMatch in valueMatches) {
        if (valueMatch.groupCount < 1) continue;

        final values = _splitValues(valueMatch.group(1)!);

        if (values.length != columns.length) {
          print('Nombre de colonnes incorrect pour la ligne dans $tableName');
          continue;
        }

        final Map<String, dynamic> row = {};
        for (int i = 0; i < columns.length; i++) {
          row[columns[i]] = _parseValue(values[i]);
        }

        result.add(row);
      }
    }

    return result;
  }

  // Aide à diviser correctement les valeurs en gérant les chaînes entre guillemets
  static List<String> _splitValues(String valuesStr) {
    final List<String> result = [];
    bool inQuote = false;
    String currentValue = '';

    for (int i = 0; i < valuesStr.length; i++) {
      final char = valuesStr[i];

      if (char == '\'' && (i == 0 || valuesStr[i - 1] != '\\')) {
        inQuote = !inQuote;
        currentValue += char;
      } else if (char == ',' && !inQuote) {
        result.add(currentValue.trim());
        currentValue = '';
      } else {
        currentValue += char;
      }
    }

    if (currentValue.isNotEmpty) {
      result.add(currentValue.trim());
    }

    return result;
  }

  // Analyser la valeur SQL vers le type Dart approprié
  static dynamic _parseValue(String value) {
    if (value == 'NULL') {
      return null;
    }

    // Supprimer les guillemets des valeurs de chaîne
    if (value.startsWith('\'') && value.endsWith('\'')) {
      return value.substring(1, value.length - 1);
    }

    // Essayer d'analyser comme un nombre
    if (RegExp(r'^-?\d+$').hasMatch(value)) {
      return int.tryParse(value);
    }

    if (RegExp(r'^-?\d+\.\d+$').hasMatch(value)) {
      return double.tryParse(value);
    }

    return value;
  }
}
