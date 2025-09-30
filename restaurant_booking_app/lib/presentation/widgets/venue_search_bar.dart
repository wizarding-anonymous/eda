import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/venue_search_provider.dart';

class VenueSearchBar extends ConsumerStatefulWidget {
  const VenueSearchBar({super.key});

  @override
  ConsumerState<VenueSearchBar> createState() => _VenueSearchBarState();
}

class _VenueSearchBarState extends ConsumerState<VenueSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Поиск ресторанов, кафе...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _controller.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        onChanged: (value) {
          setState(() {}); // Rebuild to show/hide clear button
        },
        onSubmitted: (value) {
          ref.read(searchQueryProvider.notifier).state = value;
        },
        textInputAction: TextInputAction.search,
      ),
    );
  }
}
