import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:saf/saf.dart';

class RomFile {
  final String name;
  final String path;

  const RomFile({
    required this.name,
    required this.path,
  });
}

class RomSystem {
  final String name;
  final String folderName;
  final List<RomFile> roms;

  RomSystem({
    required this.name,
    required this.folderName,
    required this.roms,
  });
}

class RomScanner {
  static final Map<String, Map<String, dynamic>> systems = {
    'nes': {
      'name': 'NES',
      'extensions': ['nes', 'fds', 'unf'],
    },
    'famicom': {
      'name': 'NES',
      'extensions': ['nes', 'fds', 'unf'],
    },
    'snes': {
      'name': 'SNES',
      'extensions': ['sfc', 'smc', 'fig'],
    },
    'supernintendo': {
      'name': 'SNES',
      'extensions': ['sfc', 'smc', 'fig'],
    },
    'gb': {
      'name': 'GAME BOY',
      'extensions': ['gb'],
    },
    'gameboy': {
      'name': 'GAME BOY',
      'extensions': ['gb'],
    },
    'gbc': {
      'name': 'GAME BOY COLOR',
      'extensions': ['gbc'],
    },
    'gameboycolor': {
      'name': 'GAME BOY COLOR',
      'extensions': ['gbc'],
    },
    'gba': {
      'name': 'GAME BOY ADVANCE',
      'extensions': ['gba'],
    },
    'gameboyadvance': {
      'name': 'GAME BOY ADVANCE',
      'extensions': ['gba'],
    },
    'n64': {
      'name': 'N64',
      'extensions': ['n64', 'z64', 'v64'],
    },
    'nds': {
      'name': 'NINTENDO DS',
      'extensions': ['nds'],
    },
    '3ds': {
      'name': '3DS',
      'extensions': ['3ds', 'cia'],
    },
    'ps1': {
      'name': 'PLAYSTATION',
      'extensions': ['iso', 'bin', 'cue', 'chd', 'pbp'],
    },
    'psx': {
      'name': 'PLAYSTATION',
      'extensions': ['iso', 'bin', 'cue', 'chd', 'pbp'],
    },
    'playstation': {
      'name': 'PLAYSTATION',
      'extensions': ['iso', 'bin', 'cue', 'chd', 'pbp'],
    },
    'psp': {
      'name': 'PSP',
      'extensions': ['iso', 'cso', 'pbp'],
    },
    'genesis': {
      'name': 'GENESIS',
      'extensions': ['md', 'gen', 'bin'],
    },
    'megadrive': {
      'name': 'GENESIS',
      'extensions': ['md', 'gen', 'bin'],
    },
    'dreamcast': {
      'name': 'DREAMCAST',
      'extensions': ['gdi', 'cdi', 'chd'],
    },
  };

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('_', '')
        .replaceAll('-', '');
  }

  static bool _matchesExtension(
    String fileName,
    List<String> extensions,
  ) {
    final dot = fileName.lastIndexOf('.');

    if (dot <= 0 || dot == fileName.length - 1) {
      return false;
    }

    final extension = fileName
        .substring(dot + 1)
        .toLowerCase();

    return extensions.contains(extension);
  }

  static Future<List<RomSystem>> scan(String rootPath) async {
    if (Platform.isAndroid) {
      return _scanAndroid(rootPath);
    }

    return _scanDesktop(rootPath);
  }

  static Future<List<RomSystem>> _scanDesktop(
    String rootPath,
  ) async {
    final root = Directory(rootPath);

    if (!await root.exists()) {
      return [];
    }

    final results = <RomSystem>[];

    try {
      await for (final entity in root.list(
        followLinks: false,
      )) {
        if (entity is! Directory) {
          continue;
        }

        final folderName = entity.path
            .split(Platform.pathSeparator)
            .last;

        final normalizedName = _normalize(folderName);

        final systemInfo = systems[normalizedName];

        if (systemInfo == null) {
          continue;
        }

        final extensions =
            (systemInfo['extensions'] as List<dynamic>)
                .cast<String>();

        final roms = <RomFile>[];

        await for (final fileEntity in entity.list(
          recursive: true,
          followLinks: false,
        )) {
          if (fileEntity is! File) {
            continue;
          }

          final fileName = fileEntity.path
              .split(Platform.pathSeparator)
              .last;

          if (!_matchesExtension(
            fileName,
            extensions,
          )) {
            continue;
          }

          roms.add(
            RomFile(
              name: fileName,
              path: fileEntity.path,
            ),
          );
        }

        roms.sort(
          (a, b) => a.path.toLowerCase().compareTo(
                b.path.toLowerCase(),
              ),
        );

        if (roms.isNotEmpty) {
          results.add(
            RomSystem(
              name: systemInfo['name'] as String,
              folderName: folderName,
              roms: roms,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Desktop ROM scan error: $e');
      return [];
    }

    results.sort(
      (a, b) => a.name.compareTo(b.name),
    );

    return results;
  }

  static Future<List<RomSystem>> _scanAndroid(
    String rootUri,
  ) async {
    final saf = Saf();

    final results = <RomSystem>[];

    try {
      debugPrint('ANDROID SAF ROOT: $rootUri');

      await for (final entry in saf.walk(rootUri)) {
        final file = entry.file;

        if (file.isDir) {
          continue;
        }

        final parts = entry.relativePath.split('/');

        if (parts.isEmpty) {
          continue;
        }

        final fileName = file.name;

        if (parts.length < 2) {
          continue;
        }

        // The first directory underneath the selected ROM folder
        // determines the system.
        final folderName = parts.first;
        final normalizedName = _normalize(folderName);

        final systemInfo = systems[normalizedName];

        if (systemInfo == null) {
          continue;
        }

        final extensions =
            (systemInfo['extensions'] as List<dynamic>)
                .cast<String>();

        if (!_matchesExtension(
          fileName,
          extensions,
        )) {
          continue;
        }

        RomSystem? existingSystem;

        for (final system in results) {
          if (system.folderName == folderName) {
            existingSystem = system;
            break;
          }
        }

        final rom = RomFile(
          name: fileName,
          path: file.uri,
        );

        if (existingSystem == null) {
          results.add(
            RomSystem(
              name: systemInfo['name'] as String,
              folderName: folderName,
              roms: [rom],
            ),
          );
        } else {
          existingSystem.roms.add(rom);
        }
      }

      for (final system in results) {
        system.roms.sort(
          (a, b) => a.name.toLowerCase().compareTo(
                b.name.toLowerCase(),
              ),
        );
      }

      results.sort(
        (a, b) => a.name.compareTo(b.name),
      );

      debugPrint(
        'ANDROID SAF SYSTEMS FOUND: ${results.length}',
      );

      for (final system in results) {
        debugPrint(
          'SYSTEM: ${system.name} | ROMS: ${system.roms.length}',
        );

        for (final rom in system.roms) {
          debugPrint(
            '  ROM: ${rom.name} | ${rom.path}',
          );
        }
      }

      return results;
    } catch (e) {
      debugPrint('Android SAF scan error: $e');
      return [];
    }
  }
}