import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/library_service.dart';
import '../widgets/menu_list.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? romFolder;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final folder = await LibraryService.getRomFolder();

    if (!mounted) return;

    setState(() {
      romFolder = folder;
    });
  }

  Future<void> _chooseRomFolder() async {
    final selectedFolder = await FilePicker.getDirectoryPath(
      dialogTitle: 'Select ROM Folder',
    );

    if (selectedFolder == null) {
      return;
    }

    await LibraryService.setRomFolder(selectedFolder);

    if (!mounted) return;

    setState(() {
      romFolder = selectedFolder;
    });
  }

  Future<void> _clearRomFolder() async {
    await LibraryService.clearRomFolder();

    if (!mounted) return;

    setState(() {
      romFolder = null;
    });
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
                'SETTINGS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),

              const SizedBox(height: 40),

              MenuList(
                items: const [
                  'ROM FOLDER',
                  'RESCAN LIBRARY',
                  'CLEAR ROM FOLDER',
                ],
                onBack: _goBack,
                onSelected: (index) async {
                  switch (index) {
                    case 0:
                      await _chooseRomFolder();
                      break;

                    case 1:
                      await _loadSettings();
                      break;

                    case 2:
                      await _clearRomFolder();
                      break;
                  }
                },
              ),

              const SizedBox(height: 40),

              Text(
                romFolder == null
                    ? 'ROM FOLDER: NOT SET'
                    : 'ROM FOLDER:',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),

              if (romFolder != null) ...[
                const SizedBox(height: 8),

                Text(
                  romFolder!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}