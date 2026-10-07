import 'package:flutter/material.dart';

import '../services/library_service.dart';
import '../services/rom_scanner.dart';
import '../widgets/menu_list.dart';

class RomsScreen extends StatefulWidget {
  final RomSystem system;

  const RomsScreen({
    super.key,
    required this.system,
  });

  @override
  State<RomsScreen> createState() => _RomsScreenState();
}

class _RomsScreenState extends State<RomsScreen> {
  List<RomFile> roms = [];
  Set<String> favorites = {};

  @override
  void initState() {
    super.initState();

    _loadRoms();
  }

  Future<void> _loadRoms() async {
    final savedFavorites =
        await LibraryService.getFavorites();

    final sortedRoms =
        List<RomFile>.from(widget.system.roms);

    sortedRoms.sort((a, b) {
      final aFavorite =
          savedFavorites.contains(a.path);

      final bFavorite =
          savedFavorites.contains(b.path);

      if (aFavorite && !bFavorite) {
        return -1;
      }

      if (!aFavorite && bFavorite) {
        return 1;
      }

      return a.name
          .toLowerCase()
          .compareTo(b.name.toLowerCase());
    });

    if (!mounted) return;

    setState(() {
      roms = sortedRoms;
      favorites = savedFavorites.toSet();
    });
  }

  Future<void> _toggleFavorite(int index) async {
    if (index < 0 || index >= roms.length) {
      return;
    }

    final rom = roms[index];

    await LibraryService.toggleFavorite(
      rom.path,
    );

    await _loadRoms();
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final items = roms.map((rom) {
      final isFavorite =
          favorites.contains(rom.path);

      return isFavorite
          ? '* ${rom.name}'
          : rom.name;
    }).toList();

    if (roms.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 60,
              top: 60,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.system.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),

                const SizedBox(height: 40),

                MenuList(
                  items: const [
                    'NO ROMS FOUND',
                    'BACK',
                  ],
                  onBack: _goBack,
                  onSelected: (index) {
                    if (index == 1) {
                      _goBack();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 60,
            top: 60,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                widget.system.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),

              const SizedBox(height: 40),

              MenuList(
                items: items,
                onBack: _goBack,
                onFavorite: _toggleFavorite,
                onSelected: (index) {
                  debugPrint(
                    'Launching ROM: '
                    '${roms[index].path}',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}