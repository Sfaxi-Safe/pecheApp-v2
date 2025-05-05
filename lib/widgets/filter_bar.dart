import 'package:flutter/material.dart';
import '../services/filter_service.dart';

/// Widget de barre de filtre pour les écrans de liste
class FilterBar extends StatefulWidget {
  /// Callback appelé lorsque les filtres sont appliqués
  final Function(Map<String, dynamic> filters) onApplyFilters;

  /// Filtres initiaux
  final Map<String, dynamic> initialFilters;

  /// Options de filtre disponibles
  final List<FilterOption> filterOptions;

  /// Indique si la barre de filtre doit être compacte
  final bool isCompact;

  /// Indique si la barre de filtre doit afficher un bouton de réinitialisation
  final bool showResetButton;

  const FilterBar({
    Key? key,
    required this.onApplyFilters,
    this.initialFilters = const {},
    this.filterOptions = const [],
    this.isCompact = false,
    this.showResetButton = true,
  }) : super(key: key);

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  late Map<String, dynamic> _filters;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.initialFilters);
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _resetFilters() {
    setState(() {
      _filters = {};
    });
    widget.onApplyFilters({});
  }

  void _applyFilters() {
    widget.onApplyFilters(_filters);
    if (_isExpanded) {
      _toggleExpanded();
    }
  }

  void _updateFilter(String key, dynamic value) {
    setState(() {
      if (value == null || (value is String && value.isEmpty)) {
        _filters.remove(key);
      } else {
        _filters[key] = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barre principale
            Row(
              children: [
                Icon(Icons.filter_list, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8.0),
                Text('Filtres', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                if (_filters.isNotEmpty && widget.showResetButton)
                  TextButton.icon(
                    onPressed: _resetFilters,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Réinitialiser'),
                  ),
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: _toggleExpanded,
                ),
              ],
            ),

            // Filtres appliqués (en mode compact)
            if (widget.isCompact && _filters.isNotEmpty && !_isExpanded)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children:
                      _filters.entries.map((entry) {
                        final option = widget.filterOptions.firstWhere(
                          (o) => o.key == entry.key,
                          orElse:
                              () => FilterOption(
                                key: entry.key,
                                label: entry.key,
                                type: FilterType.text,
                              ),
                        );

                        return Chip(
                          label: Text(
                            '${option.label}: ${_formatFilterValue(entry.value, option.type)}',
                          ),
                          onDeleted: () {
                            _updateFilter(entry.key, null);
                            _applyFilters();
                          },
                        );
                      }).toList(),
                ),
              ),

            // Contenu des filtres (en mode étendu)
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(),
                    ...widget.filterOptions.map((option) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: _buildFilterOption(option),
                      );
                    }),
                    const SizedBox(height: 8.0),
                    ElevatedButton(
                      onPressed: _applyFilters,
                      child: const Text('Appliquer les filtres'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(FilterOption option) {
    switch (option.type) {
      case FilterType.text:
        return _buildTextFilter(option);
      case FilterType.dropdown:
        return _buildDropdownFilter(option);
      case FilterType.date:
        return _buildDateFilter(option);
      case FilterType.dateRange:
        return _buildDateRangeFilter(option);
      case FilterType.checkbox:
        return _buildCheckboxFilter(option);
      case FilterType.radio:
        return _buildRadioFilter(option);
    }
  }

  Widget _buildTextFilter(FilterOption option) {
    return TextField(
      decoration: InputDecoration(
        labelText: option.label,
        hintText: option.hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 8.0,
        ),
      ),
      controller: TextEditingController(
        text: _filters[option.key]?.toString() ?? '',
      ),
      onChanged: (value) => _updateFilter(option.key, value),
    );
  }

  Widget _buildDropdownFilter(FilterOption option) {
    final items = option.items ?? [];
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: option.label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 8.0,
        ),
      ),
      value: _filters[option.key]?.toString(),
      items: [
        if (option.allowEmpty)
          const DropdownMenuItem<String>(value: '', child: Text('Tous')),
        ...items.map((item) {
          return DropdownMenuItem<String>(
            value: item.value,
            child: Text(item.label),
          );
        }),
      ],
      onChanged: (value) => _updateFilter(option.key, value),
    );
  }

  Widget _buildDateFilter(FilterOption option) {
    final value = _filters[option.key];
    final displayValue =
        value != null
            ? FilterService.instance.formatDate(value)
            : 'Sélectionner une date';

    return InkWell(
      onTap: () async {
        final date = await FilterService.instance.selectDate(
          context: context,
          initialDate: value,
          helpText: option.hint ?? 'Sélectionner une date',
        );

        if (date != null) {
          _updateFilter(option.key, date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: option.label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 8.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(displayValue), const Icon(Icons.calendar_today)],
        ),
      ),
    );
  }

  Widget _buildDateRangeFilter(FilterOption option) {
    final startKey = '${option.key}Start';
    final endKey = '${option.key}End';
    final startDate = _filters[startKey];
    final endDate = _filters[endKey];

    String displayValue;
    if (startDate != null && endDate != null) {
      displayValue =
          '${FilterService.instance.formatDate(startDate)} - ${FilterService.instance.formatDate(endDate)}';
    } else if (startDate != null) {
      displayValue = 'Depuis ${FilterService.instance.formatDate(startDate)}';
    } else if (endDate != null) {
      displayValue = 'Jusqu\'au ${FilterService.instance.formatDate(endDate)}';
    } else {
      displayValue = 'Sélectionner une période';
    }

    return InkWell(
      onTap: () async {
        final dateRange = await FilterService.instance.selectDateRange(
          context: context,
          initialDateRange:
              startDate != null && endDate != null
                  ? DateTimeRange(start: startDate, end: endDate)
                  : null,
          helpText: option.hint ?? 'Sélectionner une période',
        );

        if (dateRange != null) {
          _updateFilter(startKey, dateRange.start);
          _updateFilter(endKey, dateRange.end);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: option.label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 8.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(displayValue), const Icon(Icons.date_range)],
        ),
      ),
    );
  }

  Widget _buildCheckboxFilter(FilterOption option) {
    final items = option.items ?? [];
    final values = _filters[option.key] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(option.label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4.0),
        ...items.map((item) {
          return CheckboxListTile(
            title: Text(item.label),
            value: values.contains(item.value),
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (checked) {
              final newValues = List<String>.from(values);
              if (checked == true) {
                if (!newValues.contains(item.value)) {
                  newValues.add(item.value);
                }
              } else {
                newValues.remove(item.value);
              }
              _updateFilter(option.key, newValues);
            },
          );
        }),
      ],
    );
  }

  Widget _buildRadioFilter(FilterOption option) {
    final items = option.items ?? [];
    final value = _filters[option.key];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(option.label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4.0),
        ...items.map((item) {
          return RadioListTile<String>(
            title: Text(item.label),
            value: item.value,
            groupValue: value,
            dense: true,
            contentPadding: EdgeInsets.zero,
            onChanged: (newValue) {
              _updateFilter(option.key, newValue);
            },
          );
        }),
        if (option.allowEmpty)
          RadioListTile<String>(
            title: const Text('Tous'),
            value: '',
            groupValue: value,
            dense: true,
            contentPadding: EdgeInsets.zero,
            onChanged: (newValue) {
              _updateFilter(option.key, null);
            },
          ),
      ],
    );
  }

  String _formatFilterValue(dynamic value, FilterType type) {
    if (value == null) return '';

    switch (type) {
      case FilterType.date:
        return FilterService.instance.formatDate(value);
      case FilterType.dateRange:
        if (value is DateTimeRange) {
          return '${FilterService.instance.formatDate(value.start)} - ${FilterService.instance.formatDate(value.end)}';
        }
        return value.toString();
      case FilterType.checkbox:
        if (value is List) {
          return value.join(', ');
        }
        return value.toString();
      default:
        return value.toString();
    }
  }
}

/// Types de filtres disponibles
enum FilterType { text, dropdown, date, dateRange, checkbox, radio }

/// Option de filtre
class FilterOption {
  /// Clé unique du filtre
  final String key;

  /// Libellé du filtre
  final String label;

  /// Type de filtre
  final FilterType type;

  /// Texte d'aide
  final String? hint;

  /// Liste d'éléments pour les filtres de type dropdown, checkbox et radio
  final List<FilterItem>? items;

  /// Indique si le filtre peut être vide
  final bool allowEmpty;

  FilterOption({
    required this.key,
    required this.label,
    required this.type,
    this.hint,
    this.items,
    this.allowEmpty = true,
  });
}

/// Élément de filtre pour les filtres de type dropdown, checkbox et radio
class FilterItem {
  /// Valeur de l'élément
  final String value;

  /// Libellé de l'élément
  final String label;

  FilterItem({required this.value, required this.label});
}
