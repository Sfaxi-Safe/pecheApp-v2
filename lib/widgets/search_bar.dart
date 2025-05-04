import 'dart:async';
import 'package:flutter/material.dart';

/// Widget de barre de recherche améliorée
class SearchBarWidget extends StatefulWidget {
  /// Callback appelé lorsque la recherche est soumise
  final Function(String) onSearch;
  
  /// Callback appelé lorsque le texte de recherche change
  final Function(String)? onChanged;
  
  /// Texte initial de la recherche
  final String initialQuery;
  
  /// Texte d'aide
  final String hintText;
  
  /// Délai avant de déclencher la recherche automatique
  final Duration debounceTime;
  
  /// Indique si la recherche doit être déclenchée automatiquement
  final bool autoSearch;
  
  /// Indique si la barre de recherche doit être compacte
  final bool isCompact;
  
  /// Indique si la barre de recherche doit avoir un bouton de réinitialisation
  final bool showClearButton;

  const SearchBarWidget({
    Key? key,
    required this.onSearch,
    this.onChanged,
    this.initialQuery = '',
    this.hintText = 'Rechercher...',
    this.debounceTime = const Duration(milliseconds: 500),
    this.autoSearch = true,
    this.isCompact = false,
    this.showClearButton = true,
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  Timer? _debounce;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _showClearButton = widget.initialQuery.isNotEmpty;
    
    // Déclencher la recherche initiale si nécessaire
    if (widget.initialQuery.isNotEmpty && widget.autoSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSearch(widget.initialQuery);
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    setState(() {
      _showClearButton = value.isNotEmpty;
    });
    
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
    
    if (widget.autoSearch) {
      if (_debounce?.isActive ?? false) {
        _debounce!.cancel();
      }
      
      _debounce = Timer(widget.debounceTime, () {
        widget.onSearch(value);
      });
    }
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _showClearButton = false;
    });
    
    if (widget.onChanged != null) {
      widget.onChanged!('');
    }
    
    if (widget.autoSearch) {
      widget.onSearch('');
    }
  }

  void _submitSearch() {
    widget.onSearch(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(widget.isCompact ? 4.0 : 8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: EdgeInsets.all(widget.isCompact ? 4.0 : 8.0),
      padding: EdgeInsets.symmetric(
        horizontal: widget.isCompact ? 8.0 : 12.0,
        vertical: widget.isCompact ? 4.0 : 8.0,
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Theme.of(context).primaryColor,
            size: widget.isCompact ? 20.0 : 24.0,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
                isDense: widget.isCompact,
                contentPadding: EdgeInsets.symmetric(
                  vertical: widget.isCompact ? 8.0 : 12.0,
                ),
              ),
              onChanged: _onTextChanged,
              onSubmitted: (_) => _submitSearch(),
              textInputAction: TextInputAction.search,
            ),
          ),
          if (_showClearButton && widget.showClearButton)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSearch,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: widget.isCompact ? 32.0 : 40.0,
                minHeight: widget.isCompact ? 32.0 : 40.0,
              ),
              iconSize: widget.isCompact ? 18.0 : 20.0,
            ),
          if (!widget.autoSearch)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _submitSearch,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: widget.isCompact ? 32.0 : 40.0,
                minHeight: widget.isCompact ? 32.0 : 40.0,
              ),
              iconSize: widget.isCompact ? 18.0 : 20.0,
            ),
        ],
      ),
    );
  }
}
