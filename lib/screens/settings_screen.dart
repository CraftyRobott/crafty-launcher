import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:saf/saf.dart';

import '../services/library_service.dart';
import '../widgets/menu_list.dart';
import 'retroarch_cores_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? romFolder;
  String? retroArchPath;

  @override
  void initState() {
    super.initState();

    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final folder = await LibraryService.getRomFolder();
    final retroArch = await LibraryService.getRetroArchPath();

    if (!mounted) return;

    setState(() {
      romFolder = folder;
      retroArchPath = retroArch;
    });
  }

  Future<void> _chooseRetroArch() async {
    final result = await FilePicker.pickFile(
      dialogTitle: 'Select RetroArch executable',
      type: FileType.any,
    );
    final selected = result?.path;
    if (selected == null) return;

    await LibraryService.setRetroArchPath(selected);
    if (!mounted) return;
    setState(() => retroArchPath = selected);
  }

  Future<void> _clearRetroArch() async {
    await LibraryService.clearRetroArchPath();
    if (!mounted) return;
    setState(() => retroArchPath = null);
  }

  Future<void> _chooseRomFolder() async {
    String? selectedFolder;
    String? displayFolder;

    if (Platform.isAndroid) {
      final saf = Saf();

      final selected = await saf.pickDirectory(
        writePermission: false,
        persistablePermission: true,
      );

      if (selected == null) {
        return;
      }

      selectedFolder = selected.uri;
      displayFolder = selected.name;
    } else {
      selectedFolder = await FilePicker.getDirectoryPath(
        dialogTitle: 'Select ROM Folder',
      );

      if (selectedFolder == null) {
        return;
      }

      displayFolder = selectedFolder;
    }

    await LibraryService.setRomFolder(
      selectedFolder,
    );

    if (!mounted) return;

    setState(() {
      romFolder = displayFolder;
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

  void _openRetroArchCores() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const RetroArchCoresScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAndroid =
        Platform.isAndroid;

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
                  'RETROARCH EXECUTABLE',
                  'RETROARCH CORES',
                  'RESCAN LIBRARY',
                  'CLEAR ROM FOLDER',
                  'CLEAR RETROARCH PATH',
                ],
                onBack: _goBack,
                onSelected: (index) async {
                  switch (index) {
                    case 0:
                      await _chooseRomFolder();
                      break;

                    case 1:
                      await _chooseRetroArch();
                      break;

                    case 2:
                      _openRetroArchCores();
                      break;

                    case 3:
                      await _loadSettings();
                      break;

                    case 4:
                      await _clearRomFolder();
                      break;

                    case 5:
                      await _clearRetroArch();
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 28),
              Text(
                retroArchPath == null
                    ? 'RETROARCH: NOT SET'
                    : 'RETROARCH EXECUTABLE:',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              if (retroArchPath != null) ...[
                const SizedBox(height: 8),
                Text(
                  retroArchPath!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              if (isAndroid) ...[
                const SizedBox(height: 8),

                const Text(
                  'ANDROID STORAGE ACCESS',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
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
