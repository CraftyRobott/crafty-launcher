import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/library_service.dart';
import '../services/rom_scanner.dart';
import '../widgets/menu_list.dart';

class RetroArchCoresScreen extends StatefulWidget {
  const RetroArchCoresScreen({super.key});

  @override
  State<RetroArchCoresScreen> createState() =>
      _RetroArchCoresScreenState();
}

class _RetroArchCoresScreenState extends State<RetroArchCoresScreen> {
  List<RomSystem> systems = [];
  Map<String, String> cores = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadSystems();
  }

  Future<void> _loadSystems() async {
    final folder = await LibraryService.getRomFolder();
    final scanned = folder == null ? <RomSystem>[] : await RomScanner.scan(folder);
    final selectedCores = <String, String>{};
    for (final system in scanned) {
      final core = await LibraryService.getRetroArchCore(system.folderName);
      if (core != null) selectedCores[system.folderName] = core;
    }

    if (!mounted) return;
    setState(() {
      systems = scanned;
      cores = selectedCores;
      loading = false;
    });
  }

  Future<void> _selectCore(int index) async {
    final system = systems[index];
    final result = await FilePicker.pickFile(
      dialogTitle: 'Select RetroArch core for ${system.name}',
      type: FileType.any,
    );
    final path = result?.path;
    if (path == null) return;

    await LibraryService.setRetroArchCore(system.folderName, path);
    if (!mounted) return;
    setState(() => cores[system.folderName] = path);
  }

  @override
  Widget build(BuildContext context) {
    final items = systems.map((system) {
      final corePath = cores[system.folderName];
      final coreName = corePath == null
          ? 'SELECT CORE'
          : corePath.split(RegExp(r'[/\\]')).last;
      return '${system.name} — $coreName';
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 60, top: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'RETROARCH CORES',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 40),
              if (loading)
                const Text(
                  'SCANNING ROMS...',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                )
              else if (systems.isEmpty)
                const Text(
                  'NO SYSTEMS FOUND. SET A ROM FOLDER IN SETTINGS.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                )
              else
                MenuList(
                  items: items,
                  onBack: () => Navigator.of(context).pop(),
                  onSelected: _selectCore,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
