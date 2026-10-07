import 'package:flutter/material.dart';

import '../services/library_service.dart';
import '../services/rom_scanner.dart';
import '../widgets/menu_list.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() =>
      _FavoritesScreenState();
}

class _FavoriteRom {
  final RomFile file;
  final String systemName;

  const _FavoriteRom({
    required this.file,
    required this.systemName,
  });
}

class _FavoritesScreenState
    extends State<FavoritesScreen> {
  List<_FavoriteRom> favorites = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();

    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      loading = true;
    });

    final folder =
        await LibraryService.getRomFolder();

    if (folder == null) {
      if (!mounted) return;

      setState(() {
        favorites = [];
        loading = false;
      });

      return;
    }

    final systems =
        await RomScanner.scan(folder);

    final favoritePaths =
        await LibraryService.getFavorites();

    final favoriteSet =
        favoritePaths.toSet();

    final result = <_FavoriteRom>[];

    for (final system in systems) {
      for (final rom in system.roms) {
        if (favoriteSet.contains(rom.path)) {
          result.add(
            _FavoriteRom(
              file: rom,
              systemName: system.name,
            ),
          );
        }
      }
    }

    result.sort((a, b) {
      return a.file.name
          .toLowerCase()
          .compareTo(
            b.file.name.toLowerCase(),
          );
    });

    if (!mounted) return;

    setState(() {
      favorites = result;
      loading = false;
    });
  }

  Future<void> _toggleFavorite(int index) async {
    if (index < 0 ||
        index >= favorites.length) {
      return;
    }

    final rom =
        favorites[index].file;

    await LibraryService.removeFavorite(
      rom.path,
    );

    await _loadFavorites();
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 60,
              top: 60,
            ),
            child: const Text(
              'LOADING FAVORITES...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ),
      );
    }

    final items = favorites.isEmpty
        ? const [
            'NO FAVORITES',
            'BACK',
          ]
        : favorites.map((favorite) {
            return '* ${favorite.file.name}';
          }).toList();

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
              const Text(
                'FAVORITES',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),

              const SizedBox(height: 40),

              MenuList(
                items: items,
                onBack: _goBack,
                onFavorite: favorites.isEmpty
                    ? null
                    : _toggleFavorite,
                onSelected: (index) {
                  if (favorites.isEmpty) {
                    if (index == 1) {
                      _goBack();
                    }

                    return;
                  }

                  debugPrint(
                    'Launching favorite: '
                    '${favorites[index].file.path}',
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