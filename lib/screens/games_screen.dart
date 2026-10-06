import 'package:flutter/material.dart';

import '../services/library_service.dart';
import '../services/rom_scanner.dart';
import '../widgets/menu_list.dart';
import 'roms_screen.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  List<RomSystem> systems = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();

    _scan();
  }

  Future<void> _scan() async {
    setState(() {
      loading = true;
    });

    final folder = await LibraryService.getRomFolder();

    if (folder == null) {
      if (!mounted) return;

      setState(() {
        systems = [];
        loading = false;
      });

      return;
    }

    final scannedSystems = await RomScanner.scan(folder);

    if (!mounted) return;

    setState(() {
      systems = scannedSystems;
      loading = false;
    });
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
              'SCANNING...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ),
      );
    }

    final hasSystems = systems.isNotEmpty;

    final items = hasSystems
        ? systems.map((system) => system.name).toList()
        : [
            'NO ROMS FOUND',
            'BACK',
          ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 60,
            top: 60,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'GAMES',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 40),

              if (!hasSystems)
                const Text(
                  'SET A ROM FOLDER IN SETTINGS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),

              if (!hasSystems)
                const SizedBox(height: 20),

              MenuList(
                items: items,
                onBack: _goBack,
                onSelected: (index) {
                  if (!hasSystems) {
                    // "NO ROMS FOUND" does nothing.
                    if (index == 1) {
                      _goBack();
                    }

                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RomsScreen(
                        system: systems[index],
                      ),
                    ),
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