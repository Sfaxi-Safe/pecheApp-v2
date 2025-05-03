import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum DateFilterType {
  all,
  today,
  thisWeek,
  thisMonth,
  custom,
}

class DateFilter {
  final DateFilterType type;
  final DateTime? startDate;
  final DateTime? endDate;

  DateFilter({
    required this.type,
    this.startDate,
    this.endDate,
  });

  factory DateFilter.all() => DateFilter(type: DateFilterType.all);
  factory DateFilter.today() => DateFilter(
        type: DateFilterType.today,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
      );
  factory DateFilter.thisWeek() => DateFilter(
        type: DateFilterType.thisWeek,
        startDate: DateTime.now().subtract(
          Duration(days: DateTime.now().weekday - 1),
        ),
        endDate: DateTime.now().add(
          Duration(days: 7 - DateTime.now().weekday),
        ),
      );
  factory DateFilter.thisMonth() => DateFilter(
        type: DateFilterType.thisMonth,
        startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
        endDate: DateTime(
          DateTime.now().year,
          DateTime.now().month + 1,
          0,
        ),
      );
  factory DateFilter.custom({
    required DateTime startDate,
    required DateTime endDate,
  }) =>
      DateFilter(
        type: DateFilterType.custom,
        startDate: startDate,
        endDate: endDate,
      );

  String get label {
    switch (type) {
      case DateFilterType.all:
        return 'Toutes les dates';
      case DateFilterType.today:
        return 'Aujourd\'hui';
      case DateFilterType.thisWeek:
        return 'Cette semaine';
      case DateFilterType.thisMonth:
        return 'Ce mois';
      case DateFilterType.custom:
        if (startDate != null && endDate != null) {
          final formatter = DateFormat('dd/MM/yyyy');
          return '${formatter.format(startDate!)} - ${formatter.format(endDate!)}';
        }
        return 'Personnalisé';
    }
  }

  bool isDateInRange(DateTime date) {
    if (type == DateFilterType.all) return true;
    if (startDate == null || endDate == null) return false;

    return date.isAfter(startDate!) && date.isBefore(endDate!);
  }
}

class SeaFilterBar extends StatefulWidget {
  final List<String> statusFilters;
  final String? selectedStatusFilter;
  final DateFilter dateFilter;
  final Function(String?) onStatusFilterChanged;
  final Function(DateFilter) onDateFilterChanged;
  final bool showStatusFilter;
  final bool showDateFilter;

  const SeaFilterBar({
    Key? key,
    required this.statusFilters,
    this.selectedStatusFilter,
    required this.dateFilter,
    required this.onStatusFilterChanged,
    required this.onDateFilterChanged,
    this.showStatusFilter = true,
    this.showDateFilter = true,
  }) : super(key: key);

  @override
  State<SeaFilterBar> createState() => _SeaFilterBarState();
}

class _SeaFilterBarState extends State<SeaFilterBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Filtre par statut
            if (widget.showStatusFilter) ...[
              _buildStatusFilterDropdown(theme),
              const SizedBox(width: 12),
            ],

            // Filtre par date
            if (widget.showDateFilter) _buildDateFilterDropdown(theme),

            // Bouton de réinitialisation
            if (widget.selectedStatusFilter != null ||
                widget.dateFilter.type != DateFilterType.all) ...[
              const SizedBox(width: 12),
              _buildResetButton(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilterDropdown(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DropdownButton<String>(
        value: widget.selectedStatusFilter,
        hint: const Text('Statut'),
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down),
        isDense: true,
        items: [
          const DropdownMenuItem<String>(
            value: null,
            child: Text('Tous les statuts'),
          ),
          ...widget.statusFilters.map((status) {
            return DropdownMenuItem<String>(
              value: status,
              child: Text(status),
            );
          }).toList(),
        ],
        onChanged: widget.onStatusFilterChanged,
      ),
    );
  }

  Widget _buildDateFilterDropdown(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DropdownButton<DateFilterType>(
        value: widget.dateFilter.type,
        hint: const Text('Date'),
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down),
        isDense: true,
        items: [
          DropdownMenuItem<DateFilterType>(
            value: DateFilterType.all,
            child: const Text('Toutes les dates'),
          ),
          DropdownMenuItem<DateFilterType>(
            value: DateFilterType.today,
            child: const Text('Aujourd\'hui'),
          ),
          DropdownMenuItem<DateFilterType>(
            value: DateFilterType.thisWeek,
            child: const Text('Cette semaine'),
          ),
          DropdownMenuItem<DateFilterType>(
            value: DateFilterType.thisMonth,
            child: const Text('Ce mois'),
          ),
          DropdownMenuItem<DateFilterType>(
            value: DateFilterType.custom,
            child: const Text('Personnalisé...'),
          ),
        ],
        onChanged: (value) async {
          if (value == null) return;

          if (value == DateFilterType.custom) {
            // Afficher le sélecteur de date
            final DateTimeRange? dateRange = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              initialDateRange: DateTimeRange(
                start: DateTime.now().subtract(const Duration(days: 7)),
                end: DateTime.now(),
              ),
              builder: (context, child) {
                return Theme(
                  data: theme.copyWith(
                    colorScheme: theme.colorScheme.copyWith(
                      primary: theme.colorScheme.primary,
                      onPrimary: theme.colorScheme.onPrimary,
                      surface: theme.colorScheme.surface,
                      onSurface: theme.colorScheme.onSurface,
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (dateRange != null) {
              widget.onDateFilterChanged(
                DateFilter.custom(
                  startDate: dateRange.start,
                  endDate: dateRange.end,
                ),
              );
            }
          } else {
            // Appliquer le filtre prédéfini
            switch (value) {
              case DateFilterType.all:
                widget.onDateFilterChanged(DateFilter.all());
                break;
              case DateFilterType.today:
                widget.onDateFilterChanged(DateFilter.today());
                break;
              case DateFilterType.thisWeek:
                widget.onDateFilterChanged(DateFilter.thisWeek());
                break;
              case DateFilterType.thisMonth:
                widget.onDateFilterChanged(DateFilter.thisMonth());
                break;
              default:
                break;
            }
          }
        },
        selectedItemBuilder: (context) {
          return [
            DateFilterType.all,
            DateFilterType.today,
            DateFilterType.thisWeek,
            DateFilterType.thisMonth,
            DateFilterType.custom,
          ].map((type) {
            if (type == widget.dateFilter.type) {
              return Center(
                child: Text(
                  widget.dateFilter.label,
                  style: const TextStyle(overflow: TextOverflow.ellipsis),
                ),
              );
            }
            return Center(
              child: Text(
                DateFilter(type: type).label,
                style: const TextStyle(overflow: TextOverflow.ellipsis),
              ),
            );
          }).toList();
        },
      ),
    );
  }

  Widget _buildResetButton(ThemeData theme) {
    return InkWell(
      onTap: () {
        widget.onStatusFilterChanged(null);
        widget.onDateFilterChanged(DateFilter.all());
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.refresh,
              size: 16,
              color: theme.colorScheme.error,
            ),
            const SizedBox(width: 4),
            Text(
              'Réinitialiser',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
